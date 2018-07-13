//
//  U128.swift
//  EllipticSwift
//
//  Created by Alexander Vlasov on 12.07.2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import Foundation
import Accelerate

public typealias U256 = vU256
public typealias U512 = vU512
public typealias U1024 = vU1024

public var U256bitLength = 256
public var U256byteLength = 32
public var U256MAX = U256(Data(repeating: 255, count: U256byteLength))!
public var U256MIN = U256(Data(repeating: 0, count: U256byteLength))!

extension U256: BytesInitializable, BytesRepresentable {
    
    public init?(_ bytes: Data) {
        if bytes.count <= 32 {
            let padding = Data(repeating: 0, count: U256byteLength - bytes.count)
            let fullData = padding + bytes
            var res = vU256(v: (BigNumber.vZERO, BigNumber.vZERO))
            withUnsafeMutableBytes(of: &res) { (p) -> Void in
                p.copyBytes(from: fullData.bytes)
            }
            self = res
        } else {
            return nil
        }
    }
    
    public var bytes: Data {
        var data = Data(repeating: 0, count: U256byteLength).bytes
        var copy = self
        withUnsafePointer(to: &copy, { (copyPtr) -> Void in
            let copyRawPtr = UnsafeRawBufferPointer.init(start: copyPtr, count: U256byteLength)
            for i in 0 ..< U256byteLength {
                let b = copyRawPtr.load(fromByteOffset: i, as: UInt8.self)
                data[i] = b
            }
        })
        return Data(data)
    }
}


