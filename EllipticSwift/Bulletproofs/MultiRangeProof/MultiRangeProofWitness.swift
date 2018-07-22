//
//  MultiRangeProof.swift
//  EllipticSwift
//
//  Created by Alexander Vlasov on 22.07.2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import Foundation

public struct MultiRangeProofWitness {
    public var witnesses: [PeddersenCommitment]
    
    public init(_ witnesses: [PeddersenCommitment]) {
        self.witnesses = witnesses
    }
    
    public var commitments: [AffinePoint] {
        return self.witnesses.map({ (el) -> AffinePoint in
            return el.commitment
        })
    }
    
    
}
