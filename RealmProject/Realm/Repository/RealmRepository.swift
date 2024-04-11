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
    
    func getOne(_ key: ID) -> T? {
        let realm = getRealm()
        
        if key is String {
            return realm.objects(T.self)
                .filter("key == %@", key)
                .first
        } else {
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
    
    func deleteAll() {
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
}
