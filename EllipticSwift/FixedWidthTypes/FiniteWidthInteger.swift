//
//  FiniteWidthInteger.swift
//  EllipticSwift
//
//  Created by Alexander Vlasov on 13.07.2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import Foundation
import BigInt
import Accelerate

public typealias U256 = vU256
public typealias U512 = vU512
public typealias U1024 = vU1024

extension U256: FiniteFieldCompatible {
}

public protocol FiniteFieldCompatible: Comparable, Numeric, ModReducable, BytesInitializable, BitsAndBytes, BitShiftable, EvenOrOdd {
}

public protocol BitsAndBytes: BytesRepresentable, BitAccessible, FixedWidth, Zeroable {
}

public protocol BytesInitializable {
    init? (_ bytes: Data)
}

public protocol BytesRepresentable {
    var bytes: Data {get}
}

public protocol Zeroable {
    var isZero: Bool {get}
}

public protocol EvenOrOdd {
    var isEven: Bool {get}
}

public protocol BitAccessible {
    func bit(_ i: Int) -> Bool
}

public protocol FixedWidth {
    var bitWidth: Int {get}
}

public protocol BitShiftable {
    static func >> (lhs: Self, rhs: UInt32) -> Self
    static func << (lhs: Self, rhs: UInt32) -> Self
}

public protocol ModReducable {
    func modMultiply(_ a: Self, _ modulus: Self) -> Self
    func mod(_ modulus: Self) -> Self
    func modInv(_ modulus: Self) -> Self
    func div(_ a: Self) -> (Self, Self)
    func fullMultiply(_ a: Self) -> (Self, Self)
}
