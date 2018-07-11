//
//  InnerProductProver.swift
//  EllipticSwift
//
//  Created by Alexander Vlasov on 11.07.2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import Foundation
import BigInt

public struct InnerProductProver {

    public static func generateProofFromWitness(base: VectorBase, c: AffinePoint, witness: InnerProductWitness) -> InnerProductProof {
        let n = base.gs.size
            if (!((n & (n - 1)) == 0)) {
                precondition(false, "Vector base length is not a power of 2")
            }
        let emptyLs = [AffinePoint]()
        let emptyRs = [AffinePoint]()
        return generateProof(base: base, P: c, As: witness.a, Bs: witness.b, Ls: emptyLs, Rs: emptyRs)
    }
    
    public static func generateProof(base: VectorBase, P: AffinePoint, As: FieldVector , Bs: FieldVector , Ls: [AffinePoint], Rs: [AffinePoint]) -> InnerProductProof {
        let n = As.size
        if (n == 1) {
            return InnerProductProof(L: Rs, R: Rs, a: As.get(0), b: Bs.get(0))
        }
        let nPrime = n >> 1
        let asLeft = As.subvector(0, nPrime)
        let asRight = As.subvector(nPrime, nPrime * 2)
        let bsLeft = Bs.subvector(0, nPrime)
        let bsRight = Bs.subvector(nPrime, nPrime * 2)
        
        let gs = base.gs
        let gLeft = gs.subvector(0, nPrime)
        let gRight = gs.subvector(nPrime, nPrime * 2)
        
        let hs = base.hs
        let hLeft = hs.subvector(0, nPrime)
        let hRight = hs.subvector(nPrime, nPrime * 2)
        
        let cL = asLeft.innerPoduct(bsRight)
        let cR = asRight.innerPoduct(bsLeft)
        var L = gRight.commit(asLeft.vector) + hLeft.commit(bsRight.vector)
        var R = gLeft.commit(asRight.vector) + hRight.commit(bsLeft.vector)
        
        var ls = Ls
        var rs = Rs
        
        let u = base.h
        L = L + cL * u
        ls.append(L.toAffine())
        R = R + cR * u
        rs.append(R.toAffine())
        
        let lAffine = L.toAffine()
        let rAffine = R.toAffine()
        
        let q = gs.curve.order
        let x = ProofUtils.computeChallenge(q: q, points: [lAffine, P, rAffine])
        let xInv = x.inverse(q)
        precondition(xInv != nil)
        let xSquare = x.power(2, modulus: q)
        let xInvSquare = xInv!.power(2, modulus: q)
        let xs = [BigUInt](repeating: x, count: nPrime)
        let xInverses = [BigUInt](repeating: xInv!, count: nPrime)
        
        let gPrime = gLeft.hadamardProduct(xInverses).add(gRight.hadamardProduct(xs))
        let hPrime = hLeft.hadamardProduct(xs).add(hRight.hadamardProduct(xInverses))
        let aPrime = asLeft.times(x).add(asRight.times(xInv!))
        let bPrime = bsLeft.times(xInv!).add(bsRight.times(x))
        // console.log(aPrime.getVector()[0].toString(16))
        
        let PPrime = xSquare * lAffine + xInvSquare * rAffine + P
        let basePrime = VectorBase(gs: gPrime, hs: hPrime, h: u)
        
        return generateProof(base: basePrime, P: PPrime.toAffine(), As: aPrime, Bs: bPrime, Ls: ls, Rs: rs)
    }
    
}
