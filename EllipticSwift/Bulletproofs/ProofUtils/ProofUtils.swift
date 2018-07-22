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
    
    public static func serialize(_ a: BigNumber) -> Data {
        let dataLength = UnsignedIntegerBitWidth/8
        let uintData = a.bytes
        precondition(uintData.count <= dataLength)
        let padding = Data(repeating: 0, count: dataLength - uintData.count)
        return padding + uintData
    }
    
    public static func serialize(_ a: AffinePoint) -> Data {
        return serialize(a.X) + serialize(a.Y)
    }
    
    
    public static func computeChallenge(points: [AffinePoint]) -> BigNumber {
        var data = Data()
        for point in points {
            data.append(serialize(point))
        }
        let hash = hashFunctionForChallenges(data)
        let bn = BigNumber(hash)
        precondition(bn != nil)
        return bn!
    }
    
    public static func computeChallenge(points: [AffinePoint], field: GeneralPrimeField) -> GeneralPrimeFieldElement {
        let bn = computeChallenge(points: points)
        return field.fromValue(bn)
    }
    
    public static func computeChallengeForBigIntegersAndPoints(ints: [BigNumber], points: [AffinePoint]) -> BigNumber {
        var data = Data()
        for int in ints {
            data.append(serialize(int))
        }
        for point in points {
            data.append(serialize(point))
        }
        let hash = hashFunctionForChallenges(data)
        let bn = BigNumber(hash)
        precondition(bn != nil)
        return bn!
    }
    
    public static func computeChallengeForBigIntegersAndPoints(ints: [BigNumber], points: [AffinePoint], field: GeneralPrimeField) -> GeneralPrimeFieldElement {
        let bn = computeChallengeForBigIntegersAndPoints(ints: ints, points: points)
        return field.fromValue(bn)
    }
    
    public static func computeChallengeForBigIntegers(ints: [BigNumber]) -> BigNumber {
        var data = Data()
        for int in ints {
            data.append(serialize(int))
        }
        let hash = hashFunctionForChallenges(data)
        let bn = BigNumber(hash)
        precondition(bn != nil)
        return bn!
    }
    
    public static func computeChallengeForBigIntegers(ints: [BigNumber], field: GeneralPrimeField) -> GeneralPrimeFieldElement {
        let bn = computeChallengeForBigIntegers(ints: ints)
        return field.fromValue(bn)
    }
    
    
    public static func randomNumber(bitWidth: Int = UnsignedIntegerBitWidth) -> BigNumber {
        return BigNumber(integerLiteral: 1)
        let bytes = randomBytes(length: bitWidth/8)
        precondition(bytes != nil)
        let bn = BigNumber(bytes!)
        precondition(bn != nil)
        return bn!
    }
    
    public static func randomNumber(bitWidth: Int = UnsignedIntegerBitWidth, field: GeneralPrimeField) -> GeneralPrimeFieldElement {
        let bn = randomNumber(bitWidth: bitWidth)
        return field.fromValue(bn)
    }
    
    internal static func randomBytes(length: Int) -> Data? {
        for _ in 0...1024 {
            var data = Data(repeating: 0, count: length)
            let result = data.withUnsafeMutableBytes {
                (mutableBytes: UnsafeMutablePointer<UInt8>) -> Int32 in
                SecRandomCopyBytes(kSecRandomDefault, 32, mutableBytes)
            }
            if result == errSecSuccess {
                return data
            }
        }
        return nil
    }
}
