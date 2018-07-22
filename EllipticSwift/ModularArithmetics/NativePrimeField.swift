//
//  NativePrimeField.swift
//  EllipticSwift
//
//  Created by Alexander Vlasov on 13.07.2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import Foundation
import Accelerate
import BigInt

//public enum NativePrimeField {
//    case u256(NativeNaivePrimeField<U256>)
//
//    public var modulus: BigUInt {
//        switch self {
//        case .u256(let field):
//            return field.modulus
//        }
//    }
//
//    public init(_ p: BigUInt) {
//        let naiveField = NativeNaivePrimeField<U256>(p)
//        self = NativePrimeField.u256(naiveField)
//    }
//
//    public func isEqualTo(_ other: NativePrimeField) -> Bool {
//        switch self {
//        case .u256(let thisField):
//            guard case .u256(let otherField) = other else {
//                return false
//            }
//            return thisField.prime == otherField.prime
//        }
//    }
//
//    public func add(_ a: NativePrimeFieldElement, _ b: NativePrimeFieldElement) -> NativePrimeFieldElement {
//        switch self {
//        case .u256(let field):
//            return field.add(a, b)
//        }
//    }
//
//    public func sub(_ a: NativePrimeFieldElement, _ b: NativePrimeFieldElement) -> NativePrimeFieldElement {
//        switch self {
//        case .u256(let field):
//            return field.sub(a, b)
//        }
//    }
//
//    public func mul(_ a: NativePrimeFieldElement, _ b: NativePrimeFieldElement) -> NativePrimeFieldElement {
//        switch self {
//        case .u256(let field):
//            return field.mul(a, b)
//        }
//    }
//
//
//    public func neg<T>(_ a: NativePrimeFieldElement<T>) -> NativePrimeFieldElement<T> {
//        switch self {
//        case .u256(let field):
//            return field.neg(a)
//        }
//    }
//
//    public func div(_ a: NativePrimeFieldElement, _ b: NativePrimeFieldElement) -> NativePrimeFieldElement {
//        switch self {
//        case .u256(let field):
//            return field.add(a, b)
//        }
//    }
//
//    public func inv(_ a: NativePrimeFieldElement) -> NativePrimeFieldElement {
//        switch self {
//        case .u256(let field):
//            return field.add(a, b)
//        }
//    }
//
//    public func pow(_ a: NativePrimeFieldElement, _ b: BigUInt) -> NativePrimeFieldElement {
//        switch self {
//        case .u256(let field):
//            return field.add(a, b)
//        }
//    }
//
//    public func sqrt(_ a: NativePrimeFieldElement) -> NativePrimeFieldElement {
//        switch self {
//        case .u256(let field):
//            return field.add(a, b)
//        }
//    }
//
//    public func fromValue(_ a: BigUInt) -> NativePrimeFieldElement {
//        switch self {
//        case .u256(let field):
//            return field.add(a, b)
//        }
//    }
//
//    public func toValue(_ a: NativePrimeFieldElement) -> BigUInt {
//        switch self {
//        case .u256(let field):
//            return field.add(a, b)
//        }
//    }
//
//    public var identityElement: NativePrimeFieldElement {
//        switch self {
//        case .u256(let field):
//            return field.add(a, b)
//        }
//    }
//
//    public var zeroElement: NativePrimeFieldElement {
//        switch self {
//        case .u256(let field):
//            return field.add(a, b)
//        }
//    }
//}
