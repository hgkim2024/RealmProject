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
    let pagingSize = 50
    
    // MARK: - Notification Token: Received Realm Change Event
    var insertTokenWorker: RealmTokenWorker<Item>?
    
    private override init() {
        super.init()
        
        insertTokenWorker = RealmTokenWorker({ [weak self] in self?.getAll() }) { changes in
            switch changes {
                
            case .initial(_):
                break
            case .update(let results, deletions: let deletions, insertions: let insertions, modifications: let modifications):
                if !insertions.isEmpty {
                    let items = results.sorted(byKeyPath: "number", ascending: false)
                    for i in insertions.indices { // : 아래 처럼 접근해야 insert 된 순서대로 접근할 수 있다.
                        Log.tag(.DB).tag(.ADD).d("number: \(items[insertions.count - i - 1].number)")
                        // : 다른 곳에 Event 전달이 필요하다면 여기서 전달하자
//                        Log.tag(.DB).tag(.ADD).d("insertions: \(insertions.count)")
                    }
                }
                break
            case .error(_):
                break
            }
        }
    }
    
    deinit {
        insertTokenWorker = nil
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
        let items = getAll().sorted(byKeyPath: "number", ascending: true)
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
        
        let items = getAll().sorted(byKeyPath: "number", ascending: false)
//        guard var endIdx = items.firstIndex(of: endItem) else {
//            Log.tag(.DB).tag(.PAGING).e("not found end item index")
//            return nil
//        }
        
        guard var startIdx = items.firstIndex(of: endItem) else {
            Log.tag(.DB).tag(.PAGING).e("not found start item index")
            return nil
        }
        
        if endItem.key != lastItem.key {
            startIdx += 1
        }
        
        let endIdx = startIdx + pagingSize
        var itemDtos: [ItemDto] = []
        
        for item in items[max(0, startIdx) ..< min(endIdx, items.count)] {
            itemDtos.append(item.toDto())
        }
        
//        itemDtos = itemDtos.sorted(by: { $0.number > $1.number })
        
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
