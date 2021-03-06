//
//  FixedWidthNumbers.swift
//  EllipticSwiftTests
//
//  Created by Alexander Vlasov on 13.07.2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import XCTest
import BigInt

@testable import EllipticSwift
class FixedWidthNumbers: XCTestCase {

    func testCompareU512split() {
        let raw = U512(BigUInt(1).serialize())!
        print(raw.bytes.toHexString())
        let (top, bottom) = (raw as U512).split()
        let topBytes = top.bytes
        let bottomBytes = bottom.bytes
        print(topBytes.toHexString())
        print(bottomBytes.toHexString())
    }
    
    func testModularSub() {
        let modulus = BigNumber(97)
        let field = NativeNaivePrimeField<U256>(modulus)
        let fe1 = field.fromValue(BigNumber(43))
        let fe2 = field.fromValue(BigNumber(56))
        let sub1 = field.sub(fe1, fe2)
        let sub2 = field.sub(fe2, fe1)
        XCTAssert(sub1.value == 84)
        XCTAssert(sub2.value == 13)
        XCTAssert(field.neg(sub1).isEqualTo(sub2))
    }
    
    func testModularNonoverflowingAdd() {
        let modulus = BigNumber(97)
        let field = NativeNaivePrimeField<U256>(modulus)
        let fe1 = field.fromValue(BigNumber(1))
        let fe2 = field.fromValue(BigNumber(2))
        let sum = field.add(fe1, fe2)
        XCTAssert(sum.value == 3)
    }
    
    func testModularOverflowingAdd() {
        let modulus = BigNumber(97)
        let field = NativeNaivePrimeField<U256>(modulus)
        let fe1 = field.fromValue(BigNumber(43))
        let fe2 = field.fromValue(BigNumber(56))
        let sum = field.add(fe1, fe2)
        XCTAssert(sum.value == 2)
    }
    
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
    
    func testPointMul() {
        let scalar = BigUInt("e853ff4cc88e32bc6c2b74ffaca14a7e4b118686e77eefb086cb0ae298811127", radix: 16)!
        let c = EllipticSwift.secp256k1WeierstrassCurve
        let p = c.toPoint(BigUInt("5cfdf0eaa22d4d954067ab6f348e400f97357e2703821195131bfe78f7c92b38", radix: 16)!, BigUInt("584171d79868d22fae4442faede6d2c4972a35d1699453254d1b0df029225032", radix: 16)!)
        XCTAssert(p != nil)
        let res = c.mul(BigNumber(scalar.serialize())!, p!)
        let resAff = res.toAffine().coordinates
        XCTAssert(!resAff.isInfinity)
        XCTAssert(resAff.X == BigUInt("e2b1976566023f61f70893549a497dbf68f14e6cb44ba1b3bbe8c438a172a7b0", radix: 16)!)
        XCTAssert(resAff.Y == BigUInt("d088864d26ac7c96690ebc652b2906e8f2b85bccfb27b181d587899ccab4b442", radix: 16)!)
    }
    
    func testFieldDouble() {
        let modulus = BigNumber(97)
        let field = NativeNaivePrimeField<U256>(modulus)
        let fe1 = field.fromValue(BigNumber(3))
        let powOfOne = field.pow(fe1, BigNumber(1))
        XCTAssert(fe1.isEqualTo(powOfOne))
        let power = field.pow(fe1, BigNumber(2))
        let mul = field.mul(fe1, fe1)
        XCTAssert(power.isEqualTo(mul))
        XCTAssert(power.value == 9)
    }
    
    func testFieldPow() {
        let modulus = BigNumber(97)
        let field = NativeNaivePrimeField<U256>(modulus)
        let fe1 = field.fromValue(BigNumber(3))
        let power = field.pow(fe1, BigNumber(5))
        XCTAssert(power.value == 49)
    }
    
    func testLargeFieldInv() {
        let secp256k1Prime = EllipticSwift.secp256k1Prime
        let secp256k1PrimeField = NativeNaivePrimeField<U256>(secp256k1Prime)
        for i in 0 ..< 10 {
            let ar = BigUInt.randomInteger(lessThan: secp256k1PrimeBUI)
            let a = secp256k1PrimeField.fromValue(BigNumber(ar.serialize())!)
            let trivialRes = ar.inverse(secp256k1PrimeBUI)!
            let res = secp256k1PrimeField.inv(a)
            XCTAssert(res.value == trivialRes, "Failed on attempt = " + String(i))
        }
    }
    
    func testLargeFieldMul() {
        let secp256k1Prime = EllipticSwift.secp256k1Prime
        let secp256k1PrimeField = NativeNaivePrimeField<U256>(secp256k1Prime)
        for i in 0 ..< 10 {
            let ar = BigUInt.randomInteger(lessThan: secp256k1PrimeBUI)
            let br = BigUInt.randomInteger(lessThan: secp256k1PrimeBUI)
            let a = secp256k1PrimeField.fromValue(BigNumber(ar.serialize())!)
            let b = secp256k1PrimeField.fromValue(BigNumber(br.serialize())!)
            let fullTrivialMul = ar * br
            let pTrivial = fullTrivialMul % secp256k1PrimeBUI
            let p = secp256k1PrimeField.mul(a, b)
            XCTAssert(p.value == pTrivial, "Failed on attempt = " + String(i))
        }
    }
    
