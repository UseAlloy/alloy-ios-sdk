# Alloy iOS SDK

## Example project

If you open this project with Xcode you can run and test the `AlloyExample` sample app.
You can view the source code in the folder with the same name.

## Installation

Currently the only package manager we support is [CocoaPods][cocoapods].

To integrate Alloy into your XCode project, simply add this line in your `Podfile`:

```ruby
pod 'AlloyTest', '~> 0.0.4'
```

Then, run the following command:

```sh
pod install
```

**Note**: The `Alloy` pod was already taken.
Until we decide a better name `AlloyTest` is used as a placeholder.

## Usage

### Launching Alloy

```swift
import Alloy
import UIKit

class ViewController: UIViewController {
    // ...

    override func viewDidAppear

    func openAlloy() {
        var alloy = Alloy(
            key: "your-alloy-key",
            for: AlloyEvaluationData(
                nameFirst: "John",
                nameLast: "Doe"
            )
        )

        alloy.open(in: self, completion: onAlloyResult(result:))
    }

    private func onAlloyResult(result: AlloyResult) {
        // Handle the result
    }
}
```

### Handling the result

```switf
private func onAlloyResult(result: AlloyResult) {
    switch result {
    case .success(let response):
        print("outcome: \(response.summary.outcome)")
        print("outcome reasons: \(response.summary.outcomeReasons.joined(separator: ", "))")
    case .failure(let error):
        print("error: \(error.localizedDescription)")
    }
}
```

### Customizing options or passing more data

```swift
func openAlloy() {
    var data = AlloyEvaluationData(nameFirst: "John", nameLast: "Doe")
    data.addressLine1 = "123 Fake Street"
    data.addressLine2 = "1st 2nd"
    data.addressCity = "New York"
    data.addressPostalCode = "12345"
    data.addressCountryCode = "US"
    data.birthDate = "2000/01/01"

    var alloy = Alloy(key: "your-alloy-key", for: data)
    alloy.externalEntityId = "my-external-entity-id"
    alloy.entityToken = "my-entity-token"
    alloy.production = true
    alloy.maxEvaluationAttempts = 3
}
```

[cocoapods]: http://cocoapods.org/
