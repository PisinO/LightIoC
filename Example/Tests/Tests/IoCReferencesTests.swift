//
//  IoCTests.swift
//  IoCTests
//
//  Created by Ondrej Pisin on 21/08/2020.
//  Copyright © 2020 Ondrej Pisin. All rights reserved.
//

import XCTest
@testable import LightIoC

class IoCReferencesTests: XCTestCase {
    
    @Dependency private var typeService: TypeService
    @Dependency private var lazySingletonService: LazySingletonService
    @Dependency private var singletonService: SingletonService
    
    @Dependency private var notReferencedService: NotReferencedService
    
    override func setUpWithError() throws {
        IoC.register(module: ReferenceTestModule())
    }
    
    override func tearDownWithError() throws {
        IoCInternal.clean()
    }
    
    func testReferencesForRegisterSingletonAreEaqual() {
        let s1 = (typeService as? Type)?.singleton
        let s2 = (typeService as? Type)?.singleton
        
        XCTAssertNotNil(s1)
        XCTAssertNotNil(s2)
        XCTAssertEqual(s1!.id, s2!.id)
    }
    
    func testReferencesForRegisterLazySingletonAreEaqual() {
        let l1 = (typeService as? Type)?.lazySingleton
        let l2 = (typeService as? Type)?.lazySingleton
        
        XCTAssertNotNil(l1)
        XCTAssertNotNil(l2)
        XCTAssertEqual(l1!.id, l2!.id)
    }
    
    func testReferencesForRegisterByTypeAreNotEaqual() {
        let t1 = typeService as? Type
        let t2 = typeService as? Type
        
        XCTAssertNotNil(t1)
        XCTAssertNotNil(t2)
        XCTAssertNotEqual(t1!.id, t2!.id)
    }
    
    func testLazySingletonNotInitializedEarly() {
        XCTAssertNil(_lazySingletonService.initialized)
        
        XCTAssertNotNil(lazySingletonService)
        XCTAssertTrue(_lazySingletonService.initialized ?? false)
    }
    
    func testCleanDoesCleanAllReferences() {
        IoCInternal.clean()
        XCTAssertTrue(IoCInternal.allKeys.count == 0)
    }
    
    func testValidationsucceedOnAlreadyRegisteredObjects() {
        XCTAssertTrue(IoCInternal.validate(type: ObjectIdentifier(SingletonService.self)))
        XCTAssertTrue(IoCInternal.validate(type: ObjectIdentifier(LazySingletonService.self)))
        XCTAssertTrue(IoCInternal.validate(type: ObjectIdentifier(TypeService.self)))
    }
    
    func testValidationFailsOnNotRegisteredObjects() {
        XCTAssertFalse(IoCInternal.validate(type: ObjectIdentifier(NotReferencedService.self)))
    }
    
    func testNotRegisteredTypeFailsToResolve() {
        do {
            let _ = try IoCInternal.resolve(NotReferencedService.self)
        } catch {
            print(error.localizedDescription)
            
            guard case IoCError.notRegistered(_) = error else {
                return XCTFail()
            }
            
            return
        }
        
        XCTFail()
    }
    
    func testNotRegisteredWrapperFailsToResolve() {
        do {
            let _ = try IoCInternal.resolve(_notReferencedService)
        } catch {
            print(error.localizedDescription)
            
            guard case IoCError.notRegistered(_) = error else {
                return XCTFail()
            }
            
            return
        }
        
        XCTFail()
    }
    
    func testNotRegisteredWrapperInnerValueFailsToResolve() {
        expectFatalError(expectedMessage: "IoC fatal error: \(IoCError.notRegistered(NotReferencedService.self).localizedDescription)") {
            let _ = self.notReferencedService
        }
    }
    
    func testThreadSafeResolve() {
        let dg = DispatchGroup()
        let exp = expectation(description: "\(#function)\(#line)")
        
        DispatchQueue.concurrentPerform(iterations: 10) { (index) in
            dg.enter()
            DispatchQueue.global().async {
                for _ in 0..<10000 {
                    do {
                        let _ = try IoCInternal.resolve(SingletonService.self)
                        let _ = try IoCInternal.resolve(self._singletonService)
                        
                        let _ = try IoCInternal.resolve(LazySingletonService.self)
                        let _ = try IoCInternal.resolve(self._lazySingletonService)
                        
                        let _ = try IoCInternal.resolve(TypeService.self)
                        let _ = try IoCInternal.resolve(self._typeService)
                    } catch {
                        XCTFail(error.localizedDescription)
                    }
                }
                dg.leave()
            }
        }

        dg.notify(queue: DispatchQueue.main) {
            exp.fulfill()
        }
        
        self.waitForExpectations(timeout: 30, handler: nil)
    }
}
