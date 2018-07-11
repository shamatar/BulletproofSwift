//
//  InnerProductWitness.swift
//  EllipticSwift
//
//  Created by Alexander Vlasov on 11.07.2018.
//  Copyright © 2018 Alexander Vlasov. All rights reserved.
//

import Foundation

public struct InnerProductWitness {
    public var a:FieldVector
    public var b:FieldVector
    
    public init (_ a:FieldVector, _ b:FieldVector) {
        self.a = a;
        self.b = b;
    }
}
