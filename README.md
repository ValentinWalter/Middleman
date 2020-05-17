# Middleman Pre-Release
A 100% type safe API to the [x-callback-url scheme](http://x-callback-url.com). 

> This project is at an early stage. For the time being there is no versioning, and breaking changes are to be expected any time.

* [Setup](#setup)
	+ [Receiving urls](#receiving-urls)
	+ [Manually defining your url scheme](#manually-defining-your-url-scheme)
	+ [Installation](#installation)
* [API](#api)
	+ [Basic workflow](#basic-workflow)
	+ [Actions](#actions)
	+ [Apps and Receivers](#apps-and-receivers)
	+ [Running an Action](#running-an-action)
* [Best Practices](#best-practices)

## Setup
First of all, make sure your app has a [custom url scheme](https://developer.apple.com/documentation/uikit/inter-process_communication/allowing_apps_and_websites_to_link_to_your_content/defining_a_custom_url_scheme_for_your_app) implemented. Middleman will then read the first entry in the `CFBundleURLTypes` array in the main bundle's `Info.plist`. You can also [manually define a url scheme](#manually-defining-your-url-scheme).

### Receiving urls
For Middleman to be able to parse incoming urls, you need to put one of the following methods in the Delegate appropriate for your platform.
```swift
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
Middleman is based on the [Swift Package Manager](https://swift.org/package-manager/). Write this in your `Package.swift` file:
```swift
let package = Package(
    ...
    dependencies: [
        .package(url: "https://github.com/ValentinWalter/middleman.git", .branch("pre-release"))
    ],
    ...
)
```

## API
### Basic workflow
* Define an `Action`, representing an x-callback-url action.
* Define an `App`, which is responsible for sending and receiving actions.
* Run actions with their `Input` associated type, optionally providing a closure that receives the Action's `Output`.

### Actions
An Action in Middleman represents an x-callback-url action. You create an Action by conforming to the `Action` protocol. This requires you to define an `Input` and `Output`, which themselves require conformance to `Codable`. By default, Middleman will infer the path name of the action to be the [kebab-case](https://en.wikipedia.org/wiki/Letter_case#Special_case_styles) equivalent of the name of the `Action` type. In the example below, this would result in `"open-note"`. You can overwrite this behavior by implementing the `path` property into your Action.
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

You can make handy use of `typealias` when it doesn't make sense to create your own type. Here we have an Action that takes a `URL` and has no output.
```swift
struct OpenURL: Action {
    typealias Input = URL
    typealias Output = Never
}
```
Sometimes an Action doesn't have an `Input` or `Output`. In those cases, just set it to be `Never` and Middleman handles the rest.

#### Receiving Actions
You can implement the `receive(input:)` method in your Action to customize the behavior when the action was received by Middleman. Note that you also need to include your receiving action in your [Receiver's](#apps-and-receivers) `receivingActions` property.
```swift
struct OpenBook: Action {
    ...
    func receive(input: Input) {
        // Handle opening book
    }
}
```

### Apps and Receivers
Sending Actions requires an `App`. You create one by conforming to the `App` protocol. Similarly to the `Action` protocol, Middleman infers the scheme of the app to be the kebab-case equivalent of the name of the conforming type. By default, the `host` property will be assumed to be `"x-callback-url"`, as specified by the [x-callback-url 1.0 DRAFT spec](http://x-callback-url.com/specifications/).
```swift
struct Bear: App {
    // By default, Middleman infers the two properties as implemented below
    var scheme: String { "bear" }
    var host: String { "x-callback-url" }
}
```

If your intent is to not only *send*, but *receive* actions, you define a `Receiver`, which inherits from the `App` protocol.  This requires you to specify the actions with which your App can be opened. You then need to notify Middleman of your custom implementation, as described in [Manually defining your url scheme](#manually-defining-your-url-scheme).
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
        case let .success(output): print(output.note)
        case let .error(code, message): print(code, message)
        case .cancel: print("canceled")
        }
    }
)
```

In the case of an action not having an `Input` or `Output`, you would have something like this.
```swift
SomeApp().run(
    action: SomeAction(),
    then: { response in
        switch response {
        case .success: print("success!")
        case .error(let code, let message): print(code, message)
        case .cancel: print("canceled")
        }
    }
)
```

## Best Practices
It's a good idea to namespace your actions in an extension of their App. You can then also define static convenience functions, as calling the `run` method can get quite verbose over time. Following the `OpenNote` example from above:
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
                case .success: callback()
                case .error: break
                case .cancel: break
                }
            }
        )
    }
}

// Opening a note is now as easy as
Bear.openNote(titled: "Title") {
    print("🥳")
}
```
