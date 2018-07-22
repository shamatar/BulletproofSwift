//
//  NativePrimeFieldElement.swift
//  EllipticSwift
//
//  Created by Alexander Vlasov on 13.07.2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import Foundation
import BigInt

public struct NativePrimeFieldElement<T> where T: FiniteFieldCompatible {
    
    internal var rawValue: T
    
    public var isNull: Bool {
        return false
    }
    
    public func isEqualTo(_ other: NativePrimeFieldElement) -> Bool {
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
    
    public var field: NativeNaivePrimeField<T>
    
    internal init(_ bigUInt: BigUInt, _ field: NativeNaivePrimeField<T>) {
        let native: T? = T.init(bigUInt.serialize())
        precondition(native != nil)
        self.rawValue = native!
        self.field = field
    }
    
    internal init(_ rawValue: T, _ field: NativeNaivePrimeField<T>) {
        self.rawValue = rawValue
        self.field = field
    }
}
