//
//  Action+toXCallbackURL.swift
//  Middleman
//
//  Created by Valentin Walter on 4/15/20.
//

import Foundation
import StringCase

extension Action {
	/// Create the actual URL that will be opened by the operating system.
	/// - Parameters:
	///   - app: The `App` (url-scheme) with which to run this action.
	///   - input: The `Action`'s `Input` associated type.
	///   - hasCallback: Whether the action was equipped with a callback.
	/// - Returns: An instance of `CallbackURL` to build the actual URL.
    func toXCallbackURL(app: App, input: Input?, hasCallback: Bool) -> CallbackURL? {
        let callbackURL = CallbackURL(from: app.urlComponents)
        callbackURL?.path = self.path.prefixed(with: "/")
		if let input = input {
			callbackURL?.queryItems += queryItems(from: input)
		}
			
        if let id = callbackURL?.id, hasCallback {
            callbackURL?.queryItems += xCallbackParameters(for: id) ?? []
        }

        return callbackURL
    }

    private func xCallbackParameters(for id: UUID) -> [URLQueryItem]? {
        PlainResponse.allCases
            .compactMap { response in
				guard let receiver = Middleman.receiver else { return nil }
				
				let responseComponents = receiver.urlComponents
                guard let responseURL = ResponseURL(from: responseComponents, response: response) else { return nil }
                responseURL.id = id

                // Create url from components and make x-callback parameter
                guard let url = responseURL.url else { return nil }
                let xCallbackParameter = URLQueryItem(
                    name: response.asParameterKey,
                    value: url.absoluteString
                )

                // Finally, append the x-callback parameter to the components
				// that will make up the final url
                return xCallbackParameter
            }
    }

    private func queryItems(from input: Input) -> [URLQueryItem] {
        Mirror(reflecting: input).children
            .compactMap { child in
                guard let name = child.label?.snakeCased() else { return nil }
                // Check if value is `CustomQueryConvertible` first.
                // `CustomQueryConvertible` check is deliberately in
                // seperate branch from `CustomStringConvertible` below,
                // as `CustomQueryConvertible` allows for intentional
                // passing of `nil`.
                if let value = child.value as? CustomQueryConvertible {
                    guard let value = value.queryValue else { return nil }
                    return URLQueryItem(name: name, value: value)
                } else {
                    // Else assume `CustomStringConvertible`, tolerate nil if not
                    let stringConvertible = child.value as? CustomStringConvertible
                    guard let value = stringConvertible?.description else { return nil }
                    return URLQueryItem(name: name, value: value)
                }
            }
    }

}

extension App {
    /// An instance of `URLComponents` based on the `scheme`, `host` and `path`
	/// properties.
    fileprivate var urlComponents: URLComponents {
        var components = URLComponents()
        components.scheme = self.scheme
        components.host = self.host
        components.path = Middleman.clientResponsePath
        return components
    }
}
