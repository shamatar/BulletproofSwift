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

    func testInitU256() {
        let bytes = BigUInt.randomInteger(withExactWidth: 256).serialize()
        print(bytes.toHexString())
        let bn = BigNumber(bytes)
        XCTAssert(bn != nil)
        let bnBytes = bn?.bytes
        print(bnBytes?.toHexString())
        XCTAssert(bnBytes == bnBytes)
    }
    
    func testAddU256() {
        let bn1 = BigNumber(BigUInt(1).serialize())
        let bn2 = BigNumber(BigUInt(2).serialize())
        let bnBytes1 = bn1!.bytes
        let bnBytes2 = bn1!.bytes
        print(bnBytes1.toHexString())
        print(bnBytes2.toHexString())
        guard case .u256(let raw1) = bn1! else {return XCTFail()}
        guard case .u256(let raw2) = bn2! else {return XCTFail()}
        let sum = raw1.addMod(raw2)
        let wrapper = BigNumber.u256(sum)
        let bnBytes = wrapper.bytes
        print(bnBytes.toHexString() == "0000000000000000000000000000000000000000000000000000000000000003")
    }
    
    func testCompareU256() {
        let bn1 = BigNumber(BigUInt(1).serialize())
        let bn2 = BigNumber(BigUInt(2).serialize())
        let bnBytes1 = bn1!.bytes
        let bnBytes2 = bn1!.bytes
        print(bnBytes1.toHexString())
        print(bnBytes2.toHexString())
        guard case .u256(let raw1) = bn1! else {return XCTFail()}
        guard case .u256(let raw2) = bn2! else {return XCTFail()}
        XCTAssert(raw1 < raw2)
    }
    
    func testCompareU256equal() {
        let bn1 = BigNumber(BigUInt(1).serialize())
        let bn2 = BigNumber(BigUInt(1).serialize())
        let bnBytes1 = bn1!.bytes
        let bnBytes2 = bn1!.bytes
        print(bnBytes1.toHexString())
        print(bnBytes2.toHexString())
        guard case .u256(let raw1) = bn1! else {return XCTFail()}
        guard case .u256(let raw2) = bn2! else {return XCTFail()}
        XCTAssert(raw1 == raw2)
    }
    
    func testCompareU512split() {
        let raw = U512(BigUInt(1).serialize())!
        print(raw.bytes.toHexString())
        let (top, bottom) = (raw as U512).split()
        let topBytes = top.bytes
        let bottomBytes = bottom.bytes
        print(topBytes.toHexString())
        print(bottomBytes.toHexString())
    }
    
    func testComparePerformance() {
        let modulus = EllipticSwift.bn256Prime
        let field = NaivePrimeField(modulus)!
        let num1 = BigUInt.randomInteger(lessThan: modulus)
        let num2 = BigUInt.randomInteger(lessThan: modulus)
        let reducedNum1 = field.fromValue(num1)
        let reducedNum2 = field.fromValue(num2)
        measure {
            let _ = reducedNum1 * reducedNum2
        }
    }
    
    func testComparePerformanceNative() {
        let modulus = EllipticSwift.bn256Prime
        let bnPrime = U256(modulus.serialize())!
        let num1 = BigUInt.randomInteger(lessThan: modulus)
        let num2 = BigUInt.randomInteger(lessThan: modulus)
        let nativeNum1 = U256(num1.serialize())!
        let nativeNum2 = U256(num2.serialize())!
        measure {
            let _ = nativeNum1.modMul(nativeNum2, bnPrime)
        }
    }
    
    func testModularSub() {
        let modulus = BigUInt(97)
        let field = NativeNaivePrimeField<U256>(modulus)
        let fe1 = field.fromValue(BigUInt(43))
        let fe2 = field.fromValue(BigUInt(56))
        let sub1 = field.sub(fe1, fe2)
        let sub2 = field.sub(fe2, fe1)
        XCTAssert(sub1.value == 84)
        XCTAssert(sub2.value == 13)
        XCTAssert(field.neg(sub1).isEqualTo(sub2))
    }
    
    func testModularNonoverflowingAdd() {
        let modulus = BigUInt(97)
        let field = NativeNaivePrimeField<U256>(modulus)
        let fe1 = field.fromValue(BigUInt(1))
        let fe2 = field.fromValue(BigUInt(2))
        let sum = field.add(fe1, fe2)
        XCTAssert(sum.value == 3)
    }
    
    func testModularOverflowingAdd() {
        let modulus = BigUInt(97)
        let field = NativeNaivePrimeField<U256>(modulus)
        let fe1 = field.fromValue(BigUInt(43))
        let fe2 = field.fromValue(BigUInt(56))
        let sum = field.add(fe1, fe2)
        XCTAssert(sum.value == 2)
    }
}
