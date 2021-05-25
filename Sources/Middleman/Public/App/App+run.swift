//
//  App+run.swift
//  Middleman
//
//  Created by Valentin Walter on 4/23/20.
//  
//
//  Abstract:
//
//

import Foundation

public extension App {
    func run<A: Action>(
        action: A,
        with input: A.Input,
        then callback: Callback<A.Output?>?
    ) {
        action.run(on: self, with: input, then: callback)
    }

    func run<A: Action>(
        action: A,
        with input: A.Input
    ) where A.Output == Never {
        action.run(on: self, with: input, then: nil)
    }
}
