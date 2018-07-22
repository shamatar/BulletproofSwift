//
//  GeneralPrimeFieldElement.swift
//  EllipticSwift
//
//  Created by Alexander Vlasov on 13.07.2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import Foundation

public enum GeneralPrimeFieldElement {
    case bigIntBased(PrimeFieldElement)
    case nativeU256(NativePrimeFieldElement<U256>)
}

import BigInt

extension GeneralPrimeFieldElement: Equatable {
    public static func == (lhs: GeneralPrimeFieldElement, rhs: GeneralPrimeFieldElement) -> Bool {
        switch lhs {
        case .bigIntBased(let lfe):
            switch rhs {
            case .bigIntBased(let rfe):
                return lfe.isEqualTo(rfe)
            case .nativeU256(let rfe):
                return lfe.value == rfe.value
            }
        case .nativeU256(let lfe):
            switch rhs {
            case .bigIntBased(let rfe):
                return lfe.value == rfe.value
            case .nativeU256(let rfe):
                return lfe.isEqualTo(rfe)
            }
        }
    }
    
    public static func + (lhs: GeneralPrimeFieldElement, rhs: GeneralPrimeFieldElement) -> GeneralPrimeFieldElement {
        switch lhs {
        case .bigIntBased(let lfe):
            switch rhs {
            case .bigIntBased(let rfe):
                return GeneralPrimeFieldElement.bigIntBased(lfe.field.add(lfe, rfe))
            case .nativeU256(_):
                precondition(false)
            }
        case .nativeU256(let lfe):
            switch rhs {
            case .bigIntBased(_):
                precondition(false)
            case .nativeU256(let rfe):
                return GeneralPrimeFieldElement.nativeU256(lfe.field.add(lfe, rfe))
            }
        }
        precondition(false)
        let dummyF = NativeNaivePrimeField<U256>(U256(integerLiteral: 1))
        let el = dummyF.zeroElement
        return GeneralPrimeFieldElement.nativeU256(el)
    }
    
    public static func - (lhs: GeneralPrimeFieldElement, rhs: GeneralPrimeFieldElement) -> GeneralPrimeFieldElement {
        switch lhs {
        case .bigIntBased(let lfe):
            switch rhs {
            case .bigIntBased(let rfe):
                return GeneralPrimeFieldElement.bigIntBased(lfe.field.sub(lfe, rfe))
            case .nativeU256(_):
                precondition(false)
            }
        case .nativeU256(let lfe):
            switch rhs {
            case .bigIntBased(_):
                precondition(false)
            case .nativeU256(let rfe):
                return GeneralPrimeFieldElement.nativeU256(lfe.field.sub(lfe, rfe))
            }
        }
        precondition(false)
        let dummyF = NativeNaivePrimeField<U256>(U256(integerLiteral: 1))
        let el = dummyF.zeroElement
        return GeneralPrimeFieldElement.nativeU256(el)
    }
    
    public static func * (lhs: GeneralPrimeFieldElement, rhs: GeneralPrimeFieldElement) -> GeneralPrimeFieldElement {
//        precondition(lhs.field.isEqualTo(rhs.field))
//        precondition(lhs.field.isEqualTo(rhs.field))
        switch lhs {
        case .bigIntBased(let lfe):
            switch rhs {
            case .bigIntBased(let rfe):
                return GeneralPrimeFieldElement.bigIntBased(lfe.field.mul(lfe, rfe))
            case .nativeU256(_):
                precondition(false)
            }
        case .nativeU256(let lfe):
            switch rhs {
            case .bigIntBased(_):
                precondition(false)
            case .nativeU256(let rfe):
                return GeneralPrimeFieldElement.nativeU256(lfe.field.mul(lfe, rfe))
            }
        }
        precondition(false)
        let dummyF = NativeNaivePrimeField<U256>(U256(integerLiteral: 1))
        let el = dummyF.zeroElement
        return GeneralPrimeFieldElement.nativeU256(el)
    }
    
    public static func * (lhs: BigNumber, rhs: GeneralPrimeFieldElement) -> GeneralPrimeFieldElement {
        switch rhs {
        case .bigIntBased(let rfe):
            let field = rfe.field
            let bn = BigUInt(lhs.bytes)
            return GeneralPrimeFieldElement.bigIntBased(field.mul(field.fromValue(bn), rfe))
        case .nativeU256(let rfe):
            let field = rfe.field
            return GeneralPrimeFieldElement.nativeU256(field.mul(field.fromValue(lhs), rfe))
        }
    }
    
    public static func + (lhs: BigUInt, rhs: GeneralPrimeFieldElement) -> GeneralPrimeFieldElement {
        switch rhs {
        case .bigIntBased(let rfe):
            let field = rfe.field
            return GeneralPrimeFieldElement.bigIntBased(field.add(field.fromValue(lhs), rfe))
        case .nativeU256(let rfe):
            let field = rfe.field
            let bn = BigNumber(lhs.serialize())
            precondition(bn != nil)
            return GeneralPrimeFieldElement.nativeU256(field.add(field.fromValue(bn!), rfe))
        }
    }
    
