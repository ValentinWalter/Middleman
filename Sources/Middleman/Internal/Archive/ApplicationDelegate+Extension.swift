//
//  ApplicationDelegate+Extension.swift
//  Middleman
//
//  Created by Valentin Walter on 4/18/20.
//
//  Extensions to various delegates. This has been archived to look at again in
//  the future.
//

import Foundation
#if os(macOS)
import Cocoa
#elseif os(iOS)
import UIKit
#endif

//#if canImport(Cocoa)
//public extension NSApplicationDelegate {
//    func application(_ application: NSApplication, open urls: [URL]) {
//        do { try Middleman.receive(urls) }
//        catch { print(error) }
//    }
//}
//#endif
//
//#if canImport(UIKit)
//private extension UISceneDelegate {
//    // ---
//    // Won't work with iOS 13 and up because SceneDelegate is now responsible for doing this.
//    // ---
//
//    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
//        do {
//            try Middleman.receive(url: url)
//            return true
//        } catch {
//            print(error)
//            return false
//        }
//    }
//}
//
//private extension UISceneDelegate {
//    // ---
//    // Won't work because protocol extensions cannot introduce @objc entry points due to
//    // limitations of the Objective-C runtime.
//    // ---
//
//    func scene(_ scene: UIScene, openURLContexts urlContexts: Set<UIOpenURLContext>) {
//        do { try Middleman.receive(urlContexts) }
//        catch { print(error) }
//    }
//}
//#endif
