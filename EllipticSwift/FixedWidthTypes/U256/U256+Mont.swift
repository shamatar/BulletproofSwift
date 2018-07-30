//
//  U256+Mont.swift
//  EllipticSwift
//
//  Created by Alexander Vlasov on 30.07.2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import Foundation
import Accelerate

extension U256: MontArithmeticsCompatible {
    
    public static func getMontParams(_ a: U256) -> (U256, U256, U256) {
        let ONE = U256.one
        var montR = U256.max.mod(a) + ONE // virtually make MAX+1 mod prime
        var montInvR = montR.modInv(a)
        var fullWidth = U512()
        vU256FullMultiply(&montR, &montInvR, &fullWidth)
        var subtracted = U512()
        var u512One = U512.one
        vU512Sub(&fullWidth, &u512One, &subtracted)
        var primeU512 = U512(v: (a.v.0, a.v.1, vZERO, vZERO))
        var montKfullWidth = U512()
        var remainder = U512()
        vU512Divide(&subtracted, &primeU512, &montKfullWidth, &remainder)
        let (_, montK) = montKfullWidth.split()
        return (montR, montInvR, montK)
    }
    

}
