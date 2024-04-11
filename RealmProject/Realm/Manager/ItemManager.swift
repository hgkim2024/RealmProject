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
    
    // MARK: - n 개 데이터가 있을 때 Paging Test
    let createSize = 100000
    
    // MARK: - k 번 페이징 반복
    let printCount = 30
    
    // MARK: - Pasination Test Code
    func testPaging() {
        
        // MARK: - Item Data 생성
        let realmItemSize = ItemRepository.shared.getAllCount()
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
        if let firstItem = ItemRepository.shared.getFirst(),
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
        if let lastItem = ItemRepository.shared.getLast(),
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
