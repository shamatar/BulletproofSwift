//
//  EllipticSwiftTests.swift
//  EllipticSwiftTests
//
//  Created by Alexander Vlasov on 07.07.2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import XCTest
import BigInt

let k256Prime = BigUInt("fffffffffffffffffffffffffffffffffffffffffffffffffffffffefffffc2f", radix: 16)!

@testable import EllipticSwift

class EllipticSwiftTests: XCTestCase {
    
    func testTrivialMontArithmetics() {
        let modulus = BigUInt(97)
        let field = MontPrimeField(modulus)!
        field.montR = BigUInt(100) // for testing purposes
        field.montInvR = BigUInt(65) // for testing purposes
        let fe1 = field.fromValue(BigUInt(43))
        XCTAssert(fe1.rawValue == 32)
        XCTAssert(fe1.value == 43)
        let fe2 = field.fromValue(BigUInt(56))
        XCTAssert(fe2.rawValue == 71)
        XCTAssert(fe2.value == 56)
    }
    
    func testMontR() {
        let modulus = BigUInt(97)
        let field = MontPrimeField(modulus)!
        XCTAssert(field.montR == BigUInt(1) << 64)
    }
    
    func testTrivialMontMul() {
        let modulus = BigUInt(97)
        let field = MontPrimeField(modulus)!
        let fe1 = field.fromValue(BigUInt(43))
        let fe2 = field.fromValue(BigUInt(56))
        let multiple = field.mul(fe1, fe2)
        XCTAssert(multiple.value == 80)
    }
    
    func testSub() {
        let modulus = BigUInt(97)
        let field = MontPrimeField(modulus)!
        let fe1 = field.fromValue(BigUInt(43))
        let fe2 = field.fromValue(BigUInt(56))
        let sum = field.add(fe1, fe2)
        let sub1 = field.sub(fe1, fe2)
        let sub2 = field.sub(fe2, fe1)
        XCTAssert(sum.value == 2)
        XCTAssert(sub1.value == 84)
        XCTAssert(sub2.value == 13)
        XCTAssert(field.neg(sub1).isEqualTo(sub2))
    }
    
    func testIdentity() {
        let modulus = BigUInt(97)
        let field = MontPrimeField(modulus)!
        let identity = field.identity()
        let fe1 = field.fromValue(BigUInt(3))
        let mul = field.mul(fe1, identity)
        XCTAssert(mul.isEqualTo(fe1))
    }
    
    func testMontDouble() {
        let modulus = BigUInt(97)
        let field = MontPrimeField(modulus)!
        let fe1 = field.fromValue(BigUInt(3))
        XCTAssert(fe1.isEqualTo(field.pow(fe1, BigUInt(1))))
        let power = field.pow(fe1, BigUInt(2))
        let mul = field.mul(fe1, fe1)
        XCTAssert(power.isEqualTo(mul))
    }
    
    func testMontPow() {
        let modulus = BigUInt(97)
        let field = MontPrimeField(modulus)!
        let fe1 = field.fromValue(BigUInt(3))
        let power = field.pow(fe1, BigUInt(5))
        XCTAssert(power.value == 49)
    }
    
    func testDoubleAndAddPow() {
        let modulus = BigUInt(97)
        let field = MontPrimeField(modulus)!
        let fe1 = field.fromValue(BigUInt(3))
        let power = field.doubleAndAddExponentiation(fe1, BigUInt(5))
        XCTAssert(power.value == 49)
    }
    
    func testKWindowPow() {
        let modulus = BigUInt(97)
        let field = MontPrimeField(modulus)!
        let fe1 = field.fromValue(BigUInt(3))
        let power = field.kSlidingWindowExponentiation(fe1, BigUInt(11749), windowSize: 3)
        let trivialPower = field.doubleAndAddExponentiation(fe1, BigUInt(11749))
        XCTAssert(power.value == trivialPower.value)
    }
    
    func testKWindowPowWiderWindow() {
        let modulus = BigUInt(97)
        let field = MontPrimeField(modulus)!
        let fe1 = field.fromValue(BigUInt(3))
        let power = field.kSlidingWindowExponentiation(fe1, BigUInt(11749))
        let trivialPower = field.doubleAndAddExponentiation(fe1, BigUInt(11749))
        XCTAssert(power.value == trivialPower.value)
    }
    
