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
    let searchController = UISearchController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpSearchBar()
        setUpCollectionView()
    }
    
    func setUpCollectionView() {
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
    
    func setUpSearchBar() {
        searchController.searchResultsUpdater = self // 필요에 따라 UISearchResultsUpdating 프로토콜을 구현한 객체를 설정해줍니다.
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Number"
        navigationItem.searchController = searchController
        definesPresentationContext = true
        navigationItem.hidesSearchBarWhenScrolling = false
//        navigationItem.hidesBackButton = true
        
        if let searchBarTextField = searchController.searchBar.value(forKey: "searchField") as? UITextField {
            searchBarTextField.keyboardType = .numberPad
        }
    }
}

extension PagingCollectionViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text else { return }
        Log.tag(.DB).tag(.SEARCH).d(searchText)
        let itemDto = ItemManager.shared.getItem(number: Int(searchText) ?? -1)
        collectionView.searchItem(item: itemDto)
    }
}