    func testLargeFieldAddition() {
        let secp256k1Prime = EllipticSwift.secp256k1Prime
        let secp256k1PrimeField = NativeNaivePrimeField<U256>(secp256k1Prime)
        for i in 0 ..< 10 {
            let ar = BigUInt.randomInteger(lessThan: secp256k1PrimeBUI)
            let br = BigUInt.randomInteger(lessThan: secp256k1PrimeBUI)
            let a = secp256k1PrimeField.fromValue(BigNumber(ar.serialize())!)
            let b = secp256k1PrimeField.fromValue(BigNumber(br.serialize())!)
            let fullTrivialMul = ar + br
            let pTrivial = fullTrivialMul % secp256k1PrimeBUI
            let p = secp256k1PrimeField.add(a, b)
            if p.value != pTrivial {
                print(ar)
                print(br)
                print(pTrivial)
                print(p.value)
                let _ = secp256k1PrimeField.add(a, b)
            }
            XCTAssert(p.value == pTrivial, "Failed on attempt = " + String(i))
        }
    }
    
    func testLargeFieldPow() {
        let secp256k1Prime = EllipticSwift.secp256k1Prime
        let secp256k1PrimeField = NativeNaivePrimeField<U256>(secp256k1Prime)
        for i in 0 ..< 10 {
            let base = BigUInt.randomInteger(lessThan: secp256k1PrimeBUI)
            let power = BigUInt.randomInteger(lessThan: secp256k1PrimeBUI)
            let pTrivial = base.power(power, modulus: secp256k1PrimeBUI)
            let a = secp256k1PrimeField.fromValue(BigNumber(base.serialize())!)
            let p = secp256k1PrimeField.pow(a, BigNumber(power.serialize())!)
            XCTAssert(p.value == pTrivial, "Failed on attempt = " + String(i))
        }
    }
    
    func testFieldInversion() {
        let modulus = BigUInt(97)
        let inverse = BigUInt(3).inverse(modulus)!
        let field = NativeNaivePrimeField<U256>(modulus)
        let fe1 = field.fromValue(BigNumber(3))
        let inv = field.inv(fe1)
        XCTAssert(inverse == inv.value)
        let mul = field.mul(fe1, inv)
        XCTAssert(mul.value == 1)
    }
    
    func testMontFieldConversion() {
        let modulus = BigUInt(97)
        let field = NativeMontPrimeField<U256>(modulus)!
        let forward = field.fromValue(BigNumber(3))
        let back = forward.value
        XCTAssert(back == 3)
        let rawValue = U256(3)
        let reduced = rawValue.toMontForm(U256(modulus.serialize())!)
        XCTAssert(forward.rawValue == reduced)
    }
    
    func testMontParamsCalculation() {
        let modulus = BigUInt(97)
        let field = NativeMontPrimeField<U256>(modulus)!
        let R = BigUInt(1) << 256
        let montR = R % modulus
        XCTAssert(montR == BigUInt(field.montR.bytes))
        let montInvR = montR.inverse(modulus)!
        XCTAssert(montInvR == BigUInt(field.montInvR.bytes))
        let montK = (R * montInvR - BigUInt(1)) / modulus
        XCTAssert(montK == BigUInt(field.montK.bytes))
        XCTAssert(BigUInt(field.montR.modMultiply(field.montInvR, field.prime).bytes) == 1)
    }
    
    func testMontReduction() {
        let modulus = BigUInt(97)
        let field = GeneralizedMontPrimeField<U256>(modulus)
        let R = BigUInt(1) << 256
        let montR = R % modulus
        XCTAssert(montR == BigUInt(field.montR.bytes))
        let montInvR = montR.inverse(modulus)!
        XCTAssert(montInvR == BigUInt(field.montInvR.bytes))
        let montK = (R * montInvR - BigUInt(1)) / modulus
        XCTAssert(montK == BigUInt(field.montK.bytes))
        
        let a = BigUInt.randomInteger(lessThan: modulus)
        let aReduced = (a * R) % modulus
        let fe = GeneralizedPrimeFieldElement.fromValue(a, field: field)
        XCTAssert(aReduced == BigUInt(fe.rawValue.bytes))
    }

    func testMontMultiplication() {
        let modulus = BigUInt(97)
        let field = NativeMontPrimeField<U256>(modulus)!
        let a = field.fromValue(BigNumber(43))
        let b = field.fromValue(BigNumber(56))
        let mul = field.montMul(a, b)
        let value = mul.value
        XCTAssert(value == 80)
    }
    
    func testInit() {
        let bn = BigNumber(3)
        XCTAssert("0000000000000000000000000000000000000000000000000000000000000003" == bn.bytes.toHexString())
    }
    
