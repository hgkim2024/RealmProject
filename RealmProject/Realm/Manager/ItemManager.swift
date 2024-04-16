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
    static let shared = ItemManager()
    
    // MARK: - n 개 데이터가 있을 때 Paging Test
    let createSize = 100000
    
    // MARK: - k 번 페이징 반복
    let printCount = 30
    
    // MARK: - Notification Token: Received Realm Change Event
    var insertTokenWorker: RealmTokenWorker<Item>?
    
    private init() {
        insertTokenWorker = RealmTokenWorker({ ItemRepository.shared.all }) { changes in
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
        ItemRepository.shared.deleteAll()
        ItemRepository.shared.autoAdd(createSize)
        let itemDtos = ItemRepository.shared.all.sorted(by: { $0.number < $1.number }).map({ $0.toDto() })
        for itemDto in itemDtos {
            itemDto.number += 10
            ItemRepository.shared.add(itemDto.toRealm())
        }
    }
    
    // MARK: - Pasination Test Code
    func testPaging() {
        
        // MARK: - Item Data 생성
        let realmItemSize = ItemRepository.shared.allCount
        if realmItemSize == 0 || realmItemSize > createSize {
            ItemRepository.shared.deleteAll()
            ItemRepository.shared.autoAdd(createSize)
        } else if realmItemSize < createSize {
            ItemRepository.shared.autoAdd(createSize - realmItemSize)
        }
        
        // MARK: - Paging
//        printPagingFromStartToEnd()
        printPagingFromEndToStart()
    }
    
    // MARK: - Pasination Code
    func printPagingFromStartToEnd() {
        if let firstItem = ItemRepository.shared.first,
           var dtos = ItemRepository.shared.pagingFromStartToEnd(startItemDto: firstItem.toDto()) {
            
            var i = 0
            while true {
                if i >= printCount - 1 {
                    break
                }
                
                if let lastItem = dtos.last {
                    let pageDtos = ItemRepository.shared.pagingFromStartToEnd(startItemDto: lastItem) ?? []
                    if pageDtos.isEmpty == true {
                        break
                    }
                    dtos += pageDtos
                } else {
                    break
                }
                i += 1
            }
            
//            ItemRepository.shared.printDtos(dtos)
        }
    }
    
    func printPagingFromEndToStart() {
        if let lastItem = ItemRepository.shared.last,
           var dtos = ItemRepository.shared.pagingFromEndToStart(endItemDto: lastItem.toDto()) {
            
            var i = 0
            while true {
                if i >= printCount - 1 {
                    break
                }
                
                if let firstItem = dtos.last {
                    let pageDtos = ItemRepository.shared.pagingFromEndToStart(endItemDto: firstItem) ?? []
                    if pageDtos.isEmpty == true {
                        break
                    }
                    dtos += pageDtos
                } else {
                    break
                }
                i += 1
            }
            
//            ItemRepository.shared.printDtos(dtos)
        }
    }
}
