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
public func computeWNAF(scalar: BigUInt, windowSize: Int = DefaultWindowSize) -> ([Int], [BigUInt]){
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
            let elementNumber = Int(bitSlice) - 1
            if bitSlice == 0 {
                i = nextI
                continue
            }
            while bitSlice & 1 == 0 {
                bitSlice = bitSlice >> 1
                l = l + 1
            }
            let power = 1 << windowSize
            lookupCoeffs.append(elementNumber)
            powers.append(BigUInt(power))
            i = nextI
        }
    }
    return (lookupCoeffs, powers)
}
