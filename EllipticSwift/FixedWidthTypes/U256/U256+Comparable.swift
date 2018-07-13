//
//  U256+Comparable.swift
//  EllipticSwift
//
//  Created by Alexander Vlasov on 13.07.2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import Foundation
import Accelerate

extension U256: Equatable, Comparable {
    public mutating func compareTo(_ other: U256) -> ComparisonResult {
        var otherCopy = other
        let result = withUnsafeBytes(of: &self, { (thisPtr) -> ComparisonResult in
            withUnsafeBytes(of: &otherCopy, { (otherPtr) -> ComparisonResult in
                for i in 0 ..< U256byteLength/4 {
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
}
