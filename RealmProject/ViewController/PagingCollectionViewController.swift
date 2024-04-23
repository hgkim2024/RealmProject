//
//  PagingCollectionViewController.swift
//  RealmProject
//
//  Created by 김현구 on 4/22/24.
//

import Foundation
import UIKit

class PagingCollectionViewController: UIViewController {
    let collectionView = PagingCollectionView(startPagingPosition: .BOTTOM)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
        ])
        
        DispatchQueue.main.async { [weak self] in
            if self?.collectionView.startPagingPosition == .BOTTOM {
                self?.collectionView.scrollToBottom()
            }
        }
    }
}
