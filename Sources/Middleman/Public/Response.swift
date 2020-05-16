//
//  Response.swift
//  Middleman
//
//  Created by Valentin Walter on 4/15/20.
//  
//
//  Abstract:
//  Two types abstracting x-callback responses.
//

import Foundation

/// A type abstracting x-callback responses.
///
/// - Note: If you need a purely semantic representation, refer to `PlainResponse`.
public enum Response<Output> {
    case success(Output)
    case cancel
    case error(code: Int, message: String)
}

/// A type abstracting x-callback responses in a purely semantic way.
///
/// - Note: If you need to transport data, refer to `Response<Output>`.
public enum PlainResponse: String, CaseIterable {
    case success
    case cancel
    case error

    /// The name of the query used in x-callback urls.
    var asParameterName: String {
        "x-\(rawValue)"
    }
}
