//
//  TestModule.swift
//  IoCTests
//
//  Created by Ondrej Pisin on 21/08/2020.
//  Copyright © 2020 Ondrej Pisin. All rights reserved.
//

import Foundation
import XCTest
@testable import LightIoC

protocol SingletonService {
    var id: String { get }
}

protocol LazySingletonService {
    var id: String { get }
}

protocol TypeService {
    var id: String { get }
}

class Singleton: SingletonService {
    let id: String = UUID().uuidString
}

class LazySingleton: LazySingletonService {
    
    @Dependency var singleton: SingletonService?
    
    let id: String = UUID().uuidString
}

class Type: TypeService {
    
    @Dependency var singleton: SingletonService
    @Dependency var lazySingleton: LazySingletonService
    
    let id: String = UUID().uuidString
}

protocol NotReferencedService { }
class NotReferenced: NotReferencedService { }


struct ReferenceTestModule: IoCModule {
    func register(container: IoCContainer) {
        do {
            try container.registerSingleton(SingletonService.self, Singleton())
            try container.registerLazySingleton(LazySingletonService.self, { return LazySingleton() })
            try container.registerType(TypeService.self, { return Type() })
        } catch let error {
            XCTFail(error.localizedDescription)
        }
    }
}

struct WrongSingletonTypeTestModule: IoCModule {
    func register(container: IoCContainer) {
        do {
            try container.registerSingleton(LazySingleton.self, Singleton())
        } catch {
            print(error.localizedDescription)
            
            guard case IoCError.doesntConform(_, _) = error else {
                return XCTFail()
            }
            
            return
        }
        
        XCTFail()
    }
}

struct WrongLazySingletonTypeTestModule: IoCModule {
    func register(container: IoCContainer) {
        do {
            try container.registerLazySingleton(SingletonService.self, { return LazySingleton() })
        } catch {
            print(error.localizedDescription)
            
            guard case IoCError.doesntConform(_, _) = error else {
                return XCTFail()
            }
            
            return
        }
        
        XCTFail()
    }
}

struct WrongTypeTestModule: IoCModule {
    func register(container: IoCContainer) {
        do {
            try container.registerType(LazySingleton.self, { return Type() })
        } catch let error as IoCError {
            print(error.localizedDescription)
            
            guard case IoCError.doesntConform(_, _) = error else {
                return XCTFail()
            }
            
            return
        } catch {
            XCTFail()
        }
        
        XCTFail()
    }
}

struct TwoSameSingletonsTestModule: IoCModule {
    func register(container: IoCContainer) {
        do {
            try container.registerSingleton(SingletonService.self, Singleton())
            try container.registerSingleton(SingletonService.self, Singleton())
        } catch let error as IoCError {
            print(error.localizedDescription)
            
            guard case IoCError.alreadyRegistered(_) = error else {
                return XCTFail()
            }
            
            return
        } catch {
            XCTFail()
        }
        
        XCTFail()
    }
}

struct TwoSameLazySingletonsTestModule: IoCModule {
    func register(container: IoCContainer) {
        do {
            try container.registerLazySingleton(LazySingletonService.self, { return LazySingleton() })
            try container.registerLazySingleton(LazySingletonService.self, { return LazySingleton() })
        } catch let error as IoCError {
            print(error.localizedDescription)
            
            guard case IoCError.alreadyRegistered(_) = error else {
                return XCTFail()
            }
            
            return
        } catch {
            XCTFail()
        }
        
        XCTFail()
    }
}

struct TwoSameTypesTestModule: IoCModule {
    func register(container: IoCContainer) {
        do {
            try container.registerType(TypeService.self, { return Type() })
            try container.registerType(TypeService.self, { return Type() })
        } catch let error as IoCError {
            print(error.localizedDescription)
            
            guard case IoCError.alreadyRegistered(_) = error else {
                return XCTFail()
            }
            
            return
        } catch {
            XCTFail()
        }
        
        XCTFail()
    }
}

// MARK: - Overwrite

class MockSingleton: SingletonService {
    var id: String {
        return "\(MockSingleton.self)"
    }
}

class MockLazySingleton: LazySingletonService {
    var id: String {
        return "\(MockLazySingleton.self)"
    }
}

class MockType: TypeService {
    var id: String {
        return "\(MockType.self)"
    }
}

struct SingletonOverwriteModule: IoCOverwriteModule {
    func register(container: IoCOverwriteContainer) {
        do {
            try container.overwriteSingleton(SingletonService.self, with: MockSingleton())
        } catch {
            XCTFail()
        }
    }
}

struct LazySingletonOverwriteModule: IoCOverwriteModule {
    func register(container: IoCOverwriteContainer) {
        do {
            try container.overwriteLazySingleton(LazySingletonService.self, with: { return MockLazySingleton() })
        } catch {
            XCTFail()
        }
    }
}

struct TypeOverwriteModule: IoCOverwriteModule {
    func register(container: IoCOverwriteContainer) {
        do {
            try container.overwriteType(TypeService.self, with: { return MockType() })
        } catch {
            XCTFail()
        }
    }
}

struct NotRegisteredSingletonOverwriteModule: IoCOverwriteModule {
    func register(container: IoCOverwriteContainer) {
        do {
            try container.overwriteSingleton(NotReferencedService.self, with: NotReferenced())
        } catch let error as IoCError {
            print(error.localizedDescription)
            
            guard case IoCError.notRegistered(_) = error else {
                return XCTFail()
            }
            
            return
        } catch {
            XCTFail()
        }
        
        XCTFail()
    }
}

struct NotRegisteredLazySingletonOverwriteModule: IoCOverwriteModule {
    func register(container: IoCOverwriteContainer) {
        do {
            try container.overwriteLazySingleton(NotReferencedService.self, with: { return NotReferenced() })
        } catch let error as IoCError {
            print(error.localizedDescription)
            
            guard case IoCError.notRegistered(_) = error else {
                return XCTFail()
            }
            
            return
        } catch {
            XCTFail()
        }
        
        XCTFail()
    }
}

struct NotRegisteredTypeOverwriteModule: IoCOverwriteModule {
    func register(container: IoCOverwriteContainer) {
        do {
            try container.overwriteType(NotReferencedService.self, with: { return NotReferenced() })
        } catch let error as IoCError {
            print(error.localizedDescription)
            
            guard case IoCError.notRegistered(_) = error else {
                return XCTFail()
            }
            
            return
        } catch {
            XCTFail()
        }
        
        XCTFail()
    }
}
