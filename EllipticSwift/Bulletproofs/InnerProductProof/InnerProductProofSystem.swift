//
//  InnerProductProofSystem.swift
//  EllipticSwift
//
//  Created by Alexander Vlasov on 21.07.2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import Foundation

public struct InnerProductProofSystem {
    public var vectorBase: VectorBase
    
    public init(_ params: GeneratorParams) {
        self.vectorBase = VectorBase(gs: params.gs, hs: params.hs, h: params.v)
    }
    
    public func generateProof(P: AffinePoint, As: FieldVector , Bs: FieldVector , Ls: [AffinePoint], Rs: [AffinePoint]) -> InnerProductProof {
        let base = self.vectorBase
        return InnerProductProver.generateProof(base: base, P: P, As: As, Bs: Bs, Ls: Ls, Rs: Rs)
    }
    
    public func verify(c: AffinePoint, proof: InnerProductProof) -> Bool {
        let base = self.vectorBase
        return EfficientInnerProductVerifier.verify(params: base, c: c, proof: proof)
    }
    
    public func generateProofFromWitness(c: AffinePoint, witness: InnerProductWitness) -> InnerProductProof {
        let base = self.vectorBase
        return InnerProductProver.generateProofFromWitness(base: base, c: c, witness: witness)
    }
}
