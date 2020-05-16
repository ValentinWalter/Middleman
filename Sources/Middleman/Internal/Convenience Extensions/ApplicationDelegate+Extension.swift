//
//  ApplicationDelegate+Extension.swift
//  Middleman
//
//  Created by Valentin Walter on 4/18/20.
//
//
//  Abstract:
//
//

import Foundation
#if os(macOS)
import Cocoa
#elseif os(iOS)
import UIKit
#endif

#if canImport(Cocoa)
public extension NSApplicationDelegate {
    func application(_ application: NSApplication, open urls: [URL]) {
        do { try Middleman.receive(urls: urls) }
        catch { print(error) }
    }
}
#endif

#if canImport(UIKit)
private extension UISceneDelegate {
    // ---
    // Won't work because SceneDelegate is now responsible for doing this
    // ---

    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        do {
            try Middleman.receive(url: url)
            return true
        } catch {
            print(error)
            return false
        }
    }
}

private extension UISceneDelegate {
    // ---
    // Won't work because protocol extensions cannot introduce @objc entry points due to
    // limitations of the Objective-C runtime.
    // ---

    func scene(_ scene: UIScene, openURLContexts urlContexts: Set<UIOpenURLContext>) {
        let urls = urlContexts.map(\.url)
        do { try Middleman.receive(urls: urls) }
        catch { print(error) }
    }
}
#endif
