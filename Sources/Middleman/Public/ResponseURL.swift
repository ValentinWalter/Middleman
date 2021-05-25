//
//  ResponseURL.swift
//  Middleman
//
//  Created by Valentin Walter on 5/25/21.
//

import Foundation

/// A `CallbackURL` with additional information of the type of response
/// (success/error/cancel and error codes/messages).
public class ResponseURL: CallbackURL {
	/// The response this url represents.
	public let response: PlainResponse

	public let errorCode: Int?
	public let errorMessage: String?

	// Used for receiving
	public init(from url: URL) throws {
		// Quick convenience for throwing errors
		func err(_ msg: String) -> ReceiveError {
			return .urlCorrupted(url, message: msg)
		}

		//TODO: Break down guards
		guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true) else { throw err("URL could not be resolved") }
		guard let host = components.host else { throw err("No host") }
		guard let scheme = components.scheme else { throw err("No scheme") }
		guard var queries = components.queryItems else { throw err("No query items") }
		guard let response = PlainResponse(rawValue: queries.removeFirst(where: { $0.name == Middleman.plainResponseIdentifier})?.value ?? "") else { throw err("No response") }
		guard let id = UUID(uuidString: queries.removeFirst(where: { $0.name == Middleman.responseIDIdentifier})?.value ?? "") else { throw err("No ID") }

		self.response = response
		self.errorCode = Int(queries.removeFirst(where: { $0.name == "errorCode"})?.value ?? "")
		self.errorMessage = queries.removeFirst(where: { $0.name == "errorMessage"})?.value

		super.init(
			scheme: scheme,
			host: host,
			path: components.path,
			queries: Set(queries),
			id: id
		)
	}

	public init?(
		from components: URLComponents,
		errorCode: Int? = nil,
		errorMessage: String? = nil,
		response: PlainResponse
	) {
		self.response = response
		self.errorCode = errorCode
		self.errorMessage = errorMessage
		super.init(from: components)
	}

	public override var components: URLComponents {
		var components = URLComponents()
		components.scheme = self.scheme
		components.host = self.host
		components.path = self.path
		components.queryItems = Array(self.queryItems) + specialQueryItems
		return components
	}

	private var specialQueryItems: [URLQueryItem] {
		[
			URLQueryItem(
				name: Middleman.plainResponseIdentifier,
				value: response.rawValue
			),
			URLQueryItem(
				name: Middleman.responseIDIdentifier,
				value: id.uuidString
			),
			URLQueryItem(
				name: "errorCode",
				value: errorCode.map(String.init)
			),
			URLQueryItem(
				name: "errorMessage",
				value: errorMessage
			)
		].filter { $0.value != nil }
	}
}
