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
    let countPerPage = 50
    
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
        guard let items = getPage(all: all, startObjectKey: startItemDto.key, byKeyPath: "number", ascending: true, countPerPage: countPerPage) else {
            return nil
        }
        
        let itemDtos = items.map({ $0.toDto()})
        printDtos(itemDtos)
        return itemDtos
    }
    
    func pagingFromEndToStart(endItemDto: ItemDto) -> [ItemDto]? {
        guard let items = getPage(all: all, startObjectKey: endItemDto.key, byKeyPath: "number", ascending: false, countPerPage: countPerPage) else {
            return nil
        }
        
        let itemDtos = items.map({ $0.toDto()})
        printDtos(itemDtos)
        return itemDtos
    }
    
    func pagingFromCenter(centerItemDto: ItemDto) -> [ItemDto]? {
        guard let upItems = pagingFromEndToStart(endItemDto: centerItemDto)?.sorted(by: { $0.number < $1.number }),
              let downItems = pagingFromStartToEnd(startItemDto: centerItemDto) else {
            return nil
        }
        
        if upItems.isEmpty && downItems.isEmpty {
            return nil
        }
        
        let upFirst = upItems.first(where: { $0.number == centerItemDto.number })
        let downFirst = downItems.first(where: { $0.number == centerItemDto.number })
        
        if upFirst == nil && downFirst == nil {
            return upItems + [centerItemDto] + downItems
        }
        
        return upItems + downItems
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
    
    func getItem(number: Int) -> ItemDto? {
        return all.first(where: { $0.number == number })?.toDto()
    }
}
