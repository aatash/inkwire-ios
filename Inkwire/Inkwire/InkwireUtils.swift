//
//  InkwireUtils.swift
//  Inkwire
//
//  Created by Virindh Borra on 11/11/16.
//  Copyright © 2017 Aatash Parikh. All rights reserved.
//

import Foundation

extension Array where Element: Equatable {
    mutating func remove(object: Element) { 
        if let index = index(of: object) {
            remove(at: index)
        }
    }
}
