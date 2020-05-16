//
//  DefaultReceiver.swift
//  Middleman
//
//  Created by Valentin Walter on 4/23/20.
//  
//
//  Abstract:
//
//

import Foundation

/// Middleman uses this `Receiver` as default when you do not specify any custom `Receiver` yourself.
/// This is useful if you only *send* actions, but do not intend on *receiving* any.
internal struct DefaultReceiver: Receiver {
    let scheme: String
    let receivingActions: [AnyAction] = []

    /// Creates an instance of `DefaultApp` with the specified `scheme`.
    init(scheme: String) { self.scheme = scheme }

    /// Creates an instance of `DefaultApp` with an empty `scheme`.
    init() { self.scheme = "" }

    /// Creates an instance of `DefaultApp` with `scheme` set to the first entry found in `CFBundleURLTypes` in the specified bundle's info dictionary.
    /// - Throws: `BundleError`
    static func from(bundle: Bundle) throws -> Self {
        //TODO: Break down statements
        guard bundle.infoDictionary != nil else { throw BundleError.infoDictionaryMissing }
        guard let urlTypes = bundle.object(forInfoDictionaryKey: "CFBundleURLTypes") as? [[String: Any]] else { throw BundleError.urlTypesMissing }
        guard let urlSchemes = urlTypes.first?["CFBundleURLSchemes"] as? [String] else { throw BundleError.urlSchemesMissing }
        guard let scheme = urlSchemes.first else { throw BundleError.urlSchemesEmpty }

        return self.init(scheme: scheme)
    }

    /// An error that can occurr when calling `from(bundle:)`.
    struct BundleError: Error {
        /// The message specific to this error.
        let message: String

        /// A guide that is appended to each error message.
        private static let appendix = """
        Make sure you have a custom url scheme defined for your app. \
        If you have, try manually configuring Middleman by calling \
        'Middleman.configure(with:)' and using 'Config.init(scheme:host:path:)'.
        """

        var description: String {
            "\(message) \(Self.appendix)"
        }

        static let infoDictionaryMissing = BundleError(message: "'Info.plist' missing in Bundle.")
        static let urlTypesMissing = BundleError(message: "'CFBundleURLTypes' missing in 'Info.plist'.")
        static let urlSchemesMissing = BundleError(message: "'CFBundleURLSchemes' missing in 'Info.plist'.")
        static let urlSchemesEmpty = BundleError(message: "'CFBundleURLSchemes' in 'Info.plist' is empty.")
    }
}

extension DefaultReceiver {
    /// Intended for testing.
    internal static func from(xml: String) throws -> Self {
        let plist = try? PropertyListSerialization.propertyList(from: xml.data(using: .utf8)!, format: nil)
        guard let urlTypes = (plist as? [String: Any])?["CFBundleURLTypes"] as? [[String: Any]] else { throw BundleError.urlTypesMissing }
        guard let urlSchemes = urlTypes.first?["CFBundleURLSchemes"] as? [String] else { throw BundleError.urlSchemesMissing }
        guard let scheme = urlSchemes.first else { throw BundleError.urlSchemesEmpty }

        return self.init(scheme: scheme)
    }
}
