//
//  NativeMontPrimeFieldElement.swift
//  EllipticSwift
//
//  Created by Alexander Vlasov on 30.07.2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import Foundation
import BigInt

public struct NativeMontPrimeFieldElement<T> where T: FiniteFieldCompatible, T: MontArithmeticsCompatible {
    
    internal var rawValue: T
    
    public var isNull: Bool {
        return false
    }
    
    public func isEqualTo(_ other: NativeMontPrimeFieldElement) -> Bool {
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
    
    public var field: NativeMontPrimeField<T>
    
    internal init(_ bigUInt: BigUInt, _ field: NativeMontPrimeField<T>) {
        let native: T? = T.init(bigUInt.serialize())
        precondition(native != nil)
        self.rawValue = native!
        self.field = field
    }
    
    internal init(_ rawValue: T, _ field: NativeMontPrimeField<T>) {
        self.rawValue = rawValue
        self.field = field
    }
}

