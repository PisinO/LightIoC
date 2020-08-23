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
    
    override func tearDownWithError() throws {
        IoCInternal.clean()
    }
    
    func testSingletonWithWrongInterfaceDoesntRegister() {
        IoC.register(module: WrongSingletonTypeTestModule())
    }
    
    func testLazySingletonWithWrongInterfaceDoesntRegister() {
        IoC.register(module: WrongLazySingletonTypeTestModule())
    }
    
    func testTypeWithWrongInterfaceDoesntRegister() {
        IoC.register(module: WrongTypeTestModule())
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
