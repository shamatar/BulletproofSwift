//
//  MultiRangeProofSystem.swift
//  EllipticSwift
//
//  Created by Alexander Vlasov on 22.07.2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import Foundation

public struct MultiRangeProofSystem {
    public var vectorBase: VectorBase
    public var base: PeddersenBase
    
    public init(_ params: GeneratorParams) {
        self.vectorBase = VectorBase(gs: params.gs, hs: params.hs, h: params.h)
        self.base = params.base
    }
    
    public func generateProof(witness: MultiRangeProofWitness) -> RangeProof {
        let vectorBase = self.vectorBase
        let base = self.base
        return MultiRangeProofProver.generateProof(vectorBase: vectorBase, base: base, witness: witness)
    }
    
    public func verify(inputs: [AffinePoint], proof: RangeProof) -> Bool {
        let vectorBase = self.vectorBase
        let base = self.base
        return MultiRangeProofVerifier.verify(vectorBase: vectorBase, base: base, inputs: inputs, proof: proof)
    }
}
