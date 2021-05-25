//
//  SingleValueContainer.swift
//  Middleman
//
//  Created by Valentin Walter on 4/17/20.
//  

import Foundation

extension CallbackURLDecoder {
    struct SingleValueContainer: SingleValueDecodingContainer {
        let codingPath: [CodingKey]
        let item: String

        init(codingPath: [CodingKey], item: String) {
            self.codingPath = codingPath
            self.item = item
        }

        func decodeNil() -> Bool { false }

        func decode(_ type: Bool.Type) throws -> Bool {
            try decode(using: type.init(yesNo:))
        }

        func decode(_ type: String.Type) throws -> String { item }

        func decode(_ type: Double.Type) throws -> Double {
            try decode(using: type.init)
        }

        func decode(_ type: Float.Type) throws -> Float {
            try decode(using: type.init)
        }

        func decode(_ type: Int.Type) throws -> Int {
            try decode(using: type.init)
        }

        func decode(_ type: Int8.Type) throws -> Int8 {
            try decode(using: type.init)
        }

        func decode(_ type: Int16.Type) throws -> Int16 {
            try decode(using: type.init)
        }

        func decode(_ type: Int32.Type) throws -> Int32 {
            try decode(using: type.init)
        }

        func decode(_ type: Int64.Type) throws -> Int64 {
            try decode(using: type.init)
        }

        func decode(_ type: UInt.Type) throws -> UInt {
            try decode(using: type.init)
        }

        func decode(_ type: UInt8.Type) throws -> UInt8 {
            try decode(using: type.init)
        }

        func decode(_ type: UInt16.Type) throws -> UInt16 {
            try decode(using: type.init)
        }

        func decode(_ type: UInt32.Type) throws -> UInt32 {
            try decode(using: type.init)
        }

        func decode(_ type: UInt64.Type) throws -> UInt64 {
            try decode(using: type.init)
        }

        func decode<T: Decodable>(_ type: T.Type) throws -> T {
            let decoder = SingleValueDecoder(
                codingPath: codingPath,
                item: item
            )

            return try T(from: decoder)
        }

        private func decode<T>(using transform: (String) -> T?) throws -> T {
            guard let transformed = transform(item) else {
                throw DecodingError.typeMismatch(
                    T.self,
                    DecodingError.Context(
                        codingPath: codingPath,
                        debugDescription: """
                            Could not convert '\(item)' into a value of type '\(String(describing: T.self))'.
                        """
                    )
                )
            }

            return transformed
        }
    }

    struct SingleValueDecoder: Decoder {
        var userInfo: [CodingUserInfoKey: Any] { [:] }
        let codingPath: [CodingKey]
        let item: String

        func container<T: CodingKey>(keyedBy type: T.Type) throws -> KeyedDecodingContainer<T> {
            throw DecodingError.dataCorrupted(DecodingError.Context(
                codingPath: codingPath,
                debugDescription: "Container not availalable in current context."
            ))
        }

        func unkeyedContainer() throws -> UnkeyedDecodingContainer {
            throw DecodingError.dataCorrupted(DecodingError.Context(
                codingPath: codingPath,
                debugDescription: "UnkeyedContainer not availalable in current context."
            ))
        }

        func singleValueContainer() throws -> SingleValueDecodingContainer {
            SingleValueContainer(
                codingPath: codingPath,
                item: item
            )
        }
    }
}