    func testInitU512() {
        let modulus = BigUInt(97)
        let u512 = U512(modulus.serialize())!
        print(u512.bytes.toHexString())
        XCTAssert("00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000061" == u512.bytes.toHexString())
        XCTAssert(u512.bytes.count == 64)
    }
    
    func testInitU128() {
        let modulus = BigUInt(97)
        let u128 = U128(modulus.serialize())!
        let sum = u128.add(u128)
        XCTAssert(sum.clippedValue == 194)
    }
    
    func testInitU128Mul() {
        let rand1 = BigUInt.randomInteger(withExactWidth: 128)
        let rand2 = BigUInt.randomInteger(withExactWidth: 128)
        let num1 = U128(rand1.serialize())!
        let num2 = U128(rand2.serialize())!
        let full: U256 = num1.mul(num2)
        let f = rand1 * rand2
        XCTAssert(f == BigUInt(full.bytes))
    }
    
    func testMemoryStructureU128() {
        let num1 = U128(UInt32.max)
        let num2 = U128(UInt32.max)
        let result = num1.halfMul(num2)
        let trivialResult = UInt64(UInt32.max) * UInt64(UInt32.max)
        XCTAssert(result.clippedValue == trivialResult)
    }
    
    func testInitU128Mul2() {
        let rand1 = BigUInt.randomInteger(withExactWidth: 128)
        let rand2 = BigUInt.randomInteger(withExactWidth: 128)
        let num1 = U128(rand1.serialize())!
        let num2 = U128(rand2.serialize())!
        let full: U256 = num1.mul(num2)
        let (t, b) = full.split()
        let mod = BigUInt(1) << 128
        let large = rand1 * rand2
        let (top, bottom) = large.quotientAndRemainder(dividingBy: mod)
        XCTAssert(t.bytes == top.serialize())
        XCTAssert(b.bytes == bottom.serialize())
    }
    
    func testInitU128HalfMul() {
        let rand1 = BigUInt.randomInteger(withExactWidth: 128)
        let rand2 = BigUInt.randomInteger(withExactWidth: 128)
        let num1 = U128(rand1.serialize())!
        let num2 = U128(rand2.serialize())!
        let full = num1.halfMul(num2)
        let mod = BigUInt(1) << 128
        let large = rand1 * rand2
        let (_, bottom) = large.quotientAndRemainder(dividingBy: mod)
        XCTAssert(BigUInt(full.bytes) == bottom, "Failed to half multiply U128")
    }
    
    func testInitU128Mul3() {
        let num1 = U128.max
        let num2 = U128.max
        let full: U256 = num1.mul(num2)
        let bn1 = BigUInt(num1.bytes)
        let bn2 = BigUInt(num2.bytes)
        XCTAssert(BigUInt(full.bytes) == bn1 * bn2, "Failed to full multiply U128")
    }
    
    func testSplitU256() {
        let large = BigUInt.randomInteger(withExactWidth: 512)
        let u512 = U512(large.serialize())!
        let (top, bottom) = u512.split()
        let mod = BigUInt(1) << 256
        let (t, b) = large.quotientAndRemainder(dividingBy: mod)
        XCTAssert(top.bytes == t.serialize())
        XCTAssert(bottom.bytes == b.serialize())
    }
    
    func testMultiply() {
        let rand1 = BigUInt.randomInteger(withExactWidth: 256)
        let rand2 = BigUInt.randomInteger(withExactWidth: 256)
        let num1 = U256(rand1.serialize())!
        let num2 = U256(rand2.serialize())!
        let full: U512 = num1.fullMul(num2)
        let f = rand1 * rand2
        XCTAssert(f == BigUInt(full.bytes))
        print(full.bytes.toHexString())
        print(String(f, radix: 16))
    }
    
    func testMultiply2() {
        let rand1 = BigUInt(1)
        let rand2 = BigUInt(2)
        let num1 = U256(rand1.serialize())!
        let num2 = U256(rand2.serialize())!
        let full: U512 = num1.fullMul(num2)
        let f = rand1 * rand2
        XCTAssert(BigUInt(full.bytes) == f)
    }
    
    func testTrivialAddU256() {
        let rand1 = BigUInt(1)
        let rand2 = BigUInt(512)
        let num1 = U256(rand1.serialize())!
        let num2 = U256(rand2.serialize())!
        let full = num1.addMod(num2)
        let f = rand1 + rand2
        XCTAssert(f == BigUInt(full.bytes))
    }
    
    func testMultiply3() {
        let num1 = U256.max
        let num2 = U256.max
        let full: U512 = num1.fullMul(num2)
        let bn1 = BigUInt(num1.bytes)
        let bn2 = BigUInt(num2.bytes)
        let f = bn1 * bn2
        XCTAssert(f == BigUInt(full.bytes))
    }
    
    func testUInt32Bytes() {
        let num = UInt32("11223344", radix: 16)!
        let beBytes = num.bigEndianBytes
        let leBytes = num.littleEndianBytes
        XCTAssert(beBytes.toHexString() == "11223344")
        XCTAssert(leBytes.toHexString() == "44332211")
    }
    