    func testKWindowSpeed() {
        let modulus = k256Prime
        let field = MontPrimeField(modulus)!
        let fe1 = field.fromValue(BigUInt(3))
        measure {
            let _ = field.kSlidingWindowExponentiation(fe1, BigUInt(11749), windowSize: 5)
        }
    }
    
    func testDoubleAndAddSpeed() {
        let modulus = k256Prime
        let field = MontPrimeField(modulus)!
        let fe1 = field.fromValue(BigUInt(3))
        measure {
            let _ = field.doubleAndAddExponentiation(fe1, BigUInt(11749))
        }
    }
    
    func testSecp256k1Init() {
        let _ = EllipticSwift.secp256k1WeierstrassCurve
    }
    
    func testBN256Init() {
        let _ = EllipticSwift.bn256WeierstrassCurve
    }
    
    func testInfinityPointGeneration() {
        let c = EllipticSwift.secp256k1Curve
        let p = ProjectivePoint.infinityPoint(c)
        XCTAssert(p.isInfinity)
        let a = p.toAffine()
        XCTAssert(a.isInfinity)
    }
    
    func testFieldInversion() {
        let modulus = BigUInt(97)
        let inverse = BigUInt(3).inverse(modulus)!
        let field = MontPrimeField(modulus)!
        let fe1 = field.fromValue(BigUInt(3))
        let inv = field.inv(fe1)
        XCTAssert(inverse == inv.value)
        let mul = field.mul(fe1, inv)
        XCTAssert(mul.value == 1)
    }
    
    func testPointConversionCycle() {
        let c = EllipticSwift.secp256k1WeierstrassCurve
        let x = BigUInt("5cfdf0eaa22d4d954067ab6f348e400f97357e2703821195131bfe78f7c92b38", radix: 16)!
        let y = BigUInt("584171d79868d22fae4442faede6d2c4972a35d1699453254d1b0df029225032", radix: 16)!
        let p = c.toPoint(x, y)
        XCTAssert(p != nil)
        let proj = p!.toProjective()
        let backToAffine = proj.toAffine().coordinates
        XCTAssert(backToAffine.X == x)
        XCTAssert(backToAffine.Y == y)
    }
    
    func testPointAddition() {
        let c = EllipticSwift.secp256k1WeierstrassCurve
        let p = c.toPoint(BigUInt("5cfdf0eaa22d4d954067ab6f348e400f97357e2703821195131bfe78f7c92b38", radix: 16)!, BigUInt("584171d79868d22fae4442faede6d2c4972a35d1699453254d1b0df029225032", radix: 16)!)
        XCTAssert(p != nil)
        let q = c.toPoint(BigUInt("a1904a2f1366086462462b759857ee4ec785343d9e9c64f980527a9b62651e31", radix: 16)!, BigUInt("3e0e62a6dd89b0775092c1552751c35cf0769b4b2647ce6491e88dbff1c692ce", radix: 16)!)
        XCTAssert(q != nil)
        let sum = c.add(p!.toProjective(), q!.toProjective())
        let sumAffine = sum.toAffine().coordinates
        XCTAssert(!sumAffine.isInfinity)
        XCTAssert(sumAffine.X == BigUInt("cb48b4b3237451109ddd2fb9146556f4c1acb4082a9c667adf4fcb9b0bb6ff83", radix: 16)!)
        XCTAssert(sumAffine.Y == BigUInt("b47df17dfc7607880c54f2c2bfea0f0118c79319573dc66fcb0d952115beb554", radix: 16)!)
    }
    
