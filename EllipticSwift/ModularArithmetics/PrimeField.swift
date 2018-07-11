//
//  Field.swift
//  EllipticSwift
//
//  Created by Alexander Vlasov on 07.07.2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import Foundation
import BigInt

public class PrimeField {
    public var prime: BigUInt
    public var modulus: BigUInt {
        get {
            return self.prime
        }
    }
    lazy public var identityElement: PrimeFieldElement = self.identity()
    
    var montR: BigUInt
    var montInvR: BigUInt
    var montK: BigUInt
    var numWords: Int
    
    public var order: BigUInt {
        return self.prime
    }
    
    func isEqualTo(_ other: PrimeField) -> Bool {
        return self.modulus == other.modulus
    }
    
    public func identity() -> PrimeFieldElement {
        return self.fromValue(BigUInt(1))
    }
    
    public func add(_ a: PrimeFieldElement, _ b: PrimeFieldElement) -> PrimeFieldElement {
        var v = a.rawValue + b.rawValue
        if v > self.prime {
            v = v % self.prime
        }
        return PrimeFieldElement(v, self)
    }
    
    public func neg(_ a: PrimeFieldElement) -> PrimeFieldElement {
        return PrimeFieldElement(self.prime - a.rawValue, self)
    }
    
    public func sub(_ a: PrimeFieldElement, _ b: PrimeFieldElement) -> PrimeFieldElement {
        if a.rawValue > b.rawValue {
            return PrimeFieldElement(a.rawValue - b.rawValue, self)
        } else {
            return PrimeFieldElement(self.prime - (b.rawValue - a.rawValue), self)
        }
    }
    
    public func mul(_ a: PrimeFieldElement, _ b: PrimeFieldElement) -> PrimeFieldElement {
        return montMul(a, b)
    }

    func montMul(_ a: PrimeFieldElement, _ b: PrimeFieldElement) -> PrimeFieldElement {
        let x = a.rawValue*b.rawValue
        let v = x*self.montK
        var wordsToCut = self.numWords
        if v.words.count < wordsToCut {
            wordsToCut = v.words.count
        }
        let s = BigUInt(words: v.words[0..<wordsToCut]) // v mod r
        let t = x + s*self.prime
        if (t.trailingZeroBitCount < self.numWords * WordSize) {
            return PrimeFieldElement(0, self)
        }
        let u = t >>  (self.numWords * WordSize) // t / r
        if u < self.prime {
            return PrimeFieldElement(u, self)
        } else {
            return PrimeFieldElement(u - self.prime, self)
        }
    }
    
    public func div(_ a: PrimeFieldElement, _ b: PrimeFieldElement) -> PrimeFieldElement {
        return mul(a, inv(b))
    }

    public func inv(_ a: PrimeFieldElement) -> PrimeFieldElement {
        if let v = a.value.inverse(self.prime) { // TODO may be improved
            return fromValue(v)
        } else {
            // TODO check if there is a fallback
            return PrimeFieldElement(BigUInt(0), self)
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
    }
    
    public func doubleAndAddExponentiation(_ a: PrimeFieldElement, _ b: BigUInt) -> PrimeFieldElement {
        // double and add
        var base = a
        var result = self.identityElement
        var bCopy = b
        for _ in 0 ..< bCopy.bitWidth {
            if bCopy.words.first! & BigUInt.Word(1) == BigUInt.Word(1) {
                result = mul(result, base)
            }
            bCopy = bCopy >> 1
            if bCopy == 0 {
                break
            }
            base = mul(base, base)
        }
        return result
    }
    
    public func kSlidingWindowExponentiation(_ a: PrimeFieldElement, _ b: BigUInt, windowSize: Int = DefaultWindowSize) -> PrimeFieldElement {
        let numPrecomputedElements = (1 << windowSize) - 1 // 2**k - 1
        var precomputations = [PrimeFieldElement](repeating: self.identityElement, count: numPrecomputedElements)
        precomputations[0] = a
        precomputations[1] = mul(a, a)
        for i in 2 ..< numPrecomputedElements {
            precomputations[i] = mul(precomputations[i-2], precomputations[1])
        }
        var result = self.identityElement
        let (lookups, powers) = computeSlidingWindow(scalar: b, windowSize: windowSize)
        for i in 0 ..< lookups.count {
            let lookupCoeff = lookups[i]
            if lookupCoeff == -1 {
                result = mul(result, result)
            } else {
                let power = powers[i]
                let intermediatePower = doubleAndAddExponentiation(result, power) // use trivial form to don't go recursion
//                let intermediatePower = pow(result, power)
                result = mul(intermediatePower, precomputations[lookupCoeff])
            }
        }
        return result
    }
    
    public func fromValue(_ a: BigUInt) -> PrimeFieldElement {
        let reducedValue = (a*self.montR) % self.prime
        return PrimeFieldElement(reducedValue, self)
    }
    
    public func toValue(_ a: PrimeFieldElement) -> BigUInt {
        let normalValue = (a.rawValue*self.montInvR) % self.prime
        return normalValue
    }

    public init?(_ prime: BigUInt) {
        guard prime.isPrime() else {return nil}
        self.prime = prime
        let numWords = prime.words.count
        self.numWords = numWords
        self.montR = BigUInt(1) << (numWords*WordSize)
        guard let montInvR = self.montR.inverse(self.prime) else {return nil}
        self.montInvR = montInvR
        self.montK = (self.montR * self.montInvR - BigUInt(1)) / self.prime
    }
}
