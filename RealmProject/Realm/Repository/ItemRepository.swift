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
    
//    override var all: Results<MessageTable> {
//        return super.all
//            .filter("loginId == %@", LinphoneManager.instance().mMyMcpttUri)
//            .sorted(byKeyPath: "sendTime", ascending: true)
//    }
    
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
            Log.tag(.DB).tag(.SELECT).d(item.toModel().description)
        }
    }
    
    func pagingFromStartToEnd(startItemModel: ItemModel) -> [ItemModel]? {
        guard let first = all.first else { return nil }
        guard let items = getPage(all: all, startObjectKey: startItemModel.key, criteriaObjectKey: first.key, byKeyPath: "number", ascending: true, countPerPage: countPerPage) else {
            return nil
        }
        
        let itemModels = items.map({ $0.toModel()})
        printModels(itemModels)
        return itemModels
    }
    
    func pagingFromEndToStart(endItemModel: ItemModel) -> [ItemModel]? {
        guard let last = all.last else { return nil }
        guard let items = getPage(all: all, startObjectKey: endItemModel.key, criteriaObjectKey: last.key, byKeyPath: "number", ascending: false, countPerPage: countPerPage) else {
            return nil
        }
        
        let itemModels = items.map({ $0.toModel()})
        printModels(itemModels)
        return itemModels
    }
    
    func pagingFromCenter(centerItemModel: ItemModel) -> [ItemModel]? {
        guard let upItems = pagingFromEndToStart(endItemModel: centerItemModel)?.sorted(by: { $0.number < $1.number }),
              let downItems = pagingFromStartToEnd(startItemModel: centerItemModel) else {
            return nil
        }
        
        if upItems.isEmpty && downItems.isEmpty {
            return nil
        }
        
        let upFirst = upItems.first(where: { $0.number == centerItemModel.number })
        let downFirst = downItems.first(where: { $0.number == centerItemModel.number })
        
        if upFirst == nil && downFirst == nil {
            return upItems + [centerItemModel] + downItems
        }
        
        return upItems + downItems
    }
    
    func printModels(_ itemModels: [ItemModel]) {
        for index in itemModels.indices {
            let itemModel = itemModels[index]
            var print = itemModel.description
            
            if index == 0 {
                print += " ## start"
            } else if index == itemModels.endIndex - 1 {
                print += " ## end"
            }
            
            Log.tag(.DB).tag(.PAGING).d(print)
        }
    }
    
    func getItem(number: Int) -> ItemModel? {
        return all.first(where: { $0.number == number })?.toModel()
    }
}
