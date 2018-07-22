//
//  PrimeField.swift
//  EllipticSwift
//
//  Created by Alexander Vlasov on 12.07.2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import Foundation
import BigInt

public enum PrimeField {
    case naive(NaivePrimeField)
    case montgommery(MontPrimeField)
    // barret
    // 2^n - x special case
        
    public var modulus: BigUInt {
        switch self {
        case .naive(let field):
            return field.modulus
        case .montgommery(let field):
            return field.modulus
        }
    }
    
    public init(_ p: BigUInt) {
        let naiveField = NaivePrimeField(p)
        precondition(naiveField != nil)
        self = PrimeField.naive(naiveField!)        
    }
    
    public func isEqualTo(_ other: PrimeField) -> Bool {
        switch self {
        case .naive(let thisField):
            guard case .naive(let otherField) = other else {
                return false
            }
            return thisField.modulus == otherField.modulus
        case .montgommery(let thisField):
            guard case .naive(let otherField) = other else {
                return false
            }
            return thisField.modulus == otherField.modulus
        }
    }
    
    public func add(_ a: PrimeFieldElement, _ b: PrimeFieldElement) -> PrimeFieldElement {
        switch self {
        case .naive(let field):
            return field.add(a, b)
        case .montgommery(let field):
            return field.add(a, b)
        }
    }
    
    public func sub(_ a: PrimeFieldElement, _ b: PrimeFieldElement) -> PrimeFieldElement {
        switch self {
        case .naive(let field):
            return field.sub(a, b)
        case .montgommery(let field):
            return field.sub(a, b)
        }
    }
    
    public func mul(_ a: PrimeFieldElement, _ b: PrimeFieldElement) -> PrimeFieldElement {
        switch self {
        case .naive(let field):
            return field.mul(a, b)
        case .montgommery(let field):
            return field.mul(a, b)
        }
    }
    
    
    public func neg(_ a: PrimeFieldElement) -> PrimeFieldElement {
        switch self {
        case .naive(let field):
            return field.neg(a)
        case .montgommery(let field):
            return field.neg(a)
        }
    }
    
    public func div(_ a: PrimeFieldElement, _ b: PrimeFieldElement) -> PrimeFieldElement {
        switch self {
        case .naive(let field):
            return field.div(a, b)
        case .montgommery(let field):
            return field.div(a, b)
        }
    }
    
    public func inv(_ a: PrimeFieldElement) -> PrimeFieldElement {
        switch self {
        case .naive(let field):
            return field.inv(a)
        case .montgommery(let field):
            return field.inv(a)
        }
    }
    
    public func pow(_ a: PrimeFieldElement, _ b: BigUInt) -> PrimeFieldElement {
        switch self {
        case .naive(let field):
            return field.pow(a, b)
        case .montgommery(let field):
            return field.pow(a, b)
        }
    }
    
    public func sqrt(_ a: PrimeFieldElement) -> PrimeFieldElement {
        switch self {
        case .naive(let field):
            return field.sqrt(a)
        case .montgommery(let field):
            return field.sqrt(a)
        }
    }
    
    public func fromValue(_ a: BigUInt) -> PrimeFieldElement {
        switch self {
        case .naive(let field):
            return field.fromValue(a)
        case .montgommery(let field):
            return field.fromValue(a)
        }
    }
    
    public func toValue(_ a: PrimeFieldElement) -> BigUInt {
        switch self {
        case .naive(let field):
            return field.toValue(a)
        case .montgommery(let field):
            return field.toValue(a)
        }
    }
    
    public var identityElement: PrimeFieldElement {
        switch self {
        case .naive(let field):
            return field.identityElement
        case .montgommery(let field):
            return field.identityElement
        }
    }
    
    public var zeroElement: PrimeFieldElement {
        switch self {
        case .naive(let field):
            return field.zeroElement
        case .montgommery(let field):
            return field.zeroElement
        }
    }
}

