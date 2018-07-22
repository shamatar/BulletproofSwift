//
//  WeierstrassCurve.swift
//  EllipticSwift
//
//  Created by Alexander Vlasov on 10.07.2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import Foundation
import BigInt

public class WeierstrassCurve {
    public var field: GeneralPrimeField
    public var order: BigNumber
    public var curveOrderField: GeneralPrimeField
    public var A: GeneralPrimeFieldElement
    public var B: GeneralPrimeFieldElement
    public var generator: AffinePoint?
    
    internal var aIsZero: Bool = false
    internal var bIsZero: Bool = false
    
    public init(field: GeneralPrimeField, order: BigNumber, A: BigNumber, B: BigNumber) {
        self.field = field
        self.order = order
        let reducedA = field.fromValue(A)
        let reducedB = field.fromValue(B)
        if A == 0 {
            self.aIsZero = true
        }
        if B == 0 {
            self.bIsZero = true
        }
        self.A = reducedA
        self.B = reducedB
        let det = field.fromValue(BigNumber(integerLiteral: 4)) * self.A * self.A * self.A + field.fromValue(BigNumber(integerLiteral: 27)) * self.B * self.B
        precondition(det.value != 0, "Creating a curve with 0 determinant")
        self.curveOrderField = GeneralPrimeField(self.order)
    }
    
    public func setGenerator(_ p: AffineCoordinates) -> Bool {
        if p.isInfinity {
            return false
        }
        let reducedGeneratorX = field.fromValue(p.X)
        let reducedGeneratorY = field.fromValue(p.Y)
        let generatorPoint = AffinePoint(reducedGeneratorX, reducedGeneratorY, Curve.weierstrass(self))
        if !checkOnCurve(generatorPoint) {
            return false
        }
        if !self.mul(self.order, generatorPoint).isInfinity {
            return false
        }
        self.generator = generatorPoint
        return true
    }

    
    public func checkOnCurve(_ p: AffinePoint) -> Bool {
        if p.isInfinity {
            return false
        }
        let lhs = p.rawY * p.rawY // y^2
        var rhs = p.rawX * p.rawX * p.rawX
        if !self.aIsZero {
            rhs = rhs + self.A * p.rawX // x^3 + a*x
        }
        if !self.bIsZero {
            rhs = rhs + self.B // x^3 + a*x + b
        }
        return lhs == rhs
    }
    
    public func toPoint(_ x: BigUInt, _ y: BigUInt) -> AffinePoint? {
        return toPoint(AffineCoordinates(x, y))
    }
    
    public func toPoint(_ p: AffineCoordinates) -> AffinePoint? {
        let reducedX = field.fromValue(p.X)
        let reducedY = field.fromValue(p.Y)
        let point = AffinePoint(reducedX, reducedY, Curve.weierstrass(self))
        if !checkOnCurve(point) {
            return nil
        }
        return point
    }
    
    public func isEqualTo(_ other: WeierstrassCurve) -> Bool {
        return self.field.isEqualTo(other.field) &&
            self.order == other.order &&
            self.A == other.A &&
            self.B == other.B
    }
    
    public func hashInto(_ data: Data) -> AffinePoint {
        let bn = BigNumber(data)
        precondition(bn != nil)
        var seed = self.field.fromValue(bn!)
        for _ in 0 ..< 100 {
            let x = seed
            var y2 = x * x * x
            if !self.aIsZero {
                y2 = y2 + self.A * x
            }
            if !self.bIsZero {
                y2 = y2 + self.B
            }
            // TODO
            let yReduced = y2.sqrt()
            if y2 == yReduced * yReduced {
                return AffinePoint(x, yReduced, Curve.weierstrass(self))
            }
            seed = seed + self.field.identityElement
        }
        precondition(false, "Are you using a normal curve?")
        return ProjectivePoint.infinityPoint(Curve.weierstrass(self)).toAffine()
    }
}

