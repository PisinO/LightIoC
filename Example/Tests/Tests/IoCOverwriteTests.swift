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
        IoC.register(ReferenceTestModule())
    }
    
    override func tearDownWithError() throws {
        IoCInternal.clean()
    }
    
    func testTestClassOverwritesSingleton() {
        IoC.registerAndOverwrite(SingletonOverwriteModule())
        
        XCTAssertEqual(singletonService.id, "\(MockSingleton.self)")
    }
    
    func testTestClassOverwritesLazySingleton() {
        IoC.registerAndOverwrite(LazySingletonOverwriteModule())
        
        XCTAssertEqual(lazySingletonService.id, "\(MockLazySingleton.self)")
    }
    
    func testTestClassOverwritesType() {
        IoC.registerAndOverwrite(TypeOverwriteModule())
        
        XCTAssertEqual(typeService.id, "\(MockType.self)")
    }
    
    func testOverwriteOfNotRegisteredSingletonFails() {
        IoC.registerAndOverwrite(NotRegisteredSingletonOverwriteModule())
    }
    
    func testOverwriteOfNotRegisteredLazySingletonFails() {
        IoC.registerAndOverwrite(NotRegisteredLazySingletonOverwriteModule())
    }
    
    func testOverwriteOfNotRegisteredTypeFails() {
        IoC.registerAndOverwrite(NotRegisteredTypeOverwriteModule())
    }
}
