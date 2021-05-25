//
//  UnkeyedContainer.swift
//  Middleman
//
//  Created by Valentin Walter on 4/17/20.
//  

import Foundation

extension CallbackURLDecoder {
    struct UnkeyedContainer: UnkeyedDecodingContainer {
        var codingPath: [CodingKey]
        let items: [String]

        var count: Int? { items.count }
        var isAtEnd: Bool { currentIndex == items.endIndex }
        var currentIndex: Int = 0

        init(codingPath: [CodingKey], items: [String]) {
            self.codingPath = codingPath
            self.items = items
        }

        mutating func decodeNil() throws -> Bool { false }

        mutating func decode(_ type: Bool.Type) throws -> Bool {
            try decodeNext(using: type.init(yesNo:))
        }

        mutating func decode(_ type: String.Type) throws -> String {
            try decodeNext(using: type.init)
        }

        mutating func decode(_ type: Double.Type) throws -> Double {
            try decodeNext(using: type.init)
        }

        mutating func decode(_ type: Float.Type) throws -> Float {
            try decodeNext(using: type.init)
        }

        mutating func decode(_ type: Int.Type) throws -> Int {
            try decodeNext(using: type.init)
        }

        mutating func decode(_ type: Int8.Type) throws -> Int8 {
            try decodeNext(using: type.init)
        }

        mutating func decode(_ type: Int16.Type) throws -> Int16 {
            try decodeNext(using: type.init)
        }

        mutating func decode(_ type: Int32.Type) throws -> Int32 {
            try decodeNext(using: type.init)
        }

        mutating func decode(_ type: Int64.Type) throws -> Int64 {
            try decodeNext(using: type.init)
        }

        mutating func decode(_ type: UInt.Type) throws -> UInt {
            try decodeNext(using: type.init)
        }

        mutating func decode(_ type: UInt8.Type) throws -> UInt8 {
            try decodeNext(using: type.init)
        }

        mutating func decode(_ type: UInt16.Type) throws -> UInt16 {
            try decodeNext(using: type.init)
        }

        mutating func decode(_ type: UInt32.Type) throws -> UInt32 {
            try decodeNext(using: type.init)
        }

        mutating func decode(_ type: UInt64.Type) throws -> UInt64 {
            try decodeNext(using: type.init)
        }

        mutating func decode<T: Decodable>(_ type: T.Type) throws -> T {
            try T(from: SingleValueDecoder(
                codingPath: codingPath,
                item: decodeNext(using: String.init)
            ))
        }

        mutating func nestedContainer<T: CodingKey>(
            keyedBy type: T.Type
        ) throws -> KeyedDecodingContainer<T> {
            throw DecodingError.dataCorrupted(DecodingError.Context(
                codingPath: codingPath,
                debugDescription: "NestedContainer not available in current context."
            ))
        }

        mutating func nestedUnkeyedContainer() throws -> UnkeyedDecodingContainer {
            let items = try decodeNext(using: String.init)
                .split(separator: ",")
                .map(String.init)

            return UnkeyedContainer(
                codingPath: codingPath,
                items: items
            )
        }

        mutating func superDecoder() throws -> Decoder {
            UnkeyedDecoder(
                codingPath: codingPath,
                items: items
            )
        }

        private mutating func decodeNext<T>(using transform: (String) -> T?) throws -> T {
            let string = items[currentIndex]

            guard let transformed = transform(string) else {
                throw DecodingError.typeMismatch(
                    T.self,
                    DecodingError.Context(
                        codingPath: codingPath,
                        debugDescription: """
                            Could not convert '\(string)' into a value of type '\(String(describing: T.self))'.
                        """
                    )
                )
            }

            currentIndex += 1
            return transformed
        }
    }

    struct UnkeyedDecoder: Decoder {
        var userInfo: [CodingUserInfoKey: Any] { [:] }
        var codingPath: [CodingKey]
        let items: [String]

        func container<T: CodingKey>(keyedBy type: T.Type) throws -> KeyedDecodingContainer<T> {
            throw DecodingError.dataCorrupted(DecodingError.Context(
                codingPath: codingPath,
                debugDescription: "KeyedDecodingContainer not available in current context."
            ))
        }

        func unkeyedContainer() throws -> UnkeyedDecodingContainer {
            UnkeyedContainer(codingPath: codingPath, items: items)
        }

        func singleValueContainer() throws -> SingleValueDecodingContainer {
            throw DecodingError.dataCorrupted(DecodingError.Context(
                codingPath: codingPath,
                debugDescription: "SingleValueDecodingContainer not available in current context."
            ))
        }
    }
}
