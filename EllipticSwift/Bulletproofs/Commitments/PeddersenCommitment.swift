//
//  PeddersenCommitment.swift
//  EllipticSwift
//
//  Created by Alexander Vlasov on 11.07.2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import Foundation
import BigInt

public struct PeddersenCommitment {
    public var base: PeddersenBase
    public var x: BigNumber {
        return self.xReduced.value
    }
    public var r: BigNumber {
        return self.rReduced.value
    }
    public var field: GeneralPrimeField
    public var xReduced: GeneralPrimeFieldElement
    public var rReduced: GeneralPrimeFieldElement
    
    public init (base: PeddersenBase, x: BigNumber) {
        self.base = base
        self.field = GeneralPrimeField(base.curve.order)
        self.xReduced = field.fromValue(x)
        self.rReduced = field.fromValue(ProofUtils.randomNumber(bitWidth: base.curve.order.bitWidth))
    }
    
    public init (base: PeddersenBase, x: BigNumber, r: BigNumber) {
        self.base = base
        self.field = GeneralPrimeField(base.curve.order)
        self.xReduced = field.fromValue(x)
        self.rReduced = field.fromValue(r)
    }
    
    public init (base: PeddersenBase, x: GeneralPrimeFieldElement, r: GeneralPrimeFieldElement) {
        self.base = base
        self.field = GeneralPrimeField(base.curve.order)
        self.xReduced = x
        self.rReduced = r
    }
    
    public func add(_ other: PeddersenCommitment) -> PeddersenCommitment {
        return PeddersenCommitment(base: self.base, x: self.xReduced + other.xReduced, r: self.rReduced + other.rReduced)
    }
    
    public func times(_ exponent: BigNumber ) -> PeddersenCommitment {
        let eReduced = self.field.fromValue(exponent)
        return PeddersenCommitment(base: self.base, x: self.xReduced * eReduced , r: self.rReduced * eReduced)
    }
    
    public func times(_ exponent: GeneralPrimeFieldElement ) -> PeddersenCommitment {
        return PeddersenCommitment(base: self.base, x: self.xReduced * exponent , r: self.rReduced * exponent)
    }
    
    public func addConstant(_ constant: BigNumber) -> PeddersenCommitment {
        let cReduced = self.field.fromValue(constant)
        return PeddersenCommitment(base: self.base, x: self.xReduced + cReduced, r: self.rReduced)
    }
    
    public func addConstant(_ constant: GeneralPrimeFieldElement) -> PeddersenCommitment {
        return PeddersenCommitment(base: self.base, x: self.xReduced + constant, r: self.rReduced)
    }
    
    public var commitment: AffinePoint {
        let commitment = self.base.commit(self.x, self.r)
        return commitment
    }
    
    public var blinding: AffinePoint {
        let p = self.r * self.base.h
        return p.toAffine()
    }
}
