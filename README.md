# LightIoC
> Light IoC container for Swift.

![CI Status](https://github.com/PisinO/LightIoC/workflows/CI/badge.svg)
![Codecov](https://img.shields.io/codecov/c/github/PisinO/LightIoC)
[![Version](https://img.shields.io/cocoapods/v/LightIoC.svg?style=flat)](https://cocoapods.org/pods/LightIoC)
[![License](https://img.shields.io/cocoapods/l/LightIoC.svg?style=flat)](https://cocoapods.org/pods/LightIoC)
[![Platform](https://img.shields.io/cocoapods/p/LightIoC.svg?style=flat)](https://cocoapods.org/pods/LightIoC)
![Swift](https://img.shields.io/badge/swift-%3E%3D5.1-yellow?style=flat)

LightIoC is an easy-to-use Dependency Injection (DI) framework for Swift, implementing automatic dependency injection. It manages object creation and it's life-time, and also injects dependencies to the class. The IoC container creates an object of the specified class and also injects all the dependency objects through properties at run time. This is done so that you don't have to create and manage objects manually.

## Why to use DI

DI guides you to make **SOLID** applications.
- Cover your classes behind protocols so they are easily testable, just change module registration in your Test project with mocked classes.
- Do not hide class dependencies, you can see all dependencies enlisted in class and recognizable with @Dependency syntax.
- You don't have to write singletons with `class.shared.func` syntax anymore, register class as singleton and just call the variable `class.func`, DI will take care of object life-cycle
- DI container validates all dependencies right after start and tells you whether they all can be constructed

See this short yet informative article on [medium.com](https://medium.com/@mari_azevedo/s-o-l-i-d-principles-what-are-they-and-why-projects-should-use-them-50b85e4aa8b6) about solid principles.

## Installation

LightIoC is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'LightIoC'
```

## Development setup

There are tests included covering whole framework as example, clone the repo, and run `pod install`. Then you can run test scheme `LightIoC-Example`.

## Usage

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
        
        IoC.register(module: DatabaseLayerModule())

        // IoC.register(module: BusinessLayerModule())
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

#### Overwrite

You can overwrite already registered service with another instance/factory by calling `IoC.registerAndOverwrite(module:)`. Let's say you are writing tests and you want to change instance of database servis for mock service, so in your test just register another modul conforming to `IoCOverwriteModule` with both register and overwrite functions:

```swift
class MockSingleton: SingletonService {
    let id: String = "mock singleton id"
}

struct MockDatabaseLayerModule: IoCOverwriteModule {
    func register(container: IoCContainer) {
        do {
            try container.overwriteSingleton(SingletonService.self, MockSingleton())
        } catch {
            // Handle error
        }
    }
}

IoC.registerAndOverwrite(module: MockDatabaseLayerModule())
```

#### Thread-safe

All resolves are thread-safe, the access to internal collections is synchronized.

## Requirements

**>=Swift 5.1**

## Author

Ondrej Pisin, ondrej.pisin@gmail.com

## License

LightIoC is available under the MIT license. See the LICENSE file for more info.
