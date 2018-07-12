//
//  Field.swift
//  EllipticSwift
//
//  Created by Alexander Vlasov on 07.07.2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import Foundation
import BigInt

public var WordSize = BigInt.Word.bitWidth

//public protocol GroupElement {
//    var group: Group {get}
//    var isNull: Bool {get}
//    func isEqualTo(_ other: GroupElement) -> Bool
//}
//
//public protocol Group{
//    var order: BigUInt {get}
//    func identity() -> GroupElement
//    func add(_ a: GroupElement, _ b: GroupElement) -> GroupElement
//    func neg(_ a: GroupElement) -> GroupElement
//    func sub(_ a: GroupElement, _ b: GroupElement) -> GroupElement
//    func mul(_ a: GroupElement, _ b: GroupElement) -> GroupElement
//    func div(_ a: GroupElement, _ b: GroupElement) -> GroupElement
//    func inv(_ a: GroupElement) -> GroupElement
//    func pow(_ a: GroupElement, _ b: BigUInt) -> GroupElement
//    func isEqualTo(_ other: Group) -> Bool
//}
//
//public protocol FieldElement {
//    var value: BigUInt {get}
//    var rawValue: BigUInt {get}
//    var field: Field {get}
//    func isEqualTo(_ other: FieldElement) -> Bool
//}
//
//public protocol Field {
//    var modulus: BigUInt {get}
////    func identity() -> FieldElement
////    func add(_ a: FieldElement, _ b: FieldElement) -> FieldElement
////    func neg(_ a: FieldElement) -> FieldElement
////    func sub(_ a: FieldElement, _ b: FieldElement) -> FieldElement
////    func mul(_ a: FieldElement, _ b: FieldElement) -> FieldElement
////    func div(_ a: FieldElement, _ b: FieldElement) -> FieldElement
////    func inv(_ a: FieldElement) -> FieldElement
////    func pow(_ a: FieldElement, _ b: BigUInt) -> FieldElement
//    func isEqualTo(_ other: Field) -> Bool
//    func fromValue(_ a: BigUInt) -> FieldElement
//    func toValue(_ a: FieldElement) -> BigUInt
//}
