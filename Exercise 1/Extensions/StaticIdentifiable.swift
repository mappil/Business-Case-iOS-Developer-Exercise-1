//
//  StaticIdentifiable.swift
//  Exercise 1
//
//  Created by allegretti massimiliano on 13/04/24.
//

import Foundation

protocol StaticIdentifiable {
    static var identifier: String { get }
}

extension StaticIdentifiable {
    static var identifier: String { .init(describing: Self.self) }
}