    func testModularSquareRoot() {
        let bn256Prime = BigUInt("21888242871839275222246405745257275088696311157297823662689037894645226208583", radix: 10)!
        let bn256PrimeField = GeneralPrimeField.nativeU256(NativeNaivePrimeField<U256>(bn256Prime))
        let primeField = bn256PrimeField
        let x = BigUInt("16013846061302606236678105035458059333313648338706491832021059651102665958964", radix: 10)!
        let xReduced = primeField.fromValue(x)
        let sqrtReduced = xReduced.sqrt()
        let y = sqrtReduced.value
//        XCTAssert(sqrtReduced * sqrtReduced == xReduced)
//        XCTAssert((y * y) % primeField.modulus == x)
        XCTAssert(BigUInt(y.bytes) == BigUInt("19775247992460679389771436516608933805782779220511590267128505960436574705663", radix: 10)!)
    }
    
    func testNaiveModularMultiplicationPerformance() {
        let bn256Prime = BigUInt("21888242871839275222246405745257275088696311157297823662689037894645226208583", radix: 10)!
        let modulus = U256(bn256Prime.serialize())!
        let number1 = BigUInt.randomInteger(lessThan: bn256Prime)
        let number2 = BigUInt.randomInteger(lessThan: bn256Prime)
        let bn1 = U256(number1.serialize())!
        let bn2 = U256(number2.serialize())!
        measure {
            let _ = bn1.modMultiply(bn2, modulus)
        }
    }
    
    func testBitWidth() {
        let br = BigUInt(11749)
        let b = U256(br.serialize())!
        let leadingZeroes = UInt32(11794).leadingZeroBitCount
        let actualWidth = 32 - leadingZeroes
        let bitWidth = b.bitWidth
        let largeLeadingZeroes = b.leadingZeroBitCount
        XCTAssert(largeLeadingZeroes + bitWidth == 256)
        XCTAssert(actualWidth == bitWidth)
        XCTAssert(leadingZeroes + 224 == largeLeadingZeroes)
    }
    
    func testComputeSlidingWindow() {
        let exponent = 12686028502
        let br = BigUInt(exponent)
        let b = U256(br.serialize())!
        let windowSize = 5
        let (lookups, powers) = computeSlidingWindow(scalar: b, windowSize: windowSize)
        let numPrecomputedElements = (1 << windowSize) - 1 // 2**k - 1
        var precomputations = [Int](repeating: 0, count: numPrecomputedElements)
        precomputations[0] = 1
        precomputations[1] = 2
        for i in 2 ..< numPrecomputedElements {
            precomputations[i] = precomputations[i-2] + precomputations[1]
        }
        XCTAssert(lookups[0] != -1)
        // base implementation of sliding windows exponentiation
        var resultOrder = 0
        for i in 0 ..< lookups.count {
            if lookups[i] == -1 {
                resultOrder = resultOrder * 2
            } else {
                let power = powers[i]
                let intermediatePower = resultOrder * Int(power)
                resultOrder = intermediatePower + precomputations[lookups[i]]
            }
        }
        XCTAssert(resultOrder == exponent)
    }
    
    func testDifferentSquaring() {
        let secp256k1Prime = EllipticSwift.secp256k1Prime
        let secp256k1PrimeField = NativeNaivePrimeField<U256>(secp256k1Prime)
        let ar = BigUInt.randomInteger(lessThan: secp256k1PrimeBUI)
        let a = secp256k1PrimeField.fromValue(BigNumber(ar.serialize())!)
        //        let br = BigUInt.randomInteger(lessThan: secp256k1PrimeBUI)
        let br = BigUInt(2)
        let b = U256(br.serialize())!
        let mul = a.field.mul(a, a)
        let trivial = a.field.doubleAndAddExponentiation(a, b)
        let sliding = a.field.kSlidingWindowExponentiation(a, b, windowSize: 5)
        XCTAssert(mul.value == trivial.value)
        XCTAssert(trivial.value == sliding.value)
    }
    
    func testDifferentCubing() {
        let secp256k1Prime = EllipticSwift.secp256k1Prime
        let secp256k1PrimeField = NativeNaivePrimeField<U256>(secp256k1Prime)
        let ar = BigUInt.randomInteger(lessThan: secp256k1PrimeBUI)
        let a = secp256k1PrimeField.fromValue(BigNumber(ar.serialize())!)
        //        let br = BigUInt.randomInteger(lessThan: secp256k1PrimeBUI)
        let br = BigUInt(3)
        let b = U256(br.serialize())!
        var mul = a.field.mul(a, a)
        mul = a.field.mul(a, mul)
        let trivial = a.field.doubleAndAddExponentiation(a, b)
        let sliding = a.field.kSlidingWindowExponentiation(a, b, windowSize: 5)
        XCTAssert(mul.value == trivial.value)
        XCTAssert(trivial.value == sliding.value)
    }
    
