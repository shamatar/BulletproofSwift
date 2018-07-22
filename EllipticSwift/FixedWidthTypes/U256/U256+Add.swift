//
//  U256+Add.swift
//  EllipticSwift
//
//  Created by Alexander Vlasov on 13.07.2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import Foundation
import Accelerate

extension U256 {
    public func addMod(_ a: U256) -> U256 {
        var result = U256()
        var aCopy = a
        var selfCopy = self
        withUnsafePointer(to: &selfCopy) { (selfPtr: UnsafePointer<vU256>) -> Void in
            withUnsafePointer(to: &aCopy, { (aPtr: UnsafePointer<vU256>) -> Void in
                withUnsafeMutablePointer(to: &result, { (resultPtr: UnsafeMutablePointer<vU256>) -> Void in
                    vU256Add(selfPtr, aPtr, resultPtr)
                })
            })
        }
        return result
    }
    
    public mutating func inplaceAddMod(_ a: U256) {
        var aCopy = a
        var selfCopy = self
        withUnsafePointer(to: &selfCopy) { (selfPtr: UnsafePointer<vU256>) -> Void in
            withUnsafePointer(to: &aCopy, { (aPtr: UnsafePointer<vU256>) -> Void in
                withUnsafeMutablePointer(to: &self, { (resultPtr: UnsafeMutablePointer<vU256>) -> Void in
                    vU256Add(selfPtr, aPtr, resultPtr)
                })
            })
        }
    }
}
