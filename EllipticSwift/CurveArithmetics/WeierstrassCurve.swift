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
    public var field: PrimeField
    public var order: BigUInt
    public var A: PrimeFieldElement
    public var B: PrimeFieldElement
    public var generator: AffinePoint?
    
    internal var aIsZero: Bool = false
    internal var bIsZero: Bool = false
    
    public init(field: PrimeField, order: BigUInt, A: BigUInt, B: BigUInt) {
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
        var det = field.mul(self.A, self.A)
        det = field.mul(det, self.A)
        det = field.mul(det, field.fromValue(4))
        var det2 = field.mul(self.B, self.B)
        det2 = field.mul(det2, field.fromValue(27))
        det = field.add(det, det2)
        precondition(det.value != 0, "Creating a curve with 0 determinant")
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
        let field = p.rawX.field
        let lhs = field.mul(p.rawY, p.rawY) // y^2
        var rhs = field.mul(p.rawX, p.rawX)
        rhs = field.mul(rhs, p.rawX) // x^3
        if !self.aIsZero {
            rhs = field.add(rhs, field.mul(p.rawX, self.A)) // x^3 + a*x
        }
        if !self.bIsZero {
            rhs = field.add(rhs, self.B) // x^3 + a*x + b
        }
        return lhs.isEqualTo(rhs)
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
            self.A.isEqualTo(other.A) &&
            self.B.isEqualTo(other.B)
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
        var zs = [PrimeFieldElement]() // Pz^2, Pz^3, Qz^2, Qz^3
        zs.append(field.mul(p.rawZ, p.rawZ)) // Pz^2
        zs.append(field.mul(p.rawZ, zs[0])) // Pz^3
        zs.append(field.mul(q.rawZ, q.rawZ)) // Pz^2
        zs.append(field.mul(q.rawZ, zs[2])) // Pz^3
        var us = [PrimeFieldElement]() // Pu, Ps, Qu, Qs
        us.append(field.mul(p.rawX, zs[2])) // U1 = X1*Z2^2
        us.append(field.mul(p.rawY, zs[3])) // S1 = Y1*Z2^3
        us.append(field.mul(q.rawX, zs[0])) // U2 = X2*Z1^2
        us.append(field.mul(q.rawY, zs[1])) // S2 = Y2*Z1^3
        // Pu, Ps, Qu, Qs
        if us[0].isEqualTo(us[2]) { // U1 == U2
            if !us[1].isEqualTo(us[3]) { // S1 != S2
                return ProjectivePoint.infinityPoint(Curve.weierstrass(self))
            }
            else {
                return double(p);
            }
        }
        let h = field.sub(us[2], us[0]) // U2 - U1
        let r = field.sub(us[3], us[1]) // S2 - S1
        let h2 = field.mul(h, h) // h^2
        let h3 = field.mul(h2, h) // h^3
        var rx = field.mul(r, r) // r^2
        rx = field.sub(rx, h3) // r^2 - h^3
        let uh2 = field.mul(us[0], h2) // U1*h^2
        let TWO = field.fromValue(2)
        rx = field.sub(rx, field.mul(TWO, uh2)) // r^2 - h^3 - 2*U1*h^2
        var ry = field.sub(uh2, rx) // U1*h^2 - rx
        ry = field.mul(r, ry) // r*(U1*h^2 - rx)
        ry = field.sub(ry, field.mul(us[1], h3)) // R*(U1*H^2 - X3) - S1*H^3
        let rz = field.mul(h, field.mul(p.rawZ, q.rawZ)) // H*Z1*Z2
        return ProjectivePoint(rx, ry, rz, Curve.weierstrass(self))
    }
    
    public func neg(_ p: ProjectivePoint) -> ProjectivePoint {
        let field = self.field
        return ProjectivePoint(p.rawX, field.neg(p.rawY), p.rawZ, Curve.weierstrass(self))
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
        let py2 = field.mul(py, py)
        let FOUR = field.fromValue(4)
        let THREE = field.fromValue(3)
        let s = field.mul(FOUR, field.mul(px, py2))
        var m = field.mul(THREE, field.mul(px, px))
        if !self.aIsZero {
            let z2 = field.mul(p.rawZ, p.rawZ)
            m = field.add(m, field.mul(field.mul(z2, z2), self.A)) // m = m + z^4*A
        }
        let qx = field.sub(field.mul(m, m), field.add(s, s)) // m^2 - s^2
        let TWO = field.fromValue(2)
        let EIGHT = field.fromValue(8)
        let qy = field.sub(field.mul(m, field.sub(s, qx)), field.mul(EIGHT, field.mul(py2, py2)))
        let qz = field.mul(TWO, field.mul(py, p.rawZ))
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
        var zs = [PrimeFieldElement]() // Pz^2, Pz^3, Qz^2, Qz^3
        zs.append(field.mul(p.rawZ, p.rawZ)) // Pz^2
        zs.append(field.mul(p.rawZ, zs[0])) // Pz^3
        
        var us = [PrimeFieldElement]() // Pu, Ps, Qu, Qs
        us.append(p.rawX) // U1 = X1*Z2^2
        us.append(p.rawY) // S1 = Y1*Z2^3
        us.append(field.mul(q.rawX, zs[0])) // U2 = X2*Z1^2
        us.append(field.mul(q.rawY, zs[1])) // S2 = Y2*Z1^3
        if us[0].isEqualTo(us[2]) {
            if !us[1].isEqualTo(us[3]) {
                return ProjectivePoint.infinityPoint(Curve.weierstrass(self))
            }
            else {
                return double(p);
            }
        }
        let h = field.sub(us[2], us[0])
        let r = field.sub(us[3], us[1]) // S2 - S1
        let h2 = field.mul(h, h) // h^2
        let h3 = field.mul(h2, h) // h^3
        var rx = field.mul(r, r) // r^2
        rx = field.sub(rx, h3) // r^2 - h^3
        let uh2 = field.mul(us[0], h2) // U1*h^2
        let TWO = field.fromValue(2)
        rx = field.sub(rx, field.mul(TWO, uh2)) // r^2 - h^3 - 2*U1*h^2
        var ry = field.sub(uh2, rx) // U1*h^2 - rx
        ry = field.mul(r, ry) // r*(U1*h^2 - rx)
        ry = field.sub(ry, field.mul(us[1], h3)) // R*(U1*H^2 - X3) - S1*H^3
        let rz = field.mul(h, p.rawZ) // H*Z1*Z2
        return ProjectivePoint(rx, ry, rz, Curve.weierstrass(self))
    }
    
    public func mul(_ scalar: BigUInt, _ p: AffinePoint) -> ProjectivePoint {
        return wNAFmul(scalar, p)
    }
    
    func wNAFmul(_ scalar: BigUInt, _ p: AffinePoint, windowSize: Int = DefaultWindowSize) -> ProjectivePoint {
        if scalar == 0 {
            return ProjectivePoint.infinityPoint(Curve.weierstrass(self))
        }
        if p.isInfinity {
            return ProjectivePoint.infinityPoint(Curve.weierstrass(self))
        }
        let reducedScalar = scalar % self.order
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
    
    
}

