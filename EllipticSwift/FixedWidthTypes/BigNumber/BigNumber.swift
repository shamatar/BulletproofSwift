//
//  BigNumber.swift
//  EllipticSwift
//
//  Created by Alexander Vlasov on 20.07.2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import Foundation

public enum BigNumber {
    case acceleratedU256(U256)
}

extension BigNumber: BytesInitializable {
    public init?(_ bytes: Data) {
        guard let u256 = U256(bytes) else {return nil}
        self = BigNumber.acceleratedU256(u256)
    }
}

extension BigNumber: BitsAndBytes {
    public var bytes: Data {
        switch self {
        case .acceleratedU256(let u256):
            return u256.bytes
        }
    }
    
    public func bit(_ i: Int) -> Bool {
        switch self {
        case .acceleratedU256(let u256):
            return u256.bit(i)
        }
    }
    
    public var bitWidth: Int {
        switch self {
        case .acceleratedU256(let u256):
            return u256.bitWidth
        }
    }
    
    public var isZero: Bool {
        switch self {
        case .acceleratedU256(let u256):
            return u256.isZero
        }
    }
}

extension BigNumber: EvenOrOdd {
    public var isEven: Bool {
        switch self {
        case .acceleratedU256(let u256):
            return u256.isEven
        }
    }
}

extension BigNumber {
    public init(_ i: Int) {
        let u256 = U256(integerLiteral: UInt64(i))
        self = BigNumber.acceleratedU256(u256)
    }
}

extension BigNumber: ModReducable {
    public func modMultiply(_ a: BigNumber, _ modulus: BigNumber) -> BigNumber {
        switch self {
        case .acceleratedU256(let u256):
            let aCopy = U256(a.bytes)
            let modulusCopy = U256(modulus.bytes)
            precondition(aCopy != nil)
            precondition(modulusCopy != nil)
            let res = u256.modMultiply(aCopy!, modulusCopy!)
            return BigNumber.acceleratedU256(res)
        }
    }
    
    public func mod(_ modulus: BigNumber) -> BigNumber {
        switch self {
        case .acceleratedU256(let u256):
            let modulusCopy = U256(modulus.bytes)
            precondition(modulusCopy != nil)
            let res = u256.mod(modulusCopy!)
            return BigNumber.acceleratedU256(res)
        }
    }
    
    public func modInv(_ modulus: BigNumber) -> BigNumber {
        switch self {
        case .acceleratedU256(let u256):
            let modulusCopy = U256(modulus.bytes)
            precondition(modulusCopy != nil)
            let res = u256.modInv(modulusCopy!)
            return BigNumber.acceleratedU256(res)
        }
    }
    
    public func div(_ a: BigNumber) -> (BigNumber, BigNumber) {
        switch self {
        case .acceleratedU256(let u256):
            let aCopy = U256(a.bytes)
            precondition(aCopy != nil)
            let (q, r) = u256.div(aCopy!)
            return (BigNumber.acceleratedU256(q), BigNumber.acceleratedU256(r))
        }
    }
    
    public func fullMultiply(_ a: BigNumber) -> (BigNumber, BigNumber) {
        switch self {
        case .acceleratedU256(let u256):
            let aCopy = U256(a.bytes)
            precondition(aCopy != nil)
            let (q, r) = u256.fullMultiply(aCopy!)
            return (BigNumber.acceleratedU256(q), BigNumber.acceleratedU256(r))
        }
    }
//    
//    public func modAdd(_ a: BigNumber, _ modulus: BigNumber) -> BigNumber {
//        switch self {
//            case .acceleratedU256(let u256):
//            let aCopy = U256(a.bytes)
//            let modulusCopy = U256(modulus.bytes)
//            precondition(aCopy != nil)
//            precondition(modulusCopy != nil)
//            let res = u256.modAdd(aCopy!, modulusCopy!)
//            return BigNumber.acceleratedU256(res)
//        }
//    }
    
}

extension BigNumber: Comparable {
    public static func < (lhs: BigNumber, rhs: BigNumber) -> Bool {
        switch lhs {
        case .acceleratedU256(let u256):
            switch rhs {
            case .acceleratedU256(let otherU256):
                return u256 < otherU256
            }
        }
    }
    
    public static func == (lhs: BigNumber, rhs: BigNumber) -> Bool {
        switch lhs {
        case .acceleratedU256(let u256):
            switch rhs {
            case .acceleratedU256(let otherU256):
                return u256 == otherU256
            }
        }
    }
}

extension BigNumber: Numeric {
    public static func -= (lhs: inout BigNumber, rhs: BigNumber) {
        switch lhs {
        case .acceleratedU256(let u256):
            switch rhs {
            case .acceleratedU256(let otherU256):
                return lhs = BigNumber.acceleratedU256(u256 - otherU256)
            }
        }
    }
    
    public static func - (lhs: BigNumber, rhs: BigNumber) -> BigNumber {
        switch lhs {
        case .acceleratedU256(let u256):
            switch rhs {
            case .acceleratedU256(let otherU256):
                return BigNumber.acceleratedU256(u256 - otherU256)
            }
        }
//        return BigNumber(integerLiteral: 0)
    }
    
    public static func += (lhs: inout BigNumber, rhs: BigNumber) {
        switch lhs {
        case .acceleratedU256(let u256):
            switch rhs {
            case .acceleratedU256(let otherU256):
                return lhs = BigNumber.acceleratedU256(u256 + otherU256)
            }
        }
    }
    
    public static func + (lhs: BigNumber, rhs: BigNumber) -> BigNumber {
        switch lhs {
        case .acceleratedU256(let u256):
            switch rhs {
            case .acceleratedU256(let otherU256):
                return BigNumber.acceleratedU256(u256 + otherU256)
            }
        }
//        return BigNumber(integerLiteral: 0)
    }
    
    public init?<T>(exactly source: T) where T : BinaryInteger {
        guard let u256 = U256(exactly: source) else {return nil}
        self = BigNumber.acceleratedU256(u256)
    }
    
    public var magnitude: BigNumber {
        return self
    }
    
    public static func * (lhs: BigNumber, rhs: BigNumber) -> BigNumber {
        switch lhs {
        case .acceleratedU256(let u256):
            switch rhs {
            case .acceleratedU256(let otherU256):
                return BigNumber.acceleratedU256(u256 * otherU256)
            }
        }
//        return BigNumber(integerLiteral: 0)
    }
    
    public static func *= (lhs: inout BigNumber, rhs: BigNumber) {
        switch lhs {
        case .acceleratedU256(let u256):
            switch rhs {
            case .acceleratedU256(let otherU256):
                return lhs = BigNumber.acceleratedU256(u256 * otherU256)
            }
        }
    }
    
    public init(integerLiteral value: UInt64) {
        let u256 = U256(integerLiteral: U256.IntegerLiteralType(value))
        self = BigNumber.acceleratedU256(u256)
    }
    
    public typealias Magnitude = BigNumber
    
    public typealias IntegerLiteralType = UInt64
    
    
}

extension BigNumber: BitShiftable {
    public static func << (lhs: BigNumber, rhs: UInt32) -> BigNumber {
        switch lhs {
        case .acceleratedU256(let u256):
            return BigNumber.acceleratedU256(u256 << rhs)
        }
    }
    
    public static func >> (lhs: BigNumber, rhs: UInt32) -> BigNumber {
        switch lhs {
        case .acceleratedU256(let u256):
            return BigNumber.acceleratedU256(u256 >> rhs)
        }
    }
    
    
}


