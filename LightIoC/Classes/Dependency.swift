//
//  Dependency.swift
//  IoC
//
//  Created by Ondrej Pisin on 21/08/2020.
//  Copyright © 2020 Ondrej Pisin. All rights reserved.
//

import Foundation

@propertyWrapper
public class Dependency<Value> {

    internal let isOptional: Bool
    
    // Test helper
    internal var initialized: Bool?
    
    /// Inner value
    /// - Warning: When type can't be resolved, error is printed and process killed, there's some programmers mistake. Can't do more here.
    public var wrappedValue: Value {
        do {
            let value = try IoCInternal.resolve(self)
            self.initialized = true
            return value
        } catch {
            let errorDescription = (error as? IoCError)?.localizedDescription ?? "Unknown"
            fatalError("IoC fatal error: \(errorDescription)")
        }
    }

    public init() {
        self.isOptional = Util.isOptional(Value.self)
    }
}
