//
//  GeneralPrimeField.swift
//  EllipticSwift
//
//  Created by Alexander Vlasov on 13.07.2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import Foundation
import BigInt

public enum GeneralPrimeField {
    case bigIntBased(NaivePrimeField)
    case nativeU256(NativeNaivePrimeField<U256>)
    
    public var modulus: BigNumber {
        switch self {
        case .bigIntBased(let field):
            let bn = BigNumber(field.prime.serialize())
            precondition(bn != nil)
            return bn!
        case .nativeU256(let field):
            return BigNumber.acceleratedU256(field.prime)
        }
    }
    
    public init(_ p: BigUInt) {
        let naiveField = NativeNaivePrimeField<U256>(p)
        self = GeneralPrimeField.nativeU256(naiveField)
    }
    
    public init(_ p: BigNumber) {
        switch p {
        case .acceleratedU256(let u256):
            let naiveField = NativeNaivePrimeField<U256>(u256)
            self = GeneralPrimeField.nativeU256(naiveField)
        }
    }
    
    public func isEqualTo(_ other: GeneralPrimeField) -> Bool {
        switch self {
        case .bigIntBased(let thisField):
            guard case .bigIntBased(let otherField) = other else {
                return false
            }
            return thisField.modulus == otherField.modulus
        case .nativeU256(let thisField):
            guard case .nativeU256(let otherField) = other else {
                return false
            }
            return thisField.modulus == otherField.modulus
        }
    }
    
//    public func add(_ a: GeneralPrimeFieldElement, _ b: GeneralPrimeFieldElement) -> GeneralPrimeFieldElement {
//        switch self {
//        case .bigIntBased(let field):
//            return field.add(a, b)
//        case .nativeU256(let field):
//            return field.add(a, b)
//        }
//    }
//
//    public func sub(_ a: PrimeFieldElement, _ b: PrimeFieldElement) -> PrimeFieldElement {
//        switch self {
//        case .naive(let field):
//            return field.sub(a, b)
//        case .montgommery(let field):
//            return field.sub(a, b)
//        }
//    }
//
//    public func mul(_ a: PrimeFieldElement, _ b: PrimeFieldElement) -> PrimeFieldElement {
//        switch self {
//        case .naive(let field):
//            return field.mul(a, b)
//        case .montgommery(let field):
//            return field.mul(a, b)
//        }
//    }
//
//
//    public func neg(_ a: PrimeFieldElement) -> PrimeFieldElement {
//        switch self {
//        case .naive(let field):
//            return field.neg(a)
//        case .montgommery(let field):
//            return field.neg(a)
//        }
//    }
//
//    public func div(_ a: PrimeFieldElement, _ b: PrimeFieldElement) -> PrimeFieldElement {
//        switch self {
//        case .naive(let field):
//            return field.div(a, b)
//        case .montgommery(let field):
//            return field.div(a, b)
//        }
//    }
//
//    public func inv(_ a: PrimeFieldElement) -> PrimeFieldElement {
//        switch self {
//        case .naive(let field):
//            return field.inv(a)
//        case .montgommery(let field):
//            return field.inv(a)
//        }
//    }
//
    public func pow(_ a: GeneralPrimeFieldElement, _ b: BigNumber) -> GeneralPrimeFieldElement {
        switch self {
        case .bigIntBased(let field):
            guard case .bigIntBased(let el) = a else {
                precondition(false)
                return self.identityElement
            }
            return GeneralPrimeFieldElement.bigIntBased(field.pow(el, BigUInt(b.bytes)))
        case .nativeU256(let field):
            guard case .nativeU256(let el) = a else {
                precondition(false)
                return self.identityElement
            }
            guard case .acceleratedU256(let b256) = b else {
                precondition(false)
                return self.identityElement
            }
            return GeneralPrimeFieldElement.nativeU256(field.pow(el, b256))
        }
    }
//
//    public func sqrt(_ a: PrimeFieldElement) -> PrimeFieldElement {
//        switch self {
//        case .naive(let field):
//            return field.sqrt(a)
//        case .montgommery(let field):
//            return field.sqrt(a)
//        }
//    }
    
    public func fromValue(_ a: BigUInt) -> GeneralPrimeFieldElement {
        switch self {
        case .bigIntBased(let field):
            return GeneralPrimeFieldElement.bigIntBased(field.fromValue(a))
        case .nativeU256(let field):
            let bn = BigNumber(a.serialize())
            precondition(bn != nil)
            return GeneralPrimeFieldElement.nativeU256(field.fromValue(bn!))
        }
    }
    
    public func fromValue(_ a: BigNumber) -> GeneralPrimeFieldElement {
        switch self {
        case .bigIntBased(let field):
            return GeneralPrimeFieldElement.bigIntBased(field.fromValue(BigUInt(a.bytes)))
        case .nativeU256(let field):
            return GeneralPrimeFieldElement.nativeU256(field.fromValue(a))
        }
    }
    
    public func toValue(_ a: GeneralPrimeFieldElement) -> BigUInt {
        switch self {
        case .bigIntBased(_):
            guard case .bigIntBased(let el) = a else {
                precondition(false)
                return 0
            }
            return el.value
        case .nativeU256(_):
            guard case .nativeU256(let el) = a else {
                precondition(false)
                return 0
            }
            return el.value
        }
    }
    
    public var identityElement: GeneralPrimeFieldElement {
        switch self {
        case .bigIntBased(let field):
            return GeneralPrimeFieldElement.bigIntBased(field.identityElement)
        case .nativeU256(let field):
            return GeneralPrimeFieldElement.nativeU256(field.identityElement)
        }
    }
    
    public var zeroElement: GeneralPrimeFieldElement {
        switch self {
        case .bigIntBased(let field):
            return GeneralPrimeFieldElement.bigIntBased(field.zeroElement)
        case .nativeU256(let field):
            return GeneralPrimeFieldElement.nativeU256(field.zeroElement)
        }
    }
}
