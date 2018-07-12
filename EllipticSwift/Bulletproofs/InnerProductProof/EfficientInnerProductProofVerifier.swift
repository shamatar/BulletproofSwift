//
//  EfficientInnerProductProofVerifier.swift
//  EllipticSwift
//
//  Created by Alexander Vlasov on 12.07.2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import Foundation
import BigInt

public struct EfficientInnerProductVerifier {

    public static func verify(params: VectorBase, c: AffinePoint, proof: InnerProductProof) -> Bool {
    let ls = proof.L
    let rs = proof.R

    var challenges = [BigUInt]()
    var inverseChallenges = [BigUInt]()
    let q = params.gs.curve.order
        
    var localC : ProjectivePoint = ProjectivePoint.infinityPoint(params.gs.curve)
    for i in 0 ..< ls.count {
        let l = ls[i]
        let r = rs[i]
        let x = ProofUtils.computeChallenge(q: q, points: [l, c, r])
        challenges.append(x)
        let xInv = x.inverse(q)
        precondition(xInv != nil)
        inverseChallenges.append(xInv!)
        localC = (x.power(2, modulus: q) * l) + (xInv!.power(2, modulus: q) * r) + localC
    }
    let n = params.gs.size
    var otherExponents = [BigUInt](repeating: BigUInt(0), count: n)
    otherExponents[0] = challenges.reduce(1, { (prev, current) -> BigUInt in
        (prev * current) % q
    }) % q
    challenges = challenges.reversed()
    var bitSet = BigUInt(0)
    let ONE = BigUInt(1)
    let bigN = BigUInt(n)
    for i in 0 ..< n/2 {
        let bigI = BigUInt(i)
        var j = 0
        while true {
            let shifted = ONE << j
            if bigI + shifted >= bigN {
                break
            }
            let i1 = i + Int(shifted)
            if bitSet.bit(i1) {
                // already set
            } else {
                otherExponents[i1] = (otherExponents[i] * (challenges[j].power(2, modulus: q))) % q
                bitSet |= ONE << i1 // TODO
            }
            j = j + 1
        }
    }
    let g = params.gs.commit(otherExponents)
    let h = params.hs.commit(otherExponents.reversed())
    let prod = (proof.a * proof.b) % q
    let cProof = (proof.a * g) + (proof.b * h) + (prod * params.h)
    return c.isEqualTo(cProof.toAffine())
    }
}
