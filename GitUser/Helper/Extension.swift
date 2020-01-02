//
//  Extension.swift
//  GitUser
//
//  Created by Antoni on 02/01/20.
//  Copyright © 2020 aiwiguna. All rights reserved.
//

import Foundation
extension Array where Element: Equatable {
    func isExist(where predicate: (Element) -> Bool) -> Bool  {
        let map = self.compactMap { predicate($0) ? $0 : nil }
        if map.count > 0{
            return true
        }else{
            return false
        }
    }
    
    func all(where predicate: (Element) -> Bool) -> [Element]  {
        return self.compactMap { predicate($0) ? $0 : nil }
    }
}
