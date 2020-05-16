# Middleman Pre-Release
A 100% type safe API to the [x-callback-url scheme](http://x-callback-url.com). 

> This project is at a very early stage. For the time being there is no versioning, and breaking changes are to be expected any time.

* [Setup](#setup)
  + [Receiving urls](#receiving-urls)
  + [Manually defining your url scheme](#manually-defining-your-url-scheme)
* [API](#api)
  + [Basic workflow](#basic-workflow)
  + [Actions](#actions)
  + [Apps and Receivers](#apps-and-receivers)
    - [Running an Action](#running-an-action)
* [Best Practices](#best-practices)

## Setup
First of all, make sure your app has a [custom url scheme](https://developer.apple.com/documentation/uikit/inter-process_communication/allowing_apps_and_websites_to_link_to_your_content/defining_a_custom_url_scheme_for_your_app) implemented. Middleman will then read the first entry in the `CFBundleURLTypes` entry in the `Info.plist` file in the main bundle. You can also [manually define a url scheme](#manually-defining-your-url-scheme).

### Receiving urls
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
If Middleman's default behavior does not work for you, you can manually define your url scheme. You do so by setting `Middleman.receiver` to your custom implementation.
```swift
struct MyApp: Receiver {
    var scheme: String { "my-scheme" }
}

// Then, notify Middleman of your custom implementation
Middleman.receiver = MyApp()
```

## API
### Basic workflow
* Define an Action, representing a x-callback-url action
* Define an App, which is responsible for sending and receiving actions
* Running actions with their `Input`, optionally providing a closure that receives the Action's `Output`

### Actions
An Action in Middleman represents an x-callback-url action. You create an Action by conforming to the `Action` protocol. This requires you to define an `Input` and `Output`, which themselves require to conform to `Codable`. By default, Middleman will convert the name of the `Action` type from uppercase camelcase to [kebab-case](https://en.wikipedia.org/wiki/Letter_case#Special_case_styles). In the example below, this would result in `"open-note"`. You can overwrite this behavior by implementing `path` into your Action.
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

An implementation of an Action that takes a `URL` and has no output.
```swift
struct OpenURL: Action {
    typealias Input = URL
    typealias Output = Never
}
```
Sometimes an Action doesn't have an `Input` or `Output`. In those cases, just set it to be `Never` and Middleman handles the rest. Also, when you don't need to define a custom type for your `Input` or `Output`, just make use of `typealias`.

### Apps and Receivers
Sending Actions requires an `App`. You create one by conforming to the `App` protocol. Similarly to the Action protocol, Middleman infers the scheme of the app to be the name of the type. By default, `host` will be assumed to be `"x-callback-url"`, as specified by the [x-callback-url 1.0 DRAFT spec](http://x-callback-url.com/specifications/).
```swift
struct Bear: App {
    // By default, Middleman infers the two properties as implemented below
    var scheme: String { "bear" }
    var host: String { "x-callback-url" }
}
```

If your intent is to not only *send*, but *receive* actions, you define a `Receiver`. You then need to notify Middleman of your custom implementation, as described in [Manually defining your url scheme](#manually-defining-your-url-scheme).
```swift
struct MyApp: Receiver {
    var receivingActions = [
        MyAction().erased(),
        AnotherAction().erased()
    ]
}
```

#### Running an Action
Here's how running the above implementation of `OpenNote` would look.
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

In the case of an action not having an Input or Output.
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
Calling the `run` method can get quite verbose over time. To make working with your actions more pleasant, you can define static convenience methods in your `App`. Following the `OpenNote` example from above:
```swift
extension Bear {
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
                case let .success(output): callback()
                case let .error(code, message): break
                case .cancel: break
                }
            }
        )
    }
}

// Opening a note is now as easy as
Bear.openNote(titled: "Title")
```
