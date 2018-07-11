//
//  Curve.swift
//  EllipticSwift
//
//  Created by Alexander Vlasov on 10.07.2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import Foundation
import BigInt

public enum Curve {
    case weierstrass(WeierstrassCurve)
//    case montgommery(MontgommeryCurve)
//    case edwards(EdwardsCurve)
    
    public func checkOnCurve(_ p: AffinePoint) -> Bool {
        switch self {
        case .weierstrass(let curve):
            return curve.checkOnCurve(p)
        }
    }
    
    public var field: PrimeField {
        switch self {
        case .weierstrass(let curve):
            return curve.field
        }
    }
    
    public func isEqualTo(_ other: Curve) -> Bool {
        switch self {
        case .weierstrass(let thisCurve):
            guard case .weierstrass(let otherCurve) = other else {
                return false
            }
            return thisCurve.isEqualTo(otherCurve)
        }
    }
    
    public func add(_ p: ProjectivePoint, _ q: ProjectivePoint) -> ProjectivePoint {
        switch self {
        case .weierstrass(let curve):
            return curve.add(p, q)
        }
    }
    
    public func sub(_ p: ProjectivePoint, _ q: ProjectivePoint) -> ProjectivePoint {
        switch self {
        case .weierstrass(let curve):
            return curve.sub(p, q)
        }
    }
    
    public func mixedAdd(_ p: ProjectivePoint, _ q: AffinePoint) -> ProjectivePoint {
        switch self {
        case .weierstrass(let curve):
            return curve.mixedAdd(p, q)
        }
    }
    
    public func mul(_ scalar: BigUInt , _ p: AffinePoint) -> ProjectivePoint {
        switch self {
        case .weierstrass(let curve):
            return curve.mul(scalar, p)
        }
    }
    
    public func neg(_ p: ProjectivePoint) -> ProjectivePoint {
        switch self {
        case .weierstrass(let curve):
            return curve.neg(p)
        }
    }
    
    public var order: BigUInt {
        switch self {
        case .weierstrass(let curve):
            return curve.order
        }
    }
    
}
