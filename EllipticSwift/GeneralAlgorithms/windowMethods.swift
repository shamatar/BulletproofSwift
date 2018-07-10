//
//  KSlidingWindow.swift
//  EllipticSwift
//
//  Created by Alexander Vlasov on 10.07.2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import Foundation
import BigInt

// returns [Int] - lookup coefficients in precompute, [BigUInt] - powers to rise the result
// lookup == -1 -> Just rise in a power
public func computeSlidingWindow(scalar: BigUInt, windowSize: Int = DefaultWindowSize) -> ([Int], [BigUInt]){
    var lookupCoeffs = [Int]()
    var powers = [BigUInt]()
    var i = scalar.bitWidth-1
    while i > 0 {
        if !scalar.bit(i) {
            lookupCoeffs.append(-1)
            powers.append(2)
            i = i - 1
        } else {
            var l = i - windowSize + 1
            var nextI = l - 1
            if l <= 0 {
                l = 0
                nextI = 0
            }
            var bitSlice = scalar.bits(i, l)
            let sliceBitWidth = i - l + 1
            let elementNumber = Int(bitSlice) - 1
            if bitSlice == 0 {
                i = nextI
                continue
            }
            while bitSlice & 1 == 0 {
                bitSlice = bitSlice >> 1
                l = l + 1
            }
            var power = 1 << windowSize
            if windowSize > sliceBitWidth {
                power = 1 << sliceBitWidth
            }
            lookupCoeffs.append(elementNumber)
            powers.append(BigUInt(power))
            i = nextI
        }
    }
    return (lookupCoeffs, powers)
}

// returns [Int] - lookup coefficients in precompute, stores as UNSIGNED, so should be later converted at lookup time

public func computeWNAF(scalar: BigUInt, windowSize: Int = DefaultWindowSize) -> [Int] {
    func guardedMods(_ a: BigInt.Word, _ half: Int, _ full: Int) -> Int {
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
            let coeff = scalarCopy.bits(maxBit, 0) // should be window size long
            let mods = guardedMods(coeff, half, full)
            dCoeffs.append(mods)
            if mods > 0 {
                scalarCopy = scalarCopy - BigUInt(mods)
            } else {
                scalarCopy = scalarCopy + BigUInt(-mods)
            }
        } else {
            dCoeffs.append(0)
        }
        scalarCopy = scalarCopy >> 1
        i = i + 1
    }
//    precondition(dCoeffs.count == scalar.bitWidth)
    return dCoeffs
}
