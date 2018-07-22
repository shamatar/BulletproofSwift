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
    public var coefficients: [GeneralPrimeFieldElement]
    
    public init (_ coefficients: [GeneralPrimeFieldElement]) {
        self.coefficients = coefficients;
    }
}

