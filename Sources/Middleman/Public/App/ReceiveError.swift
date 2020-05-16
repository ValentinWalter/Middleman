//
//  ReceiveError.swift
//  Middleman
//
//  Created by Valentin Walter on 4/23/20.
//  
//
//  Abstract:
//
//

import Foundation

public enum ReceiveError: Error, CustomStringConvertible {
    case noRunningActionFound(URL)
    case noActionFound(URL)
    case urlCorrupted(URL, message: String)

    public var description: String {
        switch self {
        case let .noRunningActionFound(url):
            return """
            Error:
                URL claims to be response to action sent by Middleman,
                but no running actions could be found for incoming url.
            URL:
                \(url)
            """
        case let .noActionFound(url):
            return """
            No receivable action was found for url (\(url)). \
            Make sure you defined all action you want to be \
            receivable in the `actions` requirement in your `App`.
            """
        case let .urlCorrupted(url, message):
            return """
            Incoming url (\(url)) could not be interpreted as \
            x-callback-url scheme compliant. '\(message)'
            """
        }
    }
}
