//
//  Point.swift
//  EllipticSwift
//
//  Created by Alexander Vlasov on 10.07.2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import Foundation
import BigInt

public struct AffineCoordinates: CustomStringConvertible {
    public var description: String {
        if self.isInfinity {
            return "Point of O"
        } else {
            return "Point " + "(0x" + String(self.X, radix: 16) + ", 0x" + String(self.Y, radix: 16) + ")"
        }
    }
    
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

public struct AffinePoint: CustomStringConvertible {
    public var description: String {
        return self.coordinates.description
    }
    
    public var curve: Curve
    public var isInfinity: Bool = true
    internal var rawX: GeneralPrimeFieldElement
    internal var rawY: GeneralPrimeFieldElement
    public var X: BigNumber {
        return self.rawX.value
    }
    public var Y: BigNumber {
        return self.rawY.value
    }
    
    public var coordinates: AffineCoordinates {
        if !self.isInfinity {
            return AffineCoordinates(BigUInt(self.X.bytes), BigUInt(self.Y.bytes))
        } else {
            var p = AffineCoordinates(0, 0)
            p.setInfinity()
            return p
        }
    }
    
    internal init(_ rawX: GeneralPrimeFieldElement, _ rawY: GeneralPrimeFieldElement, _ curve: Curve) {
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
        return self.rawX == other.rawX && self.rawY == other.rawY
    }
}

public struct ProjectivePoint { // also refered as Jacobian Point
    public var curve: Curve
    
    public var isInfinity: Bool {
        return self.rawZ.value == 0
    }
    public var rawX: GeneralPrimeFieldElement
    public var rawY: GeneralPrimeFieldElement
    public var rawZ: GeneralPrimeFieldElement
    
    public static func infinityPoint(_ curve: Curve) -> ProjectivePoint {
        let field = curve.field
        let zero = field.fromValue(BigNumber(integerLiteral: 0))
        let one = field.fromValue(BigNumber(integerLiteral: 1))
        return ProjectivePoint(zero, one, zero, curve)
    }
    
    public func isEqualTo(_ other: ProjectivePoint) -> Bool {
        return self.toAffine().isEqualTo(other.toAffine())
    }
    
    internal init(_ rawX: GeneralPrimeFieldElement, _ rawY: GeneralPrimeFieldElement, _ rawZ: GeneralPrimeFieldElement, _ curve: Curve) {
//        precondition(rawX.field.isEqualTo(rawY.field), "X and Y should belong to the same field")
//        precondition(rawX.field.isEqualTo(rawZ.field), "X and Z should belong to the same field")
        self.rawX = rawX
        self.rawY = rawY
        self.rawZ = rawZ
        self.curve = curve
    }

    public func toAffine() -> AffinePoint {
        if self.isInfinity {
            let field = curve.field
            let zero = field.fromValue(BigNumber(integerLiteral: 0))
            var p = AffinePoint(zero, zero, self.curve)
            p.isInfinity = true
            return p
        }
        let zInv = self.rawZ.inv()
        let zInv2 = zInv * zInv
        let zInv3 = zInv2 * zInv
        let affineX = self.rawX * zInv2
        let affineY = self.rawY * zInv3
        return AffinePoint(affineX, affineY, self.curve)
    }
}
