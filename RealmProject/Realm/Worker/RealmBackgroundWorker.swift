//
//  RealmBackgroundWorker.swift
//  RealmProject
//
//  Created by 김현구 on 4/11/24.
//

import Foundation
import RealmSwift

// : https://academy.realm.io/posts/realm-notifications-on-background-threads-with-swift/
@objc @objcMembers class RealmBackgroundWorker: NSObject {
    private var thread: Thread!
    private var block: (()->Void)!
    
    internal func runBlock() { block() }
    
    internal func start(_ block: @escaping () -> Void) {
        self.block = block
        
        let threadName = String(describing: self)
            .components(separatedBy: .punctuationCharacters)[1]
        
        thread = Thread { [weak self] in
            while (self != nil && !self!.thread.isCancelled) {
                RunLoop.current.run(
                    mode: RunLoop.Mode.default,
                    before: Date.distantFuture)
            }
            Thread.exit()
        }
        thread.name = "\(threadName)-\(UUID().uuidString)"
        thread.start()
        
        perform(#selector(runBlock),
                on: thread,
                with: nil,
                waitUntilDone: false,
                modes: [RunLoop.Mode.default.rawValue])
    }
    
    public func stop() {
        thread.cancel()
    }
}
