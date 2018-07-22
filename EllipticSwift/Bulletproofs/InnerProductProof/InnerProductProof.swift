//
//  InnerProductProof.swift
//  EllipticSwift
//
//  Created by Alexander Vlasov on 11.07.2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import Foundation
import BigInt

public struct InnerProductProof {
    public var L: [AffinePoint]
    public var R: [AffinePoint]
    public var a: BigNumber
    public var b: BigNumber
    
    public init (L: [AffinePoint], R: [AffinePoint], a: BigNumber, b: BigNumber) {
        self.L = L;
        self.R = R;
        self.a = a;
        self.b = b;
    }
    
    public func serialize() -> Data {
        var lData = Data()
        for l in self.L {
            lData.append(ProofUtils.serialize(l))
        }
        var rData = Data()
        for r in self.R {
            rData.append(ProofUtils.serialize(r))
        }
        let aData = ProofUtils.serialize(self.a)
        let bData = ProofUtils.serialize(self.b)
        return lData + rData + aData + bData
    }
}
