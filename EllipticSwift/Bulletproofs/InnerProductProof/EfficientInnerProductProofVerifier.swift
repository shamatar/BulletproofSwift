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

    var challenges = [GeneralPrimeFieldElement]()
    var inverseChallenges = [GeneralPrimeFieldElement]()
    let q = params.gs.curve.order
    let curveOrderField = GeneralPrimeField(q)
    var localC : ProjectivePoint = c.toProjective()
    for i in 0 ..< ls.count {
        let l = ls[i]
        let r = rs[i]
        let xGenerated = ProofUtils.computeChallenge(points: [l, localC.toAffine(), r])
        let x = curveOrderField.fromValue(xGenerated)
        challenges.append(x)
        let xInv = x.inv()
        inverseChallenges.append(xInv)
        let xSquared = x * x
        let xInvSquared = xInv * xInv
        localC = (xSquared.value * l) + (xInvSquared.value * r) + localC
    }
    let n = params.gs.size
    let ZERO = curveOrderField.zeroElement
    var otherExponents = [GeneralPrimeFieldElement](repeating: ZERO, count: n)
    let firstExponent = challenges.reduce(curveOrderField.identityElement, { (prev, current) -> GeneralPrimeFieldElement in
        return prev * current
    }).inv()
    otherExponents[0] = firstExponent
    challenges = challenges.reversed()
    var bitSet: UInt64 = 0
    let ONE:UInt64 = 1
    let bigN = BigNumber(integerLiteral: UInt64(n))
    for i in 0 ..< UInt64(n/2) {
        let bigI = BigNumber(integerLiteral:UInt64(i))
        var j: Int = 0
        while true {
            let shifted = ONE << j
            if bigI + BigNumber(integerLiteral: shifted) >= bigN {
                break
            }
            let i1 = Int(i + shifted)
            if bitSet & (ONE << i1) != 0 {
                // already set
            } else {
                otherExponents[i1] = otherExponents[Int(i)] * (challenges[j] * challenges[j])
                bitSet |= ONE << i1 // TODO
            }
            j = j + 1
        }
    }
    let g = params.gs.commit(otherExponents.map({ (el) -> BigNumber in
        return el.value
    }))
    let h = params.hs.commit(otherExponents.reversed().map({ (el) -> BigNumber in
        return el.value
    }))
    let prod = proof.a.modMultiply(proof.b, q)
    let cProof = (proof.a * g) + (proof.b * h) + (prod * params.h)
    return localC.toAffine().isEqualTo(cProof.toAffine())
    }
}
