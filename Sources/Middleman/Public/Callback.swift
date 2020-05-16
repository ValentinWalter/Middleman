//
//  Callback.swift
//  Middleman
//
//  Created by Valentin Walter on 4/20/20.
//  
//
//  Abstract:
//  A closure that accepts a generic `Response`.
//

import Foundation

/// A closure that accepts a generic `Response`.
public typealias Callback<Output> = (_ response: Response<Output>) -> Void
