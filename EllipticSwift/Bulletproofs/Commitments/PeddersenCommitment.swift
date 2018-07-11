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
    public var x: BigUInt
    public var r: BigUInt
    
    public init (base: PeddersenBase, x: BigUInt) {
        self.base = base
        self.x = x
        self.r = ProofUtils.randomNumber(bitWidth: base.curve.order.bitWidth)
    }
    
    public init (base: PeddersenBase, x: BigUInt, r: BigUInt) {
        self.base = base
        self.x = x
        self.r = r
    }
    
    public func add(_ other: PeddersenCommitment) -> PeddersenCommitment {
        return PeddersenCommitment(base: self.base, x: self.x + other.x, r: self.r + other.r)
    }
    
    public func times(_ exponent: BigUInt ) -> PeddersenCommitment {
        return PeddersenCommitment(base: self.base, x: self.x * exponent , r: self.r * exponent);
    }
    
    public func addConstant(_ constant: BigUInt) -> PeddersenCommitment {
        return PeddersenCommitment(base: self.base, x: self.x + constant, r: self.r)
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
