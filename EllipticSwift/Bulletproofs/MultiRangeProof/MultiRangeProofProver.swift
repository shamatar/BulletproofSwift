//
//  MultiRangeProofProver.swift
//  EllipticSwift
//
//  Created by Alexander Vlasov on 22.07.2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import Foundation

internal struct MultiRangeProofProver {
    static func generateProof(vectorBase: VectorBase, base: PeddersenBase, witness: MultiRangeProofWitness) -> RangeProof {
        let commitments = witness.commitments
        let m = commitments.count
        let n = vectorBase.gs.size

        let curve = commitments[0].curve
        let curveOrderField = curve.curveOrderField
        let q = curveOrderField.modulus
        
        let (bitsPerNumber, remainder) = n.quotientAndRemainder(dividingBy: m)
        precondition(remainder == 0)
        
        let ZERO = BigNumber(integerLiteral: 0)
        let ONE = BigNumber(integerLiteral: 1)
        let TWO = BigNumber(integerLiteral: 2)
        
        var aLelements = [BigNumber]()
        for i in 0 ..< n {
            let number = witness.witnesses[i/bitsPerNumber].x
            if number.bit(i % bitsPerNumber) {
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
        
        let challengeArr = commitments + [a, s]
        
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
        
        let l0 = aL.add(z.negate())
        let l1 = sL
        let lPoly = FieldVectorPolynomial([l0, l1], field: curveOrderField)
        let r0 = ys.hadamardProduct(aR.add(z)).add(twoTimesZs)
        let r1 = sR.hadamardProduct(ys)
        let rPoly = FieldVectorPolynomial([r0, r1], field: curveOrderField)
        
        //t(X)
        let tPoly = lPoly.innerProduct(rPoly)
        
        //Commit(t)
        let tPolyCoefficients = tPoly.coefficients
        let t0 = tPolyCoefficients[0].value
        let tRest = tPolyCoefficients[1 ..< tPolyCoefficients.count].map { (el) -> BigNumber in
            return el.value
        }
        let polyCommitment = PolyCommitment.from(base: base, x0: t0, xs: tRest)
        
        let x = ProofUtils.computeChallenge(points: polyCommitment.getNonzeroCommitments(), field: curveOrderField)
        
        let mainCommitment = polyCommitment.evaluate(x)
        
        let mu = curveOrderField.fromValue(alpha) + (curveOrderField.fromValue(rho) * x)
        let t = mainCommitment.xReduced
        let tauX = mainCommitment.rReduced + zs.innerPoduct(FieldVector(witness.witnesses.map({ (el) -> GeneralPrimeFieldElement in
            return el.rReduced
        }), curveOrderField))
        
        let uChallenge = ProofUtils.computeChallengeForBigIntegers(ints: [tauX.value, mu.value, t.value])

        let u = uChallenge * base.g
        
        let hs = vectorBase.hs
        let gs = vectorBase.gs
        
        let hPrimes = hs.hadamardProduct(ys.inv().vector)
        let l = l0.add(l1.times(x))
        let r = r0.add(r1.times(x))
        let hExp = ys.times(z).add(twoTimesZs)
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
