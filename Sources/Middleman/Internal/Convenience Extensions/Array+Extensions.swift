//
//  Array+Appending.swift
//  Middleman
//
//  Created by Valentin Walter on 4/17/20.
//

import Foundation

internal extension Array {
	/// Appends the element and returns a new array.
	/// - Parameter element: The element to append.
	/// - Returns: A new array.
    func appending(_ element: Element) -> Self {
        var array = self
        array.append(element)
        return array
    }

    /// Removes and returns the first element that satisfies the given predicate.
    /// - Returns: The element that has been removed.
    mutating func removeFirst(where shouldBeRemoved: (Element) -> Bool) -> Element? {
        var i = 0
        for element in self {
            if shouldBeRemoved(element) {
                remove(at: i)
                return element
            }
            i += 1
        }
        return nil
    }

    /// Removes and returns the last element that satisfies the given predicate.
    /// - Returns: The element that has been removed.
    mutating func removeLast(where shouldBeRemoved: (Element) -> Bool) -> Element? {
        var reversed = Array(self.reversed())
        return reversed.removeFirst(where: shouldBeRemoved)
    }
}
