//
//  ItemDto.swift
//  RealmProject
//
//  Created by 김현구 on 4/9/24.
//

import Foundation

class ItemDto: NSObject {
    
    let key: String
    var number: Int
    
    init(_ item: Item) {
        self.key = item.key
        self.number = item.number
    }
    
    public override var description: String {
        return "number: \(number), key: \(key)"
    }
    
    // : Update 용도
    func toRealm() -> Item {
        let item = Item()
        item.key = key
        item.number = number
        return item
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        guard let object = object as? ItemDto else { return false }
        
        if key == object.key
            && number == object.number {
            return true
        } else {
            return false
        }
    }
}
