//
//  RangeProofVerifier.swift
//  EllipticSwift
//
//  Created by Alexander Vlasov on 21.07.2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import Foundation

internal struct RangeProofVerifier {
        
    static func verify(vectorBase: VectorBase, base: PeddersenBase, input: AffinePoint, proof: RangeProof) -> Bool {
        let n = vectorBase.gs.size
        let a = proof.aI
        let s = proof.s
        
        let curveOrderField = input.curve.curveOrderField
        let ZERO = BigNumber(0)
        let TWO = BigNumber(2)
    
        let yGenerated = ProofUtils.computeChallenge(points: [input, a, s], field: curveOrderField)

        let ys = FieldVector.powers(k: yGenerated.value, n: n, field: curveOrderField)
    
        let z = ProofUtils.computeChallengeForBigIntegers(ints: [yGenerated.value], field: curveOrderField)
        let zSquared = z * z
        let zCubed = zSquared * z
        
        let twos = FieldVector.powers(k: TWO, n: n, field: curveOrderField) // Powers of TWO
        let twoTimesZSquared = twos.times(zSquared)
        let tCommits = proof.tCommits
        
        let x = ProofUtils.computeChallenge(points: tCommits.vector, field: curveOrderField)
        
        let tauX = proof.tauX
        let mu = proof.mu
        let t = proof.t
        let lhs = base.commit(t, tauX)
        let zCubedMulPowerOf2 = zCubed * (curveOrderField.pow(curveOrderField.fromValue(TWO), BigNumber(integerLiteral: UInt64(n))))
        
        let k = ((z - zSquared) * ys.sum()) - (zCubedMulPowerOf2 - zCubed)
        var rhs = tCommits.commit([x, x * x]).toProjective()
        rhs = rhs + zSquared.value * input
        rhs = rhs + base.commit(k.value, ZERO)

        if (lhs != rhs.toAffine()) {
            return false
        }
        
        let uChallenge = ProofUtils.computeChallengeForBigIntegers(ints: [tauX, mu, t])

        let u = uChallenge * base.g
        let hs = vectorBase.hs
        let gs = vectorBase.gs
        
        let hPrimes = hs.hadamardProduct(ys.inv().vector)
        let hExp = ys.times(z).add(twoTimesZSquared)

        let P = a.toProjective() + (x.value * s) - (z.value * gs.sum()) + (hPrimes.commit(hExp.vector)) - (mu * base.h) + (t * u)
        
        let primeBase = VectorBase(gs: gs, hs: hPrimes, h: u.toAffine())
        return EfficientInnerProductVerifier.verify(params: primeBase, c: P.toAffine(), proof: proof.productProof)
    
    }

}
