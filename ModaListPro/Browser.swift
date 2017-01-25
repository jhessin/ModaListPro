//
//  Browser.swift
//  ModaListPro
//
//  Created by Jim Hessin on 11/25/16.
//  Copyright © 2016 GrillbrickStudios. All rights reserved.
//

import Foundation

class Browser {

    // Types

    enum Dir: String{
        case Root = "Menu",
        PrivateLists = "Private Lists",
        PrivateItems = "Private Items",
        Groups = "Groups",
        AdminLists = "Lists",
        AdminItems = "Items",
        ReadOnlyLists = "Lists (Read-Only)",
        ReadOnlyItems = "Items (Read-Only)"
    }

    // MARK: Path Data

    var dir: Dir {
        switch isPrivate {
        case nil:
            return .Root
        case .some(true):
            let parentKey = viewStack.peek!.parentKey
            switch parentKey {
            case System.Keys.lists:
                return .PrivateLists
            default:
                return .PrivateItems
            }
        case .some(false):

            switch System.getType(viewStack.peek!)! {
            case .List:
                if readOnlyGroups.keys.contains(viewStack.peek!.indexKey!){
                    return .ReadOnlyLists
                }
                return .AdminLists
            case .Item:
                if readOnlyGroups.keys.contains(viewStack.peek!.indexKey!){
                    return .ReadOnlyItems
                }
                return .AdminItems
            default:
                return .Groups
            }

        }
    }

    var isPrivate: Bool?{
        didSet{
            switch isPrivate {
            case nil:
                viewStack.removeAll()
            case .some(true):
                if viewStack.isEmpty(){
                    viewStack.push(System.lists[nil])
                }
            case .some(false):
                if viewStack.isEmpty(){
                    viewStack.push(System.groups.admin)
                }
            }
        }
    }

    var viewStack = Stack<FireArray>()

    var readOnlyGroups = System.groups.user

    var list: List?

    var group: Group?

    // MARK: Info

    var title: String{
        switch dir {
        case .ReadOnlyLists:
            let key = viewStack.peek!.indexKey!
            let group: Group = readOnlyGroups.storable(forKey: key)
            return group.name + " (Read-Only)"
        case .AdminLists:
            let key = viewStack.peek!.indexKey!
            let group: Group = viewStack.peek(2)!.storable(forKey: key)
            return group.name
        case .ReadOnlyItems, .AdminItems, .PrivateItems:
            let key = viewStack.peek!.indexKey!
            let list: List = viewStack.peek(2)!.storable(forKey: key)
            return list.name + (dir == .ReadOnlyItems ? " (Read-Only)" : "")
        default:
            return dir.rawValue
        }
    }

    func title(forSection section: Int) -> String{
        if dir == .Groups{
            return section == 0 ? "Groups" : "Read-Only Groups"
        }

        return title
    }

    var sections: Int{
        if dir == .Groups{
            return 2
        }else{
            return 1
        }
    }

    func count(forSection section: Int) -> Int{
        switch dir {
        case .Groups:
            return section == 0 ? Int(viewStack.peek!.count) : Int(readOnlyGroups.count)
        case .Root:
            return 2
        default:
            return Int(viewStack.peek!.count)
        }
    }

    var count: Int{
        return count(forSection: 0)
    }

    func name(forIndexPath indexPath: IndexPath) -> String{
        switch dir {
        case .AdminItems, .PrivateItems, .ReadOnlyItems:
            let item: Item = viewStack.peek!.storable(at: indexPath.row)
            return item.name
        case .AdminLists, .PrivateLists, .ReadOnlyLists:
            let list: List = viewStack.peek!.storable(at: indexPath.row)
            return list.name
        case .Groups:
            switch indexPath.section {
            case 0:
                let group: Group = viewStack.peek!.storable(at: indexPath.row)
                return group.name
            default:
                let group: Group = readOnlyGroups.storable(at: indexPath.row)
                return group.name
            }
        case .Root:
            switch indexPath.row {
            case 0:
                return "Private"
            default:
                return "Groups"
            }
        }
    }

    func name(forIndex index: Int) -> String{
        return name(forIndexPath: IndexPath(row: index, section: 0))
    }

    func data(forIndexPath indexPath: IndexPath) -> Storable?{
        switch dir {
        case .Root:
            return nil
        case .Groups:
            if indexPath.section != 0{
                return readOnlyGroups.storable(at: indexPath.row) as Group
            }else{
                return viewStack.peek!.storable(at: indexPath.row) as Group
            }
        case .AdminLists, .PrivateLists, .ReadOnlyLists:
            return viewStack.peek!.storable(at: indexPath.row) as List
        case .AdminItems, .PrivateItems, .ReadOnlyItems:
            return viewStack.peek!.storable(at: indexPath.row) as Item
        }
    }

    func data(forIndex index: Int) -> Storable?{
        return data(forIndexPath: IndexPath(row: index, section: 0))
    }

    // MARK: Navigation

    func select(_ indexPath: IndexPath){
        switch dir {
        case .Root:
            switch indexPath.row {
            case 0:
                isPrivate = true
            default:
                isPrivate = false
            }
        case .Groups:
            switch indexPath.section {
            case 0:
                self.group = viewStack.peek!.storable(at: indexPath.row) as Group
                viewStack.push(System.lists[group])
            default:
                self.group = readOnlyGroups.storable(at: indexPath.row) as Group
                viewStack.push(System.lists[group])
            }
        case .ReadOnlyLists, .PrivateLists, .AdminLists:
            self.list = viewStack.peek!.storable(at: indexPath.row) as List
            viewStack.push(System.items[list!])
        case .PrivateItems, .ReadOnlyItems, .AdminItems:
            return
        }
    }

    func select(_ index: Int){
        select(IndexPath(row: index, section: 0))
    }

    var backTitle: String?{
        switch dir {
        case .Root:
            return nil
        case .Groups, .PrivateLists:
            return Dir.Root.rawValue
        case .AdminLists, .ReadOnlyLists:
            return Dir.Groups.rawValue
        case .AdminItems, .PrivateItems, .ReadOnlyItems:
            let key = viewStack.peek(2)!.indexKey!
            let group: Group = viewStack.peek(3)!.storable(forKey: key)
            return group.name
        }
    }
    
    func back(){
        switch dir {
        case .Root:
            return
        case .Groups:
            isPrivate = nil
        case .AdminLists, .ReadOnlyLists:
            group = nil
            _ = viewStack.pop()
        case .PrivateItems, .AdminItems, .ReadOnlyItems:
            list = nil
            _ = viewStack.pop()
        default:
            _ = viewStack.pop()
        }
    }
}
