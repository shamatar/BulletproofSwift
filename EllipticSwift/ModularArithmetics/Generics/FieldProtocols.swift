//
//  Protocols.swift
//  EllipticSwift
//
//  Created by Alexander Vlasov on 02.08.2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import Foundation
import BigInt

public protocol FieldBound: Equatable {
    associatedtype Field: PrimeFieldProtocol
    
    var rawValue: Field.UnderlyingRawType {get}

    func isEqualTo(_ other: Self) -> Bool

    var value: BigUInt  {get}
    var nativeValue: Field.UnderlyingRawType {get}
    var isZero: Bool {get}
    var field: Field {get}

    init(_ rawValue: Field.UnderlyingRawType, _ field: Field)

    static func == (lhs: Self, rhs: Self) -> Bool
    static func + (lhs: Self, rhs: Self) -> Self
    static func - (lhs: Self, rhs: Self) -> Self
    static func * (lhs: Self, rhs: Self) -> Self
    static func * (lhs: BytesRepresentable, rhs: Self) -> Self
    static func + (lhs: BytesRepresentable, rhs: Self) -> Self
    func pow(_ a: BytesRepresentable) -> Self
    func inv() -> Self
    func sqrt() -> Self
    func negate() -> Self
    
    static func fromValue(_ a: BigUInt, field: Field) -> Self
    static func fromValue(_ a: BytesRepresentable, field: Field) -> Self
    static func fromValue(_ a: Field.UnderlyingRawType, field: Field) -> Self
    static func fromValue(_ a: UInt64, field: Field) -> Self
    static func fromBytes(_ a: Data, field: Field) -> Self
    static func toValue(_ a: Field.UnderlyingRawType, field: Field) -> BigUInt
    static func toValue(_ a: Field.UnderlyingRawType, field: Field) -> Field.UnderlyingRawType
    static func identityElement(_ field: Field) -> Self
    static func zeroElement(_ field: Field) -> Self
    
}

public protocol PrimeFieldProtocol {
    associatedtype UnderlyingRawType: FiniteFieldCompatible // U256, U512...
    
    var modulus: BigUInt {get}
    
    init(_ p: BigUInt)
    init(_ p: BytesRepresentable)
    init(_ p: UnderlyingRawType)
    
    func isEqualTo(_ other: Self) -> Bool
    
    func add(_ a: UnderlyingRawType, _ b: UnderlyingRawType) -> UnderlyingRawType
    func sub(_ a: UnderlyingRawType, _ b: UnderlyingRawType) -> UnderlyingRawType
    func neg(_ a: UnderlyingRawType) -> UnderlyingRawType
    func mul(_ a: UnderlyingRawType, _ b: UnderlyingRawType) -> UnderlyingRawType
    func div(_ a: UnderlyingRawType, _ b: UnderlyingRawType) -> UnderlyingRawType
    func inv(_ a: UnderlyingRawType) -> UnderlyingRawType
    func pow(_ a: UnderlyingRawType, _ b: UnderlyingRawType) -> UnderlyingRawType
    func pow(_ a: UnderlyingRawType, _ b: BytesRepresentable) -> UnderlyingRawType
    func sqrt(_ a: UnderlyingRawType) -> UnderlyingRawType
    func reduce(_ a: BytesRepresentable) -> UnderlyingRawType
    func reduce(_ a: UnderlyingRawType) -> UnderlyingRawType
    func fromValue(_ a: BigUInt) -> UnderlyingRawType
    func fromValue(_ a: BytesRepresentable) -> UnderlyingRawType
    func fromValue(_ a: UnderlyingRawType) -> UnderlyingRawType
    func fromValue(_ a: UInt64) -> UnderlyingRawType
    func fromBytes(_ a: Data) -> UnderlyingRawType
    func toValue(_ a: UnderlyingRawType) -> BigUInt
    func toValue(_ a: UnderlyingRawType) -> UnderlyingRawType

    var identityElement: UnderlyingRawType {get}
    var zeroElement: UnderlyingRawType {get}
}

