//
//  GeneratorParams.swift
//  EllipticSwift
//
//  Created by Alexander Vlasov on 11.07.2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import Foundation
import BigInt

public struct GeneratorParams {
    public var vectorBase: VectorBase
    public var base: PeddersenBase
    public var curve: Curve
    public var gs: GeneratorVector
    public var hs: GeneratorVector
    public var g: AffinePoint
    public var h: AffinePoint
    public var v: AffinePoint
    
    public init (vectorBase: VectorBase, base: PeddersenBase, curve: Curve, v: AffinePoint) {
        self.vectorBase = vectorBase
        self.base = base
        self.curve = curve
        self.g = base.g
        self.h = base.h
        self.v = v
        self.gs = vectorBase.gs
        self.hs = vectorBase.hs
    }
    
    public static func generateParams(size: Int, curve: Curve) -> GeneratorParams {
        var gPoints = [AffinePoint]()
        var hPoints = [AffinePoint]()
        for i in 0 ..< size {
            let gString = "G" + String(i)
            let gStringData = gString.data(using: .utf8)
            precondition(gStringData != nil)
            let gHash = hashFunctionForChallenges(gStringData!)
            let g = curve.hashInto(gHash)
            gPoints.append(g)
            let hString = "H" + String(i)
            let hStringData = hString.data(using: .utf8)
            precondition(hStringData != nil)
            let hHash = hashFunctionForChallenges(hStringData!)
            let h = curve.hashInto(hHash)
            hPoints.append(h)
        }
        let g = curve.hashInto(hashFunctionForChallenges("G".data(using: .utf8)!))
        let h = curve.hashInto(hashFunctionForChallenges("H".data(using: .utf8)!))
        let v = curve.hashInto(hashFunctionForChallenges("V".data(using: .utf8)!))
        let generatorVectorG = GeneratorVector(gPoints, curve)
        let generatorVectorH = GeneratorVector(hPoints, curve)
        let vectorBase = VectorBase(gs: generatorVectorG, hs: generatorVectorH, h: h)
        let base = PeddersenBase(g: g, h: h, curve: curve)
        return GeneratorParams(vectorBase: vectorBase, base: base, curve: curve, v: v)
    }
}
