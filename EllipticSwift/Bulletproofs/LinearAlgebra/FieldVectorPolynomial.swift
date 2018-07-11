//
//  FieldVectorPolynomial.swift
//  EllipticSwift
//
//  Created by Alexander Vlasov on 11.07.2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import Foundation
import BigInt

public struct FieldVectorPolynomial {
    public var coefficients: [FieldVector];
    
    public init (_ coefficients: [FieldVector]) {
        precondition(coefficients.count > 0)
        for i in 0 ..< coefficients.count - 1 {
            precondition(coefficients[i].q == coefficients[i+1].q)
        }
        self.coefficients = coefficients
    }
    
    public func evaluate(_ x: BigUInt) -> FieldVector {
        let q = self.coefficients[0].q
        let field = PrimeField(q)
        precondition(field != nil)
        let xRed = field!.fromValue(x)
        let result = self.coefficients.enumerated().map { (index: Int, element: FieldVector) -> (FieldVector, BigUInt) in
            return (element, BigUInt(index))
            }.map { (arg) -> (FieldVector, BigUInt) in
                let (el, idx) = arg
                return (el, field!.pow(xRed, idx).value)
            }.map { (arg) -> FieldVector in
                let (el, idx) = arg
                return el.times(idx)
            }
        var res = result[0]
        for i in 1 ..< result.count {
            res = res.add(result[i])
        }
        return res
    }
    
    public func innerProduct(_ other: FieldVectorPolynomial) -> FieldPolynomial {
        let q = self.coefficients[0].q
        let field = PrimeField(q)
        precondition(field != nil)
        let ZERO = field!.fromValue(0)
        var newCoeffs = [PrimeFieldElement](repeating: ZERO, count: self.coefficients.count + other.coefficients.count)
        for i in 0 ..< self.coefficients.count {
            let coeff = self.coefficients[i]
            for j in 0 ..< other.coefficients.count {
                let otherCoeff = other.coefficients[j]
                newCoeffs[i+j] = newCoeffs[i+j] + coeff.innerPoduct(otherCoeff)
            }
        }
        return FieldPolynomial(newCoeffs)
    }
}
