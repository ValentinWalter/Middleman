//
//  Action+Run.swift
//  Middleman
//
//  Created by Valentin Walter on 4/15/20.
//  
//
//  Abstract:
//  The function that opens the action in the current environment with the specified input.
//

import Foundation

#if canImport(Cocoa)
import Cocoa
#elseif canImport(UIKit)
import UIKit
#endif

public extension Action {
    #if swift(>=5.2)
    /// Open the `Endpoint` of this action in the current workspace.
    /// - Parameter input: The input with which to run this action.
    /// - Parameter callback: Called when the client answers either
    /// of the x-callback parameters.
//    func callAsFunction(on app: App, with input: Input, then callback: Callback<Output?>?) {
//        run(on: app, with: input, then: callback)
//    }
    #endif

    /// Open the `Endpoint` of this action in the current workspace.
    /// - Parameter input: The input with which to run this action.
    /// - Parameter callback: Called when the client answers either
    /// of the x-callback parameters.
    func run(on app: App, with input: Input, then callback: Callback<Output?>?) {
        // Convert this action to an endpoint
        guard let xurl = toXCallbackURL(app: app, input: input, callback: callback != nil), let url = xurl.url else {
            print("Could not convert Action '\(String(describing: self))' to x-callback url.")
            return
        }

        // Open url with platform-specific API
        #if canImport(Cocoa)
        NSWorkspace.shared.open(url)
        #elseif canImport(UIKit)
        UIApplication.shared.open(url)
        #endif

        // Store callback identified by UUID (will be called
        // in `Middleman.receive(url:)` with the decoder fit
        // to create this action's `Ouput`)
        guard let callback = callback else { return }
        Middleman.register(for: xurl.id) { xurl in
            switch xurl.response {
            case .success:
                do {
                    let output = try Output(from: xurl.decoder)
                    callback(.success(output))
                } catch {
                    // Will always happen in case of Output being `Never`
                    // TODO: Replace nil with error
                    callback(.success(nil))
                }
            case .error:
                callback(.cancel)
            case .cancel:
                callback(.error(
                    code: xurl.errorCode ?? -1,
                    message: xurl.errorMessage ?? "Middleman: No error message received."
                ))
            }
        }
    }
}

// Provide option to run action without callback when `Output` is `Never`
public extension Action where Output == Never {
    /// Open the `Endpoint` of this action in the current workspace.
    /// - Parameter input: The input with which to run this action.
    func run(on app: App, with input: Input) {
        run(on: app, with: input, then: nil)
    }
}
