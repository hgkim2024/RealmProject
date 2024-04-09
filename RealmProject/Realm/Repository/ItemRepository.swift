//
//  ItemRepository.swift
//  RealmProject
//
//  Created by 김현구 on 4/9/24.
//

import Foundation
import RealmSwift

class ItemRepository: RealmRepository<Item, String> {
    static let shared = ItemRepository()
    private override init() {
        super.init()
    }
    
    func autoAdd() {
        var number = 0
        if let last = getAll().last {
            number = last.number
        }
        number += 1
        add(Item.create(number: number))
    }
    
    func autoAdd(_ count: Int) {
        for i in 0 ..< count {
            autoAdd()
        }
    }
    
    func printAll() {
        let list = getAll()
        for item in list {
            Log.tag(.DB).tag(.SELECT).d(item.toDto().description)
        }
    }
}