    func testDifferentExponentiations() {
        let secp256k1Prime = EllipticSwift.secp256k1Prime
        let secp256k1PrimeField = NativeNaivePrimeField<U256>(secp256k1Prime)
//        let ar = BigUInt.randomInteger(lessThan: secp256k1PrimeBUI)
        let ar = BigUInt.randomInteger(withExactWidth: 256)
        let a = secp256k1PrimeField.fromValue(BigNumber(ar.serialize())!)
//        let br = BigUInt.randomInteger(lessThan: secp256k1PrimeBUI)
        let br = BigUInt.randomInteger(withExactWidth: 256)
        let b = U256(br.serialize())!
        let trivial = a.field.doubleAndAddExponentiation(a, b)
        let sliding = a.field.kSlidingWindowExponentiation(a, b, windowSize: 5)
        XCTAssert(trivial.value == sliding.value)
    }
    
    func testDoubleAndAddExponentiationPerformance() {
        let secp256k1Prime = EllipticSwift.secp256k1Prime
        let secp256k1PrimeField = NativeNaivePrimeField<U256>(secp256k1Prime)
        let ar = BigUInt.randomInteger(lessThan: secp256k1PrimeBUI)
        let a = secp256k1PrimeField.fromValue(BigNumber(ar.serialize())!)
        let br = BigUInt.randomInteger(lessThan: secp256k1PrimeBUI)
        let b = U256(br.serialize())!
        measure {
            let _ = a.field.doubleAndAddExponentiation(a, b)
        }
    }
    
    func testSlidingWindowExponentiationPerformance() {
        let secp256k1Prime = EllipticSwift.secp256k1Prime
        let secp256k1PrimeField = NativeNaivePrimeField<U256>(secp256k1Prime)
        let ar = BigUInt.randomInteger(lessThan: secp256k1PrimeBUI)
        let a = secp256k1PrimeField.fromValue(BigNumber(ar.serialize())!)
        let br = BigUInt.randomInteger(lessThan: secp256k1PrimeBUI)
        let b = U256(br.serialize())!
        measure {
            let _ = a.field.kSlidingWindowExponentiation(a, b, windowSize: 5)
        }
    }
    
    func testDoubleAndAddExponentiationPerformanceInMontForm() {
        let secp256k1Prime = EllipticSwift.secp256k1Prime
        let secp256k1PrimeField = NativeMontPrimeField<U256>(secp256k1Prime)
        let ar = BigUInt.randomInteger(lessThan: secp256k1PrimeBUI)
        let a = secp256k1PrimeField.fromValue(BigNumber(ar.serialize())!)
        let br = BigUInt.randomInteger(lessThan: secp256k1PrimeBUI)
        let b = U256(br.serialize())!
        measure {
            let _ = a.field.doubleAndAddExponentiation(a, b)
        }
    }
    
    func testSlidingWindowExponentiationPerformanceInMontForm() {
        let secp256k1Prime = EllipticSwift.secp256k1Prime
        let secp256k1PrimeField = NativeMontPrimeField<U256>(secp256k1Prime)
        let ar = BigUInt.randomInteger(lessThan: secp256k1PrimeBUI)
        let a = secp256k1PrimeField.fromValue(BigNumber(ar.serialize())!)
        let br = BigUInt.randomInteger(lessThan: secp256k1PrimeBUI)
        let b = U256(br.serialize())!
        measure {
            let _ = a.field.kSlidingWindowExponentiation(a, b, windowSize: 5)
        }
    }
    
    func testWideSlidingWindowExponentiationPerformanceInMontForm() {
        let secp256k1Prime = EllipticSwift.secp256k1Prime
        let secp256k1PrimeField = NativeMontPrimeField<U256>(secp256k1Prime)
        let ar = BigUInt.randomInteger(lessThan: secp256k1PrimeBUI)
        let a = secp256k1PrimeField.fromValue(BigNumber(ar.serialize())!)
        let br = BigUInt.randomInteger(lessThan: secp256k1PrimeBUI)
        let b = U256(br.serialize())!
        measure {
            let _ = a.field.kSlidingWindowExponentiation(a, b, windowSize: 16)
        }
    }
    
    func testNaviteModInverse() {
        let modulus = U256(97)
        let number = U256(3)
        let inverse = number.modInv(modulus)
        XCTAssert(inverse.v.0.clippedValue == 65)
    }
    
    func testGenericFEInversion() {
        let modulus = U256(97)
        let field = GeneralizedMontPrimeField<U256>(modulus)
        let fe = GeneralizedPrimeFieldElement.fromValue(UInt64(3), field: field)
        let inverse = fe.inv()
        let value = inverse.value
        XCTAssert(value == 65)
    }
    
    func testGenericFEMul() {
        let modulus = U256(97)
        let field = GeneralizedMontPrimeField<U256>(modulus)
        let fe = GeneralizedPrimeFieldElement.fromValue(UInt64(3), field: field)
        let mul = fe * fe
        let value = mul.value
        XCTAssert(value == 9)
    }
    
    func testGenericFEMulWithOverflow() {
        let modulus = U256(97)
        let field = GeneralizedMontPrimeField<U256>(modulus)
        let fe = GeneralizedPrimeFieldElement.fromValue(UInt64(40), field: field)
        let mul = fe * fe
        let value = mul.value
        XCTAssert(value == 48)
    }
    
