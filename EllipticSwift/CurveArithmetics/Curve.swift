//
//  Curve.swift
//  EllipticSwift
//
//  Created by Alexander Vlasov on 10.07.2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import Foundation

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
}
