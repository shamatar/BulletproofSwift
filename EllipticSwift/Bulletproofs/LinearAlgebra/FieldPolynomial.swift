//
//  FieldPolynomial.swift
//  EllipticSwift
//
//  Created by Alexander Vlasov on 11.07.2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import Foundation
import BigInt
public struct FieldPolynomial {
    public var coefficients: [BigUInt]
    
    
    public init (_ coefficients: [BigUInt]) {
        self.coefficients = coefficients;
    }
}

