//
//  CallbackURL.swift
//  Middleman
//
//  Created by Valentin Walter on 4/23/20.
//

import Foundation

/// A representation of an `x-callback-url`.
public class CallbackURL {
    public var scheme: String
    public var host: String
    public var path: String
    public var queryItems: Set<URLQueryItem>

    /// The id coupling `CallbackURL` and `Action`.
    var id: UUID

    // Used for creating
    public init(
        scheme: String,
        host: String,
        path: String,
        queries: Set<URLQueryItem>,
        id: UUID = .init()
    ) {
        self.queryItems = queries
        self.path = path
        self.host = host
        self.scheme = scheme
        self.id = id
    }

    // Used for creating
    public init?(from components: URLComponents) {
        guard let scheme = components.scheme else { return nil }
        guard let host = components.host else { return nil }

        self.queryItems = Set(components.queryItems ?? [])
        self.path = components.path
        self.host = host
        self.scheme = scheme
        self.id = UUID()
    }

    /// The `CallbackURLDecoder` fit for decoding this url into an `Action`'s
	/// `Input` or `Output`.
    var decoder: CallbackURLDecoder { .init(for: self) }

    public var url: URL? { components.url }

    public var components: URLComponents {
        var components = URLComponents()
        components.scheme = self.scheme
        components.host = self.host
        components.path = self.path
        components.queryItems = Array(self.queryItems) + specialQueryItems
        return components
    }

    private var specialQueryItems: [URLQueryItem] {
        [
            URLQueryItem(
                name: Middleman.responseIDIdentifier,
                value: id.uuidString
            )
        ].filter { $0.value != nil }
    }

    /// Use this to get the values of a certain parameter in the url.
    public subscript(param: String) -> String? {
        queryItems.first(where: { $0.name == param })?.value
    }
}
