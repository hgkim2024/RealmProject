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
    private init() { }
    
    // MARK: - Item Service Test Code
    func test() {
        ItemRepository.shared.deleteAll()
        ItemRepository.shared.autoAdd(17)
        
//        ItemRepository.shared.printAll()
        printPagingFromStartToEnd()
//        printPagingFromLast()
    }
    
    // MARK: - Paging Code
    func printPagingFromStartToEnd() {
        if let firstItem = ItemRepository.shared.getFirst(),
           var dtos = ItemRepository.shared.pagingFromStartToEnd(startItemDto: firstItem.toDto()) {
            
            while true {
                if let lastItem = dtos.last {
                    let pageDtos = ItemRepository.shared.pagingFromStartToEnd(startItemDto: lastItem) ?? []
                    if pageDtos.isEmpty == true {
                        break
                    }
                    dtos += pageDtos
                } else {
                    break
                }
            }
            
            ItemRepository.shared.printDtos(dtos)
        }
    }
    
    func printPagingFromEndToStart() {
        if let lastItem = ItemRepository.shared.getLast(),
           var dtos = ItemRepository.shared.pagingFromEndToStart(endItemDto: lastItem.toDto()) {
            
            while true {
                if let firstItem = dtos.last {
                    let pageDtos = ItemRepository.shared.pagingFromEndToStart(endItemDto: firstItem) ?? []
                    if pageDtos.isEmpty == true {
                        break
                    }
                    dtos += pageDtos
                } else {
                    break
                }
            }
            
            ItemRepository.shared.printDtos(dtos)
        }
    }
}
