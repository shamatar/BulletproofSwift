//
//  RangeProof.swift
//  EllipticSwift
//
//  Created by Alexander Vlasov on 11.07.2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import Foundation
import BigInt

public struct RangeProof {
    public var aI: AffinePoint
    public var s: AffinePoint
    public var tCommits: GeneratorVector
    public var tauX: BigUInt
    public var mu: BigUInt
    public var t: BigUInt
    public var productProof: InnerProductProof
    
    public init (aI: AffinePoint, s: AffinePoint, tCommits: GeneratorVector, tauX: BigUInt, mu: BigUInt, t: BigUInt, productProof: InnerProductProof) {
        self.aI = aI
        self.s = s
        self.tCommits = tCommits
        self.tauX = tauX
        self.mu = mu
        self.t = t
        self.productProof = productProof
    }
    
    public var numIntegers: Int{
        return 5
    }
    public var numElements: Int {
        return 2 + self.tCommits.vector.count + self.productProof.L.count + self.productProof.R.count
    }
}
