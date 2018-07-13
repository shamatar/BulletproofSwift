//
//  U256+Sub.swift
//  EllipticSwift
//
//  Created by Alexander Vlasov on 13.07.2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import Foundation
import Accelerate

extension U256 {
    public func subMod(_ a: U256) -> U256 {
        var result = U256(v: (BigNumber.vZERO, BigNumber.vZERO))
        var aCopy = a
        var selfCopy = self
        withUnsafePointer(to: &selfCopy) { (selfPtr: UnsafePointer<vU256>) -> Void in
            withUnsafePointer(to: &aCopy, { (aPtr: UnsafePointer<vU256>) -> Void in
                withUnsafeMutablePointer(to: &result, { (resultPtr: UnsafeMutablePointer<vU256>) -> Void in
                    vU256Sub(selfPtr, aPtr, resultPtr)
                })
            })
        }
        return result
    }
    
    public mutating func inplaceSubMod(_ a: U256) {
        var aCopy = a
        var selfCopy = self
        withUnsafePointer(to: &selfCopy) { (selfPtr: UnsafePointer<vU256>) -> Void in
            withUnsafePointer(to: &aCopy, { (aPtr: UnsafePointer<vU256>) -> Void in
                withUnsafeMutablePointer(to: &self, { (resultPtr: UnsafeMutablePointer<vU256>) -> Void in
                    vU256Sub(selfPtr, aPtr, resultPtr)
                })
            })
        }
    }
}
