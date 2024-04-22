//
//  UIButton + Extension.swift
//  RealmProject
//
//  Created by 김현구 on 4/22/24.
//

import Foundation
import RxSwift
import RxCocoa

extension UIButton {
//    throttle
    func addRxTap(disposeBag: DisposeBag, completion: @escaping () -> Void) {
        rx.tap
        // prevent double tap 500 ms
            .throttle(.microseconds(500), scheduler: MainScheduler.instance)
            .subscribe { event in
                completion()
            }
            .disposed(by: disposeBag)
    }
    
}
