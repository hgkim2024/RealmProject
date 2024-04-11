//
//  RealmCacheWorker.swift
//  RealmProject
//
//  Created by 김현구 on 4/11/24.
//

import Foundation
import RealmSwift

// : https://academy.realm.io/posts/realm-notifications-on-background-threads-with-swift/
class RealmTokenWorker<T: Object>: RealmBackgroundWorker {
    private var token: NotificationToken?
    
    init(_ query: @escaping () -> Results<T>?, _ block: @escaping (RealmCollectionChange<Results<T>>) -> Void) {
        super.init()
        start { [weak self] in
            self?.token = query()?.observe(block)
        }
    }

    deinit {
      token?.invalidate()
    }
}