//public protocol PrimeFieldProtocol {
//    associatedtype UnderlyingRawType: FiniteFieldCompatible // U256, U512...
////    associatedtype BigNumberType: BitAccessible, BytesRepresentable
////    associatedtype OtherPrimeField: PrimeFieldProtocol where OtherPrimeField.UnderlyingRawType == UnderlyingRawType
////    associatedtype UnderlyingFieldElementType: PrimeFieldElementProtocol where UnderlyingFieldElementType.Field == Self
////    associatedtype UnderlyingFieldElementType: FieldBound where UnderlyingFieldElementType.Field == Self
//    associatedtype UnderlyingFieldElementType: FieldBound
//
//    var modulus: BigUInt {get}
//
//    init(_ p: BigUInt)
//    init(_ p: BytesRepresentable)
//    init(_ p: UnderlyingRawType)
//
////    func isEqualTo(_ other: OtherPrimeField) -> Bool
//
//    func add(_ a: UnderlyingFieldElementType, _ b: UnderlyingFieldElementType) -> UnderlyingFieldElementType
//    func sub(_ a: UnderlyingFieldElementType, _ b: UnderlyingFieldElementType) -> UnderlyingFieldElementType
//    func neg(_ a: UnderlyingFieldElementType) -> UnderlyingFieldElementType
//    func mul(_ a: UnderlyingFieldElementType, _ b: UnderlyingFieldElementType) -> UnderlyingFieldElementType
//    func div(_ a: UnderlyingFieldElementType, _ b: UnderlyingFieldElementType) -> UnderlyingFieldElementType
//    func inv(_ a: UnderlyingFieldElementType) -> UnderlyingFieldElementType
//    func pow(_ a: UnderlyingFieldElementType, _ b: UnderlyingRawType) -> UnderlyingFieldElementType
//    func pow(_ a: UnderlyingFieldElementType, _ b: BytesRepresentable) -> UnderlyingFieldElementType
//    func sqrt(_ a: UnderlyingFieldElementType) -> UnderlyingFieldElementType
//    func fromValue(_ a: BytesRepresentable) -> UnderlyingFieldElementType
//    func fromValue(_ a: UnderlyingRawType) -> UnderlyingFieldElementType
//    func toValue(_ a: UnderlyingFieldElementType) -> BigUInt
//    func toValue(_ a: UnderlyingRawType) -> BigUInt
//
//    var identityElement: UnderlyingFieldElementType {get}
//    var zeroElement: UnderlyingFieldElementType {get}
//}

//public protocol PrimeFieldElementProtocol: Equatable {
//    associatedtype UnderlyingType
////    associatedtype OtherPrimeFieldElement: PrimeFieldElementProtocol where OtherPrimeFieldElement.UnderlyingType == UnderlyingType
////    associatedtype Field: PrimeFieldProtocol where Field.UnderlyingRawType == UnderlyingType
//    associatedtype Field: PrimeFieldProtocol where Field.UnderlyingFieldElementType == Self
//
////    var rawValue: UnderlyingType {get}
////
//////    func isEqualTo(_ other: OtherPrimeFieldElement) -> Bool
////
////    var value: BigUInt  {get}
////    var isZero: Bool {get}
////    var field: Field {get}
////
////    init(_ bigUInt: BigUInt, _ field: Field)
////    init(_ rawValue: UnderlyingType, _ field: Field)
////
////    static func == (lhs: Self, rhs: Self) -> Bool
////    static func + (lhs: Self, rhs: Self) -> Self
////    static func - (lhs: Self, rhs: Self) -> Self
////    static func * (lhs: Self, rhs: Self) -> Self
////    static func * (lhs: BytesRepresentable, rhs: Self) -> Self
////    static func + (lhs: BigUInt, rhs: Self) -> Self
////    static func + (lhs: BytesRepresentable, rhs: Self) -> Self
//////    func mod(_ q: BigUInt) -> Self
//////    func mod(_ q: BigUInt) -> BigUInt
//////    func mod(_ q: BytesRepresentable) -> BytesRepresentable
//////    func mod(_ q: UnderlyingType) -> Self
//////    func mod(_ q: Self) -> Self
//////    func inv(_ q: BigUInt) -> Self
////    func pow(_ a: BytesRepresentable) -> Self
////    func inv() -> Self
////    func sqrt() -> Self
////    func negate() -> Self
//
//}

