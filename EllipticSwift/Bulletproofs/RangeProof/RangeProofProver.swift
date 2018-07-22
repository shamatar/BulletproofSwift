//
//  RangeProver.swift
//  EllipticSwift
//
//  Created by Alexander Vlasov on 11.07.2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import Foundation
import BigInt

internal struct RangeProofProver {
    
    static func generateProof(vectorBase: VectorBase, base: PeddersenBase, witness: PeddersenCommitment) -> RangeProof {
        let commitment = witness.commitment

        let curve = commitment.curve
        let q = curve.order
        let curveOrderField = curve.curveOrderField
        let number = witness.x
        let n = vectorBase.gs.size
        let ZERO = BigNumber(integerLiteral: 0)
        let ONE = BigNumber(integerLiteral: 1)
        let TWO = BigNumber(integerLiteral: 2)
        
        var aLelements = [BigNumber]()
        for i in 0 ..< n {
            if number.bit(i) {
                aLelements.append(ONE)
            } else {
                aLelements.append(ZERO)
            }
        }

        let aL = FieldVector(aLelements, curveOrderField)
        let aR = aL.sub(FieldVector.fill(k: ONE, n: n, field: curveOrderField))
        
        let alpha = ProofUtils.randomNumber(bitWidth: q.bitWidth)

        let a = vectorBase.commitToTwoVectors(gExp: aL.vector, hExp: aR.vector, blinding: alpha)

        let sL = FieldVector.random(n: n, field: curveOrderField)
        let sR = FieldVector.random(n: n, field: curveOrderField)
        let rho = ProofUtils.randomNumber(bitWidth: q.bitWidth)
        let s = vectorBase.commitToTwoVectors(gExp: sL.vector, hExp: sR.vector, blinding: rho)

        let y = ProofUtils.computeChallenge(points: [commitment, a, s], field: curveOrderField)
        let ys = FieldVector.powers(k: y.value, n: n, field: curveOrderField)

        let z = ProofUtils.computeChallengeForBigIntegers(ints: [y.value],  field: curveOrderField)
        let zSquared = z * z
        let zCubed = zSquared * z

        let twos = FieldVector.powers(k: TWO, n: n, field: curveOrderField)
        let zNegated = z.negate()
        let l0 = aL.add(zNegated)
        
        let l1 = sL
        let twoTimesZSquared = twos.times(zSquared)
        let r0 = ys.hadamardProduct(aR.add(z)).add(twoTimesZSquared)
        let r1 = sR.hadamardProduct(ys)
        let zCubedMulPowerOf2 = zCubed * (curveOrderField.pow(curveOrderField.fromValue(TWO), BigNumber(integerLiteral: UInt64(n))))
        let k = (ys.sum() * (z - zSquared)) - (zCubedMulPowerOf2 - zCubed)
        let t0 = k + (zSquared * curveOrderField.fromValue(number))
        var t1 = l1.innerPoduct(r0)
        t1 = t1 + l0.innerPoduct(r1)
        let t2 = l1.innerPoduct(r1)

        let polyCommitment = PolyCommitment.from(base: base, x0: t0.value, xs: [t1.value, t2.value])
        
        let x = ProofUtils.computeChallenge(points: polyCommitment.getNonzeroCommitments(), field: curveOrderField)

        let evalCommit = polyCommitment.evaluate(x)

        let tauX = zSquared * curveOrderField.fromValue(witness.r) + curveOrderField.fromValue(evalCommit.r)
        let t = curveOrderField.fromValue(evalCommit.x)
        let mu = alpha + (rho * x)
        
        let uChallenge = ProofUtils.computeChallengeForBigIntegers(ints: [tauX.value, mu.value, t.value]) // order doesn't matter as it's only multiplied by H
        
        let u = uChallenge * base.g
        let hs = vectorBase.hs
        let gs = vectorBase.gs
        
        let hPrimes = hs.hadamardProduct(ys.inv().vector)
        let l = l0.add(l1.times(x))
        let r = r0.add(r1.times(x))
        let hExp = ys.times(z).add(twoTimesZSquared)
        var P = (x.value * s)
        P = P + a
        P = P - z.value * gs.sum()
        P = P + hPrimes.commit(hExp.vector)
        P = P + (t.value * u).toAffine()
        P = P - (mu.value * base.h)

        let primeBase = VectorBase(gs: gs, hs: hPrimes, h: u.toAffine())
        let innerProductWitness = InnerProductWitness(l, r)
        let proof = InnerProductProver.generateProofFromWitness(base: primeBase, c: P.toAffine(), witness: innerProductWitness)
        let tComm = GeneratorVector(polyCommitment.getNonzeroCommitments(), curve)
        return RangeProof(aI: a, s: s, tCommits: tComm , tauX: tauX.value, mu: mu.value, t: t.value, productProof: proof)
    }
}
