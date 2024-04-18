//
//  ItemRepository.swift
//  RealmProject
//
//  Created by 김현구 on 4/9/24.
//

import Foundation
import RealmSwift

// MARK: - Item Object 의 필요한 Query 를 모아둔 클래스
class ItemRepository: RealmRepository<Item, String> {
    static let shared = ItemRepository()
    
    // MARK: - 한 페이지에 데이터 갯수
    let pageSize = 50
    
    private override init() { super.init() }
    
    func autoAdd() {
        var number = 0
        if let last = last {
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
        for item in all {
            Log.tag(.DB).tag(.SELECT).d(item.toDto().description)
        }
    }
    
    func pagingFromStartToEnd(startItemDto: ItemDto) -> [ItemDto]? {
        guard let items = getPage(startObjectKey: startItemDto.key, byKeyPath: "number", ascending: true, pageSize: pageSize) else {
            return nil
        }
        
        let itemDtos = items.map({ $0.toDto()})
        printDtos(itemDtos)
        return itemDtos
    }
    
    func pagingFromEndToStart(endItemDto: ItemDto) -> [ItemDto]? {
        guard let items = getPage(startObjectKey: endItemDto.key, byKeyPath: "number", ascending: false, pageSize: pageSize) else {
            return nil
        }
        
        let itemDtos = items.map({ $0.toDto()})
        printDtos(itemDtos)
        return itemDtos
    }
    
    func pagingCenter(criteriaItem: ItemDto) -> [ItemDto]? {
        // TODO: - 개발
        return nil
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
