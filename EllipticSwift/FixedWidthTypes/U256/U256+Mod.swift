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
        var result = U256(v: (BigNumber.vZERO, BigNumber.vZERO))
        var modCopy = modulus
        var selfCopy = self
        withUnsafePointer(to: &selfCopy) { (selfPtr: UnsafePointer<vU256>) -> Void in
            withUnsafePointer(to: &modCopy, { (modulusPtr: UnsafePointer<vU256>) -> Void in
                withUnsafeMutablePointer(to: &result, { (resultPtr: UnsafeMutablePointer<vU256>) -> Void in
                    vU256Mod(selfPtr, modulusPtr, resultPtr)
                })
            })
        }
        return result
    }
    
    public mutating func inplaceMod(_ modulus: U256) {
        var modCopy = modulus
        var selfCopy = self
        withUnsafePointer(to: &selfCopy) { (selfPtr: UnsafePointer<vU256>) -> Void in
            withUnsafePointer(to: &modCopy, { (modulusPtr: UnsafePointer<vU256>) -> Void in
                withUnsafeMutablePointer(to: &self, { (resultPtr: UnsafeMutablePointer<vU256>) -> Void in
                    vU256Mod(selfPtr, modulusPtr, resultPtr)
                })
            })
        }
    }
    
    public func modInv(_ modulus: U256) -> U256 {
        var x1 = U256.one
        var x2 = U256.zero
        var v = modulus
        var u = self
        while u != U256.one {
            let (q, r) = v.div(u)
            var qx1 = q * x1
            qx1.inplaceMod(modulus)
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
        x1.inplaceMod(modulus)
        return x1
    }
}