extension WeierstrassCurve {
    public func add(_ p: ProjectivePoint, _ q: ProjectivePoint) -> ProjectivePoint {
        if p.isInfinity {
            return q
        }
        if q.isInfinity {
            return p
        }
        let field = self.field
        let pz2 = p.rawZ * p.rawZ// Pz^2
        let pz3 = p.rawZ * pz2 // Pz^3
        let qz2 = q.rawZ * q.rawZ // Pz^2
        let qz3 = q.rawZ * qz2 // Pz^3
        let u1 = p.rawX * qz2 // U1 = X1*Z2^2
        let s1 = p.rawY * qz3 // S1 = Y1*Z2^3
        let u2 = q.rawX * pz2 // U2 = X2*Z1^2
        let s2 = q.rawY * pz3 // S2 = Y2*Z1^3
        // Pu, Ps, Qu, Qs
        if u1 == u2 { // U1 == U2
            if s1 != s2 { // S1 != S2
                return ProjectivePoint.infinityPoint(Curve.weierstrass(self))
            }
            else {
                return double(p)
            }
        }
        let h = u2 - u1 // U2 - U1
        let r = s2 - s1 // S2 - S1
        let h2 = h * h // h^2
        let h3 = h2 * h // h^3
        var rx = r * r // r^2
        rx = rx - h3 // r^2 - h^3
        let uh2 = u1 * h2 // U1*h^2
        let TWO = field.fromValue(BigNumber(integerLiteral: 2))
        rx = rx - (TWO * uh2) // r^2 - h^3 - 2*U1*h^2
        var ry = uh2 - rx // U1*h^2 - rx
        ry = r * ry // r*(U1*h^2 - rx)
        ry = ry - (s1 * h3) // R*(U1*H^2 - X3) - S1*H^3
        let rz = h * p.rawZ * q.rawZ // H*Z1*Z2
        return ProjectivePoint(rx, ry, rz, Curve.weierstrass(self))
    }
    
    public func neg(_ p: ProjectivePoint) -> ProjectivePoint {
        return ProjectivePoint(p.rawX, p.rawY.negate(), p.rawZ, Curve.weierstrass(self))
    }
    
    public func sub(_ p: ProjectivePoint, _ q: ProjectivePoint) -> ProjectivePoint {
        return self.add(p, neg(q))
    }
    
    public func double(_ p: ProjectivePoint) -> ProjectivePoint {
        if p.isInfinity {
           return ProjectivePoint.infinityPoint(Curve.weierstrass(self))
        }
        let field = self.field
        let px = p.rawX
        let py = p.rawY
        let py2 = py * py
        let FOUR = field.fromValue(BigNumber(integerLiteral: 4))
        let THREE = field.fromValue(BigNumber(integerLiteral: 3))
        var s = FOUR * px
        s = s * py2
        var m = THREE * px
        m = m * px
        if !self.aIsZero {
            let z2 = p.rawZ * p.rawZ
            m = m + z2 * z2 * self.A // m = m + z^4*A
        }
        let qx = m * m - s - s // m^2 - 2*s
        let TWO = field.fromValue(BigNumber(integerLiteral: 2))
        let EIGHT = field.fromValue(BigNumber(integerLiteral: 8))
        let qy = m * (s - qx) - (EIGHT * py2 * py2)
        let qz = TWO * py * p.rawZ
        return ProjectivePoint(qx, qy, qz, Curve.weierstrass(self))
    }
    
    public func mixedAdd(_ p: ProjectivePoint, _ q: AffinePoint) -> ProjectivePoint {
        if p.isInfinity {
            return q.toProjective()
        }
        if q.isInfinity {
            return p
        }
        let field = self.field
        let pz2 = p.rawZ * p.rawZ // Pz^2
        let pz3 = p.rawZ * pz2 // Pz^3
        
        let u1 = p.rawX // U1 = X1*Z2^2
        let s1 = p.rawY // S1 = Y1*Z2^3
        let u2 = q.rawX * pz2 // U2 = X2*Z1^2
        let s2 = q.rawY * pz3 // S2 = Y2*Z1^3
        if u1 == u2 {
            if s1 != s2 {
                return ProjectivePoint.infinityPoint(Curve.weierstrass(self))
            }
            else {
                return double(p)
            }
        }
        let h = u2 - u1
        let r = s2 - s1 // S2 - S1
        let h2 = h * h // h^2
        let h3 = h2 * h// h^3
        var rx = r * r // r^2
        rx = rx - h3 // r^2 - h^3
        let uh2 = u1 * h2 // U1*h^2
        let TWO = field.fromValue(BigNumber(integerLiteral: 2))
        rx = rx - (TWO * uh2) // r^2 - h^3 - 2*U1*h^2
        var ry = uh2 - rx // U1*h^2 - rx
        ry = r * ry // r*(U1*h^2 - rx)
        ry = ry - (s1 * h3) // R*(U1*H^2 - X3) - S1*H^3
        let rz = h * p.rawZ // H*Z1*Z2
        return ProjectivePoint(rx, ry, rz, Curve.weierstrass(self))
    }
    
//    public func mul(_ scalar: BigUInt, _ p: AffinePoint) -> ProjectivePoint {
//        return wNAFmul(scalar, p)
//    }
    
