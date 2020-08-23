# LightIoC
> Light IoC Container for Swift.

![CI Status](https://github.com/PisinO/LightIoC/workflows/CI/badge.svg)
![Codecov](https://img.shields.io/codecov/c/github/PisinO/LightIoC)
[![Version](https://img.shields.io/cocoapods/v/LightIoC.svg?style=flat)](https://cocoapods.org/pods/LightIoC)
[![License](https://img.shields.io/cocoapods/l/LightIoC.svg?style=flat)](https://cocoapods.org/pods/LightIoC)
[![Platform](https://img.shields.io/cocoapods/p/LightIoC.svg?style=flat)](https://cocoapods.org/pods/LightIoC)
![Swift](https://img.shields.io/badge/swift-%3E%3D5.1-yellow?style=flat)

LightIoC is an easy-to-use Dependency Injection (DI) framework for Swift, implementing automatic dependency injection. It manages object creation and it's life-time, and also injects dependencies to the class. The IoC container creates an object of the specified class and also injects all the dependency objects through properties at run time. This is done so that you don't have to create and manage objects manually.

## Installation

LightIoC is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'LightIoC'
```

## Development setup

There are tests included covering whole framework as example, clone the repo, and run `pod install`. Then you can run test scheme `LightIoC-Example`.

## Usage example

#### 1) Define you service, protocol and module
```swift
// Your protocol
protocol SingletonService {
    var id: String { get }
}

// Your class to be injected
class Singleton: SingletonService {
    let id: String = "singleton id"
}

// All registrations are in modules so you can separate layer/framework specific services
struct DatabaseLayerModule: IoCModule {
    func register(container: IoCContainer) {
        do {
            try container.registerSingleton(SingletonService.self, Singleton())
        } catch {
            // Handle error
        }
    }
}
```

#### 2) Register modules in app project on startup, for example in AppDelegate, but anywhere else before first dependency is requested
```swift
class AppDelegate: UIResponder, UIApplicationDelegate {
        func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        IoC.registerModule(DatabaseLayerModule())

        // IoC.registerModule(BusinessLayerModule())
        // etc...

        return true
    }
}
```

#### 3) Now you can inject and access you service
```swift
class ViewController: UIViewController {

    @Dependency var singleton: SingletonService

    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(singleton.id)
        // result: "singleton id"
    }
}
```

## Requirements

**>=Swift 5.1**

## Author

Ondrej Pisin, ondrej.pisin@gmail.com

## License

LightIoC is available under the MIT license. See the LICENSE file for more info.
