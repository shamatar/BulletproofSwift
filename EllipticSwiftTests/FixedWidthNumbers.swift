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
}
