//
//  EllipticSwiftBulletproofTests.swift
//  EllipticSwiftTests
//
//  Created by Alexander Vlasov on 12.07.2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import XCTest
import BigInt

@testable import EllipticSwift

class EllipticSwiftBulletproofTests: XCTestCase {
    
    func testInnerProductProverAndEfficientVerifier() {
        let n = 16
        let nBitLength = 4
        let curve = EllipticSwift.bn256Curve
        let params = GeneratorParams.generateParams(size: n, curve: curve)
        let innerProductProofSystem = InnerProductProofSystem(params)
        let base = innerProductProofSystem.vectorBase
        var As = [BigNumber]()
        var Bs = [BigNumber]()
        for _ in 0 ..< 16 {
//            As.append(BigUInt(i))
//            Bs.append(BigUInt(i))
            As.append(BigNumber(BigUInt.randomInteger(lessThan: BigUInt(n)).serialize())!)
            Bs.append(BigNumber(BigUInt.randomInteger(lessThan: BigUInt(n)).serialize())!)
        }
        
        let As_field = FieldVector(As, curve.order)
        let Bs_field = FieldVector(Bs, curve.order)
        
        let vTot = base.commitToTwoVectors(gExp: As_field.vector, hExp: Bs_field.vector, blinding: As_field.innerPoduct(Bs_field).value)
        let witness = InnerProductWitness(As_field, Bs_field)

        let proof = innerProductProofSystem.generateProofFromWitness(c: vTot, witness: witness)
        XCTAssert(proof.L.count == nBitLength)
        let valid = innerProductProofSystem.verify(c: vTot, proof: proof)
        XCTAssert(valid)
    }
    
    func testGenerateRangeProof() {
        let number = BigNumber(7)
        let change = BigNumber(3)
        
        let curve = EllipticSwift.bn256Curve
        let parameters = GeneratorParams.generateParams(size: 64, curve: curve)
        let proofSystem = RangeProofSystem(parameters)
        
        let q = curve.order
        let randomness = BigNumber(123)
        let anotherRandomness = q - randomness
        
        let commitment = PeddersenCommitment(base: parameters.base, x: number, r: randomness)
        let commitmentToChange = PeddersenCommitment(base: parameters.base, x: change, r: anotherRandomness)
        
        let v = commitment.commitment
        let changeV = commitmentToChange.commitment
        
        let proof = proofSystem.generateProof(witness: commitment)
        let proofForChange = proofSystem.generateProof(witness: commitmentToChange)
        print(proof.description)
        print("For one proof size is: scalaras " + String(proof.numIntegers) + ", field elements " + String(proof.numElements))
        
        var valid = proofSystem.verify(input: v, proof: proof)
        XCTAssert(valid)
        valid = proofSystem.verify(input: changeV, proof: proofForChange)
        XCTAssert(valid)
    }
    
    func testGenerateMultiRangeProof() {
        let number = BigNumber(7)
        let change = BigNumber(3)
        
        let curve = EllipticSwift.bn256Curve
        let parameters = GeneratorParams.generateParams(size: 64, curve: curve)
        let proofSystem = MultiRangeProofSystem(parameters)
        
        let q = curve.order
        let randomness = BigNumber(123)
        let anotherRandomness = q - randomness
        
        let commitment = PeddersenCommitment(base: parameters.base, x: number, r: randomness)
        let commitmentToChange = PeddersenCommitment(base: parameters.base, x: change, r: anotherRandomness)
        
        let v = commitment.commitment
        let changeV = commitmentToChange.commitment
        
        let multiWitness = MultiRangeProofWitness([commitment, commitmentToChange])
        let proof = proofSystem.generateProof(witness: multiWitness)
        print(proof.description)
        print("For one proof size is: scalaras " + String(proof.numIntegers) + ", field elements " + String(proof.numElements))
        
        let valid = proofSystem.verify(inputs: [v, changeV], proof: proof)
        XCTAssert(valid)
    }
    
    func testBaseCorrectness() {
        let n = 256
        let curve = EllipticSwift.bn256Curve
        let params = GeneratorParams.generateParams(size: n, curve: curve)
        let base = params.vectorBase
        print(base.gs.get(0).description)
        let As = FieldVector.powers(k: 2, n: n, q: curve.order);
        let Bs = FieldVector.powers(k: 1, n: n, q: curve.order);
        let innerProduct = As.innerPoduct(Bs)
        let pointA = base.gs.commit(As.vector)
        print(pointA.description)
        let pointB = base.hs.commit(Bs.vector)
        print(pointB.description)
        let pointC = pointA + pointB + (innerProduct.value * base.h)
        print(pointC.toAffine().description)
        let point = base.commitToTwoVectors(gExp: As.vector, hExp: Bs.vector, blinding: innerProduct.value)
        print(point.description)
        XCTAssert(pointC.toAffine() == point)
    }
    
    func testNativeGenerationPerformance() {
        let curve = EllipticSwift.bn256Curve
        measure {
            let _ = GeneratorParams.generateParams(size: 256, curve: curve)
        }
    }
    
    func testGenerationPerformance() {
        let curve = EllipticSwift.bn256Curve
        measure {
            let _ = GeneratorParams.generateParams(size: 256, curve: curve)
        }
    }

}
