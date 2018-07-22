//
//  NativeNaivePrimeField.swift
//  EllipticSwift
//
//  Created by Alexander Vlasov on 13.07.2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import Foundation
import BigInt

public class NativeNaivePrimeField<T> where T: FiniteFieldCompatible {
    
    public var prime: T
    
    public var modulus: BigUInt {
        return BigUInt(self.prime.bytes)
    }
    
    public init(_ p: BigUInt) {
        let nativeType: T? = T(p.serialize())
        precondition(nativeType != nil)
        self.prime = nativeType!
    }
    
    public init(_ p: BigNumber) {
        let nativeType: T? = T(p.bytes)
        precondition(nativeType != nil)
        self.prime = nativeType!
    }
    
    public init(_ p: T) {
        self.prime = p
    }
    
    public func isEqualTo(_ other: NativeNaivePrimeField) -> Bool {
        return self.prime == other.prime
    }
    
    public func add(_ a: NativePrimeFieldElement<T>, _ b: NativePrimeFieldElement<T>) -> NativePrimeFieldElement<T> {
        //TODO May be not too optimal
        let space = self.prime - a.rawValue // q - a
        if (b.rawValue >= space) {
            return self.toElement(b.rawValue - space)
        } else {
            return self.toElement(b.rawValue + a.rawValue)
        }
    }
    
    internal func toElement<T>(_ a: T) -> NativePrimeFieldElement<T> {
        return NativePrimeFieldElement<T>(a, self as! NativeNaivePrimeField<T>)
    }
    
    public func sub(_ a: NativePrimeFieldElement<T>, _ b: NativePrimeFieldElement<T>) -> NativePrimeFieldElement<T> {
        if a.rawValue >= b.rawValue {
            return self.toElement(a.rawValue - b.rawValue)
        } else {
            return self.toElement(self.prime - (b.rawValue - a.rawValue))
        }
    }
    
    public func neg(_ a: NativePrimeFieldElement<T>) -> NativePrimeFieldElement<T> {
        return self.toElement(self.prime - a.rawValue)
    }
    
    internal func doubleAndAddExponentiation(_ a: NativePrimeFieldElement<T>, _ b: T) -> NativePrimeFieldElement<T> {
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
    
    public func mul(_ a: NativePrimeFieldElement<T>, _ b: NativePrimeFieldElement<T>) -> NativePrimeFieldElement<T> {
        let mult = a.rawValue.modMultiply(b.rawValue, self.prime)
        return self.toElement(mult)
    }
    
    public func div(_ a: NativePrimeFieldElement<T>, _ b: NativePrimeFieldElement<T>) -> NativePrimeFieldElement<T> {
        return self.mul(a, self.inv(b))
    }
    
    public func inv(_ a: NativePrimeFieldElement<T>) -> NativePrimeFieldElement<T> {
        let TWO = T(Data(repeating: 2, count: 1))!
        let power = self.prime - TWO
        return self.pow(a, power)
//        return self.toElement(a.rawValue.modInv(self.prime))
    }
    
    public func pow(_ a: NativePrimeFieldElement<T>, _ b: T) -> NativePrimeFieldElement<T> {
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
    
    public func pow(_ a: NativePrimeFieldElement<T>, _ b: BigNumber) -> NativePrimeFieldElement<T> {
        switch b {
        case .acceleratedU256(let u256):
            return self.pow(a, u256 as! T)
        }
    }
    
    public func sqrt(_ a: NativePrimeFieldElement<T>) -> NativePrimeFieldElement<T> {
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
    
//    public func fromValue(_ a: BigUInt) -> NativePrimeFieldElement<T> {
//        let element = NativePrimeFieldElement<T>(a, self)
//        return element
//    }
    
    public func fromValue(_ a: BigNumber) -> NativePrimeFieldElement<T> {
        switch a {
        case .acceleratedU256(let u256):
            let reduced = (u256 as! T).mod(self.prime)
            return NativePrimeFieldElement<T>(reduced, self)
        }
    }
    
    public func toValue(_ a: NativePrimeFieldElement<T>) -> BigUInt {
        let bytes = a.rawValue.bytes
        return BigUInt(bytes)
    }
    
    public var identityElement: NativePrimeFieldElement<T> {
        let element = self.fromValue(BigNumber(integerLiteral: 1))
        return element
    }
    
    public var zeroElement: NativePrimeFieldElement<T> {
        let element = self.fromValue(BigNumber(integerLiteral: 0))
        return element
    }
    
}
