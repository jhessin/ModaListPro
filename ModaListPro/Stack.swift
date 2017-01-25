//
//  Stack.swift
//  ModaListPro
//
//  Created by Jim Hessin on 11/26/16.
//  Copyright © 2016 GrillbrickStudios. All rights reserved.
//

import Foundation

struct Stack<Element>{

    private var items = [Element]()

    mutating func push(_ item: Element){
        items.append(item)
    }

    mutating func pop() -> Element {
        return items.removeLast()
    }

    mutating func removeAll(){
        items.removeAll()
    }

    func isEmpty() -> Bool{
        return items.isEmpty
    }

    var peek: Element? {
        return items.last
    }

    func peek(_ count: Int) -> Element?{
        if count > items.count{
            return nil
        }

        return items[items.count - count]
    }

    var count: Int{
        return items.count
    }
}
