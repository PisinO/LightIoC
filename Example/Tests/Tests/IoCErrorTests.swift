//
//  IoCErrorTests.swift
//  IoCTests
//
//  Created by Ondrej Pisin on 21/08/2020.
//  Copyright © 2020 Ondrej Pisin. All rights reserved.
//

import XCTest
@testable import LightIoC

class IoCErrorTests: XCTestCase {
    @Dependency private var singleton: SingletonService
    @Dependency private var lazySingleton: LazySingleton
    
    override func tearDownWithError() throws {
        IoCInternal.clean()
    }
    
    
    func testSingletonWithWrongInterfaceDoesntRegister() {
        IoC.register(module: WrongSingletonTypeTestModule())

        expectFatalError(expectedMessage: "IoC fatal error: \(IoCError.doesntConform(Singleton.self, LazySingleton.self).localizedDescription)") {
            let _ = self.lazySingleton
        }
    }

    func testLazySingletonWithWrongInterfaceDoesntRegister() {
        IoC.register(module: WrongLazySingletonTypeTestModule())
        
        expectFatalError(expectedMessage: "IoC fatal error: \(IoCError.doesntConform(LazySingleton.self, SingletonService.self).localizedDescription)") {
            let _ = self.singleton
        }
    }
    
    
    func testTypeWithWrongInterfaceDoesntRegister() {
        IoC.register(module: WrongTypeTestModule())
        
        expectFatalError(expectedMessage: "IoC fatal error: \(IoCError.doesntConform(Type.self, LazySingleton.self).localizedDescription)") {
            let _ = self.lazySingleton
        }
    }
    
    func testRegisterSameSingletonFails() {
        IoC.register(module: TwoSameSingletonsTestModule())
    }
    
    func testRegisterSameLazySingletonFails() {
        IoC.register(module: TwoSameLazySingletonsTestModule())
    }
    
    func testRegisterSameTypeFails() {
        IoC.register(module: TwoSameTypesTestModule())
    }
    
    func testErrorDescription() {
        XCTAssertEqual(IoCError.doesntConform(Singleton.self, SingletonService.self).localizedDescription, "Type <\(Singleton.self)> doesn't conform to interface <\(SingletonService.self)>.")
        XCTAssertEqual(IoCError.notRegistered(SingletonService.self).localizedDescription, "Type <\(SingletonService.self)> is not registered.")
        XCTAssertEqual(IoCError.alreadyRegistered(SingletonService.self).localizedDescription, "Type <\(SingletonService.self)> is already registered.")
    }
}
