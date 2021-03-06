//
//  U256+Comparable.swift
//  EllipticSwift
//
//  Created by Alexander Vlasov on 13.07.2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import Foundation
import Accelerate

extension U256: Comparable {
    public static func < (lhs: U256, rhs: U256) -> Bool {
        if lhs.v.1 < rhs.v.1 {
            return true
        } else if lhs.v.1 > rhs.v.1 {
            return false
        }
        if lhs.v.0 < rhs.v.0 {
            return true
        }
        return false
    }
}

extension U256: EvenOrOdd {
    public var isEven: Bool {
        return self.v.0.isEven
    }
}
