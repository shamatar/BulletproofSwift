//
//  U128.swift
//  EllipticSwift
//
//  Created by Alexander Vlasov on 12.07.2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import Foundation
import Accelerate

public typealias U128 = vU128
public typealias U256 = vU256

extension U256: Equatable, Comparable {
    public var bytes: Data {
        var data = Data(repeating: 0, count: 32).bytes
        var copy = self
        withUnsafePointer(to: &copy, { (copyPtr) -> Void in
            let copyRawPtr = UnsafeRawBufferPointer.init(start: copyPtr, count: 32)
            for i in 0 ..< 32 {
                let b = copyRawPtr.load(fromByteOffset: i, as: UInt8.self)
                data[i] = b
            }
        })
        return Data(data)
    }
    
    public mutating func compareTo(_ other: U256) -> ComparisonResult {
        var otherCopy = other
        let result = withUnsafeBytes(of: &self, { (thisPtr) -> ComparisonResult in
            withUnsafeBytes(of: &otherCopy, { (otherPtr) -> ComparisonResult in
                for i in 0 ..< 8 {
                    let a = thisPtr.load(fromByteOffset: i*4, as: UInt32.self)
                    let b = otherPtr.load(fromByteOffset: i*4, as: UInt32.self)
                    if a > b {
                        return ComparisonResult.orderedDescending
                    } else if a < b {
                        return ComparisonResult.orderedAscending
                    }
                }
                return ComparisonResult.orderedSame
            })
        })
        return result
    }
    
    public static func < (lhs: U256, rhs: U256) -> Bool {
        var lhsCopy = lhs
        switch lhsCopy.compareTo(rhs) {
        case .orderedAscending:
            return true
        default:
            return false
        }
    }
    
    public static func == (lhs: U256, rhs: U256) -> Bool {
        var lhsCopy = lhs
        switch lhsCopy.compareTo(rhs) {
        case .orderedSame:
            return true
        default:
            return false
        }
    }
    
    public func addMod(_ a: U256) -> U256 {
        let zero = vUInt32(0)
        var result = U256(v: (zero, zero))
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
    
    public func subMod(_ a: U256) -> U256 {
        let zero = vUInt32(0)
        var result = U256(v: (zero, zero))
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
}
