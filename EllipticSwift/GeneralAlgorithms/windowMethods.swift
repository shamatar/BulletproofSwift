//
//  KSlidingWindow.swift
//  EllipticSwift
//
//  Created by Alexander Vlasov on 10.07.2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import Foundation
import BigInt

//// returns [Int] - lookup coefficients in precompute, [BigUInt] - powers to rise the result
//// lookup == -1 -> Just rise in a power
//public func computeSlidingWindow(scalar: BigUInt, windowSize: Int = DefaultWindowSize) -> ([Int], [BigUInt]){
//    var lookupCoeffs = [Int]()
//    var powers = [BigUInt]()
//    var i = scalar.bitWidth-1
//    while i > 0 {
//        if !scalar[bitAt: i] {
//            lookupCoeffs.append(-1)
//            powers.append(2)
//            i = i - 1
//        } else {
//            var l = i - windowSize + 1
//            var nextI = l - 1
//            if l <= 0 {
//                l = 0
//                nextI = 0
//            }
//            var bitSlice = scalar.bits(i, l)
//            let sliceBitWidth = i - l + 1
//            let elementNumber = Int(bitSlice) - 1
//            if bitSlice == 0 {
//                i = nextI
//                continue
//            }
//            while bitSlice & 1 == 0 {
//                bitSlice = bitSlice >> 1
//                l = l + 1
//            }
//            var power = 1 << windowSize
//            if windowSize > sliceBitWidth {
//                power = 1 << sliceBitWidth
//            }
//            lookupCoeffs.append(elementNumber)
//            powers.append(BigUInt(power))
//            i = nextI
//        }
//    }
//    return (lookupCoeffs, powers)
//}

//// returns [Int] - lookup coefficients in precompute, stores as SIGNED
//public func computeWNAF(scalar: BigUInt, windowSize: Int = DefaultWindowSize) -> [Int] {
//    func guardedMods(_ a: BigInt.Word, _ half: Int, _ full: Int) -> Int {
//        if a > half {
//            return full - Int(a)
//        } else {
//            return Int(a)
//        }
//    }
//    
//    var dCoeffs = [Int]()
//    var i = 0
//    var scalarCopy = scalar
//    let maxBit = windowSize - 1
//    let half = 1 << (windowSize-1)
//    let full = 1 << windowSize
//    while scalarCopy > 0 {
//        if scalarCopy.bit(0) {
//            let coeff = scalarCopy.bits(maxBit, 0) // should be window size long
//            let mods = guardedMods(coeff, half, full)
//            dCoeffs.append(mods)
//            if mods > 0 {
//                scalarCopy = scalarCopy - BigUInt(mods)
//            } else {
//                scalarCopy = scalarCopy + BigUInt(-mods)
//            }
//        } else {
//            dCoeffs.append(0)
//        }
//        scalarCopy = scalarCopy >> 1
//        i = i + 1
//    }
////    precondition(dCoeffs.count == scalar.bitWidth)
//    return dCoeffs
//}

// returns [Int] - lookup coefficients in precompute, stores as SIGNED
public func computeWNAF(scalar: BigNumber, windowSize: Int = DefaultWindowSize) -> [Int] {
    var result = [Int]()
    result.reserveCapacity(100)
    var coeffsIndex: Int = 0 // points to array of NAF coefficients.
//    var i: Int = 0
//    var dm: Int = 0
//    var scalarCopy = scalar
//    while !scalarCopy.isZero {
//        if scalarCopy.isEven {
//
//        }
//        let byte =
//    }
//    // wNAF
//    assembly
//        {
//            loop:
//            jumpi(loop_end, iszero(d))
//            jumpi(even, iszero(and(d, 1)))
//            dm := mod(d, 32)
//            mstore8(add(dwPtr, i), dm) // Don't store as signed - convert when reading.
//            d := add(sub(d, dm), mul(gt(dm, 16), 32))
//            even:
//            d := div(d, 2)
//            i := add(i, 1)
//            jump(loop)
//            loop_end:
//    }
//
//
//
//
    func guardedMods(_ a: UInt32, _ half: Int, _ full: Int) -> Int {
        precondition(full <= UInt32.max)
        if a > half {
            return full - Int(a)
        } else {
            return Int(a)
        }
    }
    var dCoeffs = [Int]()
    var i = 0
    var scalarCopy = scalar
    let maxBit = windowSize - 1
    let half = 1 << (windowSize-1)
    let full = 1 << windowSize
    while scalarCopy > 0 {
        if scalarCopy.bit(0) {
            let coeff = bits(of: scalarCopy, maxBit, 0) // should be window size long
            let mods = guardedMods(coeff, half, full)
            dCoeffs.append(mods)
            if mods > 0 {
                scalarCopy = scalarCopy - BigNumber(integerLiteral: UInt64(mods))
            } else {
                scalarCopy = scalarCopy + BigNumber(integerLiteral: UInt64(-mods))
            }
        } else {
            dCoeffs.append(0)
        }
        scalarCopy = scalarCopy >> UInt32(1)
        i = i + 1
    }
    return dCoeffs
}

internal func bits(of element: BytesRepresentable, _ from: Int, _ to: Int) -> UInt32 {
    let beData: [UInt8] = element.bytes.reversed()
    precondition(to < beData.count * 8, "accessing out of range bits")
    precondition(from > to, "should access nonzero range with LE notation")
    precondition(to - from < UInt32.bitWidth, "not meant to access more than " + String(UInt32.bitWidth) + " bits")
    //        print("Accessing bits from " + String(from) + " to " + String(to) + " (zero enumerated)")
//    let numBits = from - to + 1
    let (upperByteNumber, upperBitInByte) = from.quotientAndRemainder(dividingBy: 8)
    let (lowerByteNumber, lowerBitInByte) = to.quotientAndRemainder(dividingBy: 8)
    if upperByteNumber == lowerByteNumber {
        precondition(upperBitInByte <= 7)
        let bitmask: UInt8 = ((1 << (upperBitInByte - lowerBitInByte + 1)) - 1) << lowerBitInByte
        let byte = beData[lowerByteNumber]
        let maskedValue = byte & bitmask
        let result = UInt32(maskedValue >> lowerBitInByte)
        return result
    } else {
        let bitsFromLowerByte = 8 - lowerBitInByte
        let lowerByteBitmask: UInt8 = ((1 << bitsFromLowerByte) - 1) << lowerBitInByte
        let lowerByte = beData[lowerByteNumber]
        let lowerBits = (lowerByte & lowerByteBitmask) >> lowerBitInByte
        
        let upperByteBitmask: UInt8 = ((1 << upperBitInByte) - 1)
        let upperByte = beData[upperByteNumber]
        let upperBits = (upperByte & upperByteBitmask)
        
        var fullBits = UInt32(lowerBits)
        var shiftMultiplier = 0
        for i in lowerByteNumber+1 ..< upperByteNumber {
            fullBits |= UInt32(beData[i]) << (shiftMultiplier*8 + lowerBitInByte)
            shiftMultiplier = shiftMultiplier + 1
        }
        fullBits |= UInt32(upperBits) << (shiftMultiplier*8 + lowerBitInByte)
        return fullBits
    }
    
}
