//
//  RangeProver.swift
//  EllipticSwift
//
//  Created by Alexander Vlasov on 11.07.2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import Foundation
import BigInt

public struct RangeProofProver {
    
    public static func generateProof(parameter: GeneratorParams, commitment: AffinePoint, witness: PeddersenCommitment) -> RangeProof {
        let q = parameter.curve.order
        let curve = parameter.curve
        let number = witness.x
        let vectorBase = parameter.vectorBase
        let base = parameter.base
        let n = vectorBase.gs.size
        let ZERO = BigUInt(0)
        let ONE = BigUInt(1)
        let TWO = BigUInt(2)
        let THREE = BigUInt(3)
        var aLelements = [BigUInt]()
        for i in 0 ..< n {
            if number.bit(i) {
                aLelements.append(ONE)
            } else {
                aLelements.append(ZERO)
            }
        }

        let aL = FieldVector(aLelements, q)
        let aR = aL.sub(FieldVector.fill(k: ONE, n: n, q: q))
        let alpha = ProofUtils.randomNumber(bitWidth: q.bitWidth)
        let a = vectorBase.commitToTwoVectors(gExp: aL.vector, hExp: aR.vector, blinding: alpha)
        let sL = FieldVector.random(n: n, q: q)
        let sR = FieldVector.random(n: n, q: q)
        let rho = ProofUtils.randomNumber(bitWidth: q.bitWidth)
        let s = vectorBase.commitToTwoVectors(gExp: sL.vector, hExp: sR.vector, blinding: rho)
        
        let y = ProofUtils.computeChallenge(q: q, points: [commitment, a, s])
        let ys = FieldVector.powers(k: y, n: n, q: q)
        
        let z = ProofUtils.computeChallengeForBigIntegers(q: q, ints: [y])
        let zSquared = z.power(TWO, modulus: q)
        let zCubed = z.power(THREE, modulus: q)
        
        let twos = FieldVector.powers(k: TWO, n: n, q: q)
        let zNegated = q - z
        let l0 = aL.add(zNegated)
        
        let l1 = sL
        let twoTimesZSquared = twos.times(zSquared)
        let r0 = ys.hadamardProduct(aR.add(z)).add(twoTimesZSquared)
        let r1 = sR.hadamardProduct(ys)
        let k = (ys.sum() * (z - zSquared)) - ((zCubed << n) - zCubed)
        let t0 = k + (zSquared * number)
        var t1: BigUInt = l1.innerPoduct(r0)
        t1 = t1 + l0.innerPoduct(r1)
        let t2: BigUInt = l1.innerPoduct(r1)
        let polyCommitment = PolyCommitment.from(base: base, x0: t0, xs: [t1, t2])
        
        let x = ProofUtils.computeChallenge(q: q, points: polyCommitment.getNonzeroCommitments())
        
        let evalCommit = polyCommitment.evaluate(x)
        let tauX = ((zSquared * witness.r) + evalCommit.r) % q
        let t = evalCommit.x % q
        let mu = (alpha + (rho * x)) % q
        
        let uChallenge = ProofUtils.computeChallengeForBigIntegers(q: q, ints: [tauX, mu, t]);
        let u = uChallenge * base.g
        let hs = vectorBase.hs
        let gs = vectorBase.gs
        let hPrimes = hs.hadamardProduct(ys.inv().vector)
        let l = l0.add(l1.times(x))
        let r = r0.add(r1.times(x))
        let hExp = ys.times(z).add(twoTimesZSquared)
        var P = (x * s)
        P = P + a
        P = P - z * gs.sum()
        P = P + hPrimes.commit(hExp.vector)
        P = P + (t * u).toAffine()
        P = P - (mu * base.h)
//        let P = a.add(s.mul(x)).add(gs.sum().mul(z.neg())).add(hPrimes.commit(hExp.getVector())).add(u.mul(t)).sub(base.h.mul(mu));
        let primeBase = VectorBase(gs: gs, hs: hPrimes, h: u.toAffine())
        let innerProductWitness = InnerProductWitness(l, r)
        let proof = InnerProductProver.generateProofFromWitness(base: primeBase, c: P.toAffine(), witness: innerProductWitness)
        let tComm = GeneratorVector(polyCommitment.getNonzeroCommitments(), curve)
        return RangeProof(aI: a, s: s, tCommits: tComm , tauX: tauX, mu: mu, t: t, productProof: proof)
    }
}
