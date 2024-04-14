//
//  Extensions+Result.swift
//  Exercise 1
//
//  Created by allegretti massimiliano on 13/04/24.
//

import Foundation

extension Result where Success == Void {
    
    /// A success, storing a Success value.
    ///
    /// Instead of `.success(())`, now  `.success`
    static var success: Result {
        return .success(())
    }
}
