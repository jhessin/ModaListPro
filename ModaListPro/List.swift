//
//  List.swift
//  ModaListPro
//
//  Created by Jim Hessin on 11/24/16.
//  Copyright © 2016 GrillbrickStudios. All rights reserved.
//

import Foundation

struct List: Storable{

    // MARK: - Keys
    struct Keys {
        static let key = "key"
        static let name = "name"
        static let group = "group"
    }

    // MARK: - Data
    let store: Store

    var key: String{
        return unwrap(Keys.key) as? String ?? ""
    }

    var name: String{
        return unwrap(Keys.name) as? String ?? ""
    }

    var group: String?{
        return unwrap(Keys.group) as? String
    }

    // MARK: - init
    init(name: String = "", key: String = "", group: String? = nil) {
        var data = Store()
        data = [Keys.key : key,
                 Keys.name : name]
        if let group = group{
            data[Keys.group] = group
        }
        store = data
    }

    init(_ snap: Snap){
        store = snap.value as! Store
    }

    // MARK: - Setters
    func key(_ key: String) -> List{
        return List(name: name, key: key, group: group)
    }

    func name(_ name: String) -> List{
        return List(name: name, key: key, group: group)
    }

    func group(_ group: String?) -> List{
        return List(name: name, key: key, group: group)
    }

    // MARK: Store
}
