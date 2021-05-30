<p align="right">⭐️ <a href="http://x-callback-url.com/2021/05/middleman-type-safe-x-callback-url-library/">Featured on the official <code>x-callback-url.com</code> blog</a></p>

# 👤 Middleman
**A 100% type-safe API to the [x-callback-url scheme](http://x-callback-url.com).**

* [Overview](#-overview)
* [Setup](#-setup)
    + [Receiving urls](#receiving-urls)
    + [Manually defining your url scheme](#manually-defining-your-url-scheme)
    + [Installation](#installation)
* [API](#-api)
    + [Basic workflow](#basic-workflow)
    + [Actions](#actions)
    + [Apps and Receivers](#apps-and-receivers)
    + [Running an Action](#running-an-action)
* [Best Practices](#-best-practices)
* [Behind the scenes](#-behind-the-scenes)

## 🏔 Overview
Suppose we want to build this `x-callback-url` in Middleman:

```
target://x-callback-url/do-something?
    key=value&
    x-success=source://x-callback-url/success?
        something=thing&
    x-error=source://x-callback-url/error?
        errorCode=404&
        errorMessage=message
```

We first declare the `App` called "Target". Target's only purpose is to provide the `url-scheme://`. It also makes a good namespace for all your actions. An `Action` is comprised of two nested types: `Input` and `Output`, which must conform to `Codable`. There are further customization option that you will learn about later.\
To run the action, you call `run(action:with:then:)` on the `App`. `run` wants to know the `Action` to run, the `Input` of that action and a closure that is called with a `Response<Output>` once a callback is registered.

```swift
struct Target: App {
    struct DoSomething: Action {
        struct Input: Codable {
            let key: Value
            let optional: Value?
            let default: Value? = nil
        }
        
        struct Output: Codable {
            let something: Thing
        }
    }
}

// Running the action
Target().run(
    action: DoSomething(),
    with: .init(
        key: value,
        optional: nil
    ),
    then: { response in
        switch response {
        case let .success(output):
            print(output?.something)
        case let .error(code, msg):
            print(code, msg)
        case .cancel:
            print("canceled")
        }
    }
)
```

#### Next steps
* Overhaul the receiving-urls-API so Middleman can be used to maintain x-callback APIs, not just work with existing ones
* Implement a command-line interface using `apple/swift-argument-parser`
* Migrate from callbacks to `async` in Swift 6

#### Examples
* 🍯 [Honey](https://github.com/ValentinWalter/Honey) uses Middleman to provide a swifty API for Bear's x-callback-url API
* File a pull request to include your own project!

## 🛠 Setup
If you want to receive callbacks you need to make sure your app has a [custom url scheme](https://developer.apple.com/documentation/uikit/inter-process_communication/allowing_apps_and_websites_to_link_to_your_content/defining_a_custom_url_scheme_for_your_app) implemented. Middleman will then read the first entry in the `CFBundleURLTypes` array in the main bundle's `Info.plist`. You can also [manually define a url scheme](#manually-defining-your-url-scheme).

### Receiving urls
For Middleman to be able to parse incoming urls, you need to put one of the following methods in the delegate (UIKit/Cocoa) appropriate for your platform or in the `onOpenURL` SwiftUI modifier.

```swift
// SwiftUI
// On any view (maybe in your `App`)
.onOpenURL { url in
    Middleman.receive(url)
}

// macOS
// In your `NSAppDelegate`:
func application(_ application: NSApplication, open urls: [URL]) {
    Middleman.receive(urls)
}

// iOS 13 and up
// In your `UISceneDelegate`:
func scene(_ scene: UIScene, openURLContexts urlContexts: Set<UIOpenURLContext>) {
    Middleman.receive(urlContexts)
}

// iOS 12 and below
// In your `UIAppDelegate`:
func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
    Middleman.receive(url)
}
```

### Manually defining your url scheme
If Middleman's default behavior of reading from the `Info.plist` file does not work for you, you can manually define your url scheme. You do so by setting `Middleman.receiver` to your custom implementation.

```swift
struct MyApp: Receiver {
    var scheme: String { "my-scheme" }
}

// Then, notify Middleman of your custom implementation
Middleman.receiver = MyApp()
```

### Installation
Middleman is a [Swift Package](https://swift.org/package-manager/). Write this in your `Package.swift` file:

```swift
let package = Package(
    ...
    dependencies: [
        .package(url: "https://github.com/ValentinWalter/middleman.git", from: "1.0.0")
    ],
    ...
)
```

## 👾 API
### Basic workflow
* Define an `Action`, representing an x-callback-url action.
* Define an `App`, which is responsible for sending and receiving actions.
* Run actions via `App.run(action:)` with their `Input` associated type, optionally providing a closure that receives the Action's `Output`.

### Actions
An action in Middleman represents an x-callback-url action. You create an action by conforming to the `Action` protocol. This requires you to define an `Input` and `Output`, which themselves require conformance to `Codable`. By default, Middleman will infer the path name of the action to be the [kebab-case](https://en.wikipedia.org/wiki/Letter_case#Special_case_styles) equivalent of the name of the `Action` type. In the example below, this would result in `"open-note"`. You can overwrite this behavior by implementing the `path` property into your Action.

```swift
// Shortened version of Bear's /open-note action
struct OpenNote: Action {
    struct Input: Codable {
        var title: String
        var excludeTrashed: Bool
    }

    struct Output: Codable {
        var note: String
        var modificationDate: Date
    }
}
```

You can make handy use of `typealias` when it doesn't make sense to create your own type. Here we have an Action that takes a `URL` and has no output. Sometimes an Action doesn't have an `Input` or `Output`. In those cases, just typealias it to be `Never` and Middleman handles the rest.

```swift
struct OpenURL: Action {
    typealias Input = URL
    typealias Output = Never
}
```

#### Receiving Actions
You can implement the `receive(input:)` method in your Action to customize the behavior when the action was received by Middleman. Note that you also need to include your receiving action in your [Receiver's](#apps-and-receivers) `receivingActions` property. This API is in an alpha state (see [next steps](#next-steps)).

```swift
struct OpenBook: Action {
    ...
    func receive(input: Input) {
        // Handle opening book
    }
}
```

### Apps and Receivers
Sending actions requires an `App`. You create one by conforming to the `App` protocol. Similarly to the `Action` protocol, Middleman infers the url-scheme of the app to be the kebab-case equivalent of the name of the conforming type. By default, the `host` property will be assumed to be `"x-callback-url"`, as specified by the [x-callback-url 1.0 DRAFT spec](http://x-callback-url.com/specifications/).

```swift
struct Bear: App {
    // By default, Middleman infers the two properties as implemented below
    var scheme: String { "bear" }
    var host: String { "x-callback-url" }
}
```

If your intent is to not only *send*, but *receive* actions, you define a `Receiver`, which inherits from the `App` protocol.  This requires you to specify the actions with which your App can be opened. You then need to notify Middleman of your custom implementation, as described in [Manually defining your url scheme](#manually-defining-your-url-scheme). This API is in an alpha state (see [next steps](#next-steps)).

```swift
struct MyApp: Receiver {
    var receivingActions = [
        OpenBook().erased(),
        AnotherAction().erased()
    ]
}
```

### Running an Action
Here's how running the [above implementation](#actions) of `OpenNote` would look.

```swift
Bear().run(
    action: OpenNote(),
    with: .init(
        title: "Title",
        excludeTrashed: true
    ),
    then: { response in
        switch response {
        case let .success(output): print(output?.note)
        case let .error(code, message): print(code, message)
        case .cancel: print("canceled")
        }
    }
)
```

In the case of an action having neither an `Input` or `Output`, you would have something like this:

```swift
SomeApp().run(
    action: SomeAction(),
    then: { response in
        switch response {
        case .success: print("success!")
        case .error(let code, let msg): print(code, msg)
        case .cancel: print("canceled")
        }
    }
)
```

## 🤝 Best Practices
It's a good idea to namespace your actions in an extension of their `App`. You can then also define static convenience functions, as calling the `run` method can get quite verbose. Following the `OpenNote` example from above:

```swift
extension Bear {
    // Namespaced declaration of the `OpenNote` action
    struct OpenNote { ... }

    // Static convenience function, making working with `OpenNote` more pleasant
    static func openNote(
        titled title: String,
        excludeTrashed: Bool = false,
        then callback: @escaping () -> Void
    ) {
        Bear().run(
            action: OpenNote(),
            with: .init(
                title: title,
                excludeTrashed: excludeTrashed
            ),
            then: { response in
                switch response {
                case .success(let output):
                    guard let output = output else { break }
                    callback(output.note)
                case .error: break
                case .cancel: break
                }
            }
        )
    }
}

// Opening a note is now as easy as
Bear.openNote(titled: "Title") { note in
    print("\(note) 🥳")
}
```

## 🎭 Behind the scenes
Middleman uses a custom `Decoder` to go from raw URL to your `Action.Output`. Dispatched actions are stored with a `UUID` that Middleman inserts to each `x-success`/`x-error`/`x-cancel` parameter to match actions and their stored callbacks.
