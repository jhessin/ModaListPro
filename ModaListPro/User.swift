//
//  User.swift
//  ModaListPro
//
//  Created by Jim Hessin on 11/24/16.
//  Copyright © 2016 GrillbrickStudios. All rights reserved.
//

import Foundation

struct User: Storable{



    // MARK: - Keys
    struct Keys {
        static let uid = "key"
        static let name = "name"
        static let photo = "photo"
    }

    // MARK: - Data
    let store: Store

    var uid: String{
        return unwrap(Keys.uid) as? String ?? ""
    }

    var key: String{ return uid } // For Storable support

    var name: String{
        return unwrap(Keys.name) as? String ?? ""
    }

    var photo: URL?{
        if let photoString = unwrap(Keys.photo) as? String{
            return URL(string: photoString)
        }
        return nil
    }

    // MARK: - init
    init(uid: String = "", name: String = "", photo: String? = nil) {
        var data = Store()
        data = [Keys.uid:uid,
                 Keys.name:name]
        if let photo = photo{
            data[Keys.photo] = photo
        }
        store = data
    }

    init(_ user: FireUser){
        var data = Store()
        data = [Keys.uid:user.uid]
        if let name = user.displayName{
            data[Keys.name] = name
        }
        if let photo = user.photoURL?.absoluteString{
            data[Keys.photo] = photo
        }
        store = data
    }

    init(_ snap: Snap) {
        store = snap.value as! Store
    }

    // MARK: - Setters
    func name(_ name: String) -> User{
        return User(uid: uid, name: name, photo: photo?.absoluteString)
    }

    func photo(_ photo: URL?) -> User{
        return User(uid: uid, name: name, photo: photo?.absoluteString)
    }

    func key(_: String) -> User {
        return self
    }
}
