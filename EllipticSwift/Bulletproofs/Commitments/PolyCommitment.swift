//
//  PolyCommitment.swift
//  EllipticSwift
//
//  Created by Alexander Vlasov on 11.07.2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import Foundation
import BigInt

public struct PolyCommitment {
    
    public var coefficientCommitments: [PeddersenCommitment]
    
    public init (_ coefficientCommitments: [PeddersenCommitment]) {
        self.coefficientCommitments = coefficientCommitments
    }
    
    public func evaluate(_ x: BigUInt) -> PeddersenCommitment  {
        var multiplier = BigUInt(1)
        var intermediates = [PeddersenCommitment]()
        intermediates.append(self.coefficientCommitments[0].times(multiplier))
        for i in 1 ..< self.coefficientCommitments.count {
            multiplier = multiplier * x
            intermediates.append(self.coefficientCommitments[i].times(multiplier))
        }
        var result = intermediates[0]
        for i in 1 ..< intermediates.count {
            result = result.add(intermediates[i])
        }
        return result
    }
    
    public func getNonzeroCommitments() -> [AffinePoint] {
        let res = self.coefficientCommitments.filter { (el) -> Bool in
                return el.r != 0
            }.map { (el) -> AffinePoint in
                return el.commitment
            }
        return res
    }
    
    public static func from(base: PeddersenBase, x0: BigUInt, xs: [BigUInt]) -> PolyCommitment {
        let toZero = PeddersenCommitment(base: base, x: x0, r: 0)
        var coeffs = [PeddersenCommitment]()
        coeffs.append(toZero)
        for x in xs {
            coeffs.append(PeddersenCommitment(base: base, x: x))
        }
        return PolyCommitment(coeffs)
    }
}
