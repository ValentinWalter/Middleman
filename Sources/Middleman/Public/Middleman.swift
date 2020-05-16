//
//  Middleman.swift
//  Middleman
//
//  Created by Valentin Walter on 4/15/20.
//
//
//  Abstract:
//  The entity responsible for parsing incoming urls.
//

import Foundation

public struct Middleman {

    //MARK:- Public

    /// The app that is receiving responses to actions sent by Middleman.
    ///
    /// Middleman tries to read your custom scheme from your info dictionary.
    /// - Note: Ignore this if you're aim is just to provide an interface for other applications.
    public static var receiver: Receiver = {
        do {
            return try DefaultReceiver.from(bundle: .main)
        } catch {
            print(error)
            return DefaultReceiver()
        }
    }()

    /// Call this in the `application(_:open:)` method in your `NSAppDelegate`.
    ///
    /// - Parameter url: The array of urls with which your app was opened.
    public static func receive(urls: [URL]) throws { try urls.forEach(receive) }

    /// Call this in the `application(_:open:options:)` method in your `UIAppDelegate`.
    ///
    /// - Parameter url: The url with which your app was opened.
    public static func receive(url: URL) throws {
        // Compare incoming url with url components described in config
        let xurl = try ResponseURL(from: url)
        // If action is response to action sent by Middleman
        if xurl.path == Middleman.clientResponsePath {
            // Extract action from running actions
            guard let index = Middleman.runningActions.index(forKey: xurl.id) else {
                throw ReceiveError.noRunningActionFound(url)
            }
            let action = Middleman.runningActions.remove(at: index).value

            try action(xurl)
        } else {
            // Else, leave processing to the Receiver's implmentation
            try receiver.receive(xurl: xurl)
        }
    }

    //MARK:- Internal

    /// An `Action` will insert its callback here, keyed by a unique identifier that will allow calling the stored callback later in `Middleman.receive(url:)`.
    private static var runningActions: [UUID: (ResponseURL) throws -> Void] = [:]

    /// Provides a readable way to register callbacks for actions in `Middleman.runningActions`. Called by actions to handle the decoding of their Outputs.
    /// 
    /// - Parameters:
    ///   - callback: A `Callback` that injects a `CallbackURLDecoder` fit for decoding the action's `Output`.
    ///   - actionID: The `UUID` associated with the action.
    internal static func register(
        for actionID: UUID,
        then callback: @escaping (ResponseURL) -> Void
    ) {
        runningActions[actionID] = callback
    }

    /// Middleman uses this identifier to look for the
    /// response type in the x-success, x-error and
    /// x-cancel urls opened by the client. This being
    /// prefixed by `"__middleman"` makes it
    /// practically impossible for the user or client to
    /// come up with a conflicting query name.
    internal static let plainResponseIdentifier = "__middleman_response_type_identifier"
    /// Middleman uses this identifier to look for the
    /// response id in the x-success, x-error and
    /// x-cancel urls opened by the client. This being
    /// prefixed by `"__middleman"` makes it
    /// practically impossible for the user or client to
    /// come up with a conflicting query name.
    internal static let responseIDIdentifier = "__middleman_response_id_identifier"
    /// Middleman uses this path to build the x-success,
    /// x-error and x-cancel urls opened by the client.
    /// This being prefixed by `"__middleman"` makes
    /// it practically impossible for the user or client to
    /// come up with a conflicting query name.
    internal static let clientResponsePath = "/__middleman-client-response"
}

#if canImport(UIKit)
import UIKit

extension Middleman {
    /// Call this in the `scene(_:openURLContexts:)` method in your `UISceneDelegate`.
    ///
    /// - Parameter urlContexts: The array of `UIOpenURLContext`s with which your app were opened.
    public static func receive(urlContexts: Set<UIOpenURLContext>) throws {
        let urls = urlContexts.map(\.url)
        try urls.forEach(receive)
    }
}
#endif