    func testGenericDoubleAndAddExponentiationPerformanceInMontForm() {
        let secp256k1Prime = EllipticSwift.secp256k1Prime
        let secp256k1PrimeField = GeneralizedMontPrimeField<U256>(secp256k1Prime)
        let ar = BigUInt.randomInteger(lessThan: secp256k1PrimeBUI)
        let a = GeneralizedPrimeFieldElement.fromValue(BigNumber(ar.serialize())!, field: secp256k1PrimeField)
        let br = BigUInt.randomInteger(lessThan: secp256k1PrimeBUI)
        let b = U256(br.serialize())!
        measure {
            let _ = a.pow(b)
        }
    }
    
    func testGenericCurveCreation() {
        let secp256k1PrimeBUI = BigUInt("fffffffffffffffffffffffffffffffffffffffffffffffffffffffefffffc2f", radix: 16)!
//        let secp256k1PrimeField = GeneralizedMontPrimeField<U256>.init(secp256k1PrimeBUI)
        let secp256k1PrimeField = GeneralizedNaivePrimeField<U256>.init(secp256k1PrimeBUI)
        let secp256k1CurveOrderBUI = BigUInt("fffffffffffffffffffffffffffffffebaaedce6af48a03bbfd25e8cd0364141", radix: 16)!
        let secp256k1CurveOrder = U256(secp256k1CurveOrderBUI.serialize())!
        let secp256k1WeierstrassCurve = GeneralizedWeierstrassCurve(field: secp256k1PrimeField, order: secp256k1CurveOrder, A: U256(0), B: U256(7))
        let generatorX = BigUInt("79BE667EF9DCBBAC55A06295CE870B07029BFCDB2DCE28D959F2815B16F81798", radix: 16)!
        let generatorY = BigUInt("483ADA7726A3C4655DA4FBFC0E1108A8FD17B448A68554199C47D08FFB10D4B8", radix: 16)!
        let success = secp256k1WeierstrassCurve.testGenerator(AffineCoordinates(generatorX, generatorY))
        precondition(success, "Failed to init secp256k1 curve!")
    }
    
    func testPointMulInGenerics() {
        let secp256k1PrimeBUI = BigUInt("fffffffffffffffffffffffffffffffffffffffffffffffffffffffefffffc2f", radix: 16)!
        //        let secp256k1PrimeField = GeneralizedMontPrimeField<U256>.init(secp256k1PrimeBUI)
        let secp256k1PrimeField = GeneralizedNaivePrimeField<U256>.init(secp256k1PrimeBUI)
        let secp256k1CurveOrderBUI = BigUInt("fffffffffffffffffffffffffffffffebaaedce6af48a03bbfd25e8cd0364141", radix: 16)!
        let secp256k1CurveOrder = U256(secp256k1CurveOrderBUI.serialize())!
        let secp256k1WeierstrassCurve = GeneralizedWeierstrassCurve(field: secp256k1PrimeField, order: secp256k1CurveOrder, A: U256(0), B: U256(7))
        let generatorX = BigUInt("79BE667EF9DCBBAC55A06295CE870B07029BFCDB2DCE28D959F2815B16F81798", radix: 16)!
        let generatorY = BigUInt("483ADA7726A3C4655DA4FBFC0E1108A8FD17B448A68554199C47D08FFB10D4B8", radix: 16)!
        let success = secp256k1WeierstrassCurve.testGenerator(AffineCoordinates(generatorX, generatorY))
        XCTAssert(success, "Failed to init secp256k1 curve!")
        
        let scalar = BigUInt("e853ff4cc88e32bc6c2b74ffaca14a7e4b118686e77eefb086cb0ae298811127", radix: 16)!
        let c = secp256k1WeierstrassCurve
        let p = c.toPoint(BigUInt("5cfdf0eaa22d4d954067ab6f348e400f97357e2703821195131bfe78f7c92b38", radix: 16)!, BigUInt("584171d79868d22fae4442faede6d2c4972a35d1699453254d1b0df029225032", radix: 16)!)
        XCTAssert(p != nil)
        let res = c.mul(U256(scalar.serialize())! , p!)
        let resAff = res.toAffine().coordinates
        XCTAssert(!resAff.isInfinity)
        XCTAssert(resAff.X == BigUInt("e2b1976566023f61f70893549a497dbf68f14e6cb44ba1b3bbe8c438a172a7b0", radix: 16)!)
        XCTAssert(resAff.Y == BigUInt("d088864d26ac7c96690ebc652b2906e8f2b85bccfb27b181d587899ccab4b442", radix: 16)!)
    }
    
