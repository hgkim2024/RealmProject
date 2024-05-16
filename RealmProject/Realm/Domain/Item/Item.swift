//
//  Item.swift
//  RealmProject
//
//  Created by 김현구 on 4/9/24.
//

import Foundation
import RealmSwift

class Item: Object {
    @Persisted(primaryKey: true) var key: String = UUID().uuidString
    @Persisted var number: Int = -1
    
    private override init() {
        super.init()
    }
    
    static func create(number: Int) -> Item {
        let item = Item()
        item.number = number
        return item
    }

    func toModel() -> ItemModel {
        return ItemModel(self)
    }
}
