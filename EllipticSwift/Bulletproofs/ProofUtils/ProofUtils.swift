//
//  ProofUtils.swift
//  EllipticSwift
//
//  Created by Alexander Vlasov on 11.07.2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import Foundation
import BigInt
import CryptoSwift


func keccak256(_ data: Data) -> Data {
    return data.sha3(.keccak256)
}
public var hashFunctionForChallenges : ((Data) -> Data) = keccak256

public struct ProofUtils {
    
    public static func serialize(_ a: BigUInt) -> Data {
        let dataLength = UnsignedIntegerBitWidth/8
        let uintData = a.serialize()
        precondition(uintData.count <= dataLength)
        let padding = Data(repeating: 0, count: dataLength - uintData.count)
        return padding + uintData
    }
    
    public static func serialize(_ a: AffinePoint) -> Data {
        return serialize(a.X) + serialize(a.Y)
    }
    
    
    public static func computeChallenge(q: BigUInt, points:[AffinePoint]) -> BigUInt {
        var data = Data()
        for point in points {
            data.append(serialize(point))
        }
        let hash = hashFunctionForChallenges(data)
        let bn = BigUInt(hash)
        return bn % q
    }
    
    public static func computeChallengeForBigIntegersAndPoints(q: BigUInt, ints: [BigUInt], points: [AffinePoint]) -> BigUInt {
        var data = Data()
        for int in ints {
            data.append(serialize(int))
        }
        for point in points {
            data.append(serialize(point))
        }
        let hash = hashFunctionForChallenges(data)
        let bn = BigUInt(hash)
        return bn % q
    }
    
    public static func computeChallengeForBigIntegers(q: BigUInt, ints: [BigUInt]) -> BigUInt {
        var data = Data()
        for int in ints {
            data.append(serialize(int))
        }
        let hash = hashFunctionForChallenges(data)
        let bn = BigUInt(hash)
        return bn % q
    }
    
    public static func randomNumber(bitWidth: Int = UnsignedIntegerBitWidth) -> BigUInt {
        return BigUInt.randomInteger(withMaximumWidth: bitWidth)
    }
}