    public static func + (lhs: BigNumber, rhs: GeneralPrimeFieldElement) -> GeneralPrimeFieldElement {
        switch rhs {
        case .bigIntBased(let rfe):
            let field = rfe.field
            let bn = BigUInt(lhs.bytes)
            return GeneralPrimeFieldElement.bigIntBased(field.add(field.fromValue(bn), rfe))
        case .nativeU256(let rfe):
            let field = rfe.field
            return GeneralPrimeFieldElement.nativeU256(field.add(field.fromValue(lhs), rfe))
        }
    }
    
    public func mod(_ q: BigUInt) -> GeneralPrimeFieldElement {
        switch self {
        case .bigIntBased(let lfe):
            if q == lfe.field.modulus {
                return self
            }
            let newField = PrimeField(q)
            return GeneralPrimeFieldElement.bigIntBased(newField.fromValue(lfe.value))
        case .nativeU256(let lfe):
            if q == lfe.field.modulus {
                return self
            }
            let newField = NativeNaivePrimeField<U256>(q)
            let bn = BigNumber.acceleratedU256(lfe.rawValue)
            return GeneralPrimeFieldElement.nativeU256(newField.fromValue(bn))
        }
    }
    
    public func mod(_ q: BigUInt) -> BigUInt {
        switch self {
        case .bigIntBased(let lfe):
            if q == lfe.field.modulus {
                return lfe.value
            }
            return lfe.value % q
        case .nativeU256(let lfe):
            if q == lfe.field.modulus {
                return lfe.value
            }
            return lfe.value % q
        }
    }
    
    public func mod(_ q: BigNumber) -> BigNumber {
        switch self {
        case .bigIntBased(_):
            precondition(false)
            return BigNumber(integerLiteral: 0)
        case .nativeU256(let lfe):
            switch q {
            case .acceleratedU256(let q256):
                if q256 == lfe.field.prime {
                    return BigNumber.acceleratedU256(lfe.rawValue)
                }
                return BigNumber.acceleratedU256(lfe.rawValue).mod(q)
            }
        }
    }
    
    public func inv(_ q: BigUInt) -> GeneralPrimeFieldElement {
        switch self {
        case .bigIntBased(let lfe):
            if q == lfe.field.modulus {
                return GeneralPrimeFieldElement.bigIntBased(lfe.field.inv(lfe))
            }
            let newField = PrimeField(q)
            return GeneralPrimeFieldElement.bigIntBased(newField.inv(newField.fromValue(lfe.value)))
        case .nativeU256(let lfe):
            if q == lfe.field.modulus {
                return GeneralPrimeFieldElement.nativeU256(lfe.field.inv(lfe))
            }
            let newField = NativeNaivePrimeField<U256>(q)
            let bn = BigNumber.acceleratedU256(lfe.rawValue)
            return GeneralPrimeFieldElement.nativeU256(newField.inv(newField.fromValue(bn)))
        }
    }
    
    public func inv() -> GeneralPrimeFieldElement {
        switch self {
        case .bigIntBased(let lfe):
            return GeneralPrimeFieldElement.bigIntBased(lfe.field.inv(lfe))
        case .nativeU256(let lfe):
            return GeneralPrimeFieldElement.nativeU256(lfe.field.inv(lfe))
        }
    }
    
    public func sqrt() -> GeneralPrimeFieldElement {
        switch self {
        case .bigIntBased(let lfe):
            return GeneralPrimeFieldElement.bigIntBased(lfe.field.sqrt(lfe))
        case .nativeU256(let lfe):
            return GeneralPrimeFieldElement.nativeU256(lfe.field.sqrt(lfe))
        }
    }
    
    public func negate() -> GeneralPrimeFieldElement {
        switch self {
        case .bigIntBased(let lfe):
            return GeneralPrimeFieldElement.bigIntBased(lfe.field.neg(lfe))
        case .nativeU256(let lfe):
            return GeneralPrimeFieldElement.nativeU256(lfe.field.neg(lfe))
        }
    }
    
    public var value: BigNumber {
        switch self {
        case .bigIntBased(let lfe):
            let val = BigNumber(lfe.rawValue.serialize())
            precondition(val != nil)
            return val!
        case .nativeU256(let lfe):
            return BigNumber.acceleratedU256(lfe.rawValue)
        }
    }
    
    public var isZero: Bool {
        switch self {
        case .bigIntBased(let lfe):
            return lfe.value == 0
        case .nativeU256(let lfe):
            return lfe.rawValue.isZero
        }
    }
    
    public var field: GeneralPrimeField {
        switch self {
        case .bigIntBased(let lfe):
            switch lfe.field{
            case .naive(let f):
                return GeneralPrimeField.bigIntBased(f)
            default:
                return GeneralPrimeField(lfe.field.modulus)
            }
        case .nativeU256(let lfe):
            return GeneralPrimeField.nativeU256(lfe.field)
        }
    }
}