    func testPointMulInGenericsInMontForm() {
        let secp256k1PrimeBUI = BigUInt("fffffffffffffffffffffffffffffffffffffffffffffffffffffffefffffc2f", radix: 16)!
        let secp256k1PrimeField = GeneralizedMontPrimeField<U256>.init(secp256k1PrimeBUI)
//        let secp256k1PrimeField = GeneralizedNaivePrimeField<U256>.init(secp256k1PrimeBUI)
        let secp256k1CurveOrderBUI = BigUInt("fffffffffffffffffffffffffffffffebaaedce6af48a03bbfd25e8cd0364141", radix: 16)!
        let secp256k1CurveOrder = U256(secp256k1CurveOrderBUI.serialize())!
        let secp256k1WeierstrassCurve = GeneralizedWeierstrassCurve(field: secp256k1PrimeField, order: secp256k1CurveOrder, A: U256(0), B: U256(7))
        let generatorX = BigUInt("79BE667EF9DCBBAC55A06295CE870B07029BFCDB2DCE28D959F2815B16F81798", radix: 16)!
        let generatorY = BigUInt("483ADA7726A3C4655DA4FBFC0E1108A8FD17B448A68554199C47D08FFB10D4B8", radix: 16)!
        let success = secp256k1WeierstrassCurve.testGenerator(AffineCoordinates(generatorX, generatorY))
        XCTAssert(success, "Failed to init secp256k1 curve!")
        
        let scalar = BigUInt("e853ff4cc88e32bc6c2b74ffaca14a7e4b118686e77eefb086cb0ae298811127", radix: 16)!
        let c = secp256k1WeierstrassCurve
        let p = c.toPoint(BigUInt("5cfdf0eaa22d4d954067ab6f348e400f97357e2703821195131bfe78f7c92b38", radix: 16)!, BigUInt("584171d79868d22fae4442faede6d2c4972a35d1699453254d1b0df029225032", radix: 16)!)
        XCTAssert(p != nil)
        var res = c.wNAFmul(U256(scalar.serialize())! , p!)
        var resAff = res.toAffine().coordinates
        XCTAssert(!resAff.isInfinity)
        XCTAssert(resAff.X == BigUInt("e2b1976566023f61f70893549a497dbf68f14e6cb44ba1b3bbe8c438a172a7b0", radix: 16)!)
        XCTAssert(resAff.Y == BigUInt("d088864d26ac7c96690ebc652b2906e8f2b85bccfb27b181d587899ccab4b442", radix: 16)!)
        res = c.doubleAndAddMul(U256(scalar.serialize())! , p!)
        resAff = res.toAffine().coordinates
        XCTAssert(!resAff.isInfinity)
        XCTAssert(resAff.X == BigUInt("e2b1976566023f61f70893549a497dbf68f14e6cb44ba1b3bbe8c438a172a7b0", radix: 16)!)
        XCTAssert(resAff.Y == BigUInt("d088864d26ac7c96690ebc652b2906e8f2b85bccfb27b181d587899ccab4b442", radix: 16)!)
    }
    
    func testDifferentFields() {
        let bnPrime = EllipticSwift.secp256k1PrimeBUI
        let secp256k1Prime = EllipticSwift.secp256k1Prime
        let secp256k1PrimeField = GeneralizedNaivePrimeField<U256>(bnPrime)
        let secp256k1PrimeFieldMont = GeneralizedMontPrimeField<U256>(secp256k1Prime)
//                let ar = BigUInt.randomInteger(lessThan: secp256k1PrimeBUI)
        let ar = BigUInt.randomInteger(withExactWidth: 256)
        let a = GeneralizedPrimeFieldElement.fromValue(BigNumber(ar.serialize())!, field: secp256k1PrimeField)
        let aMont = GeneralizedPrimeFieldElement.fromValue(BigNumber(ar.serialize())!, field: secp256k1PrimeFieldMont)
//                let br = BigUInt.randomInteger(lessThan: secp256k1PrimeBUI)
        let br = BigUInt.randomInteger(withExactWidth: 256)
        var bnResult = (ar * ar) % bnPrime
        let b = U256(br.serialize())!
        let expectedReduction = ((BigUInt(1) << 256) * ar) % bnPrime
        XCTAssert(expectedReduction == BigUInt(aMont.rawValue.bytes))
        var trivial = a * a
        var mont = aMont * aMont
        XCTAssert(bnResult == trivial.value)
        XCTAssert(trivial.value == mont.value)
        
        bnResult = ar.power(br, modulus: bnPrime)
        trivial = a.pow(b)
        mont = aMont.pow(b)
        XCTAssert(bnResult == trivial.value)
        XCTAssert(trivial.value == mont.value)
    }
    
