//
//  IoCOverwriteTests.swift
//  LightIoC_Tests
//
//  Created by Ondřej Pišín on 23/08/2020.
//  Copyright © 2020 CocoaPods. All rights reserved.
//

import XCTest
@testable import LightIoC

class IoCOverwriteTests: XCTestCase {
    
    @Dependency private var typeService: TypeService
    @Dependency private var lazySingletonService: LazySingletonService
    @Dependency private var singletonService: SingletonService
    
    override func setUpWithError() throws {
        IoC.register(module: ReferenceTestModule())
    }
    
    override func tearDownWithError() throws {
        IoCInternal.clean()
    }
    
    func testTestClassOverwritesSingleton() {
        IoC.registerAndOverwrite(module: SingletonOverwriteModule())
        
        XCTAssertEqual(singletonService.id, "\(MockSingleton.self)")
    }
    
    func testTestClassOverwritesLazySingleton() {
        IoC.registerAndOverwrite(module: LazySingletonOverwriteModule())
        
        XCTAssertEqual(lazySingletonService.id, "\(MockLazySingleton.self)")
    }
    
    func testTestClassOverwritesType() {
        IoC.registerAndOverwrite(module: TypeOverwriteModule())
        
        XCTAssertEqual(typeService.id, "\(MockType.self)")
    }
    
    func testOverwriteOfNotRegisteredSingletonFails() {
        IoC.registerAndOverwrite(module: NotRegisteredSingletonOverwriteModule())
    }
    
    func testOverwriteOfNotRegisteredLazySingletonFails() {
        IoC.registerAndOverwrite(module: NotRegisteredLazySingletonOverwriteModule())
    }
    
    func testOverwriteOfNotRegisteredTypeFails() {
        IoC.registerAndOverwrite(module: NotRegisteredTypeOverwriteModule())
    }
}
