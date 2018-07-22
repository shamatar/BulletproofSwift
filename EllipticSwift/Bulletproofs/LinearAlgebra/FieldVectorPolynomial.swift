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
    public var field: GeneralPrimeField
    
    public init (_ coefficients: [FieldVector], field: GeneralPrimeField) {
        precondition(coefficients.count > 0)
        for i in 0 ..< coefficients.count - 1 {
            precondition(coefficients[i].q == coefficients[i+1].q)
        }
        self.coefficients = coefficients
        self.field = field
    }
    
    public func evaluate(_ x: BigNumber) -> FieldVector {
        let xRed = self.field.fromValue(x)
        let result = self.coefficients.enumerated().map { (arg: (offset: Int, element: FieldVector)) -> (FieldVector, BigNumber) in
            let (index, element) = arg
            let bn = BigNumber(integerLiteral: UInt64(index))
            return (element, bn)
            }.map { (arg) -> (FieldVector, GeneralPrimeFieldElement) in
                let (el, idx) = arg
                return (el, self.field.pow(xRed, idx))
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
        var newCoeffs = [GeneralPrimeFieldElement](repeating: self.field.zeroElement, count: self.coefficients.count + other.coefficients.count)
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
