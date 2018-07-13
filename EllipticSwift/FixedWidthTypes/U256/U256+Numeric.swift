//
//  U256+Numeric.swift
//  EllipticSwift
//
//  Created by Alexander Vlasov on 13.07.2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import Foundation
import Accelerate

extension U256: Numeric {
    public typealias IntegerLiteralType = UInt64
    
    public init(integerLiteral: U256.IntegerLiteralType) {
        var data = Data(repeating: 0, count: 8)
        var copy = integerLiteral
        withUnsafePointer(to: &copy, { (copyPtr) -> Void in
            let copyRawPtr = UnsafeRawBufferPointer.init(start: copyPtr, count: 8)
            for i in 0 ..< 8 {
                let b = copyRawPtr.load(fromByteOffset: i, as: UInt8.self)
                data[i] = b
            }
        })
        self = U256(data)!
    }
    
    
    public typealias Magnitude = U256
    public var magnitude: U256 {
        return self
    }
    
    public init?<T>(exactly: T) {
        return nil
    }
    public static var bitWidth: Int = U256bitLength
    public static var max: U256 = U256MAX
    public static var min: U256 = U256MIN
    
    
    public static func * (lhs: U256, rhs: U256) -> U256 {
        return lhs.halfMul(rhs)
    }
    
    public static func *= (lhs: inout U256, rhs: U256) {
        lhs.inplaceHalfMul(rhs)
    }
    
    public static func + (lhs: U256, rhs: U256) -> U256 {
        return lhs.addMod(rhs)
    }
    
    public static func += (lhs: inout U256, rhs: U256) {
        lhs.inplaceAddMod(rhs)
    }
    
    public static func - (lhs: U256, rhs: U256) -> U256 {
        return lhs.subMod(rhs)
    }
    
    public static func -= (lhs: inout U256, rhs: U256) {
        lhs.inplaceSubMod(rhs)
    }
}
