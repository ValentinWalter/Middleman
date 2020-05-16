//
//  Receiver+receive.swift
//  Middleman
//
//  Created by Valentin Walter on 4/23/20.
//  
//
//  Abstract:
//
//

import Foundation

public extension Receiver {

    func receive(xurl: ResponseURL) throws {
        // Extract action from actions defined as receivable on `App` protocol
        guard let action = receivingActions.first(where: { $0.path == xurl.path }) else {
            throw ReceiveError.noActionFound(xurl.url!)
        }

        try action.receive(xurl.decoder)
    }

}
