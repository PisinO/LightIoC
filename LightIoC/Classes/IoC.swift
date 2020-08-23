//
//  IoC.swift
//  IoC
//
//  Created by Ondrej Pisin on 21/08/2020.
//  Copyright © 2020 Ondrej Pisin. All rights reserved.
//

import Foundation

// -------------------------------------------
// MARK: - Public
// -------------------------------------------

public protocol IoCContainer {
    
    /// Registers singleton instance, the same instance is used during container lifetime
    /// - Parameters:
    ///   - interface: Interface covering implementation
    ///   - instance: Singleton instance
    /// - Note: Usually, the container lifetime will match your application lifetime.
    func registerSingleton<T, I: AnyObject>(_ interface: T.Type, _ instance: I) throws
    
    /// Registers lazy singleton factory, instance is not constructed until needed, the same instance is used during container lifetime
    /// - Parameters:
    ///   - interface: Interface covering implementation
    ///   - construct: Factory for object
    /// - Note: Usually, the container lifetime will match your application lifetime.
    func registerLazySingleton<T, I: AnyObject>(_ interface: T.Type, _ construct: @escaping () -> I) throws
    
    /// Registers transient type factory, new service created every time it is resolved or injected
    /// - Parameters:
    ///   - interface: Interface covering implementation
    ///   - construct: Factory for object
    func registerType<T, I: AnyObject>(_ interface: T.Type, _ construct: @escaping () -> I) throws
}

public protocol IoCOverwriteContainer: IoCContainer {
    
    /// Overwrites singleton instance, the same instance is used during container lifetime
    /// - Parameters:
    ///   - interface: Interface covering implementation
    ///   - instance: Singleton instance
    /// - Note: Usually, the container lifetime will match your application lifetime.
    func overwriteSingleton<T, I: AnyObject>(_ interface: T.Type, with instance: I) throws
    
    /// Overwrites lazy singleton factory, instance is not constructed until needed, the same instance is used during container lifetime
    /// - Parameters:
    ///   - interface: Interface covering implementation
    ///   - construct: Factory for object
    /// - Note: Usually, the container lifetime will match your application lifetime.
    func overwriteLazySingleton<T, I: AnyObject>(_ interface: T.Type, with construct: @escaping () -> I) throws
    
    /// Overwrites transient type factory, new service created every time it is resolved or injected
    /// - Parameters:
    ///   - interface: Interface covering implementation
    ///   - construct: Factory for object
    func overwriteType<T, I: AnyObject>(_ interface: T.Type, with construct: @escaping () -> I) throws
}

public protocol IoCModule {
    
    /// Register all objects for specified module
    /// - Parameter container: Container instance for registrations
    func register(container: IoCContainer)
}

public protocol IoCOverwriteModule {
    
    /// Register all objects for specified module
    /// - Parameter container: Container instance for registrations
    func register(container: IoCOverwriteContainer)
}

public class IoC {
    /// Register module
    /// - Parameter module: Module with registrations
    public static func register(_ module: IoCModule) {
        module.register(container: IoCInternal.container)
    }
    
    public static func registerAndOvewrite(_ module: IoCOverwriteModule) {
        module.register(container: IoCInternal.container)
    }
}

// -------------------------------------------
// MARK: - Internal
// -------------------------------------------

final class IoCInternal {
    fileprivate static let container = IoCInternal()
    
    private init() {}
    
    private var singletons: [ObjectIdentifier: AnyObject] = [:]
    private var lazySingletons: [ObjectIdentifier: () -> AnyObject] = [:]
    private var typeConstructs: [ObjectIdentifier: () -> AnyObject] = [:]
    fileprivate var allKeys: [ObjectIdentifier] {
        var keys = [ObjectIdentifier]()
        
        keys.append(contentsOf: singletons.keys)
        keys.append(contentsOf: lazySingletons.keys)
        keys.append(contentsOf: typeConstructs.keys)
        
        return keys
    }
    
    private func registerSingleton<T, I: AnyObject>(_ interface: T.Type, _ instance: I, overwrite: Bool) throws {
        guard instance.self is T else {
            throw IoCError.doesntConform(I.self, T.self)
        }
        
        let id = ObjectIdentifier(interface)
        
        if !overwrite && singletons[id] != nil {
            throw IoCError.alreadyRegistered(T.self)
        } else if overwrite && singletons[id] == nil {
            throw IoCError.notRegistered(T.self)
        }
        
        singletons[id] = instance
    }
    
