//
//  FixedWidthTypes.swift
//  EllipticSwift
//
//  Created by Alexander Vlasov on 12.07.2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import Foundation
import Accelerate

public enum BigNumber {
    public static var vZERO: vUInt32 = vUInt32(0)
    case u256(vU256)
    case u512(vU512)
    case u1024(vU1024)
    
    public init?(_ bytes: Data) {
        if bytes.count <= 32 {
            let padding = Data(repeating: 0, count: 32 - bytes.count)
            let fullData = padding + bytes
            var zero = vU256(v: (BigNumber.vZERO, BigNumber.vZERO))
            withUnsafeMutableBytes(of: &zero) { (p) -> Void in
                p.copyBytes(from: fullData.bytes)
            }
            self = BigNumber.u256(zero)
        } else if bytes.count <= 64 {
            let padding = Data(repeating: 0, count: 64 - bytes.count)
            let fullData = padding + bytes
            var zero = vU512(v: (BigNumber.vZERO, BigNumber.vZERO, BigNumber.vZERO, BigNumber.vZERO))
            withUnsafeMutableBytes(of: &zero) { (p) -> Void in
                p.copyBytes(from: fullData.bytes)
            }
            self = BigNumber.u512(zero)
        } else if bytes.count <= 128 {
            let padding = Data(repeating: 0, count: 128 - bytes.count)
            let fullData = padding + bytes
            var zero = vU1024(v: (BigNumber.vZERO, BigNumber.vZERO, BigNumber.vZERO, BigNumber.vZERO,
                                  BigNumber.vZERO, BigNumber.vZERO, BigNumber.vZERO, BigNumber.vZERO))
            withUnsafeMutableBytes(of: &zero) { (p) -> Void in
                p.copyBytes(from: fullData.bytes)
            }
            self = BigNumber.u1024(zero)
        } else {
            return nil
        }
    }
    
    public var bytes: Data {
        switch self {
        case .u256(let u256):
            var data = Data(repeating: 0, count: 32).bytes
            var copy = u256
            withUnsafePointer(to: &copy, { (copyPtr) -> Void in
                let copyRawPtr = UnsafeRawBufferPointer.init(start: copyPtr, count: 32)
                for i in 0 ..< 32 {
                    let b = copyRawPtr.load(fromByteOffset: i, as: UInt8.self)
                    data[i] = b
                }
            })
            return Data(data)
        default:
            return Data()
        }
    }
}
