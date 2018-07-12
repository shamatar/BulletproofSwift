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
    public var a: [BigUInt]
    public var q: BigUInt
    
    public init (_ a: [BigUInt], _ q: BigUInt) {
        self.a = a.map({ (el) -> BigUInt in
            return el % q
        })
        self.q = q;
    }
    
    public func innerPoduct(_ other: FieldVector) -> BigUInt {
        precondition(self.a.count == other.a.count)
        precondition(self.q == other.q)
        precondition(self.a.count > 0)
        var result = self.a[0] * other.a[0]
        for i in 1 ..< self.a.count {
            result = result + ((self.a[i] * other.a[i]) % q)
        }
        return result % self.q
    }
    
    public func hadamardProduct(_ other: FieldVector) -> FieldVector {
        precondition(self.a.count == other.a.count)
        precondition(self.q == other.q)
        precondition(self.a.count > 0)
        var elements = [BigUInt]()
        for i in 0 ..< self.a.count {
            elements.append((self.a[i] * other.a[i]) % self.q)
        }
        return FieldVector(elements, self.q)
    }
    
    public func times(_ scalar: BigUInt) -> FieldVector {
        var elements = [BigUInt]()
        for i in 0 ..< self.a.count {
            elements.append((scalar * self.a[i]) % self.q)
        }
        return FieldVector(elements, self.q)
    }
    
    public func add(_ other: FieldVector) -> FieldVector {
        precondition(self.a.count == other.a.count)
        precondition(self.q == other.q)
        precondition(self.a.count > 0)
        var elements = [BigUInt]()
        for i in 0 ..< self.a.count {
            elements.append((self.a[i] + other.a[i]) % self.q)
        }
        return FieldVector(elements, self.q)
    }
    
    public func add(_ scalar: BigUInt) -> FieldVector {
        precondition(self.a.count > 0)
        var elements = [BigUInt]()
        for i in 0 ..< self.a.count {
            elements.append((scalar + self.a[i]) % self.q)
        }
        return FieldVector(elements, self.q)
    }
        
    public func sub(_ other: FieldVector) -> FieldVector {
        precondition(self.a.count == other.a.count)
        precondition(self.q == other.q)
        precondition(self.a.count > 0)
        var elements = [BigUInt]()
        for i in 0 ..< self.a.count {
            if self.a[i] > other.a[i] {
                elements.append(self.a[i] - other.a[i])
            } else {
                elements.append(self.q - (other.a[i] - self.a[i]))
            }
            
        }
        return FieldVector(elements, self.q)
    }
    
    public func sum() -> BigUInt {
        precondition(self.a.count > 0)
        var result = self.a[0]
        for i in 1 ..< self.a.count {
            result = result + self.a[i]
        }
        return result % self.q
    }
    
    public func inv() -> FieldVector {
        precondition(self.a.count > 0)
        var elements = [BigUInt]()
        for i in 0 ..< self.a.count {
            let inverse = self.a[i].inverse(self.q)
            precondition(inverse != nil)
            elements.append(inverse!)
        }
        return FieldVector(elements, self.q)
    }
    
    public var first: BigUInt? {
        return self.a.first
    }
    
    public func get(_ i: Int) -> BigUInt {
        return self.a[i];
    }
    
    public var size: Int {
        return self.a.count;
    }
    
    public func subvector(_ from: Int, _ noninclusiveTo: Int) -> FieldVector {
        precondition(self.a.count > 0)
        var elements = [BigUInt]()
        for i in from ..< noninclusiveTo {
            elements.append(self.a[i])
        }
        return FieldVector(elements, self.q)
    }
    
    public var vector: [BigUInt] {
        return self.a
    }
    
    
    public static func powers(k: BigUInt, n: Int, q: BigUInt) -> FieldVector {
        var elements = [BigUInt]()
        elements.append(1)
        for i in 1 ..< n {
            elements.append((elements[i-1] * k) % q)
        }
        return FieldVector(elements, q);
        
//        let field = PrimeField(q)
//        precondition(field != nil)
//        let kReduced = field!.fromValue(k)
//        var elements = [PrimeFieldElement]()
//        elements.append(field!.identityElement)
//        for i in 1 ..< n {
//            elements.append(elements[i-1] * kReduced)
//        }
//        let normalElements = elements.map { (el) -> BigUInt in
//            return el.value
//        }
//        return FieldVector(normalElements, q);
    }
    
    public static func fill(k: BigUInt, n: Int, q: BigUInt) -> FieldVector {
        var elements = [BigUInt]()
        for _ in 0 ..< n {
            elements.append(k)
        }
        return FieldVector(elements, q);
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
    
    public static func random(n: Int, q: BigUInt) -> FieldVector  {
        var res = [BigUInt]()
        for _ in 0 ..< n {
            res.append(ProofUtils.randomNumber(bitWidth: q.bitWidth))
        }
        return FieldVector(res, q);
    }
}
