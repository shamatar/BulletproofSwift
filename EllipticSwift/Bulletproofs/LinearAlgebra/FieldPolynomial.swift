//
//  FieldPolynomial.swift
//  EllipticSwift
//
//  Created by Alexander Vlasov on 11.07.2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import Foundation

public struct  FieldPolynomial {
    public var coefficients: [PrimeFieldElement]
    
    
    public init (_ coefficients: [PrimeFieldElement]) {
        self.coefficients = coefficients;
    }
}

