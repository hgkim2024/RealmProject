//
//  Item.swift
//  RealmProject
//
//  Created by 김현구 on 4/9/24.
//

import Foundation
import RealmSwift

// MARK: - Repository 에서 공통으로 처리할 로직을 모아둔 클래스
class RealmRepository<T: Object, ID> {
    
    // MARK: - CRUD
    func getOne(_ key: ID) -> T? {
        let realm = getRealm()
        
        if key is String {
            return realm.objects(T.self)
                .filter("key == %@", key)
                .first
        } else {
            // TODO: - 크래시 발생되는 Type 이 있다면 추가 분기 필요
            return realm.objects(T.self)
                .filter("key == \(key)")
                .first
        }
    }
    
    func getFirst() -> T? {
        let realm = getRealm()
        
        let result = realm.objects(T.self)
            .first
        
        return result
    }
    
    func getLast() -> T? {
        let realm = getRealm()
        
        let result = realm.objects(T.self)
            .last
        
        return result
    }
    
    func getRealm() -> Realm {
        // TODO: - 마이그레이션 코드 추가
        return try! Realm()
    }
    
    func getAll() -> Results<T> {
        let realm = getRealm()
        return realm.objects(T.self)
    }
    
    func getAllCount() -> Int {
        return getAll().count
    }
    
    func add(_ object: T) { // : Create, Update
        let realm = getRealm()
        do {
            try realm.write {
                realm.add(object, update: .modified)
            }
        }
        catch let e {
            Log.tag(.DB).tag(.ADD).tag(.FAIL).e(e.localizedDescription)
        }
    }
    
    func delete(_ object: T) { // : Delete
        let realm = getRealm()
        
        do {
            try realm.write {
                realm.delete(object)
            }
        }
        catch let e {
            Log.tag(.DB).tag(.DELETE).tag(.FAIL).e(e.localizedDescription)
        }
    }
    
    func deleteAll() { // : All Table Drop
        let realm = getRealm()
        
        do {
            try realm.write {
                realm.deleteAll()
            }
        }
        catch let e {
            Log.tag(.DB).tag(.DELETE).tag(.FAIL).e(e.localizedDescription)
        }
    }
    
    // MARK: - Pagination
    func getPage(startObjectKey: ID, byKeyPath: String, ascending: Bool, pageSize: Int) -> [T]? {
        
        if ascending {
            return getPageFromStartToEnd(startObjectKey: startObjectKey, byKeyPath: byKeyPath, pageSize: pageSize)
        } else {
            return getPageFromEndToStart(startObjectKey: startObjectKey, byKeyPath: byKeyPath, pageSize: pageSize)
        }

    }
    
    private func getPageFromStartToEnd(startObjectKey: ID, byKeyPath: String, pageSize: Int) -> [T]? {
        guard let startItem = getOne(startObjectKey),
              let firstItem = getFirst() else {
            Log.tag(.DB).tag(.PAGING).e("not found start item")
            return nil
        }
        let results = getAll().sorted(byKeyPath: byKeyPath, ascending: true)
        guard var startIdx = results.firstIndex(of: startItem) else {
            Log.tag(.DB).tag(.PAGING).e("not found start item index")
            return nil
        }
        
        if !startItem.isEqual(firstItem) {
            startIdx += 1
        }
        
        let endIdx = startIdx + pageSize
        var items: [T] = []
        
        for item in results[max(0, startIdx) ..< min(endIdx, results.count)] {
            items.append(item)
        }
        
        return items
    }
    
    private func getPageFromEndToStart(startObjectKey: ID, byKeyPath: String, pageSize: Int) -> [T]? {
        guard let endItem = getOne(startObjectKey),
              let lastItem = getLast() else {
            Log.tag(.DB).tag(.PAGING).e("not found end item")
            return nil
        }
        
        let results = getAll().sorted(byKeyPath: byKeyPath, ascending: false)
        
        guard var startIdx = results.firstIndex(of: endItem) else {
            Log.tag(.DB).tag(.PAGING).e("not found start item index")
            return nil
        }
        
        if !endItem.isEqual(lastItem) {
            startIdx += 1
        }
        
        let endIdx = startIdx + pageSize
        var items: [T] = []
        
        for item in results[max(0, startIdx) ..< min(endIdx, results.count)] {
            items.append(item)
        }
        
//        itemDtos = itemDtos.sorted(by: { $0.number > $1.number })
        
        return items
    }
}
