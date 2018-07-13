//
//  U256+Aux.swift
//  EllipticSwift
//
//  Created by Alexander Vlasov on 13.07.2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import Foundation
import Accelerate

extension U256 {
    public static var one: U256 {
        return U256(Data(repeating: 1, count: 1))!
    }
    
    public static var zero: U256 {
        return vU256(v: (BigNumber.vZERO, BigNumber.vZERO))
    }
}
