//
//  Never+Codable.swift
//  Middleman
//
//  Created by Valentin Walter on 4/19/20.
//  
//
/// # Abstract:
/// To allow defining `Action.Output` as `Never` when
/// the action never produces an Output, `Never` has to
/// conform to `Codable`.
//

import Foundation

extension Never: Codable {
    public init(from decoder: Decoder) throws {
        throw Error.cannotBeDecoded
    }

    public func encode(to encoder: Encoder) throws {
        throw Error.cannotBeEncoded
    }

    enum Error: String, Swift.Error {
        case cannotBeDecoded = "Never cannot be decoded."
        case cannotBeEncoded = "Never cannot be encoded."
    }
}
