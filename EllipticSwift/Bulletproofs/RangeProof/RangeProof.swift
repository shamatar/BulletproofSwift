//
//  RangeProof.swift
//  EllipticSwift
//
//  Created by Alexander Vlasov on 11.07.2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import Foundation
import BigInt

public struct RangeProof: CustomStringConvertible {
    public var aI: AffinePoint
    public var s: AffinePoint
    public var tCommits: GeneratorVector
    public var tauX: BigNumber
    public var mu: BigNumber
    public var t: BigNumber
    public var productProof: InnerProductProof
    
    public init (aI: AffinePoint, s: AffinePoint, tCommits: GeneratorVector, tauX: BigNumber, mu: BigNumber, t: BigNumber, productProof: InnerProductProof) {
        self.aI = aI
        self.s = s
        self.tCommits = tCommits
        self.tauX = tauX
        self.mu = mu
        self.t = t
        self.productProof = productProof
    }
    
    public var numIntegers: Int {
        return 5
    }
    public var numElements: Int {
        return 2 + self.tCommits.vector.count + self.productProof.L.count + self.productProof.R.count
    }
    
    public var description: String {
        var str = ""
        str += "aI = " + self.aI.description + "\n"
        str += "s = " + self.s.description + "\n"
        str += "tauX = " + self.tauX.bytes.toHexString() + "\n"
        str += "mu = " + self.mu.bytes.toHexString() + "\n"
        str += "t = " + self.t.bytes.toHexString() + "\n"
        return str
    }
}
