//
//  PrecompiledCurves.swift
//  EllipticSwift
//
//  Created by Alexander Vlasov on 10.07.2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import Foundation
import BigInt

// secp256k1
internal let secp256k1PrimeBUI = BigUInt("fffffffffffffffffffffffffffffffffffffffffffffffffffffffefffffc2f", radix: 16)!
public let secp256k1Prime = BigNumber(secp256k1PrimeBUI.serialize())!
public let secp256k1PrimeField = GeneralPrimeField.nativeU256(NativeNaivePrimeField<U256>(secp256k1PrimeBUI))
internal let secp256k1CurveOrderBUI = BigUInt("fffffffffffffffffffffffffffffffebaaedce6af48a03bbfd25e8cd0364141", radix: 16)!
public let secp256k1CurveOrder = BigNumber(secp256k1CurveOrderBUI.serialize())!
public let secp256k1WeierstrassCurve: WeierstrassCurve = {
    let curve = WeierstrassCurve(field: secp256k1PrimeField, order: secp256k1CurveOrder, A: 0, B: 7)
    let generatorX = BigUInt("79BE667EF9DCBBAC55A06295CE870B07029BFCDB2DCE28D959F2815B16F81798", radix: 16)!
    let generatorY = BigUInt("483ADA7726A3C4655DA4FBFC0E1108A8FD17B448A68554199C47D08FFB10D4B8", radix: 16)!
    let success = curve.setGenerator(AffineCoordinates(generatorX, generatorY))
    precondition(success, "Failed to init secp256k1 curve!")
    return curve
}()
public let secp256k1Curve = Curve.weierstrass(secp256k1WeierstrassCurve)

// bn256
internal let bn256PrimeBUI = BigUInt("21888242871839275222246405745257275088696311157297823662689037894645226208583", radix: 10)!
public let bn256Prime = BigNumber(bn256PrimeBUI.serialize())!
public let bn256PrimeField = GeneralPrimeField.nativeU256(NativeNaivePrimeField<U256>(bn256PrimeBUI))
internal let bn256CurveOrderBUI = BigUInt("21888242871839275222246405745257275088548364400416034343698204186575808495617", radix: 10)!
public let bn256CurveOrder = BigNumber(bn256CurveOrderBUI.serialize())!
public let bn256WeierstrassCurve: WeierstrassCurve = {
    let curve = WeierstrassCurve(field: bn256PrimeField, order: bn256CurveOrder, A: 0, B: 3)
    let generatorX = BigUInt("1", radix: 10)!
    let generatorY = BigUInt("2", radix: 10)!
    let success = curve.setGenerator(AffineCoordinates(generatorX, generatorY))
    precondition(success, "Failed to init bn256 curve!")
    return curve
}()
public let bn256Curve = Curve.weierstrass(bn256WeierstrassCurve)
