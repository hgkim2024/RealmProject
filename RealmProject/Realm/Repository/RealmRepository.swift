//
//  Item.swift
//  RealmProject
//
//  Created by 김현구 on 4/9/24.
//

import Foundation
import RealmSwift


class RealmRepository<T: Object, ID> {
    
    func getOne(_ key: ID) -> T? {
        let realm = try! Realm()
        
        let result = realm.objects(T.self)
            .filter("key == \(key)")
            .first
        
        return result
    }
    
    func getAll() -> Results<T> {
        let realm = try! Realm()
        return realm.objects(T.self)
    }
    
    func add(_ object: T) { // : Create, Update
        let realm = try! Realm()
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
        let realm = try! Realm()
        
        do {
            try realm.write {
                realm.delete(object)
            }
        }
        catch let e {
            Log.tag(.DB).tag(.DELETE).tag(.FAIL).e(e.localizedDescription)
        }
    }
    
}
