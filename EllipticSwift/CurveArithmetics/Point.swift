//
//  Point.swift
//  EllipticSwift
//
//  Created by Alexander Vlasov on 10.07.2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import Foundation
import BigInt

public struct AffineCoordinates {
    public var isInfinity: Bool = false
    public var X: BigUInt
    public var Y: BigUInt
    public init(_ x: BigUInt, _ y: BigUInt) {
        self.X = x
        self.Y = y
    }
    internal mutating func setInfinity() {
        self.isInfinity = true
    }
}

public struct AffinePoint {
    public var curve: Curve
    public var isInfinity: Bool = true
    internal var rawX: PrimeFieldElement
    internal var rawY: PrimeFieldElement
    public var X: BigUInt {
        return self.rawX.value
    }
    public var Y: BigUInt {
        return self.rawY.value
    }
    
    public var coordinates: AffineCoordinates {
        if !self.isInfinity {
            return AffineCoordinates(self.X, self.Y)
        } else {
            var p = AffineCoordinates(0, 0)
            p.setInfinity()
            return p
        }
    }
    
    internal init(_ rawX: PrimeFieldElement, _ rawY: PrimeFieldElement, _ curve: Curve) {
        precondition(rawX.field.isEqualTo(rawY.field), "X and Y should belong to the same field")
        self.rawX = rawX
        self.rawY = rawY
        self.curve = curve
        self.isInfinity = false
    }
    
    public func toProjective() -> ProjectivePoint {
        if self.isInfinity {
            return ProjectivePoint.infinityPoint(self.curve)
        }
        let field = self.curve.field
        let one = field.identityElement
        let p = ProjectivePoint(self.rawX, self.rawY, one, curve)
        return p
    }
    
    public func isEqualTo(_ other: AffinePoint) -> Bool {
        if !self.curve.isEqualTo(other.curve) {
            return false
        }
        return self.rawX.isEqualTo(other.rawX) && self.rawY.isEqualTo(other.rawY)
    }
}

public struct ProjectivePoint { // also refered as Jacobian Point
    public var curve: Curve
    
    public var isInfinity: Bool {
        return self.rawZ.rawValue == 0
    }
    public var rawX: PrimeFieldElement
    public var rawY: PrimeFieldElement
    public var rawZ: PrimeFieldElement
    
    public static func infinityPoint(_ curve: Curve) -> ProjectivePoint {
        let field = curve.field
        let zero = field.fromValue(0)
        let one = field.fromValue(1)
        return ProjectivePoint(zero, one, zero, curve)
    }
    
    public func isEqualTo(_ other: ProjectivePoint) -> Bool {
        return self.toAffine().isEqualTo(other.toAffine())
    }
    
    internal init(_ rawX: PrimeFieldElement, _ rawY: PrimeFieldElement, _ rawZ: PrimeFieldElement, _ curve: Curve) {
        precondition(rawX.field.isEqualTo(rawY.field), "X and Y should belong to the same field")
        precondition(rawX.field.isEqualTo(rawZ.field), "X and Z should belong to the same field")
        self.rawX = rawX
        self.rawY = rawY
        self.rawZ = rawZ
        self.curve = curve
    }

    public func toAffine() -> AffinePoint {
        if self.isInfinity {
            let field = curve.field
            let zero = field.fromValue(0)
            var p = AffinePoint(zero, zero, self.curve)
            p.isInfinity = true
            return p
        }
        let field = self.curve.field
        let zInv = field.inv(self.rawZ)
        let zInv2 = field.mul(zInv, zInv)
        let zInv3 = field.mul(zInv2, zInv)
        let affineX = field.mul(self.rawX, zInv2)
        let affineY = field.mul(self.rawY, zInv3)
        return AffinePoint(affineX, affineY, self.curve)
    }
}
