//
//  RangeProofSystem.swift
//  EllipticSwift
//
//  Created by Alexander Vlasov on 21.07.2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import Foundation


public struct RangeProofSystem {
    public var vectorBase: VectorBase
    public var base: PeddersenBase
    
    public init(_ params: GeneratorParams) {
        self.vectorBase = VectorBase(gs: params.gs, hs: params.hs, h: params.h)
        self.base = params.base
    }
    
    public func generateProof(witness: PeddersenCommitment) -> RangeProof {
        let vectorBase = self.vectorBase
        let base = self.base
        return RangeProofProver.generateProof(vectorBase: vectorBase, base: base, witness: witness)
    }
    
    public func verify(input: AffinePoint, proof: RangeProof) -> Bool {
        let vectorBase = self.vectorBase
        let base = self.base
        return RangeProofVerifier.verify(vectorBase: vectorBase, base: base, input: input, proof: proof)
    }
}
