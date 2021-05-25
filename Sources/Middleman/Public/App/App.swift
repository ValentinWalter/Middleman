//
//  App.swift
//  Middleman
//
//  Created by Valentin Walter on 4/22/20.
//

import Foundation

/// An app specifies some of the aspects needed to *send* actions. Conform to
/// this protocol if your goal is to solely provide an API to others, not
/// receive actions.
///
/// See [Honey](https://github.com/valentinwalter/honey) for an implementation
/// of an `App` as API for others.
public protocol App {
    /// The custom scheme your app accepts x-callback-urls with.
    var scheme: String { get }
    /// The host component your app accepts x-callback-urls with.
    var host: String { get }
}

public extension App {
	/// The `url-scheme://` of the app. Usually just the lowercased app name, so
	/// `AppName` becomes `appname`.
	///
	/// By default this is the lowercased type name of your app.
    var scheme: String {
        String(describing: type(of: self)).lowercased()
    }
	
	/// By default, `host` will be assumed to be `"x-callback-url"`, as specified by the [x-callback-url 1.0 DRAFT spec](http://x-callback-url.com/specifications/).
    var host: String { "x-callback-url" }
}
