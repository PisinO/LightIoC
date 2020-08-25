//
//  Util.swift
//  IoC
//
//  Created by Ondrej Pisin on 21/08/2020.
//  Copyright © 2020 Ondrej Pisin. All rights reserved.
//

import Foundation

/// Synchronized feature from Obj-C
/// - Parameters:
///   - lock: Locking object, should be one per class
///   - block: Synchronized block that throws
/// - Returns: The result of specified block
@discardableResult internal func synchronized<T>(_ lock: NSRecursiveLock, block:() throws -> T) throws -> T {
    objc_sync_enter(lock)
    defer { objc_sync_exit(lock) }

    return try block()
}

internal final class Util {
    static func isOptional<T>(_ type: T.Type) -> Bool {
        return String(describing: type).starts(with:"Optional")
    }
}
