//
//  ItemDto.swift
//  RealmProject
//
//  Created by 김현구 on 4/9/24.
//

import Foundation

class ItemDto: NSObject {
    
    let key: String
    let number: Int
    
    init(_ item: Item) {
        self.key = item.key
        self.number = item.number
    }
    
    public override var description: String {
        return "number: \(number), key: \(key)"
    }
}
