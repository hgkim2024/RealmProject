//
//  ViewController.swift
//  RealmProject
//
//  Created by 김현구 on 4/9/24.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        ItemRepository.shared.autoAdd(3)
        ItemRepository.shared.printAll()
        ItemRepository.shared.deleteAll()
    }


}

