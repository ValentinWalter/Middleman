//
//  Receiver.swift
//  Middleman
//
//  Created by Valentin Walter on 5/16/20.
//  
//
//  Abstract:
//  Conform to this protocol if your goal is to receive actions.
//

import Foundation

public protocol Receiver: App {
    /// Specify the actions that your app can receive.
    var receivingActions: [AnyAction] { get }

    /// Called when app opened by url not sent by Middleman.
    /// - Parameter xurl: An instance of `CallbackURL` representing the url that opened the app.
    func receive(xurl: ResponseURL) throws
}
