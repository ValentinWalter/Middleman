//
//  Bool+init(yesNo).swift
//  Middleman
//
//  Created by Valentin Walter on 4/18/20.
//  
//
//  Abstract:
//
//

import Foundation

extension Bool {
    /// Initializes a boolean based on a `"yes"` or `"no"` string.
    /// - Parameter yesNo: Either `"yes"` or `"no"`. Case is irrelevant.
    init?(yesNo: String) {
        let yesNo = yesNo.lowercased()
        if yesNo == "yes" {
            self = true
        } else if yesNo == "no" {
            self = false
        } else {
            return nil
        }
    }
}
