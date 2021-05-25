//
//  Action+run.swift
//  Middleman
//
//  Created by Valentin Walter on 4/15/20.
//  

import Foundation

#if canImport(Cocoa)
import Cocoa
#elseif canImport(UIKit)
import UIKit
#endif

extension Action {
	/// This function contains the actual logic of creating the URL, opening it
	/// with the platform-specific API and registering the action with
	/// Middleman.
	/// - Parameters:
	///   - app: The `App` (url-scheme) with which to run this action.
	///   - input: The `Action`'s `Input` associated type.
	///   - callback: A callback with a `Response` to switch over.
    internal func _run(on app: App, with input: Input?, then callback: Callback<Output?>?) {
        // Convert this action to a URL
        guard let xurl = toXCallbackURL(app: app,
                                        input: input,
                                        hasCallback: callback != nil),
              let url = xurl.url else
        {
            print(
                """
                ⚠️ Could not convert Action '\(String(describing: self))' to \
                x-callback url.
                """
            )
            return
        }

        // Open url with platform-specific API
        #if canImport(Cocoa)
        NSWorkspace.shared.open(url)
        #elseif canImport(UIKit)
        UIApplication.shared.open(url)
        #endif

        // Store callback identified by a UUID (will be called in
		// `Middleman.receive(url:)` with the decoder fit to create this
		// action's `Ouput`)
        guard let callback = callback else { return }
		guard Middleman.receiver != nil else {
			print("""
			⚠️ You have specified a callback but not a Receiver.
			ℹ️ Set a receiver via `Middleman.receiver = ...`
			""")
			return
		}
        Middleman.register(for: xurl.id) { xurl in
            switch xurl.response {
            case .success:
                do {
                    let output = try Output(from: xurl.decoder)
                    callback(.success(output))
                } catch {
                    if error is Never.CodingError {
                        callback(.success(nil))
                    } else {
                        callback(
                            .error(
                                code: -1,
                                message: """
                                Middleman: `Ouput` could not be decoded.
                                """
                            )
                        )
                    }
                }
            case .error:
                callback(.error(
                    code: xurl.errorCode ?? -1,
                    message: xurl.errorMessage ??
                        "Middleman: No error message received."
                ))
            case .cancel:
                callback(.cancel)
            }
        }
    }
}
