//
//  GeneratorVector.swift
//  EllipticSwift
//
//  Created by Alexander Vlasov on 11.07.2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import Foundation

public struct GeneratorVector {
    public var gs : [AffinePoint]
    public var curve: Curve
    
    public init (_ gs: [AffinePoint], _ curve: Curve) {
        for g in gs {
            precondition(curve.isEqualTo(g.curve))
        }
        self.gs = gs;
        self.curve = curve;
    }
    
    public init (_ gs: [AffinePoint]) {
        precondition(gs.count > 0)
        let curve = gs[0].curve
        for g in gs {
            precondition(curve.isEqualTo(g.curve))
        }
        self.gs = gs
        self.curve = curve
    }
    
    public func subvector(_ from: Int, _ noninclusiveTo: Int) -> GeneratorVector {
        precondition(self.gs.count > 0)
        var elements = [AffinePoint]()
        for i in from ..< noninclusiveTo {
            elements.append(self.gs[i])
        }
        return GeneratorVector(elements, self.curve)
    }
    
    public func commit(_ exponents: [BigNumber]) -> AffinePoint {
        precondition(exponents.count == self.gs.count, "Commitment base and vector should have the same length");
        var result = exponents[0] * self.gs[0]
        for i in 1 ..< self.gs.count {
            result = result + exponents[i] * self.gs[i]
        }
        return result.toAffine()
    }
    
    public func commit(_ vector: FieldVector) -> AffinePoint {
        let exponents = vector.vector
        return commit(exponents)
    }
    
    public func commit(_ exponents: [GeneralPrimeFieldElement]) -> AffinePoint {
        let exps = exponents.map { (el: GeneralPrimeFieldElement) -> BigNumber in
            return el.value
        }
        return commit(exps)
    }
    
    public func sum() -> AffinePoint {
        precondition(self.gs.count > 0)
        var result = self.gs[0].toProjective()
        for i in 1 ..< self.gs.count {
            result = result + self.gs[i]
        }
        return result.toAffine()
    }
    
    public func hadamardProduct(_ exponents: [BigNumber]) -> GeneratorVector {
        precondition(exponents.count == self.gs.count, "Commitment base and vector should have the same length");
        precondition(self.gs.count > 0)
        var elements = [AffinePoint]()
        for i in 0 ..< self.gs.count {
            elements.append((exponents[i]*self.gs[i]).toAffine())
        }
        return GeneratorVector(elements, self.curve)
    }
    
    public func add(_ other: AffinePoint) -> GeneratorVector {
        precondition(self.gs.count > 0)
        precondition(self.curve.isEqualTo(other.curve))
        var elements = [AffinePoint]()
        for i in 0 ..< self.gs.count {
            elements.append((other + self.gs[i]).toAffine())
        }
        return GeneratorVector(elements, self.curve)
    }
    
    public func add(_ other: GeneratorVector) -> GeneratorVector {
        precondition(self.gs.count == other.gs.count)
        precondition(self.curve.isEqualTo(other.curve))
        var elements = [AffinePoint]()
        for i in 0 ..< self.gs.count {
            elements.append((other.gs[i] + self.gs[i]).toAffine())
        }
        return GeneratorVector(elements, self.curve)
    }
    
    public func get(_ i: Int) -> AffinePoint {
        return self.gs[i]
    }
    
    public var size: Int {
        return self.gs.count
    }
    
    public var vector: [AffinePoint] {
        return self.gs
    }
    
}
