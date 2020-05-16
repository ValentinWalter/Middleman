# Middleman Pre-Release
A 100% type safe API to the x-callback-url scheme.

### Defining an Action
```swift
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

### Defining an App
```swift
struct Bear: App {
  var scheme: String { "bear" }
}
```

### Running an Action
```swift
Bear().run(
  action: OpenNote(),
  with: .init(
    title: "Title",
    excludeTrashed: true
  ),
  then: { output in
    print(output.note)
  }
)
```
