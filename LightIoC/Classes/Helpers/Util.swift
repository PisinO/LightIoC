//
//  Util.swift
//  IoC
//
//  Created by Ondrej Pisin on 21/08/2020.
//  Copyright © 2020 Ondrej Pisin. All rights reserved.
//

import Foundation

internal final class Util {
    static func isOptional<T>(_ type: T.Type) -> Bool {
        return String(describing: type).starts(with:"Optional")
    }
}
