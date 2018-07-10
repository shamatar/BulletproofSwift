//
//  FieldElement.swift
//  EllipticSwift
//
//  Created by Alexander Vlasov on 07.07.2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import Foundation
import BigInt

public struct PrimeFieldElement {
    
    internal var rawValue: BigUInt
    
    public var isNull: Bool {
        return false
    }
    
    public func isEqualTo(_ other: PrimeFieldElement) -> Bool {
        if !self.field.isEqualTo(other.field) {
            return false
        }
        if self.rawValue != other.rawValue {
            return false
        }
        return true
    }
    
    public var value: BigUInt  {
        get {
            return self.field.toValue(self)
        }
    }

    public var field: PrimeField
    
    internal init(_ rawValue: BigUInt, _ field: PrimeField) {
        self.rawValue = rawValue
        self.field = field
    }
}
