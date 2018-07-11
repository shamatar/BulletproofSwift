//
//  PrimeFieldElement+Operations.swift
//  EllipticSwift
//
//  Created by Alexander Vlasov on 11.07.2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import Foundation
import BigInt

extension PrimeFieldElement: Equatable {
    public static func == (lhs: PrimeFieldElement, rhs: PrimeFieldElement) -> Bool {
        return lhs.isEqualTo(rhs)
    }
    
    public static func + (lhs: PrimeFieldElement, rhs: PrimeFieldElement) -> PrimeFieldElement {
        precondition(lhs.field.isEqualTo(rhs.field))
        return lhs.field.add(lhs, rhs)
    }
    
    public static func - (lhs: PrimeFieldElement, rhs: PrimeFieldElement) -> PrimeFieldElement {
        precondition(lhs.field.isEqualTo(rhs.field))
        return lhs.field.sub(lhs, rhs)
    }
    
    public static func * (lhs: PrimeFieldElement, rhs: PrimeFieldElement) -> PrimeFieldElement {
        precondition(lhs.field.isEqualTo(rhs.field))
        precondition(lhs.field.isEqualTo(rhs.field))
        return rhs.field.mul(lhs, rhs)
    }
    
    public static func * (lhs: BigUInt, rhs: PrimeFieldElement) -> PrimeFieldElement {
        let field = rhs.field
        return field.mul(field.fromValue(lhs), rhs)
    }
    
    public static func + (lhs: BigUInt, rhs: PrimeFieldElement) -> PrimeFieldElement {
        let field = rhs.field
        return field.add(field.fromValue(lhs), rhs)
    }
    
    public func mod(_ q: BigUInt) -> PrimeFieldElement {
        if q == self.field.prime {
            return self
        }
        let newField = PrimeField(q)
        precondition(newField != nil)
        return newField!.fromValue(self.value)
    }
    
    public func mod(_ q: BigUInt) -> BigUInt {
        if q == self.field.prime {
            return self.value
        }
        return self.value % q
    }
    
    public func inv(_ q: BigUInt) -> PrimeFieldElement {
        if q == self.field.prime {
            return self.field.inv(self)
        }
        let newField = PrimeField(q)
        precondition(newField != nil)
        let newValue = newField!.fromValue(self.value)
        return newField!.inv(newValue)
    }
}
