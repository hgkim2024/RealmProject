//
//  RxViewController.swift
//  RealmProject
//
//  Created by 김현구 on 4/22/24.
//

import Foundation
import RxSwift

class RxViewController: UIViewController {

    var disposeBag: DisposeBag = DisposeBag()
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        disposeBag = DisposeBag()
    }
    
}
