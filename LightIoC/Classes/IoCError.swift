//
//  IoCError.swift
//  IoC
//
//  Created by Ondrej Pisin on 21/08/2020.
//  Copyright © 2020 Ondrej Pisin. All rights reserved.
//

import Foundation

public enum IoCError: Error {
    case doesntConform(_ class: Any.Type, _ interface: Any.Type)
    case notRegistered(_ interface: Any.Type)
    case alreadyRegistered(_ interface: Any.Type)
    
    public var localizedDescription: String {
        switch self {
            case .doesntConform(let type, let interface):
                return NSLocalizedString("Type <\(type)> doesn't conform to interface <\(interface)>.", comment: "")
            case .notRegistered(let interface):
                return NSLocalizedString("Type <\(interface)> is not registered.", comment: "")
            case .alreadyRegistered(let interface):
                return NSLocalizedString("Type <\(interface)> is already registered.", comment: "")
        }
    }
}
