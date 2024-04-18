//
//  PagingCollectionView.swift
//  RealmProject
//
//  Created by 김현구 on 4/18/24.
//

import Foundation
import UIKit

enum PagingPosition {
    case TOP
    case BOTTOM
    case CENTER
}

class PagingCollectionView: UICollectionView {
    
    let items: [ItemDto]
    
    init() {
        items = ItemManager.shared.getCollectionViewPagingItem(position: .TOP)
        
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        layout.scrollDirection = .vertical
        
        super.init(frame: .zero, collectionViewLayout: layout)
        
        delegate = self
        dataSource = self
        backgroundColor = .clear
        
        register(PagingCollectionViewCell.self, forCellWithReuseIdentifier: PagingCollectionViewCell.identifier)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension PagingCollectionView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        return items.count
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PagingCollectionViewCell.identifier, for: indexPath) as! PagingCollectionViewCell
        cell.setItem(item: items[indexPath.row])
        return cell
    }
    
    // : Cell Size
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let size = collectionView.bounds.size
        return CGSize(width: size.width, height: 30.0)
    }
    
    // : Paging
    func collectionView(
        _ collectionView: UICollectionView,
        willDisplay cell: UICollectionViewCell,
        forItemAt indexPath: IndexPath
    ) {
        if indexPath.row == 0 {
            // TODO: - add paging items
            Log.tag(.PAGING).d("Top")
        } else if indexPath.row >= items.count - 1 {
            // TODO: - add paging items
            Log.tag(.PAGING).d("Bottom")
        }
    }
    
}


// : Step 1
// TODO: - add Cell
// TODO: - add Realm Data

// : Step 2
// TODO: - add scroll event -> Paging