    func testDifferentFieldsSmallValues() {
        let bnPrime = EllipticSwift.secp256k1PrimeBUI
        let secp256k1Prime = EllipticSwift.secp256k1Prime
        let secp256k1PrimeField = GeneralizedNaivePrimeField<U256>(bnPrime)
        let secp256k1PrimeFieldMont = GeneralizedMontPrimeField<U256>(secp256k1Prime)
        //                let ar = BigUInt.randomInteger(lessThan: secp256k1PrimeBUI)
        let ar = BigUInt.randomInteger(withExactWidth: 256)
        let a = GeneralizedPrimeFieldElement.fromValue(BigNumber(ar.serialize())!, field: secp256k1PrimeField)
        let aMont = GeneralizedPrimeFieldElement.fromValue(BigNumber(ar.serialize())!, field: secp256k1PrimeFieldMont)
        //                let br = BigUInt.randomInteger(lessThan: secp256k1PrimeBUI)
        let br = BigUInt.randomInteger(withExactWidth: 64)
        var bnResult = (ar * ar) % bnPrime
        let b = U256(br.serialize())!
        let expectedReduction = ((BigUInt(1) << 256) * ar) % bnPrime
        XCTAssert(expectedReduction == BigUInt(aMont.rawValue.bytes))
        var trivial = a * a
        var mont = aMont * aMont
        XCTAssert(bnResult == trivial.value)
        XCTAssert(trivial.value == mont.value)
        
        bnResult = ar.power(br, modulus: bnPrime)
        trivial = a.pow(b)
        mont = aMont.pow(b)
        XCTAssert(bnResult == trivial.value)
        XCTAssert(trivial.value == mont.value)
    }
    
    
    func testPointMulPerformanceDoubleAndAdd() {
        let secp256k1PrimeBUI = BigUInt("fffffffffffffffffffffffffffffffffffffffffffffffffffffffefffffc2f", radix: 16)!
        let secp256k1PrimeField = GeneralizedMontPrimeField<U256>.init(secp256k1PrimeBUI)
        //        let secp256k1PrimeField = GeneralizedNaivePrimeField<U256>.init(secp256k1PrimeBUI)
        let secp256k1CurveOrderBUI = BigUInt("fffffffffffffffffffffffffffffffebaaedce6af48a03bbfd25e8cd0364141", radix: 16)!
        let secp256k1CurveOrder = U256(secp256k1CurveOrderBUI.serialize())!
        let secp256k1WeierstrassCurve = GeneralizedWeierstrassCurve(field: secp256k1PrimeField, order: secp256k1CurveOrder, A: U256(0), B: U256(7))
        let generatorX = BigUInt("79BE667EF9DCBBAC55A06295CE870B07029BFCDB2DCE28D959F2815B16F81798", radix: 16)!
        let generatorY = BigUInt("483ADA7726A3C4655DA4FBFC0E1108A8FD17B448A68554199C47D08FFB10D4B8", radix: 16)!
        let success = secp256k1WeierstrassCurve.testGenerator(AffineCoordinates(generatorX, generatorY))
        XCTAssert(success, "Failed to init secp256k1 curve!")
        
        let scalar = BigUInt("e853ff4cc88e32bc6c2b74ffaca14a7e4b118686e77eefb086cb0ae298811127", radix: 16)!
        let c = secp256k1WeierstrassCurve
        let p = c.toPoint(BigUInt("5cfdf0eaa22d4d954067ab6f348e400f97357e2703821195131bfe78f7c92b38", radix: 16)!, BigUInt("584171d79868d22fae4442faede6d2c4972a35d1699453254d1b0df029225032", radix: 16)!)
        XCTAssert(p != nil)
        measure {
            let _ = c.doubleAndAddMul(U256(scalar.serialize())! , p!)
        }
    }
    
    func testPointMulPerformanceWNAF() {
        let secp256k1PrimeBUI = BigUInt("fffffffffffffffffffffffffffffffffffffffffffffffffffffffefffffc2f", radix: 16)!
        let secp256k1PrimeField = GeneralizedMontPrimeField<U256>.init(secp256k1PrimeBUI)
        //        let secp256k1PrimeField = GeneralizedNaivePrimeField<U256>.init(secp256k1PrimeBUI)
        let secp256k1CurveOrderBUI = BigUInt("fffffffffffffffffffffffffffffffebaaedce6af48a03bbfd25e8cd0364141", radix: 16)!
        let secp256k1CurveOrder = U256(secp256k1CurveOrderBUI.serialize())!
        let secp256k1WeierstrassCurve = GeneralizedWeierstrassCurve(field: secp256k1PrimeField, order: secp256k1CurveOrder, A: U256(0), B: U256(7))
        let generatorX = BigUInt("79BE667EF9DCBBAC55A06295CE870B07029BFCDB2DCE28D959F2815B16F81798", radix: 16)!
        let generatorY = BigUInt("483ADA7726A3C4655DA4FBFC0E1108A8FD17B448A68554199C47D08FFB10D4B8", radix: 16)!
        let success = secp256k1WeierstrassCurve.testGenerator(AffineCoordinates(generatorX, generatorY))
        XCTAssert(success, "Failed to init secp256k1 curve!")
        
        let scalar = BigUInt("e853ff4cc88e32bc6c2b74ffaca14a7e4b118686e77eefb086cb0ae298811127", radix: 16)!
        let c = secp256k1WeierstrassCurve
        let p = c.toPoint(BigUInt("5cfdf0eaa22d4d954067ab6f348e400f97357e2703821195131bfe78f7c92b38", radix: 16)!, BigUInt("584171d79868d22fae4442faede6d2c4972a35d1699453254d1b0df029225032", radix: 16)!)
        XCTAssert(p != nil)
        measure {
            let _ = c.wNAFmul(U256(scalar.serialize())! , p!)
        }
    }
}
