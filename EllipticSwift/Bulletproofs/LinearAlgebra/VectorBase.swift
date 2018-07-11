//
//  VectorBase.swift
//  EllipticSwift
//
//  Created by Alexander Vlasov on 11.07.2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import Foundation
import BigInt

public struct VectorBase{
    public var gs: GeneratorVector
    public var hs: GeneratorVector
    public var h: AffinePoint
    
    public init (gs: GeneratorVector, hs: GeneratorVector, h: AffinePoint) {
        self.gs = gs;
        self.hs = hs;
        self.h = h;
    }
    
    public func commit(gExp: [BigUInt], blinding: BigUInt) -> AffinePoint {
        let blind = blinding * self.h
        let commitGs = self.gs.commit(gExp)
        let res = blind + commitGs
        return res.toAffine()
    }
    
    public func commitToTwoVectors(gExp: [BigUInt], hExp: [BigUInt], blinding: BigUInt) -> AffinePoint {
        let blind = blinding * self.h
        let commitGs = self.gs.commit(gExp)
        let commitHs = self.hs.commit(hExp)
        let res = blind + commitGs + commitHs
        return res.toAffine();
    }
}
