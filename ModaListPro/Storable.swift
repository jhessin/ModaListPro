//
//  Storable.swift
//  ModaListPro
//
//  Created by Jim Hessin on 11/24/16.
//  Copyright © 2016 GrillbrickStudios. All rights reserved.
//

import Foundation

typealias Store = [String:Any]

protocol Storable {
    var store: Store {get}
    var name: String {get}
    var key: String {get}
    func key(_:String) -> Self

    init(_ snap: Snap)
}

extension Storable{
    func unwrap(_ key: String) -> Any?{
        if store.keys.contains(key){
            return store[key]
        }
        return nil
    }
}
