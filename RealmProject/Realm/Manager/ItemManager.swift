//
//  ItemService.swift
//  RealmProject
//
//  Created by 김현구 on 4/11/24.
//

import Foundation
import RealmSwift

// MARK: - Item Manager - Repository 에서 읽어온 데이터를 처리하는(비지니스) 로직이 담긴 클래스
class ItemManager {
    static let shared = ItemManager(itemRepository: ItemRepository.shared)
    
    // MARK: - Item Repository
    let itemRepository: ItemRepository
    
    // MARK: - Notification Token: Received Realm Change Event
    var insertTokenWorker: RealmTokenWorker<Item>?
    
    private init(itemRepository: ItemRepository) {
        self.itemRepository = itemRepository
        
        insertTokenWorker = RealmTokenWorker({ itemRepository.all }) { changes in
            switch changes {
                
            case .initial(_):
                break
            case .update(let results, deletions: let deletions, insertions: let insertions, modifications: let modifications):
                if !insertions.isEmpty {
                    // : results 는 getAll 과 동일한 결과이다.
                    let items = results.sorted(byKeyPath: "number", ascending: false)
                    for i in insertions.indices { // : 아래 처럼 접근해야 insert 된 순서대로 접근할 수 있다.
                        Log.tag(.DB).tag(.ADD).d("number: \(items[insertions.count - i - 1].number)")
                        // : 다른 곳에 Event 전달이 필요하다면 여기서 전달하자
                    }
                }
                
                if !modifications.isEmpty {
                    let items = results.sorted(byKeyPath: "number", ascending: false)
                    for i in modifications.indices {
                        Log.tag(.DB).tag(.UPDATE).d("number: \(items[modifications.count - i - 1].number)")
                    }
                }
            case .error(_):
                break
            }
        }
    }
    
    
    deinit {
        insertTokenWorker = nil
    }
    
    // MARK: - Update Test Code
    func testUpdate() {
        let createSize = 10
        itemRepository.deleteAll()
        itemRepository.autoAdd(createSize)
        let itemDtos = itemRepository.all.sorted(by: { $0.number < $1.number }).map({ $0.toDto() })
        for itemDto in itemDtos {
            itemDto.number += 10
            itemRepository.add(itemDto.toRealm())
        }
    }
    
    // MARK: - Pasination Test Code
    func testPaging() {
        // MARK: - Item Data 생성
        let createSize = 10000
        let realmItemSize = itemRepository.allCount
        if realmItemSize == 0 || realmItemSize > createSize {
            itemRepository.deleteAll()
            itemRepository.autoAdd(createSize)
        } else if realmItemSize < createSize {
            itemRepository.autoAdd(createSize - realmItemSize)
        }
        
        // MARK: - Paging
        let printCount = 200
//        printPagingFromStartToEnd(printCount: printCount)
        printPagingFromEndToStart(printCount: printCount)
    }
    
    // MARK: - Pasination Code
    func printPagingFromStartToEnd(printCount: Int) {
        if let firstItem = itemRepository.first,
           var dtos = itemRepository.pagingFromStartToEnd(startItemDto: firstItem.toDto()) {
            
            var i = 0
            while true {
                if i >= printCount - 1 {
                    break
                }
                
                if let lastItem = dtos.last {
                    let pageDtos = itemRepository.pagingFromStartToEnd(startItemDto: lastItem) ?? []
                    if pageDtos.isEmpty == true {
                        break
                    }
                    dtos += pageDtos
                } else {
                    break
                }
                i += 1
            }
            
//            itemRepository.printDtos(dtos)
        }
    }
    
    func printPagingFromEndToStart(printCount: Int) {
        if let lastItem = itemRepository.last,
           var dtos = itemRepository.pagingFromEndToStart(endItemDto: lastItem.toDto()) {
            
            var i = 0
            while true {
                if i >= printCount - 1 {
                    break
                }
                
                if let firstItem = dtos.last {
                    let pageDtos = itemRepository.pagingFromEndToStart(endItemDto: firstItem) ?? []
                    if pageDtos.isEmpty == true {
                        break
                    }
                    dtos += pageDtos
                } else {
                    break
                }
                i += 1
            }
            
//            itemRepository.printDtos(dtos)
        }
    }
    
    func getCollectionViewPagingItem(position: PagingPosition, criteriaItem: ItemDto? = nil) -> [ItemDto] {
        switch position {
            
        case .TOP:
            var startItem = criteriaItem
            
            if startItem == nil {
                startItem = itemRepository.first?.toDto()
            } else {
                if startItem!.isEqual(itemRepository.first?.toDto()) {
                    return []
                }
            }
            
            guard let startItem else { return [] }
            guard let itemDtos = itemRepository.pagingFromStartToEnd(startItemDto: startItem) else {
                return []
            }
            
            return itemDtos
            
        case .BOTTOM:
            var endItem = criteriaItem
            
            if endItem == nil {
                endItem = itemRepository.last?.toDto()
            } else {
                if endItem!.isEqual(itemRepository.last?.toDto()) {
                    return []
                }
            }
            
            guard let endItem else { return [] }
            guard let itemDtos = itemRepository.pagingFromEndToStart(endItemDto: endItem) else {
                return []
            }
            
            return itemDtos
            
        case .CENTER:
            
            // TODO: - 개발
            return []
//            guard let itemDtos = itemRepository.pagingCenter(criteriaItem: criteriaItem) else {
//                return []
//            }
//            
//            return itemDtos
        }
    }
}
