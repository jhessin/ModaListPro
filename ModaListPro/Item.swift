//
//  Item.swift
//  ModaListPro
//
//  Created by Jim Hessin on 11/24/16.
//  Copyright © 2016 GrillbrickStudios. All rights reserved.
//

import Foundation

struct Item: Storable {

    // MARK: - Keys
    struct Keys {
        static let key = "key"
        static let name = "name"
        static let checked = "checked"
        static let list = "owner"
        static let group = "group"
    }

    // MARK: - Data
    let store: Store

    var key: String{
        return unwrap(Keys.key) as! String
    }

    var name: String{
        return unwrap(Keys.name) as! String
    }

    var checked: Bool{
        return unwrap(Keys.checked) as! Bool
    }

    var list: String{
        return unwrap(Keys.list) as! String
    }

    var group: String?{
        return unwrap(Keys.group) as? String
    }

    // MARK: - init
    init(name: String = "", key: String = "", checked: Bool = false, list: String = "", group: String? = nil) {
        var data = Store()
        data = [Keys.key : key,
                 Keys.name : name,
                 Keys.checked : checked,
                 Keys.list : list]
        if let group = group{
            data[Keys.group] = group
        }
        store = data
    }

    init(_ snap: Snap){
        store = snap.value as! Store
    }

    // MARK: - Setters
    func key(_ key: String) -> Item{
        return Item(name: name, key: key, checked: checked, list: list, group: group)
    }

    func name(_ name: String) -> Item{
        return Item(name: name, key: key, checked: checked, list: list, group: group)
    }

    func checked(_ checked: Bool) -> Item{
        return Item(name: name, key: key, checked: checked, list: list, group: group)
    }

    func list(_ list: String) -> Item{
        return Item(name: name, key: key, checked: checked, list: list, group: group)
    }

    func list(_ list: List) -> Item{
        return Item(name: name, key: key, checked: checked, list: list.key, group: list.group)
    }

    func group(_ group: String?) -> Item{
        return Item(name: name, key: key, checked: checked, list: list, group: group)
    }
}
