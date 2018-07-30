//
//  NativeMontPrimeField.swift
//  EllipticSwift
//
//  Created by Alexander Vlasov on 30.07.2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import Foundation
import BigInt

public class NativeMontPrimeField<T> where T: FiniteFieldCompatible, T: MontArithmeticsCompatible {
    
    public var prime: T
    public var montR: T
    public var montInvR: T
    public var montK: T
    
    var montWordBitWidth: UInt32 = T.zero.fullBitWidth
    
    public var modulus: BigUInt {
        return BigUInt(self.prime.bytes)
    }
    
    public init?(_ p: BigUInt) {
        let nativeType: T? = T(p.serialize())
        precondition(nativeType != nil)
        self.prime = nativeType!
        let (montR, montInvR, montK) = T.getMontParams(self.prime)
        self.montR = montR
        self.montInvR = montInvR
        self.montK = montK
    }
    
    public init(_ p: BigNumber) {
        let nativeType: T? = T(p.bytes)
        precondition(nativeType != nil)
        self.prime = nativeType!
        let (montR, montInvR, montK) = T.getMontParams(self.prime)
        self.montR = montR
        self.montInvR = montInvR
        self.montK = montK
    }
    
    public init(_ p: T) {
        self.prime = p
        let (montR, montInvR, montK) = T.getMontParams(self.prime)
        self.montR = montR
        self.montInvR = montInvR
        self.montK = montK
    }
    
    public func isEqualTo(_ other: NativeMontPrimeField) -> Bool {
        return self.prime == other.prime
    }
    
    public func add(_ a: NativeMontPrimeFieldElement<T>, _ b: NativeMontPrimeFieldElement<T>) -> NativeMontPrimeFieldElement<T> {
        //TODO May be not too optimal
        let space = self.prime - a.rawValue // q - a
        if (b.rawValue >= space) {
            return self.toElement(b.rawValue - space)
        } else {
            return self.toElement(b.rawValue + a.rawValue)
        }
    }
    
    internal func toElement(_ a: T) -> NativeMontPrimeFieldElement<T> {
        return NativeMontPrimeFieldElement<T>(a, self)
    }
    
    public func sub(_ a: NativeMontPrimeFieldElement<T>, _ b: NativeMontPrimeFieldElement<T>) -> NativeMontPrimeFieldElement<T> {
        if a.rawValue >= b.rawValue {
            return self.toElement(a.rawValue - b.rawValue)
        } else {
            return self.toElement(self.prime - (b.rawValue - a.rawValue))
        }
    }
    
    public func neg(_ a: NativeMontPrimeFieldElement<T>) -> NativeMontPrimeFieldElement<T> {
        return self.toElement(self.prime - a.rawValue)
    }
    
    internal func doubleAndAddExponentiation(_ a: NativeMontPrimeFieldElement<T>, _ b: T) -> NativeMontPrimeFieldElement<T> {
        var base = a
        var result = self.identityElement
        let bitwidth = b.bitWidth
        for i in 0 ..< bitwidth {
            if b.bit(i) {
                result = mul(result, base)
            }
            if i == b.bitWidth - 1 {
                break
            }
            base = mul(base, base)
        }
        return result
    }
    
    internal func kSlidingWindowExponentiation(_ a: NativeMontPrimeFieldElement<T>, _ b: T, windowSize: Int = DefaultWindowSize) -> NativeMontPrimeFieldElement<T> {
        let numPrecomputedElements = (1 << windowSize) - 1 // 2**k - 1
        var precomputations = [NativeMontPrimeFieldElement<T>](repeating: self.identityElement, count: numPrecomputedElements)
        precomputations[0] = a
        precomputations[1] = self.mul(a, a)
        for i in 2 ..< numPrecomputedElements {
            precomputations[i] = self.mul(precomputations[i-2], precomputations[1])
        }
        var result = self.identityElement
        let (lookups, powers) = computeSlidingWindow(scalar: b, windowSize: windowSize)
        for i in 0 ..< lookups.count {
            let lookupCoeff = lookups[i]
            if lookupCoeff == -1 {
                result = mul(result, result)
            } else {
                let power = powers[i]
                let intermediatePower = self.doubleAndAddExponentiation(result, T(power)) // use trivial form to don't go recursion
                result = self.mul(intermediatePower, precomputations[lookupCoeff])
            }
        }
        return result
    }
    
