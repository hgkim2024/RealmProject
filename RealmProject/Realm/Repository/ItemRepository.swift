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
    
    let pagingSize = 3
    
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
        for _ in 0 ..< count {
            autoAdd()
        }
    }
    
    func printAll() {
        let list = getAll()
        for item in list {
            Log.tag(.DB).tag(.SELECT).d(item.toDto().description)
        }
    }
    
    func pagingFromStartToEnd(startItemDto: ItemDto) -> [ItemDto]? {
        guard let startItem = getOne(startItemDto.key),
              let firstItem = getFirst() else {
            Log.tag(.DB).tag(.PAGING).e("not found start item")
            return nil
        }
        let items = getAll().sorted(by: { $0.number < $1.number })
        guard var startIdx = items.firstIndex(of: startItem) else {
            Log.tag(.DB).tag(.PAGING).e("not found start item index")
            return nil
        }
        
        if startItem.key != firstItem.key {
            startIdx += 1
        }
        
        let endIdx = startIdx + pagingSize
        var itemDtos: [ItemDto] = []
        
        for item in items[max(0, startIdx) ..< min(endIdx, items.count)] {
            itemDtos.append(item.toDto())
        }
        
        printDtos(itemDtos)
        
        return itemDtos
    }
    
    func pagingFromEndToStart(endItemDto: ItemDto) -> [ItemDto]? {
        guard let endItem = getOne(endItemDto.key),
              let lastItem = getLast() else {
            Log.tag(.DB).tag(.PAGING).e("not found end item")
            return nil
        }
        
        let items = getAll().sorted(by: { $0.number < $1.number })
        guard var endIdx = items.firstIndex(of: endItem) else {
            Log.tag(.DB).tag(.PAGING).e("not found end item index")
            return nil
        }
        
        if endIdx == 0 {
            return []
        }
        
        if endItem.key == lastItem.key {
            endIdx += 1
        }
        
        let startIdx = endIdx - pagingSize
        var itemDtos: [ItemDto] = []
        
        for item in items[max(0, startIdx) ..< min(endIdx, items.count)] {
            itemDtos.append(item.toDto())
        }
        
        itemDtos = itemDtos.sorted(by: { $0.number > $1.number })
        
        printDtos(itemDtos)
        
        return itemDtos
    }
    
    func printDtos(_ itemDtos: [ItemDto]) {
        for index in itemDtos.indices {
            let itemDto = itemDtos[index]
            var print = itemDto.description
            
            if index == 0 {
                print += " ## start"
            } else if index == itemDtos.endIndex - 1 {
                print += " ## end"
            }
            
            Log.tag(.DB).tag(.PAGING).d(print)
        }
    }
}
