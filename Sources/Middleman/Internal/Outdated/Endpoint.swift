//
//  Endpoint.swift
//  Middleman
//
//  Created by Valentin Walter on 3/14/20.
//  Copyright © 2020 Valentin Walter. All rights reserved.
//
//  Abstract:
//  Utility to create x-callback urls for clients.
//
//  --------------
//   - Outdated -
//  --------------
//

import Foundation

/// A utility to create x-callback urls for clients.
struct Endpoint {
    /// The action to be taken in the client.
    public let scheme: String
    /// The action to be taken in the client.
    public let path: String
    /// The queries this url should be constructed with.
    public var queryItems: Set<URLQueryItem>

    /// <#Description#>
    public let id = UUID()

    /// A utility to create x-callback urls for clients.
    /// - Parameters:
    ///   - scheme: The scheme identifying the client.
    ///   - path: The action to be taken in the client.
    ///   - queryItems: The queries this url should be constructed with.
    public init(
        scheme: String,
        path: String,
        queryItems: Set<URLQueryItem>
    ) {
        // Make sure path has "/" prefix
        var path = path
        if !path.hasPrefix("/") {
            path.insert("/", at: path.startIndex)
        }

        self.path = path
        self.scheme = scheme
        self.queryItems = queryItems
    }

    // Convenience for initializing with an array instead of set
    /// A utility to create x-callback urls for clients.
    /// - Parameters:
    ///   - scheme: The scheme identifying the client.
    ///   - path: The action to be taken in the client.
    ///   - queryItems: The queries this url should be constructed with.
    public init(
        scheme: String,
        path: String,
        queryItems: [URLQueryItem]
    ) {
        self.init(scheme: scheme,
                  path: path,
                  queryItems: Set(queryItems))
    }

    /// The `URL` constructed from this endpoint.
    public var url: URL? {
        var components = URLComponents()
        components.scheme = self.scheme
        components.host = "x-callback-url"
        components.path = self.path
        components.queryItems = Array(queryItems)

        return components.url
    }
}