    func testPointDouble() {
        let c = EllipticSwift.secp256k1WeierstrassCurve
        let p = c.toPoint(BigUInt("5cfdf0eaa22d4d954067ab6f348e400f97357e2703821195131bfe78f7c92b38", radix: 16)!, BigUInt("584171d79868d22fae4442faede6d2c4972a35d1699453254d1b0df029225032", radix: 16)!)
        XCTAssert(p != nil)
        let dbl = c.add(p!.toProjective(), p!.toProjective())
        let affine = dbl.toAffine().coordinates
        XCTAssert(!affine.isInfinity)
        XCTAssert(affine.X == BigUInt("aad76204cd11092a84f04694138db345b1d7223a0bba5483cd089968a34448cb", radix: 16)!)
        XCTAssert(affine.Y == BigUInt("7cfb0467e5df4e174c1ee43c5dcca494cd3e198cf9512f7088bea0a8a76f7d78", radix: 16)!)
    }
    
//    func testWNAF() {
//        let scalar = BigUInt(11749)
//        let (lookups, powers) = EllipticSwift.computeWNAF(scalar: scalar)
//        for i in 0 ..< lookups.count {
//            print("Lookup the element " + String(lookups[i]))
//            print("Rise previous result in a power " + String(powers[i]))
//        }
//    }
    
    func testPointDoublingAndMultiplication() {
        let c = EllipticSwift.secp256k1WeierstrassCurve
        let p = c.toPoint(BigUInt("5cfdf0eaa22d4d954067ab6f348e400f97357e2703821195131bfe78f7c92b38", radix: 16)!, BigUInt("584171d79868d22fae4442faede6d2c4972a35d1699453254d1b0df029225032", radix: 16)!)
        XCTAssert(p != nil)
        let dbl = c.double(p!.toProjective()).toAffine().coordinates
        let mul = c.mul(2, p!).toAffine().coordinates
        XCTAssert(!dbl.isInfinity)
        XCTAssert(!mul.isInfinity)
        XCTAssert(dbl.X == mul.X)
        XCTAssert(dbl.Y == mul.Y)
    }
    
    func testPointTriple() {
        let c = EllipticSwift.secp256k1WeierstrassCurve
        let p = c.toPoint(BigUInt("5cfdf0eaa22d4d954067ab6f348e400f97357e2703821195131bfe78f7c92b38", radix: 16)!, BigUInt("584171d79868d22fae4442faede6d2c4972a35d1699453254d1b0df029225032", radix: 16)!)
        XCTAssert(p != nil)
        var res = c.add(p!.toProjective(), p!.toProjective())
        res = c.add(res, p!.toProjective())
        let resAff = res.toAffine().coordinates
        let mul = c.mul(3, p!).toAffine().coordinates
        XCTAssert(!resAff.isInfinity)
        XCTAssert(!mul.isInfinity)
        XCTAssert(resAff.X == mul.X)
        XCTAssert(resAff.Y == mul.Y)
    }
    
    func testPointMul() {
        let scalar = BigUInt("e853ff4cc88e32bc6c2b74ffaca14a7e4b118686e77eefb086cb0ae298811127", radix: 16)!
        let c = EllipticSwift.secp256k1WeierstrassCurve
        let p = c.toPoint(BigUInt("5cfdf0eaa22d4d954067ab6f348e400f97357e2703821195131bfe78f7c92b38", radix: 16)!, BigUInt("584171d79868d22fae4442faede6d2c4972a35d1699453254d1b0df029225032", radix: 16)!)
        XCTAssert(p != nil)
        let res = c.mul(scalar, p!)
        let resAff = res.toAffine().coordinates
        XCTAssert(!resAff.isInfinity)
        XCTAssert(resAff.X == BigUInt("e2b1976566023f61f70893549a497dbf68f14e6cb44ba1b3bbe8c438a172a7b0", radix: 16)!)
        XCTAssert(resAff.Y == BigUInt("d088864d26ac7c96690ebc652b2906e8f2b85bccfb27b181d587899ccab4b442", radix: 16)!)
    }
    
    func testModularSquareRoot() {
        let primeField = EllipticSwift.bn256PrimeField
        let x = BigUInt("16013846061302606236678105035458059333313648338706491832021059651102665958964", radix: 10)!
        let xReduced = primeField.fromValue(x)
        let sqrtReduced = primeField.sqrt(xReduced)
        let y = sqrtReduced.value
//        XCTAssert(sqrtReduced * sqrtReduced == xReduced)
//        XCTAssert((y * y) % primeField.prime == x)
        XCTAssert(y == BigUInt("19775247992460679389771436516608933805782779220511590267128505960436574705663", radix: 10)!)
    }
}
