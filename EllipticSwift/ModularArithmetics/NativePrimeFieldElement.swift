//
//  NativePrimeFieldElement.swift
//  EllipticSwift
//
//  Created by Alexander Vlasov on 13.07.2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import Foundation
import BigInt

public typealias NativePrimeField = NativeNaivePrimeField

public struct NativePrimeFieldElement<T> where T: Numeric, T: BytesInitializable, T: BytesRepresentable, T: Comparable, T: ModReducable {
    
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
    
    public var field: NativePrimeField<T>
    
    internal init(_ bigUInt: BigUInt, _ field: NativePrimeField<T>) {
        let native: T? = T.init(bigUInt.serialize())
        precondition(native != nil)
        self.rawValue = native!
        self.field = field
    }
    
    internal init(_ rawValue: T, _ field: NativePrimeField<T>) {
        self.rawValue = rawValue
        self.field = field
    }
}
