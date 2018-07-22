//
//  Curve+Operations.swift
//  EllipticSwift
//
//  Created by Alexander Vlasov on 10.07.2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import Foundation
import BigInt

extension ProjectivePoint: Equatable {
    public static func == (lhs: ProjectivePoint, rhs: ProjectivePoint) -> Bool {
        return lhs.isEqualTo(rhs)
    }
    
    public static func + (lhs: ProjectivePoint, rhs: ProjectivePoint) -> ProjectivePoint {
        precondition(lhs.curve.isEqualTo(rhs.curve))
        return lhs.curve.add(lhs, rhs)
    }
    
    public static func - (lhs: ProjectivePoint, rhs: ProjectivePoint) -> ProjectivePoint {
        precondition(lhs.curve.isEqualTo(rhs.curve))
        return lhs.curve.sub(lhs, rhs)
    }
    
    public static func * (lhs: BigNumber, rhs: ProjectivePoint) -> ProjectivePoint {
        if rhs.isInfinity {
            return rhs
        }
        return rhs.curve.mul(lhs, rhs.toAffine())
    }
    
    public static func + (lhs: ProjectivePoint, rhs: AffinePoint) -> ProjectivePoint {
        precondition(lhs.curve.isEqualTo(rhs.curve))
        return lhs.curve.mixedAdd(lhs, rhs)
    }
    
}

extension AffinePoint: Equatable {
    
    public static func == (lhs: AffinePoint, rhs: AffinePoint) -> Bool {
        return lhs.isEqualTo(rhs)
    }
    
    public static func * (lhs: BigNumber, rhs: AffinePoint) -> ProjectivePoint {
        return rhs.curve.mul(lhs, rhs)
    }
    
    public static func + (lhs: AffinePoint, rhs: AffinePoint) -> ProjectivePoint {
        precondition(lhs.curve.isEqualTo(rhs.curve))
        return lhs.curve.mixedAdd(lhs.toProjective(), rhs)
    }
}
