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
    public var a: [PrimeFieldElement]
    public var q: BigUInt
    
    public init (_ a: [PrimeFieldElement], _ q: BigUInt) {
        self.a = a;
        self.q = q;
    }
    
    public init (_ a: [BigUInt], _ q: BigUInt) {
        let field = PrimeField(q)
        precondition(field != nil)
        var elements = [PrimeFieldElement]()
        for i in 0 ..< a.count {
            let fe = field!.fromValue(a[i])
            elements.append(fe)
        }
        self.a = elements
        self.q = q
    }
    
    public func innerPoduct(_ other: FieldVector) -> PrimeFieldElement {
        precondition(self.a.count == other.a.count)
        precondition(self.q == other.q)
        precondition(self.a.count > 0)
        var result = self.a[0] * other.a[0]
        for i in 1 ..< self.a.count {
            result = result + self.a[i] * other.a[i]
        }
        return result.mod(self.q)
    }
    
    public func hadamardProduct(_ other: FieldVector) -> FieldVector {
        precondition(self.a.count == other.a.count)
        precondition(self.q == other.q)
        precondition(self.a.count > 0)
        var elements = [PrimeFieldElement]()
        for i in 0 ..< self.a.count {
            elements.append((self.a[i] * other.a[i]).mod(self.q))
        }
        return FieldVector(elements, self.q)
    }
    
    public func times(_ scalar: BigUInt) -> FieldVector {
        var elements = [PrimeFieldElement]()
        for i in 0 ..< self.a.count {
            elements.append((scalar*self.a[i]).mod(self.q))
        }
        return FieldVector(elements, self.q)
    }
    
    public func add(_ other: FieldVector) -> FieldVector {
        precondition(self.a.count == other.a.count)
        precondition(self.q == other.q)
        precondition(self.a.count > 0)
        var elements = [PrimeFieldElement]()
        for i in 0 ..< self.a.count {
            elements.append((self.a[i] + other.a[i]).mod(self.q))
        }
        return FieldVector(elements, self.q)
    }
    
    public func add(_ scalar: BigUInt) -> FieldVector {
        precondition(self.a.count > 0)
        var elements = [PrimeFieldElement]()
        for i in 0 ..< self.a.count {
            elements.append((scalar + self.a[i]).mod(self.q))
        }
        return FieldVector(elements, self.q)
    }
    
    public func sub(_ other: FieldVector) -> FieldVector {
        precondition(self.a.count == other.a.count)
        precondition(self.q == other.q)
        precondition(self.a.count > 0)
        var elements = [PrimeFieldElement]()
        for i in 0 ..< self.a.count {
            elements.append((self.a[i] - other.a[i]).mod(self.q))
        }
        return FieldVector(elements, self.q)
    }
    
    public func sum() -> PrimeFieldElement {
        precondition(self.a.count > 0)
        var result = self.a[0]
        for i in 1 ..< self.a.count {
            result = result + self.a[i]
        }
        return result.mod(self.q)
    }
    
    public func inv() -> FieldVector {
        precondition(self.a.count > 0)
        var elements = [PrimeFieldElement]()
        for i in 0 ..< self.a.count {
            elements.append(self.a[i].inv(self.q))
        }
        return FieldVector(elements, self.q)
    }
    
    public var first: BigUInt? {
        return self.a.first?.value
    }
    
    public func get(_ i: Int) -> PrimeFieldElement {
        return self.a[i];
    }
    
    public var size: Int {
        return self.a.count;
    }
    
    public func subvector(_ from: Int, _ noninclusiveTo: Int) -> FieldVector {
        precondition(self.a.count > 0)
        var elements = [PrimeFieldElement]()
        for i in from ..< noninclusiveTo {
            elements.append(self.a[i])
        }
        return FieldVector(elements, self.q)
    }
    
    public var vector: [BigUInt] {
        return self.a.map({ (el) -> BigUInt in
            return el.value
        })
    }
    
    
    public static func powers(k: BigUInt, n: Int, q: BigUInt) -> FieldVector {
        let field = PrimeField(q)
        precondition(field != nil)
        let kReduced = field!.fromValue(k)
        var elements = [PrimeFieldElement]()
        elements.append(field!.identityElement)
        for i in 1 ..< n {
            elements.append(elements[i-1] * kReduced)
        }
        return FieldVector(elements, q);
    }
    
    public static func fill(k: BigUInt, n: Int, q: BigUInt) -> FieldVector {
        let field = PrimeField(q)
        precondition(field != nil)
        let kReduced = field!.fromValue(k)
        var elements = [PrimeFieldElement]()
        for i in 0 ..< n {
            elements.append(kReduced)
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
    
//    public static func random(n: Int, q: BigUInt) -> FieldVector  {
//        const res = [];
//        for (let i = 0; i < n; i++) {
//        res.push(ProofUtils.randomNumber());
//        }
//        return new FieldVector(res, q);
//    }
}
