//
//  AnyAction.swift
//  Middleman
//
//  Created by Valentin Walter on 5/16/20.
//  
//
//  Abstract:
//  A type proividing type-erasure for Actions.
//

import Foundation

public struct AnyAction {
    let receive: (_ decoder: Decoder) throws -> Void
    let path: String

    public init<A: Action>(from action: A) {
        self.receive = { action.receive(input: try .init(from: $0)) }
        self.path = action.path
    }
}