    public func mul(_ a: NativeMontPrimeFieldElement<T>, _ b: NativeMontPrimeFieldElement<T>) -> NativeMontPrimeFieldElement<T> {
        // multiplication in Mont. reduced field
        let mult = a.rawValue.modMultiply(b.rawValue, self.prime)
        return self.toElement(mult)
    }
    
    public func div(_ a: NativeMontPrimeFieldElement<T>, _ b: NativeMontPrimeFieldElement<T>) -> NativeMontPrimeFieldElement<T> {
        return self.mul(a, self.inv(b))
    }
    
    public func inv(_ a: NativeMontPrimeFieldElement<T>) -> NativeMontPrimeFieldElement<T> {
        // TODO: inversion in Mont. field natively
        let TWO = T(Data(repeating: 2, count: 1))!
        let power = self.prime - TWO
        return self.pow(a, power)
        //        return self.toElement(a.rawValue.modInv(self.prime))
    }
    
    public func pow(_ a: NativeMontPrimeFieldElement<T>, _ b: T) -> NativeMontPrimeFieldElement<T> {
        if a.isEqualTo(self.identityElement) {
            return a
        }
        if b == 0 {
            return self.identityElement
        }
        if b == 1 {
            return a
        }
        return self.doubleAndAddExponentiation(a, b)
    }
    
    public func pow(_ a: NativeMontPrimeFieldElement<T>, _ b: BigNumber) -> NativeMontPrimeFieldElement<T> {
        switch b {
        case .acceleratedU256(let u256):
            return self.pow(a, u256 as! T)
        }
    }
    
    public func sqrt(_ a: NativeMontPrimeFieldElement<T>) -> NativeMontPrimeFieldElement<T> {
        if a.rawValue == 0 {
            return a
        }
        let ONE = T(Data(repeating: 1, count: 1))!
        let TWO = T(Data(repeating: 2, count: 1))!
        let THREE = T(Data(repeating: 3, count: 1))!
        let FOUR = T(Data(repeating: 4, count: 1))!
        //        let EIGHT = T(Data(repeating: 8, count: 1))!
        let mod4 = self.prime.mod(FOUR)
        precondition(mod4.mod(TWO) == ONE)
        
        // Fast case
        if (mod4 == THREE) {
            let (power, _) = (self.prime + ONE).div(FOUR)
            return self.pow(a, power)
        }
        precondition(false, "NYI")
        return self.fromValue(0)
    }
    
    public func fromValue(_ a: BigNumber) -> NativeMontPrimeFieldElement<T> {
        switch a {
        case .acceleratedU256(let u256):
            let reduced = (u256 as! T).modMultiply(self.montR, self.prime)
//            (a*self.montR) % self.prime
            return NativeMontPrimeFieldElement<T>(reduced, self)
        }
    }
    
    public func toValue(_ a: NativeMontPrimeFieldElement<T>) -> BigUInt {
        let normalValue = a.rawValue.modMultiply(self.montInvR, self.prime)
//        (a.rawValue*self.montInvR) % self.prime
        let bytes = normalValue.bytes
        return BigUInt(bytes)
    }
    
    public var identityElement: NativeMontPrimeFieldElement<T> {
        let element = self.fromValue(BigNumber(integerLiteral: 1))
        return element
    }
    
    public var zeroElement: NativeMontPrimeFieldElement<T> {
        let element = self.fromValue(BigNumber(integerLiteral: 0))
        return element
    }
}

