//
//  U512.swift
//  EllipticSwift
//
//  Created by Alexander Vlasov on 13.07.2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import Foundation

public var U512bitLength = 512
public var U512byteLength = 64

extension U512 {
    public init?(_ bytes: Data) {
        if bytes.count <= U512byteLength {
            let padding = Data(repeating: 0, count: U512byteLength - bytes.count)
            let fullData = padding + bytes
            var zero = U512(v: (BigNumber.vZERO, BigNumber.vZERO, BigNumber.vZERO, BigNumber.vZERO))
            withUnsafeMutableBytes(of: &zero) { (p) -> Void in
                p.copyBytes(from: fullData.bytes)
            }
            self = zero
        } else {
            return nil
        }
    }
    
    public var bytes: Data {
        var data = Data(repeating: 0, count: U512byteLength).bytes
        var copy = self
        withUnsafePointer(to: &copy, { (copyPtr) -> Void in
            let copyRawPtr = UnsafeRawBufferPointer.init(start: copyPtr, count: U512byteLength)
            for i in 0 ..< U512byteLength {
                let b = copyRawPtr.load(fromByteOffset: i, as: UInt8.self)
                data[i] = b
            }
        })
        return Data(data)
    }
    
    public func split() -> (U256, U256) {
        var copy = self
        var top = U256(v: (BigNumber.vZERO, BigNumber.vZERO))
        var bottom = U256(v: (BigNumber.vZERO, BigNumber.vZERO))
        withUnsafePointer(to: &copy, { (copyPtr) -> Void in
            copyPtr.withMemoryRebound(to: U256.self, capacity: 2, { (ptr) -> Void in
                top = ptr.pointee
                bottom = ptr.advanced(by: 1).pointee
            })
        })
        return (top, bottom)
    }
}
