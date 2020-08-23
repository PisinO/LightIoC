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
        IoC.register(WrongSingletonTypeTestModule())
    }
    
    func testLazySingletonWithWrongInterfaceDoesntRegister() {
        IoC.register(WrongLazySingletonTypeTestModule())
    }
    
    func testTypeWithWrongInterfaceDoesntRegister() {
        IoC.register(WrongTypeTestModule())
    }
    
    func testRegisterSameSingletonFails() {
        IoC.register(TwoSameSingletonsTestModule())
    }
    
    func testRegisterSameLazySingletonFails() {
        IoC.register(TwoSameLazySingletonsTestModule())
    }
    
    func testRegisterSameTypeFails() {
        IoC.register(TwoSameTypesTestModule())
    }
    
    func testErrorDescription() {
        XCTAssertEqual(IoCError.doesntConform(Singleton.self, SingletonService.self).localizedDescription, "Type <\(Singleton.self)> doesn't conform to interface <\(SingletonService.self)>.")
        XCTAssertEqual(IoCError.notRegistered(SingletonService.self).localizedDescription, "Type <\(SingletonService.self)> is not registered.")
        XCTAssertEqual(IoCError.alreadyRegistered(SingletonService.self).localizedDescription, "Type <\(SingletonService.self)> is already registered.")
    }
}
