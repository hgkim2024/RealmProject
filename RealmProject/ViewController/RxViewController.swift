//
//  RxViewController.swift
//  RealmProject
//
//  Created by 김현구 on 4/22/24.
//

import Foundation
import RxSwift

enum ViewControllerLifeCycle: Int {
    case INIT
    case LOAD_VIEW
    case VIEW_DID_LOAD
    case VIEW_WILL_APPEAR
    case VIEW_DID_APPEAR
    case VIEW_WILL_DISAPPEAR
    case VIEW_DID_DISAPPEAR
//    case VIEW_DID_UNLOAD
    case DEINIT
}

class RxViewController: UIViewController {

    var disposeBag: DisposeBag = DisposeBag()
    
    var lifeCycle: ViewControllerLifeCycle = .INIT
  
    // : Crash ...
//    override func loadView() {
//        super.loadView()
//        lifeCycle = .LOAD_VIEW
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        lifeCycle = .VIEW_DID_LOAD
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        lifeCycle = .VIEW_WILL_APPEAR
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        lifeCycle = .VIEW_DID_APPEAR
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        disposeBag = DisposeBag()
        lifeCycle = .VIEW_DID_DISAPPEAR
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        lifeCycle = .VIEW_DID_DISAPPEAR
    }
    
}
