//
//  FireArray.swift
//  ModaListPro
//
//  Created by Jim Hessin on 11/24/16.
//  Copyright © 2016 GrillbrickStudios. All rights reserved.
//

import Foundation
import FirebaseDatabaseUI

class FireArray: FUIArray{
    let queryRef: FIRDatabaseQuery

    var ref: Ref{
        return queryRef.ref
    }

    var parentKey: String{
        return ref.key
    }

    var indexKey: String?{
        return queryRef.ref.parent?.key
    }
    
    var keys: [String]{
        var list = [String]()
        for index in 0..<count{
            list.append((self.object(at: index) as! Snap).key)
        }
        return list
    }

    init(_ ref: FIRDatabaseQuery, delegate: FUIArrayDelegate? = nil) {
        self.queryRef = ref
        super.init(query: ref, delegate: delegate)
    }

    subscript(key: String) -> Snap{
        return self.object(at: self.index(forKey: key)) as! Snap
    }

    func storable<T:Storable>(at index: Int) -> T{
        return T(self.object(at: UInt(index)) as! Snap)
    }

    func storable<T:Storable>(forKey key: String) -> T{
        return T(self[key])
    }

    func update<T:Storable>(at index: Int, with object: T){
        ref(for: UInt(index)).setValue(object.store)
    }

    func array<T:Storable>() -> [T]{
        var list = [T]()
        for index in 0..<count{
            list.append(T(self.object(at: index) as! Snap))
        }
        return list
    }

    func append<T:Storable>(item: T){
        let key = queryRef.ref.childByAutoId().key

        let item = item.key(key)
        queryRef.ref.child(key).setValue(item.store)
    }
}

extension UITableViewController: FUIArrayDelegate{

    func indexPath(_ array: FUIArray, index: Int) -> IndexPath{
        return IndexPath(row: index, section: 0)
    }

    public func array(_ array: FUIArray!, didAdd object: Any!, at index: UInt) {
        tableView.insertRows(at: [indexPath(array, index: Int(index))], with: .automatic)
    }

    public func array(_ array: FUIArray!, didChange object: Any!, at index: UInt) {
        tableView.reloadRows(at: [indexPath(array, index: Int(index))], with: .automatic)
    }

    public func array(_ array: FUIArray!, didRemove object: Any!, at index: UInt) {
        tableView.deleteRows(at: [indexPath(array, index: Int(index))], with: .fade)
    }

    public func array(_ array: FUIArray!, didMove object: Any!, from fromIndex: UInt, to toIndex: UInt) {
        tableView.moveRow(at: indexPath(array, index: Int(fromIndex)), to: indexPath(array, index: Int(toIndex)))
    }
}
