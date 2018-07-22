//
//  U256+Mod.swift
//  EllipticSwift
//
//  Created by Alexander Vlasov on 13.07.2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import Foundation
import Accelerate

extension U256: ModReducable {
    public func mod(_ modulus: U256) -> U256 {
        var result = U256()
        var modCopy = modulus
        var selfCopy = self
        vU256Mod(&selfCopy, &modCopy, &result)
        return result
    }
    
    public mutating func inplaceMod(_ modulus: U256) {
        var modCopy = modulus
        var selfCopy = self
        vU256Mod(&selfCopy, &modCopy, &self)
    }
    
    public func modInv(_ modulus: U256) -> U256 {
        precondition(false, "NYI")
        var x1 = U256.one
        var x2 = U256.zero
        var v = modulus
        var u = self
        while u != U256.one {
            let (q, r) = v.div(u)
            let qx1 = q.modMultiply(x1, modulus)
            if x2 > qx1 {
                let x = x2 - qx1
                x2 = x1
                x1 = x
            } else {
                let x = modulus - (qx1 - x2)
                x2 = x1
                x1 = x
            }
            v = u
            u = r
        }
//        x1.inplaceMod(modulus)
        return x1.mod(modulus)
    }
    
    public func modMultiply(_ a: U256, _ modulus: U256) -> U256 {
        var result = U512()
        var aCopy = a
        var selfCopy = self
        vU256FullMultiply(&selfCopy, &aCopy, &result)
        var extendedModulus = U512(v: (modulus.v.0, modulus.v.1, vUInt32(0), vUInt32(0)))
        var extendedRes = U512()
        vU512Mod(&result, &extendedModulus, &extendedRes)
        let (_, bottom) = extendedRes.split()
        return bottom
    }
    
    public func fullMultiply(_ a: U256) -> (U256, U256) {
//        var result = U512()
//        var aCopy = a
//        var selfCopy = self
//        vU256FullMultiply(&selfCopy, &aCopy, &result)
        let result: U512 = self.fullMul(a)
        return result.split()
    }
    
//    public func modAdd(_ a: U256, _ modulus: U256) -> U256 {
//        var result = U256()
//        var aCopy = a
//        var selfCopy = self
//        vU256FullMultiply(&selfCopy, &aCopy, &result)
//        var extendedModulus = U512(v: (modulus.v.0, modulus.v.1, vUInt32(0), vUInt32(0)))
//        var extendedRes = U512()
//        vU512Mod(&result, &extendedModulus, &extendedRes)
//        let (_, bottom) = extendedRes.split()
//        return bottom
//    }
    
}
