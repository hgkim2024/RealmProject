//
//  ViewController.swift
//  RealmProject
//
//  Created by 김현구 on 4/9/24.
//

import UIKit

class ViewController: UIViewController {

    let collectionView = PagingCollectionView()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
        ])
        
        collectionView.scrollToBottom()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // MARK: - Paging Test Code
//        ItemManager.shared.testPaging()
//        ItemManager.shared.testUpdate()
        
        collectionView.scrollToBottom()
    }
}

