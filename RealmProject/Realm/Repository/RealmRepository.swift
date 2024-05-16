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
    var realm: Realm {
        // TODO: - 마이그레이션 코드 추가
        return try! Realm()
    }
    
    var first: T? { return all.first }
    var last: T? { return all.last }
    var all: Results<T> { return realm.objects(T.self) }
    var allCount: Int { return all.count }
    
    func getOne(_ key: ID) -> T? {
        return realm.object(ofType: T.self, forPrimaryKey: key)
    }
    
    func add(_ object: T) { // : Create, Update
        do {
            try realm.write {
                realm.add(object, update: .modified)
            }
        }
        catch let e {
            Log.tag(.DB).tag(.ADD).tag(.FAIL).e(e.localizedDescription)
        }
    }
    
    func add(_ objects: [T]) { // : Create, Update
        do {
            try realm.write {
                realm.add(objects, update: .modified)
            }
        }
        catch let e {
            Log.tag(.DB).tag(.ADD).tag(.FAIL).e(e.localizedDescription)
        }
    }
    
    func delete(_ object: T) { // : Delete
        do {
            try realm.write {
                realm.delete(object)
            }
        }
        catch let e {
            Log.tag(.DB).tag(.DELETE).tag(.FAIL).e(e.localizedDescription)
        }
    }
    
    func delete(_ objects: Results<T>) { // : Delete
        do {
            try realm.write {
                realm.delete(objects)
            }
        }
        catch let e {
            Log.tag(.DB).tag(.DELETE).tag(.FAIL).e(e.localizedDescription)
        }
    }
    
    func delete(_ key: ID) {
        if let one = getOne(key) {
            delete(one)
        }
    }
    
    func deleteAll() { // : All Table Drop
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
    func getPage(all: Results<T>, startObjectKey: ID, criteriaObjectKey: ID, byKeyPath: String, ascending: Bool, countPerPage: Int) -> [T]? {
        
        if ascending {
            return getPageFromStartToEnd(all: all, startObjectKey: startObjectKey, criteriaObjectKey: criteriaObjectKey, byKeyPath: byKeyPath, countPerPage: countPerPage)
        } else {
            return getPageFromEndToStart(all: all, startObjectKey: startObjectKey, criteriaObjectKey: criteriaObjectKey, byKeyPath: byKeyPath, countPerPage: countPerPage)
        }

    }
    
    private func getPageFromStartToEnd(all: Results<T>, startObjectKey: ID, criteriaObjectKey: ID, byKeyPath: String, countPerPage: Int) -> [T]? {
        guard let startItem = getOne(startObjectKey),
              let firstItem = getOne(criteriaObjectKey) else {
            Log.tag(.DB).tag(.PAGING).e("not found start item")
            return nil
        }
        let results = all.sorted(byKeyPath: byKeyPath, ascending: true)
        guard var startIdx = results.firstIndex(of: startItem) else {
            Log.tag(.DB).tag(.PAGING).e("not found start item index")
            return nil
        }
        
        if !startItem.isEqual(firstItem) {
            startIdx += 1
        }
        
        let endIdx = startIdx + countPerPage
        var items: [T] = []
        
        for item in results[max(0, startIdx) ..< min(endIdx, results.count)] {
            items.append(item)
        }
        
        return items
    }
    
    private func getPageFromEndToStart(all: Results<T>, startObjectKey: ID, criteriaObjectKey: ID, byKeyPath: String, countPerPage: Int) -> [T]? {
        guard let endItem = getOne(startObjectKey),
              let lastItem = getOne(criteriaObjectKey) else {
            Log.tag(.DB).tag(.PAGING).e("not found end item")
            return nil
        }
        
        let results = all.sorted(byKeyPath: byKeyPath, ascending: false)
        
        guard var startIdx = results.firstIndex(of: endItem) else {
            Log.tag(.DB).tag(.PAGING).e("not found start item index")
            return nil
        }
        
        if !endItem.isEqual(lastItem) {
            startIdx += 1
        }
        
        let endIdx = startIdx + countPerPage
        var items: [T] = []
        
        for item in results[max(0, startIdx) ..< min(endIdx, results.count)] {
            items.append(item)
        }
        
        return items
    }
}
