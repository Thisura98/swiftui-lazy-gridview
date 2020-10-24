# SwiftUILazyGridView

[![CI Status](https://img.shields.io/travis/thisura1998@gmail.com/SwiftUILazyGridView.svg?style=flat)](https://travis-ci.org/thisura1998@gmail.com/SwiftUILazyGridView)
[![Version](https://img.shields.io/cocoapods/v/SwiftUILazyGridView.svg?style=flat)](https://cocoapods.org/pods/SwiftUILazyGridView)
[![License](https://img.shields.io/cocoapods/l/SwiftUILazyGridView.svg?style=flat)](https://cocoapods.org/pods/SwiftUILazyGridView)
[![Platform](https://img.shields.io/cocoapods/p/SwiftUILazyGridView.svg?style=flat)](https://cocoapods.org/pods/SwiftUILazyGridView)

Create a Grid View that allows items to be processed lazily before being displayed. This pod does not use `LazyVGrid` or `LazyHGrid`.

##### Advantages #####

✅ Data source is maintained by the Grid View's `ViewModel`, so yo don't have to fiddle with SwiftUI States
✅ Compatible with different orientations
✅ Variables column and item spacing
✅ Supports all iOS versions that are compatible with SwiftUI

##### Unsupported Features #####

⏳ Lazy loading of items (only processing is supported) like SwiftUI's `LazyVGrid`
⏳ Fixed item size with variable columns

## Example

#### 1. A grid that has a source data type of `Int`, but needs to pre-process it before displaying.

```swift

struct ContentView: View{

    var viewModel = LazyGridViewModel<Int, String>(UIScreen.main.bounds.width - 10.0, spacing: 0.0)

    init(){
        setupData()
    }

    private func setupData(){
        for i in 0..<100{
            viewModel.addItem(i)
        }
    }

    var body: some View{
        LazyGridView<Int, String>(viewModel) { (input, callback) in

            // Processing closure
            let processedString = String(format: "Number %d", input)
            callback(processedString)

        } _: { (processed) -> AnyView in

            // View Builder closure
            return AnyView(
                Text(processed)
            )

        } _: { (clickedItem) in
            guard let index = viewModel.getAllItems().firstIndex (where: { $0?.id == clickedItem?.id }) else { return }
            print("You clicked the item at index, \(index)")
            self.addRandomItem()
        }

    }

}

```

#### 2. A grid that has a custom data source type, but needs to pre-process it before displaying.

```swift

struct CustomObject{
    var id: Int
    var name: String
}

struct ContentView: View{

    var viewModel = LazyGridViewModel<CustomObject, String>(UIScreen.main.bounds.width - 10.0, spacing: 0.0)

    init(){
        setupData()
    }

    private func setupData(){
        for i in 0..<100{
            let c = CustomObject(id: i, name: "Random Name")
            viewModel.addItem(c)
        }
    }

    var body: some View{
        LazyGridView<Int, String>(viewModel) { (input, callback) in

            // Processing closure
            DispatchQueue.global().async {
                // Simulate long running task
                let randomDelay = arc4random_uniform(10000000)
                usleep(randomDelay)

                // Processing complete!
                callback(input.name)
            }

        } _: { (processed) -> AnyView in

            // View Builder closure
            return AnyView(
                Text(processed)
            )

        } _: { (clickedItem) in
            guard let index = viewModel.getAllItems().firstIndex (where: { $0?.id == clickedItem?.id }) else { return }
            print("You clicked the item at index, \(index)")
            self.addRandomItem()
        }

    }

}

```

## Requirements

- iOS 13.0+
- Xcode 11

## Installation

SwiftUILazyGridView is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'SwiftUILazyGridView'
```

## Author

thisura1998@gmail.com

## License

SwiftUILazyGridView is available under the MIT license. See the LICENSE file for more info.