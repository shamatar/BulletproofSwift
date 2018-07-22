//
//  MultiRangeProofVerifier.swift
//  EllipticSwift
//
//  Created by Alexander Vlasov on 22.07.2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import Foundation

internal struct MultiRangeProofVerifier {
    
    static func verify(vectorBase: VectorBase, base: PeddersenBase, inputs: [AffinePoint], proof: RangeProof) -> Bool {
        let n = vectorBase.gs.size
        let a = proof.aI
        let s = proof.s
        let m = inputs.count
        let (bitsPerNumber, remainder) = n.quotientAndRemainder(dividingBy: m)
        precondition(remainder == 0)
        
        let curveOrderField = inputs[0].curve.curveOrderField
        let ZERO = BigNumber(0)
        let TWO = BigNumber(2)
        
        let challengeArr = inputs + [a, s]
        
        let y = ProofUtils.computeChallenge(points: challengeArr, field: curveOrderField)
        let ys = FieldVector.powers(k: y.value, n: n, field: curveOrderField)
        
        let z = ProofUtils.computeChallengeForBigIntegers(ints: [y.value], field: curveOrderField)
        let zs = FieldVector.powers(k: z.value, n: m+2, field: curveOrderField).subvector(2, m+2)
        precondition(zs.vector.count == m)
        
        let twos = FieldVector.powers(k: TWO, n: bitsPerNumber, field: curveOrderField)
        
        let elementsMapped = zs.a.map { (fe) -> FieldVector in
            return twos.times(fe)
        }
        
        let elements = elementsMapped.reduce([GeneralPrimeFieldElement]()) { (concated: [GeneralPrimeFieldElement], fv: FieldVector) -> [GeneralPrimeFieldElement] in
            return concated + fv.a
        }
        
        precondition(elements.count == n)
        let twoTimesZs = FieldVector(elements, curveOrderField)
        
        let zSum = zs.sum() * z
        let zSumMulPowerOf2 = zSum * (curveOrderField.pow(curveOrderField.fromValue(TWO), BigNumber(integerLiteral: UInt64(bitsPerNumber))))
        
        let k = ys.sum() * (z - zs.get(0)) - (zSumMulPowerOf2 - zSum)
        
        let tCommits = proof.tCommits
        
        let x = ProofUtils.computeChallenge(points: tCommits.vector, field: curveOrderField)
        
        let tauX = proof.tauX
        let mu = proof.mu
        let t = proof.t
        let lhs = base.commit(t, tauX)
        var rhs = tCommits.commit([x, x * x]).toProjective()
        rhs = rhs + GeneratorVector(inputs).commit(zs.vector)
        rhs = rhs + base.commit(k.value, ZERO)
        
        if (lhs != rhs.toAffine()) {
            return false
        }
        
        let uChallenge = ProofUtils.computeChallengeForBigIntegers(ints: [tauX, mu, t])

        let u = uChallenge * base.g
        let hs = vectorBase.hs
        let gs = vectorBase.gs
        
        let hPrimes = hs.hadamardProduct(ys.inv().vector)
        let hExp = ys.times(z).add(twoTimesZs)
        
        let P = a.toProjective() + (x.value * s) - (z.value * gs.sum()) + (hPrimes.commit(hExp.vector)) - (mu * base.h) + (t * u)
        
        let primeBase = VectorBase(gs: gs, hs: hPrimes, h: u.toAffine())
        return EfficientInnerProductVerifier.verify(params: primeBase, c: P.toAffine(), proof: proof.productProof)
        
    }
    
}
