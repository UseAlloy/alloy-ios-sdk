# Alloy iOS SDK

## Example project

If you open this project with Xcode you can run and test the `AlloyExample` sample app.
You can view the source code in the folder with the same name.

## Installation

Currently the only package manager we support is [CocoaPods][cocoapods].

To integrate Alloy into your XCode project, simply add this line in your `Podfile`:

```ruby
pod 'AlloyTest'
```

Then, run the following command:

```sh
pod install
```

**Note**: The `Alloy` pod was already taken.
Until we decide a better name `AlloyTest` is used as a placeholder.

## Usage

```swift
import Alloy
import UIKit

class ViewController: UIViewController {
    // ...

    func openAlloy() {
        var alloy = Alloy(
            key: "your-alloy-key",
            for: AlloyEvaluationData(
                nameFirst: "John",
                nameLast: "Doe"
            )
        )

        alloy.open(in: self) { result in
            print("result", result)
        }
    }
}
```

To add more data or edit options:

```swift
func openAlloy() {
    var data = AlloyEvaluationData(nameFirst: "John", nameLast: "Doe")
    data.addressLine1 = "123 Fake Street"

    var alloy = Alloy(key: "your-alloy-key", for: data)
    alloy.maxEvaluationAttempts = 5
    alloy.production = true

    alloy.open(in: self, completion: onAlloyResult(result:))
}

private func onAlloyResult(result: AlloyResult) {
    print("result", result)
}
```

[cocoapods]: http://cocoapods.org/
