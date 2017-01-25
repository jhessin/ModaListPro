//
//  Group.swift
//  ModaListPro
//
//  Created by Jim Hessin on 11/24/16.
//  Copyright © 2016 GrillbrickStudios. All rights reserved.
//

import Foundation
import FirebaseDatabaseUI

struct Group: Storable {


    // MARK: - Keys
    struct Keys {
        static let key = "key"
        static let name = "name"
        static let admins = "admins"
        static let users = "users"
    }

    // MARK: - Data
    let store: Store

    var key: String{
        return unwrap(Keys.key) as? String ?? ""
    }

    var name: String{
        return unwrap(Keys.name) as? String ?? ""
    }

    var admins: Set<String>{
        let users = unwrap(Keys.users) as? [String:String] ?? [String:String]()
        var result = Set<String>()
        users.forEach {
            (key, value) in
            if value == Keys.admins{
                result.insert(key)
            }
        }
        return result
    }

    var users: Set<String>{

        let users = unwrap(Keys.users) as? [String:String] ?? [String:String]()
        var result = Set<String>()
        users.forEach {
            (key, value) in
            if value == Keys.users{
                result.insert(key)
            }
        }
        return result
    }

    var adminList: [User]{
        let allUsers = System.users
        var list = [User]()
        for uid in admins{
            list.append(allUsers.storable(forKey: uid))
        }
        return list
    }

    var userList: [User]{
        let allUsers = System.users
        var list = [User]()
        for uid in users{
            list.append(allUsers.storable(forKey: uid))
        }
        return list
    }

    // MARK: - init
    init(key: String = "", name: String = "", admins: Set<String> = [System.uid], users: Set<String> = []) {
        var allUsers = [String:String]()
        for key in users{
            allUsers[key] = Keys.users
        }
        for key in admins{
            allUsers[key] = Keys.admins
        }
        store = [Keys.key: key,
                 Keys.name: name,
                 Keys.users: allUsers]
    }

    init(_ snap: Snap) {
        store = snap.value as! Store
    }

    // MARK: - Setters
    func key(_ key: String) -> Group{
        return Group(key: key, name: name, admins: admins, users: users)
    }

    func name(_ name: String) -> Group{
        return Group(key: key, name: name, admins: admins, users: users)
    }

    func add(admin user: User) -> Group{
        var admins = self.admins
        var users = self.users

        users.remove(user.uid)
        admins.insert(user.uid)

        return Group(key: key, name: name, admins: admins, users: users)
    }

    func remove(admin user: User) -> Group{
        var admins = self.admins

        admins.remove(user.uid)

        return Group(key: key, name: name, admins: admins, users: users)
    }

    func add(user: User) -> Group{
        var admins = self.admins
        var users = self.users

        users.insert(user.uid)
        admins.remove(user.uid)

        return Group(key: key, name: name, admins: admins, users: users)
    }

    func remove(user: User) -> Group{
        var users = self.users

        users.remove(user.uid)

        return Group(key: key, name: name, admins: admins, users: users)
    }

    static func +=(lhs: inout Group, rhs: User){
        lhs = lhs.add(user: rhs)
    }
    
}
