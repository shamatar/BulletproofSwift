//
//  FiniteWidthInteger.swift
//  EllipticSwift
//
//  Created by Alexander Vlasov on 13.07.2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import Foundation
import BigInt

public protocol BytesInitializable {
    init? (_ bytes: Data)
}

public protocol BytesRepresentable {
    var bytes: Data {get}
}

public protocol ModReducable {
    func mod(_ modulus: Self) -> Self
    func modInv(_ modulus: Self) -> Self
    mutating func inplaceMod(_ modulus: Self)
    func div(_ a: Self) -> (Self, Self)
}
