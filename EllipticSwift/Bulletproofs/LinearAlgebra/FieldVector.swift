//
//  FieldVector.swift
//  EllipticSwift
//
//  Created by Alexander Vlasov on 11.07.2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import Foundation
import BigInt

public struct FieldVector {
    public var a: [GeneralPrimeFieldElement]
    public var q: BigNumber
    public var field: GeneralPrimeField
    
    public init (_ a: [BigNumber], _ q: BigNumber) {
        let field = GeneralPrimeField(q)
        self.field = field
        self.a = a.map({ (el) -> GeneralPrimeFieldElement in
            return field.fromValue(el)
        })
        self.q = q
    }
    
    public init (_ a: [BigNumber], _ field: GeneralPrimeField) {
        self.field = field
        self.a = a.map({ (el) -> GeneralPrimeFieldElement in
            return field.fromValue(el)
        })
        self.q = field.modulus
    }
    
    public init (_ a: [GeneralPrimeFieldElement], _ field: GeneralPrimeField) {
        self.field = field
        self.a = a
        self.q = field.modulus
    }
    
    
    public func innerPoduct(_ other: FieldVector) -> GeneralPrimeFieldElement {
        precondition(self.a.count == other.a.count)
        precondition(self.q == other.q)
        precondition(self.a.count > 0)
        var result = self.a[0] * other.a[0]
        for i in 1 ..< self.a.count {
            result = result + (self.a[i] * other.a[i])
        }
        return result
    }
    
    public func hadamardProduct(_ other: FieldVector) -> FieldVector {
        precondition(self.a.count == other.a.count)
        precondition(self.q == other.q)
        precondition(self.a.count > 0)
        var elements = [GeneralPrimeFieldElement]()
        for i in 0 ..< self.a.count {
            elements.append(self.a[i] * other.a[i])
        }
        return FieldVector(elements, self.field)
    }
    
    public func times(_ scalar: BigNumber) -> FieldVector {
        var elements = [GeneralPrimeFieldElement]()
        for i in 0 ..< self.a.count {
            elements.append(scalar * self.a[i])
        }
        return FieldVector(elements, self.field)
    }
    
    public func times(_ scalar: GeneralPrimeFieldElement) -> FieldVector {
        var elements = [GeneralPrimeFieldElement]()
        for i in 0 ..< self.a.count {
            elements.append(scalar * self.a[i])
        }
        return FieldVector(elements, self.field)
    }
    
    public func add(_ other: FieldVector) -> FieldVector {
        precondition(self.a.count == other.a.count)
        precondition(self.q == other.q)
        precondition(self.a.count > 0)
        var elements = [GeneralPrimeFieldElement]()
        for i in 0 ..< self.a.count {
            elements.append(self.a[i] + other.a[i])
        }
        return FieldVector(elements, self.field)
    }
    
    public func add(_ scalar: GeneralPrimeFieldElement) -> FieldVector {
        precondition(self.a.count > 0)
        var elements = [GeneralPrimeFieldElement]()
        for i in 0 ..< self.a.count {
            elements.append(self.a[i] + scalar)
        }
        return FieldVector(elements, self.field)
    }
    
    public func add(_ scalar: BigNumber) -> FieldVector {
        precondition(self.a.count > 0)
        var elements = [GeneralPrimeFieldElement]()
        for i in 0 ..< self.a.count {
            elements.append(scalar + self.a[i])
        }
        return FieldVector(elements, self.field)
    }
        
    public func sub(_ other: FieldVector) -> FieldVector {
        precondition(self.a.count == other.a.count)
        precondition(self.q == other.q)
        precondition(self.a.count > 0)
        var elements = [GeneralPrimeFieldElement]()
        for i in 0 ..< self.a.count {
            elements.append(self.a[i] - other.a[i])
        }
        return FieldVector(elements, self.field)
    }
    
    public func sum() -> GeneralPrimeFieldElement {
        precondition(self.a.count > 0)
        var result = self.a[0]
        for i in 1 ..< self.a.count {
            result = result + self.a[i]
        }
        return result
    }
    
    public func inv() -> FieldVector {
        precondition(self.a.count > 0)
        var elements = [GeneralPrimeFieldElement]()
        for i in 0 ..< self.a.count {
            let inverse = self.a[i].inv()
            elements.append(inverse)
        }
        return FieldVector(elements, self.field)
    }
    
    public var first: GeneralPrimeFieldElement? {
        return self.a.first
    }
    
    public func get(_ i: Int) -> GeneralPrimeFieldElement {
        return self.a[i]
    }
    
    public var size: Int {
        return self.a.count;
    }
    
    public func subvector(_ from: Int, _ noninclusiveTo: Int) -> FieldVector {
        precondition(self.a.count > 0)
        var elements = [GeneralPrimeFieldElement]()
        for i in from ..< noninclusiveTo {
            elements.append(self.a[i])
        }
        return FieldVector(elements, self.field)
    }
    
    public var vector: [BigNumber] {
        return self.a.map({ (el) -> BigNumber in
            return el.value
        })
    }
    
    public static func powers(k: BigNumber, n: Int, q: BigNumber) -> FieldVector {
        var elements = [GeneralPrimeFieldElement]()
        let field = GeneralPrimeField(q)
        elements.append(field.identityElement)
        let kRed = field.fromValue(k)
        for i in 1 ..< n {
            elements.append(elements[i-1] * kRed)
        }
        return FieldVector(elements, field)
    }
    
    public static func powers(k: BigNumber, n: Int, field: GeneralPrimeField) -> FieldVector {
        var elements = [GeneralPrimeFieldElement]()
        elements.append(field.identityElement)
        let kRed = field.fromValue(k)
        for i in 1 ..< n {
            elements.append(elements[i-1] * kRed)
        }
        return FieldVector(elements, field)
    }
    
    public static func fill(k: BigNumber, n: Int, q: BigNumber) -> FieldVector {
        var elements = [GeneralPrimeFieldElement]()
        let field = GeneralPrimeField(q)
        let kRed = field.fromValue(k)
        for _ in 0 ..< n {
            elements.append(kRed)
        }
        return FieldVector(elements, field)
    }
    
    public static func fill(k: BigNumber, n: Int, field: GeneralPrimeField) -> FieldVector {
        var elements = [GeneralPrimeFieldElement]()
        let kRed = field.fromValue(k)
        for _ in 0 ..< n {
            elements.append(kRed)
        }
        return FieldVector(elements, field)
    }
    
    public func isEqualTo(_ other: FieldVector) -> Bool {
        if self.q != other.q {
            return false
        }
        if self.a.count != other.a.count {
            return false;
        }
        for i in 0 ..< self.a.count {
            if self.a[i] != other.a[i] {
                return false
            }
        }
        return true
    }
    
    public static func random(n: Int, q: BigNumber) -> FieldVector  {
        var res = [GeneralPrimeFieldElement]()
        let field = GeneralPrimeField(q)
        for _ in 0 ..< n {
            let random = ProofUtils.randomNumber(bitWidth: q.bitWidth)
            res.append(field.fromValue(random))
        }
        return FieldVector(res, field)
    }
    
    public static func random(n: Int, field: GeneralPrimeField) -> FieldVector  {
        var res = [GeneralPrimeFieldElement]()
        let q = field.modulus
        for _ in 0 ..< n {
            let random = ProofUtils.randomNumber(bitWidth: q.bitWidth)
            res.append(field.fromValue(random))
        }
        return FieldVector(res, field)
    }
}
