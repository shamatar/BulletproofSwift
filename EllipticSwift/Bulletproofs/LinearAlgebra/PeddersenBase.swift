//
//  PeddersenBase.swift
//  EllipticSwift
//
//  Created by Alexander Vlasov on 11.07.2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import Foundation
import BigInt

public struct PeddersenBase {
    public var generator: GeneratorVector
    public var g: AffinePoint
    public var h: AffinePoint
    public var curve: Curve
    
    public init(g: AffinePoint, h: AffinePoint, curve: Curve) {
        precondition(g.curve.isEqualTo(h.curve))
        precondition(g.curve.isEqualTo(curve))
        let gens = [g, h]
        let generator = GeneratorVector(gens, g.curve)
        self.generator = generator
        self.g = g
        self.h = h
        self.curve = curve
    }
    
    public func commit(_ x: BigNumber, _ r: BigNumber) -> AffinePoint {
        return ((x * self.g) + (r * self.h)).toAffine()
    }
    
    public func commit(_ x: GeneralPrimeFieldElement, _ r: GeneralPrimeFieldElement) -> AffinePoint {
        let xValue: BigNumber = x.value
        let rValue: BigNumber = r.value
        return commit(xValue, rValue)
    }
}
