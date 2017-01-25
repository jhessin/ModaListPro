//
//  System.swift
//  ModaListPro
//
//  Created by Jim Hessin on 11/24/16.
//  Copyright © 2016 GrillbrickStudios. All rights reserved.
//

import Foundation
import Firebase
import FirebaseDatabaseUI

typealias Ref = FIRDatabaseReference
typealias Snap = FIRDataSnapshot
typealias FireUser = FIRUser

struct System {

    // MARK: - Shortcuts

    static var auth: FIRAuth{
        return FIRAuth.auth()!
    }

    static var currentUser: FIRUser{
        return auth.currentUser!
    }

    static var uid: String{
        return currentUser.uid
    }

    static var root: Ref{
        return FIRDatabase.database().reference()
    }

    // MARK: - Constants

    struct Keys {
        static let groups = "groups"
        static let users = "users"
        static let groupdata = "groupdata"
        static let userdata = "userdata"
        static let items = "items"
        static let lists = "lists"
    }

    // MARK: - Loader Structs

    struct ListLoader {
        subscript(group: Group?) -> FireArray{
            if let group = group{
                return FireArray(root
                    .child(Keys.groupdata)
                    .child(group.key)
                    .child(Keys.lists))
            } else{
                return FireArray(root
                    .child(Keys.userdata)
                    .child(uid)
                    .child(Keys.lists))
            }
        }
    }

    struct ItemLoader {
        subscript(list: List) -> FireArray{
            if let gid = list.group{
                return FireArray(root
                    .child(Keys.groupdata)
                    .child(gid)
                    .child(Keys.items)
                    .queryOrdered(byChild: Item.Keys.list)
                    .queryEqual(toValue: list.key))
            } else{
                return FireArray(root
                    .child(Keys.userdata)
                    .child(uid)
                    .child(Keys.items)
                    .queryOrdered(byChild: Item.Keys.list)
                    .queryEqual(toValue: list.key))
            }
        }
    }

    // MARK: - Loader Data
    static let lists = ListLoader()
    static let items = ItemLoader()
    static let users = FireArray(root.child(Keys.users))

    static let groups = (
        admin: FireArray(root
            .child(Keys.groups)
            .queryOrdered(byChild: "\(Group.Keys.users)/\(uid)")
            .queryEqual(toValue: Group.Keys.admins)),
        user: FireArray(root
            .child(Keys.groups)
            .queryOrdered(byChild: "\(Group.Keys.users)/\(uid)")
            .queryEqual(toValue: Group.Keys.users)))

    // MARK: - DataFinders

    enum ArrayType {
        case Group, List, Item, User
    }

    static func getType(_ array: FireArray) -> ArrayType!{
        switch array.parentKey {
        case Keys.groups:
            return .Group
        case Keys.lists:
            return .List
        case Keys.items:
            return .Item
        case Keys.users:
            return .User
        default:
            return nil
        }
    }

    // MARK: - Data Management - Deleter

    class Delete: NSObject, FUIArrayDelegate{

        // Data
        private (set) var subs = [Delete]()
        private var array: FireArray

        // init
        init(_ list: List){
            array = System.items[list]
            super.init()
            array.delegate = self
        }

        init(_ group: Group){
            array = System.lists[group]
            super.init()
            array.delegate = self
        }

        func array(_ array: FUIArray!, didAdd object: Any!, at index: UInt) {
            let snap = object as! FIRDataSnapshot
            if snap.ref.parent?.key == Keys.items{
                snap.ref.removeValue()
            }else if snap.ref.parent?.key == Keys.lists{
                subs.append(Delete(List(snap)))
                snap.ref.removeValue()
            }
        }
    }

    private static var deleter: Delete!

    static func rm(_ list: List){
        deleter = Delete(list)
    }

    static func rm(_ group: Group){
        deleter = Delete(group)
    }

    static func rmCurrentUser(){
        // Delete private user data
        root.child(Keys.userdata)
            .child(uid)
            .removeValue()

        // Delete groups with only this user as admin
        let groups = System.groups.admin
        for group: Group in groups.array(){
            if group.admins.count == 1 {
                rm(group)
            }
        }
    }

    // MARK: - Data Management - Mover

    class Move: NSObject, FUIArrayDelegate{
        let src: FireArray
        let dest: FireArray

        init(_ src: FireArray, _ dest: List) {
            self.src = src
            self.dest = System.items[dest]
            super.init()
            self.src.delegate = self
        }

        init(_ src: List, _ dest: Group) {
            self.src = items[src]
            self.dest = System.items[src.group(dest.key)]
            super.init()
            self.src.delegate = self
        }

        func array(_ array: FUIArray!, didAdd object: Any!, at index: UInt) {
            if array == src{
                let snap = object as! Snap
                let item = Item(snap)
                dest.append(item: item)
                snap.ref.removeValue()
            }
        }
    }

    private static var mover: Move!

    static func mv(_ list: List, _ group: Group){
        mover = Move(list, group)
    }

    static func cp(_ item: Item, _ list: List){
        let dest = items[list]
        dest.append(item: item)
    }
}
