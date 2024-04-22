//
//  ViewController.swift
//  RealmProject
//
//  Created by 김현구 on 4/9/24.
//

import UIKit

class ViewController: RxViewController {
    
    @IBOutlet var showPagingCollectionViewBtn: UIButton!
    @IBOutlet var printPagingTestBtn: UIButton!
    @IBOutlet var printUpdateTestBtn: UIButton!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // MARK: - Paging Test Code
          
        showPagingCollectionViewBtn.addRxTap(disposeBag: disposeBag) { [weak self] in
            ItemManager.shared.initCollectionViewPagingItem()
            self?.navigationController?.pushViewController(PagingCollectionViewController(), animated: true)
        }
        
        printPagingTestBtn.addRxTap(disposeBag: disposeBag) {
            ItemManager.shared.testPaging()
        }
        
        printUpdateTestBtn.addRxTap(disposeBag: disposeBag) {
            ItemManager.shared.testUpdate()
        }
    }

}

