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
    private static var vZERO: vUInt32 = vUInt32(0)
    private static var uint256alignment = MemoryLayout<vUInt32>.alignment
    private static var uint256size = MemoryLayout<vUInt32>.size
    private static var uint256stride = MemoryLayout<vUInt32>.stride
    case u256(vU256)
    case u512(vU512)
    case u1024(vU1024)
    
    public init?(_ bytes: Data) {
        if bytes.count <= 32 {
            let numWords = (bytes.count + 3) / 4
            var vec0 = [UInt32](repeating: 0, count: 4)
            var vec1 = [UInt32](repeating: 0, count: 4)
            let padding = Data(repeating: 0, count: 32 - bytes.count)
            let fullData = padding + bytes
            var zero = vU256(v: (BigNumber.vZERO, BigNumber.vZERO))
            withUnsafeMutableBytes(of: &zero) { (p) -> Void in
                p.copyBytes(from: fullData.bytes)
            }
            self = BigNumber.u256(zero)
            return
            for i in  1 ... 16  {
                let base = 128 - i*4
                var word = UInt32(bytes[base + 0])
                word = word + (UInt32(bytes[base + 1]) << 4)
                word = word + (UInt32(bytes[base + 2]) << 8)
                word = word + (UInt32(bytes[base + 3]) << 12)
                vec0[i] = word
            }
            for i in  17 ... 32  {
                let base = 128 - i*4
                var word = UInt32(bytes[base + 0])
                word = word + (UInt32(bytes[base + 1]) << 4)
                word = word + (UInt32(bytes[base + 2]) << 8)
                word = word + (UInt32(bytes[base + 3]) << 12)
                vec1[i] = word
            }
            let num = vU256(v: (vUInt32(vec0), vUInt32(vec1)))
            self = BigNumber.u256(num)
        }
//        else if bytes.count < 64 {
//            let vec = vUInt32(array)
//            let num = vU512(v: vec)
//            self = BigNumber.u512(num)
//        } else if bytes.count < 128 {
//            let vec = vUInt32(array)
//            let num = vU1024(v: vec)
//            self = BigNumber.u1024(num)
//        }
        else {
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
