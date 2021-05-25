//
//  KeyedContainer.swift
//  Middleman
//
//  Created by Valentin Walter on 4/17/20.
//  

import Foundation

extension CallbackURLDecoder {
    struct KeyedContainer<Key: CodingKey>: KeyedDecodingContainerProtocol {
        var codingPath: [CodingKey]
        var allKeys: [Key] { queries.keys.compactMap(Key.init) }
        let queries: [String: String]

        init(codingPath: [CodingKey], queries: [String: String]) {
            self.codingPath = codingPath
            self.queries = queries
        }

        func contains(_ key: Key) -> Bool {
            allKeys.contains(where: { $0.stringValue == key.stringValue })
        }

        func decodeNil(forKey key: Key) throws -> Bool { false }

        func decode(_ type: Bool.Type, forKey key: Key) throws -> Bool {
            try decode(key, transform: type.init(yesNo:))
        }

        func decode(_ type: String.Type, forKey key: Key) throws -> String {
            try decode(key, transform: type.init)
        }

        func decode(_ type: Double.Type, forKey key: Key) throws -> Double {
            try decode(key, transform: type.init)
        }

        func decode(_ type: Float.Type, forKey key: Key) throws -> Float {
            try decode(key, transform: type.init)
        }

        func decode(_ type: Int.Type, forKey key: Key) throws -> Int {
            try decode(key, transform: type.init)
        }

        func decode(_ type: Int8.Type, forKey key: Key) throws -> Int8 {
            try decode(key, transform: type.init)
        }

        func decode(_ type: Int16.Type, forKey key: Key) throws -> Int16 {
            try decode(key, transform: type.init)
        }

        func decode(_ type: Int32.Type, forKey key: Key) throws -> Int32 {
            try decode(key, transform: type.init)
        }

        func decode(_ type: Int64.Type, forKey key: Key) throws -> Int64 {
            try decode(key, transform: type.init)
        }

        func decode(_ type: UInt.Type, forKey key: Key) throws -> UInt {
            try decode(key, transform: type.init)
        }

        func decode(_ type: UInt8.Type, forKey key: Key) throws -> UInt8 {
            try decode(key, transform: type.init)
        }

        func decode(_ type: UInt16.Type, forKey key: Key) throws -> UInt16 {
            try decode(key, transform: type.init)
        }

        func decode(_ type: UInt32.Type, forKey key: Key) throws -> UInt32 {
            try decode(key, transform: type.init)
        }

        func decode(_ type: UInt64.Type, forKey key: Key) throws -> UInt64 {
            try decode(key, transform: type.init)
        }

        func decode<T>(_ type: T.Type, forKey key: Key) throws -> T where T: Decodable {
            if T.self == Date.self {
                let formatter = ISO8601DateFormatter()
                return formatter.date(from: queries[key.stringValue]!) as! T
            }

            return try T(from: CallbackURLDecoder(
                for: queries,
                codingPath: codingPath.appending(key)
            ))
        }

        func nestedContainer<NestedKey>(
            keyedBy type: NestedKey.Type,
            forKey key: Key
        ) throws -> KeyedDecodingContainer<NestedKey> where NestedKey: CodingKey {
            KeyedDecodingContainer(KeyedContainer<NestedKey>(
                codingPath: codingPath.appending(key),
                queries: queries
            ))
        }

        func nestedUnkeyedContainer(forKey key: Key) throws -> UnkeyedDecodingContainer {
            guard let array = queries[key.stringValue] else {
                throw DecodingError.keyNotFound(
                    key,
                    DecodingError.Context(
                        codingPath: codingPath,
                        debugDescription: "No value found for key '\(key.stringValue)'."
                    )
                )
            }

            let items = array
                .split(separator: ",")
                .map(String.init)

            return UnkeyedContainer(
                codingPath: codingPath.appending(key),
                items: items
            )
        }

        func superDecoder() throws -> Decoder {
            CallbackURLDecoder(
                for: queries,
                codingPath: codingPath
            )
        }

        func superDecoder(forKey key: Key) throws -> Decoder {
            CallbackURLDecoder(
                for: queries,
                codingPath: codingPath.appending(key)
            )
        }

        private func decode<T>(_ key: Key, transform: (String) -> T?) throws -> T {
            let string = queries[key.stringValue.snakeCased()]
            guard let value = string else {
                throw DecodingError.keyNotFound(
                    key,
                    DecodingError.Context(
                        codingPath: codingPath,
                        debugDescription: "No value found for key '\(key.stringValue)'."
                    )
                )
            }

            guard let transformed = transform(value) else {
                throw DecodingError.typeMismatch(
                    T.self,
                    DecodingError.Context(
                        codingPath: codingPath,
                        debugDescription: """
                            Could not convert '\(value)' into a value of type '\(String(describing: T.self))'.
                        """
                    )
                )
            }

            return transformed
        }
    }
}
