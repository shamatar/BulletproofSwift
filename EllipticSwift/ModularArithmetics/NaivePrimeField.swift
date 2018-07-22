//
//  NaivePrimeField.swift
//  EllipticSwift
//
//  Created by Alexander Vlasov on 12.07.2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import Foundation
import BigInt

public class NaivePrimeField {
    public var prime: BigUInt
    public var modulus: BigUInt {
        get {
            return self.prime
        }
    }
    lazy public var identityElement: PrimeFieldElement = self.identity()
    lazy public var zeroElement: PrimeFieldElement = {
        return self.fromValue(0)
    }()
    
    public var order: BigUInt {
        return self.prime
    }
    
    public func identity() -> PrimeFieldElement {
        return self.fromValue(BigUInt(1))
    }
    
    public func add(_ a: PrimeFieldElement, _ b: PrimeFieldElement) -> PrimeFieldElement {
        var v = a.rawValue + b.rawValue
        if v > self.prime {
            v = v % self.prime
        }
        return PrimeFieldElement(v, PrimeField.naive(self))
    }
    
    public func sub(_ a: PrimeFieldElement, _ b: PrimeFieldElement) -> PrimeFieldElement {
        if a.rawValue > b.rawValue {
            return PrimeFieldElement(a.rawValue - b.rawValue, PrimeField.naive(self))
        } else {
            return PrimeFieldElement(self.prime - (b.rawValue - a.rawValue), PrimeField.naive(self))
        }
    }
    
    public func neg(_ a: PrimeFieldElement) -> PrimeFieldElement {
        return PrimeFieldElement(self.prime - a.rawValue, PrimeField.naive(self))
    }
    
    public func mul(_ a: PrimeFieldElement, _ b: PrimeFieldElement) -> PrimeFieldElement {
        return PrimeFieldElement((a.rawValue * b.rawValue) % self.prime, PrimeField.naive(self))
    }
    
    public func div(_ a: PrimeFieldElement, _ b: PrimeFieldElement) -> PrimeFieldElement {
        return mul(a, inv(b))
    }
    
    public func inv(_ a: PrimeFieldElement) -> PrimeFieldElement {
        if let v = a.rawValue.inverse(self.prime) { // TODO may be improved
            return fromValue(v)
        } else {
            // TODO check if there is a fallback
            return PrimeFieldElement(BigUInt(0),  PrimeField.naive(self))
        }
    }
    
    public func pow(_ a: PrimeFieldElement, _ b: BigUInt) -> PrimeFieldElement {
        if a.isEqualTo(self.identityElement) {
            return a
        }
        if b == 1 {
            return a
        }
        return doubleAndAddExponentiation(a, b)
//        return kSlidingWindowExponentiation(a, b)
    }
    
    public func sqrt(_ a: PrimeFieldElement) -> PrimeFieldElement {
        if a.rawValue == 0 {
            return a
        }
        
        let mod3 = self.prime.words[0] & 3
        precondition(mod3 % 2 == 1)
        
        // Fast case
        if (mod3 == 3) {
            let power = (self.prime + 1) >> 2
            return self.pow(a, power)
        }
        precondition(false, "NYI")
        return self.fromValue(0)
    }
    
    public func doubleAndAddExponentiation(_ a: PrimeFieldElement, _ b: BigUInt) -> PrimeFieldElement {
        return PrimeFieldElement(a.rawValue.power(b, modulus: self.prime), PrimeField.naive(self))
    }
    
//    public func kSlidingWindowExponentiation(_ a: PrimeFieldElement, _ b: BigUInt, windowSize: Int = DefaultWindowSize) -> PrimeFieldElement {
//        let numPrecomputedElements = (1 << windowSize) - 1 // 2**k - 1
//        var precomputations = [PrimeFieldElement](repeating: self.identityElement, count: numPrecomputedElements)
//        precomputations[0] = a
//        precomputations[1] = mul(a, a)
//        for i in 2 ..< numPrecomputedElements {
//            precomputations[i] = mul(precomputations[i-2], precomputations[1])
//        }
//        var result = self.identityElement
//        let (lookups, powers) = computeSlidingWindow(scalar: b, windowSize: windowSize)
//        for i in 0 ..< lookups.count {
//            let lookupCoeff = lookups[i]
//            if lookupCoeff == -1 {
//                result = mul(result, result)
//            } else {
//                let power = powers[i]
//                let intermediatePower = doubleAndAddExponentiation(result, power) // use trivial form to don't go recursion
//                //                let intermediatePower = pow(result, power)
//                result = mul(intermediatePower, precomputations[lookupCoeff])
//            }
//        }
//        return result
//    }
    
    public func fromValue(_ a: BigUInt) -> PrimeFieldElement {
        let reducedValue = a % self.prime
        return PrimeFieldElement(reducedValue, PrimeField.naive(self))
    }
    
    public func toValue(_ a: PrimeFieldElement) -> BigUInt {
        let normalValue = a.rawValue
        return normalValue
    }
    
    public init?(_ prime: BigUInt) {
        guard prime.isPrime() else {return nil}
        self.prime = prime
    }
}
