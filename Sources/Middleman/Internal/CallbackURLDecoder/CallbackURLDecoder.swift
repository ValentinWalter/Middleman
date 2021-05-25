//
//  CallbackURLDecoder.swift
//  Middleman
//
//  Created by Valentin Walter on 4/16/20.
//

import Foundation
import StringCase

/// This decoder is responsible for decoding incoming URLs into their
/// corresponding `Action.Output`s.
struct CallbackURLDecoder: Decoder {
    var codingPath: [CodingKey]
    var userInfo: [CodingUserInfoKey: Any] = [:]
    let queries: [String: String]

    init(for xurl: CallbackURL) {
        self.init(for: Array(xurl.queryItems))
    }

    init(
        for queries: [URLQueryItem]
    ) {
        self.init(
            for: queries.reduce(into: [:], { result, query in
                guard let value = query.value else { return }
                result[query.name] = value
            })
        )
    }

    init(
        for queries: [String: String],
        codingPath: [CodingKey] = []
    ) {
        self.codingPath = codingPath
        self.queries = queries
    }

    func container<Key>(keyedBy type: Key.Type) throws -> KeyedDecodingContainer<Key> where Key: CodingKey {
        KeyedDecodingContainer(KeyedContainer(
            codingPath: codingPath,
            queries: queries
        ))
    }

    func unkeyedContainer() throws -> UnkeyedDecodingContainer {
        fatalError()
    }

    func singleValueContainer() throws -> SingleValueDecodingContainer {
        guard let string = queries[codingPath.last?.stringValue ?? ""] else {
            throw DecodingError.dataCorrupted(DecodingError.Context(
                codingPath: codingPath,
                debugDescription: "SingleValueDecodingContainer not available in current context."
            ))
        }

        return SingleValueContainer(codingPath: codingPath, item: string)
    }
}
