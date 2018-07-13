//
//  U256+Mul.swift
//  EllipticSwift
//
//  Created by Alexander Vlasov on 13.07.2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import Foundation
import Accelerate

extension U256 {
    public func fullMul(_ a: U256) -> U512 {
        var result = U512(v: (BigNumber.vZERO, BigNumber.vZERO, BigNumber.vZERO, BigNumber.vZERO))
        var aCopy = a
        var selfCopy = self
        withUnsafePointer(to: &selfCopy) { (selfPtr: UnsafePointer<vU256>) -> Void in
            withUnsafePointer(to: &aCopy, { (aPtr: UnsafePointer<vU256>) -> Void in
                withUnsafeMutablePointer(to: &result, { (resultPtr: UnsafeMutablePointer<vU512>) -> Void in
                    vU256FullMultiply(selfPtr, aPtr, resultPtr)
                })
            })
        }
        return result
    }
    
    public func fullMul(_ a: U256) -> (U256, U256) {
        var result = U512(v: (BigNumber.vZERO, BigNumber.vZERO, BigNumber.vZERO, BigNumber.vZERO))
        var aCopy = a
        var selfCopy = self
        withUnsafePointer(to: &selfCopy) { (selfPtr: UnsafePointer<vU256>) -> Void in
            withUnsafePointer(to: &aCopy, { (aPtr: UnsafePointer<vU256>) -> Void in
                withUnsafeMutablePointer(to: &result, { (resultPtr: UnsafeMutablePointer<vU512>) -> Void in
                    vU256FullMultiply(selfPtr, aPtr, resultPtr)
                })
            })
        }
        return result.split()
    }
    
    public func halfMul(_ a: U256) -> U256 {
        var result = U256(v: (BigNumber.vZERO, BigNumber.vZERO))
        var aCopy = a
        var selfCopy = self
        withUnsafePointer(to: &selfCopy) { (selfPtr: UnsafePointer<vU256>) -> Void in
            withUnsafePointer(to: &aCopy, { (aPtr: UnsafePointer<vU256>) -> Void in
                withUnsafeMutablePointer(to: &result, { (resultPtr: UnsafeMutablePointer<vU256>) -> Void in
                    vU256HalfMultiply(selfPtr, aPtr, resultPtr)
                })
            })
        }
        return result
    }
    
    public mutating func inplaceHalfMul(_ a: U256) {
        var aCopy = a
        var selfCopy = self
        withUnsafePointer(to: &selfCopy) { (selfPtr: UnsafePointer<vU256>) -> Void in
            withUnsafePointer(to: &aCopy, { (aPtr: UnsafePointer<vU256>) -> Void in
                withUnsafeMutablePointer(to: &self, { (resultPtr: UnsafeMutablePointer<vU256>) -> Void in
                    vU256HalfMultiply(selfPtr, aPtr, resultPtr)
                })
            })
        }
    }
    
    public func modMul(_ a: U256, _ modulus: U256) -> U256 {
        var result = U256(v: (BigNumber.vZERO, BigNumber.vZERO))
        var aCopy = a
        var modCopy = modulus
        var selfCopy = self
        withUnsafePointer(to: &selfCopy) { (selfPtr: UnsafePointer<vU256>) -> Void in
            withUnsafePointer(to: &aCopy, { (aPtr: UnsafePointer<vU256>) -> Void in
                withUnsafePointer(to: &modCopy, { (modulusPtr: UnsafePointer<vU256>) -> Void in
                    withUnsafeMutablePointer(to: &result, { (resultPtr: UnsafeMutablePointer<vU256>) -> Void in
                        vU256HalfMultiply(selfPtr, aPtr, resultPtr)
                        vU256Mod(resultPtr, modulusPtr, resultPtr)
                    })
                })
                
            })
        }
        return result
    }
}
