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
    
    var countPerPage: Int {
        return itemRepository.countPerPage
    }
    
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
        let itemModels = itemRepository.all.sorted(by: { $0.number < $1.number }).map({ $0.toModel() })
        for itemModel in itemModels {
            itemModel.number += 10
            itemRepository.add(itemModel.toRealm())
        }
    }
    
    // MARK: - Pasination Test Code
    func testPaging() {
        // : Item Data 생성
        let createSize = 1000
        itemRepository.deleteAll()
        itemRepository.autoAdd(createSize)
        
        // : Paging
        let pageCount = 20
//        printPagingFromStartToEnd(pageCount: pageCount)
        printPagingFromEndToStart(pageCount: pageCount)
    }
    
    // MARK: - Pasination Code
    func printPagingFromStartToEnd(pageCount: Int) {
        if let firstItem = itemRepository.first,
           var models = itemRepository.pagingFromStartToEnd(startItemModel: firstItem.toModel()) {
            
            var i = 0
            while true {
                if i >= pageCount - 1 {
                    break
                }
                
                if let lastItem = models.last {
                    let pageModels = itemRepository.pagingFromStartToEnd(startItemModel: lastItem) ?? []
                    if pageModels.isEmpty == true {
                        break
                    }
                    models += pageModels
                } else {
                    break
                }
                i += 1
            }
        }
    }
    
    func printPagingFromEndToStart(pageCount: Int) {
        if let lastItem = itemRepository.last,
           var models = itemRepository.pagingFromEndToStart(endItemModel: lastItem.toModel()) {
            
            var i = 0
            while true {
                if i >= pageCount - 1 {
                    break
                }
                
                if let firstItem = models.last {
                    let pageModels = itemRepository.pagingFromEndToStart(endItemModel: firstItem) ?? []
                    if pageModels.isEmpty == true {
                        break
                    }
                    models += pageModels
                } else {
                    break
                }
                i += 1
            }
        }
    }
    
    func initCollectionViewPagingItem() {
        let createSize = 1000
        itemRepository.deleteAll()
        itemRepository.autoAdd(createSize)
    }
    
    func getCollectionViewPagingItem(position: PagingPosition, criteriaItem: ItemModel? = nil) -> [ItemModel] {
    
        switch position {
            
        // : 채팅방 페이징
        case .TOP:
            var startItem = criteriaItem
            
            if startItem == nil {
                startItem = itemRepository.first?.toModel()
            } else {
                if startItem!.isEqual(itemRepository.first?.toModel()) {
                    return []
                }
            }
            
            guard let startItem else { return [] }
            guard let itemModels = itemRepository.pagingFromStartToEnd(startItemModel: startItem) else {
                return []
            }
            
            return itemModels
            
        // : 일반 게시글 페이징
        case .BOTTOM:
            var endItem = criteriaItem
            
            if endItem == nil {
                endItem = itemRepository.last?.toModel()
            } else {
                if endItem!.isEqual(itemRepository.last?.toModel()) {
                    return []
                }
            }
            
            guard let endItem else { return [] }
            guard let itemModels = itemRepository.pagingFromEndToStart(endItemModel: endItem)?.sorted(by: { $0.number < $1.number }) else {
                return []
            }
            
            return itemModels
        
        // : Search 페이징
        case .CENTER:
            guard let criteriaItem else {
                return []
            }
            
            guard let itemModels = itemRepository.pagingFromCenter(centerItemModel: criteriaItem) else {
                return []
            }
            
            return itemModels
        }
    }
    
    func getItem(number: Int) -> ItemModel? {
        return itemRepository.getItem(number: number)
    }
}
