//
//  App+run.swift
//  Middleman
//
//  Created by Valentin Walter on 4/23/20.
//

import Foundation

public extension App {
	/// Run an `Action` on this app. This is the main way of running actions.
	/// - Parameters:
	///   - action: The `Action` to run.
	///   - input: The `Action.Input` with which to run this action.
	///   - callback: An optional callback with a `Response` that you can switch
	///               over.
	///
	///     ```
	///     switch response {
	///     case .success(let output): //...
	///     case .error(let code, let msg): //...
	///     case .cancel: //...
	///     }
	///     ```
    func run<A: Action>(
        action: A,
        with input: A.Input,
        then callback: Callback<A.Output?>?
    ) {
        action._run(on: self, with: input, then: callback)
    }

	
	//MARK:- Output == Never
	
	/// Run an `Action` on this app. This is the main way of running actions.
	/// - Parameters:
	///   - action: The `Action` to run.
	///   - input: The `Action.Input` with which to run this action.
    func run<A: Action>(
        action: A,
        with input: A.Input
    ) where A.Output == Never {
        action._run(on: self, with: input, then: nil)
    }
	
	
	//MARK:- Input == Never
	
	/// Run an `Action` on this app. This is the main way of running actions.
	/// - Parameters:
	///   - action: The `Action` to run.
	///   - callback: An optional callback with a `Response` that you can switch
	///               over.
	///
	///     ```
	///     switch response {
	///     case .success(let output): //...
	///     case .error(let code, let msg): //...
	///     case .cancel: //...
	///     }
	///     ```
	func run<A: Action>(
		action: A,
		then callback: Callback<A.Output?>?
	) where A.Input == Never {
		action._run(on: self, with: nil, then: callback)
	}
	
	
	//MARK:- Output & Input == Never
	
	/// Run an `Action` on this app. This is the main way of running actions.
	/// - Parameters:
	///   - action: The `Action` to run.
	func run<A: Action>(action: A) where A.Input == Never, A.Output == Never {
		action._run(on: self, with: nil, then: nil)
	}
}