    public func mul(_ scalar: GeneralPrimeFieldElement, _ p: AffinePoint) -> ProjectivePoint {
        return wNAFmul(scalar.value, p)
    }
    
    public func mul(_ scalar: BigNumber, _ p: AffinePoint) -> ProjectivePoint {
        return wNAFmul(scalar, p)
    }
    
    func wNAFmul(_ scalar: BigNumber,_ p: AffinePoint, windowSize: Int = DefaultWindowSize) -> ProjectivePoint {
        if scalar.isZero {
            return ProjectivePoint.infinityPoint(Curve.weierstrass(self))
        }
        if p.isInfinity {
            return ProjectivePoint.infinityPoint(Curve.weierstrass(self))
        }
        let reducedScalar = scalar.mod(self.order)
        let projectiveP = p.toProjective()
        let numPrecomputedElements = (1 << (windowSize-2)) // 2**(w-1) precomputations required
        var precomputations = [ProjectivePoint]() // P, 3P, 5P, 7P, 9P, 11P, 13P, 15P ...
        precomputations.append(projectiveP)
        let dbl = double(projectiveP)
        precomputations.append(mixedAdd(dbl, p))
        for i in 2 ..< numPrecomputedElements {
            precomputations.append(add(precomputations[i-1], dbl))
        }
        let lookups = computeWNAF(scalar: reducedScalar, windowSize: windowSize)
        var result = ProjectivePoint.infinityPoint(Curve.weierstrass(self))
        let range = (0 ..< lookups.count).reversed()
        for i in range {
            result = double(result)
            let lookup = lookups[i]
            if lookup == 0 {
                continue
            } else if lookup > 0 {
                let idx = lookup >> 1
                let precomputeToAdd = precomputations[idx]
                result = add(result, precomputeToAdd)
            } else if lookup < 0 {
                let idx = -lookup >> 1
                let precomputeToAdd = neg(precomputations[idx])
                result = add(result, precomputeToAdd)
            }
        }
        return result
    }
    
//    func wNAFmul(_ scalar: BigUInt, _ p: AffinePoint, windowSize: Int = DefaultWindowSize) -> ProjectivePoint {
//        if scalar == 0 {
//            return ProjectivePoint.infinityPoint(Curve.weierstrass(self))
//        }
//        if p.isInfinity {
//            return ProjectivePoint.infinityPoint(Curve.weierstrass(self))
//        }
//        let reducedScalar = scalar % self.order
//        let projectiveP = p.toProjective()
//        let numPrecomputedElements = (1 << (windowSize-2)) // 2**(w-1) precomputations required
//        var precomputations = [ProjectivePoint]() // P, 3P, 5P, 7P, 9P, 11P, 13P, 15P ...
//        precomputations.append(projectiveP)
//        let dbl = double(projectiveP)
//        precomputations.append(mixedAdd(dbl, p))
//        for i in 2 ..< numPrecomputedElements {
//            precomputations.append(add(precomputations[i-1], dbl))
//        }
//        let lookups = computeWNAF(scalar: reducedScalar, windowSize: windowSize)
//        var result = ProjectivePoint.infinityPoint(Curve.weierstrass(self))
//        let range = (0 ..< lookups.count).reversed()
//        for i in range {
//            result = double(result)
//            let lookup = lookups[i]
//            if lookup == 0 {
//                continue
//            } else if lookup > 0 {
//                let idx = lookup >> 1
//                let precomputeToAdd = precomputations[idx]
//                result = add(result, precomputeToAdd)
//            } else if lookup < 0 {
//                let idx = -lookup >> 1
//                let precomputeToAdd = neg(precomputations[idx])
//                result = add(result, precomputeToAdd)
//            }
//        }
//        return result
//    }
    
    
}

