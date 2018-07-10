//
//  BigInt+Bitset.swift
//  EllipticSwift
//
//  Created by Alexander Vlasov on 09.07.2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import Foundation
import BigInt

extension BigUInt {
    // LE indexing extension
    public func isBitSet(_ i: Int) -> Bool {
        let (wordNumber, mask) = wordIndexOfBit(i)
        return (self.words[wordNumber] & mask) != 0
    }
    
    // returns word number and effective mask
    private func wordIndexOfBit(_ i: Int) -> (Int, BigInt.Word) {
        precondition(i >= 0)
        let o = i / WordSize
        let m = BigInt.Word(i - o*WordSize)
        return (o, 1 << m)
    }
    
    public func bit (_ i: Int) -> Bool {
        return isBitSet(i)
    }
    
    // LE indexing extension
    public func bits(_ from: Int, _ to: Int) -> BigInt.Word {
        precondition(to < self.bitWidth, "accessing out of range bits")
        precondition(from > to, "should access nonzero range with LE notation")
        precondition(to - from < WordSize, "not meant to access more than " + String(WordSize) + " bits")
//        print("Accessing bits from " + String(from) + " to " + String(to) + " (zero enumerated)")
        let numBits = BigInt.Word(from - to + 1)
        let lW = from / WordSize
        let uW = to / WordSize
        if lW == uW {
            let lB = BigInt.Word(to - lW*WordSize) // single bit is that marks the lowest bit
            let bitmask: BigInt.Word = ((1 << numBits) - 1) << lB
            let word = self.words[lW]
            let unshifted = (word & bitmask)
            let shifted = unshifted >> lB
            return shifted
        } else { // lW + 1 == uW
            let lB = BigInt.Word(to - lW*WordSize) // single bit is that marks the lowest bit
            let bitsInLW = numBits - lB
            let lBitmask: BigInt.Word = ((1 << bitsInLW) - 1) << lB
            let lWord = self.words[lW]
            let uB = BigInt.Word(from - uW*WordSize) // single bit is that marks the highest bit
            let uBitmask: BigInt.Word = ((1 << uB) - 1)
            let uWord = self.words[uW]
            let uBits = (uWord & uBitmask) << lB
            let lBits = (lWord & lBitmask) >> lB
            return uBits ^ lBits
        }
    }
}
