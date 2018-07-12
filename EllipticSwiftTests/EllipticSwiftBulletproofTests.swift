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
        let base = params.vectorBase
        var As = [BigUInt]()
        var Bs = [BigUInt]()
        for _ in 0 ..< 16 {
//            As.append(BigUInt(i))
//            Bs.append(BigUInt(i))
            As.append(BigUInt.randomInteger(lessThan: BigUInt(n)))
            Bs.append(BigUInt.randomInteger(lessThan: BigUInt(n)))
        }
        
        let As_field = FieldVector(As, curve.order)
        let Bs_field = FieldVector(Bs, curve.order)
        
        let vTot = base.commitToTwoVectors(gExp: As_field.vector, hExp: Bs_field.vector, blinding: As_field.innerPoduct(Bs_field))
        let witness = InnerProductWitness(As_field, Bs_field)

        let proof = InnerProductProver.generateProofFromWitness(base: base, c: vTot, witness: witness)
        XCTAssert(proof.L.count == nBitLength)
//        print("L")
//        proof.L.forEach { (p) in
//            print(p.description)
//        }
//        print("R")
//        proof.R.forEach { (p) in
//            print(p.description)
//        }
//        print(String(proof.a, radix: 16))
//        print(String(proof.b, radix: 16))
        
        let valid = EfficientInnerProductVerifier.verify(params: base, c: vTot, proof: proof)
        XCTAssert(valid)
    }
    
    func testBaseCorrectness() {
        let n = 16
        let curve = EllipticSwift.bn256Curve
        let params = GeneratorParams.generateParams(size: n, curve: curve)
        let base = params.vectorBase
        let As = FieldVector.powers(k: 2, n: n, q: curve.order);
        let Bs = FieldVector.powers(k: 1, n: n, q: curve.order);
        let innerProduct = As.innerPoduct(Bs)
        let pointA = base.gs.commit(As.vector)
        let pointB = base.hs.commit(Bs.vector)
        let pointC = pointA + pointB + (innerProduct * base.h)
        let point = base.commitToTwoVectors(gExp: As.vector, hExp: Bs.vector, blinding: innerProduct)
        XCTAssert(pointC.toAffine() == point)
    }
    
    func testGenerationPerformance() {
        let curve = EllipticSwift.bn256Curve
        measure {
            let _ = GeneratorParams.generateParams(size: 256, curve: curve)
        }
    }

}
