//
//  Config.swift
//  Middleman
//
//  Created by Valentin Walter on 4/18/20.
//  
//  --------------
//   - Outdated -
//  --------------
//

import Foundation

public extension Middleman {

    /**
    The components that will be factored in when creating
    the url your app will be opened by the client with.

    By default, the first `CFBundleURLTypes` (or simply
    "URL types" in the plist interface) entry in your
    `Info.plist` file will be read, defining the custom
    scheme for Middleman to receive the client's callbacks
    with.

    # Manually defining the config
    You can also manually define the components. If you
    already registered a custom scheme for you app, for
    example `"myapp"`, you would create your config
    like this:

        Config(scheme: "myapp")

    - Note: Optionally you can also customize the `host`
     and `path` of the url.

    - Important: **Your app must have a custom scheme
     configured.** See *Further resources* for helpful links.

    # Further resources
    * To learn more about the [x-callback url scheme](http://x-callback-url.com)
     visit the official website.
    * To learn more about creating a custom scheme for your
     own app visit this Developer Documentation article on
     [Defining a Custom URL Scheme for Your App](https://developer.apple.com/documentation/uikit/inter-process_communication/allowing_apps_and_websites_to_link_to_your_content/defining_a_custom_url_scheme_for_your_app).
    */
    struct Config {
        public let scheme: String
        public let host: String
        public let path: String

        public init(
            scheme: String,
            host: String = "x-callback-url",
            path: String = "client-response"
        ) {
            // Make sure path has "/" prefix
            var path = path
            if !path.hasPrefix("/") {
                path.insert("/", at: path.startIndex)
            }

            self.scheme = scheme
            self.host = host
            self.path = path
        }

        // Function instead of `init` to make stark
        // difference more readable.
        // See `Config()` vs. `Config.from(bundle: .main)`
        /// The `CFBundleURLTypes` entry in your `Info.plist`
        /// file will be read, defining a custom scheme for Middleman to
        /// receive the client's callbacks with.
        /// - Parameter bundle: The `Bundle` in which to look
        ///  for the `Info.plist` file. By default `Bundle.main`.
        /// - Throws: `Config.InitError`
        internal static func from(bundle: Bundle) throws -> Self {
            //TODO: Break down statements
            guard bundle.infoDictionary != nil else { throw BundleError.infoDictionaryMissing }
            guard let urlTypes = bundle.object(forInfoDictionaryKey: "CFBundleURLTypes") as? [[String: Any]] else { throw BundleError.urlTypesMissing }
            guard let urlSchemes = urlTypes.first?["CFBundleURLSchemes"] as? [String] else { throw BundleError.urlSchemesMissing }
            guard let scheme = urlSchemes.first else { throw BundleError.urlSchemesEmpty }

            return self.init(scheme: scheme)
        }

        /// An instance of `URLComponents` based on the `scheme`,
        /// `host` and `path` properties.
        public var urlComponents: URLComponents {
            var components = URLComponents()
            components.scheme = self.scheme
            components.host = self.host
            components.path = self.path
            return components
        }

        /// An error that occurred when calling `init(for:)`.
        struct BundleError: Swift.Error {
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

}