    private func registerLazySingleton<T, I: AnyObject>(_ interface: T.Type, _ construct: @escaping () -> I, overwrite: Bool) throws {
        guard I.self is T.Type else {
            throw IoCError.doesntConform(I.self, T.self)
        }
        
        let id = ObjectIdentifier(interface)
        
        if !overwrite && lazySingletons[id] != nil {
            throw IoCError.alreadyRegistered(T.self)
        } else if overwrite && lazySingletons[id] == nil {
            throw IoCError.notRegistered(T.self)
        }
        
        lazySingletons[id] = construct
    }
    
    private func registerType<T, I: AnyObject>(_ interface: T.Type, _ construct: @escaping () -> I, overwrite: Bool) throws {
        guard I.self is T.Type else {
            throw IoCError.doesntConform(I.self, T.self)
        }
        
        let id = ObjectIdentifier(interface)
        
        if !overwrite && typeConstructs[id] != nil {
            throw IoCError.alreadyRegistered(T.self)
        } else if overwrite && typeConstructs[id] == nil {
            throw IoCError.notRegistered(T.self)
        }
        
        typeConstructs[id] = construct
    }
}

// MARK: - Register

extension IoCInternal: IoCContainer {
    func registerSingleton<T, I: AnyObject>(_ interface: T.Type, _ instance: I) throws {
        try self.registerSingleton(interface, instance, overwrite: false)
    }
    
    func registerLazySingleton<T, I: AnyObject>(_ interface: T.Type, _ construct: @escaping () -> I) throws {
        try self.registerLazySingleton(interface, construct, overwrite: false)
    }
    
    func registerType<T, I: AnyObject>(_ interface: T.Type, _ construct: @escaping () -> I) throws {
        try self.registerType(interface, construct, overwrite: false)
    }
}

// MARK: - Overwrite

extension IoCInternal: IoCOverwriteContainer {
    func overwriteSingleton<T, I>(_ interface: T.Type, with instance: I) throws where I : AnyObject {
        try self.registerSingleton(interface, instance, overwrite: true)
    }
    
    func overwriteLazySingleton<T, I>(_ interface: T.Type, with construct: @escaping () -> I) throws where I : AnyObject {
        try self.registerLazySingleton(interface, construct, overwrite: true)
    }
    
    func overwriteType<T, I>(_ interface: T.Type, with construct: @escaping () -> I) throws where I : AnyObject {
        try self.registerType(interface, construct, overwrite: true)
    }
}

// MARK: - Resolve

extension IoCInternal {
    
    func resolve<T>(_ wrapper: Dependency<T>) throws -> T {
        // Ignore optionals
        if !wrapper.isOptional && !IoCInternal.container.validate(type: ObjectIdentifier(T.self)) {
            throw IoCError.notRegistered(T.self)
        }
        
        return try resolve(T.self)
    }
    
    func resolve<T>(_ interface: T.Type) throws -> T {
        let id = ObjectIdentifier(interface)

        if let typeConstruct = typeConstructs[id] {
            return typeConstruct() as! T
        }
        
        if let lazyValue = lazySingletons.removeValue(forKey: id) {
            singletons[id] = lazyValue()
        }
        
        if let singleton = singletons[id] {
            return singleton as! T
        }

        // Can't happen with internal resolve
        throw IoCError.notRegistered(T.self)
    }
    
    func validate(type: ObjectIdentifier) -> Bool {
        return self.allKeys.contains(type)
    }
    
    func clean() {
        singletons.removeAll()
        lazySingletons.removeAll()
        typeConstructs.removeAll()
    }
}

// MARK: - Static access

extension IoCInternal {
    
    static var allKeys: [ObjectIdentifier] {
        return IoCInternal.container.allKeys
    }
    
    static func resolve<T>(_ wrapper: Dependency<T>) throws -> T {
        return try IoCInternal.container.resolve(wrapper)
    }
    
    static func resolve<T>(_ interface: T.Type) throws -> T {
        return try IoCInternal.container.resolve(interface)
    }
    
    static func validate(type: ObjectIdentifier) -> Bool {
        return IoCInternal.container.validate(type: type)
    }
    
    static func clean() {
        IoCInternal.container.clean()
    }
}
