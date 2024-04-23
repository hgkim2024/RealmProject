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
    
    let startPagingPosition: PagingPosition = .BOTTOM
    var items: [ItemDto]
    var applyWillDisplayFlag: Bool
    
    init() {
        applyWillDisplayFlag = startPagingPosition != .BOTTOM
        items = ItemManager.shared.getCollectionViewPagingItem(position: startPagingPosition)
        
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
    
    func scrollToBottom() {
        guard numberOfSections > 0 else {
            return
        }
        
        let lastSection = numberOfSections - 1
        guard numberOfItems(inSection: lastSection) > 0 else {
            return
        }
        
        let lastItemIndexPath = IndexPath(item: numberOfItems(inSection: lastSection) - 1, section: lastSection)
        scrollToItem(at: lastItemIndexPath, at: .bottom, animated: false)
        
        if !applyWillDisplayFlag {
            applyWillDisplayFlag = true
        }
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
        return CGSize(width: size.width, height: 45.0)
    }
    
    // : Paging
    func collectionView(
        _ collectionView: UICollectionView,
        willDisplay cell: UICollectionViewCell,
        forItemAt indexPath: IndexPath
    ) {
        if !applyWillDisplayFlag { return }
        
        if indexPath.row == 0 {
            Log.tag(.PAGING).d("Top")
            if items.isEmpty { return }
            let startItem = items[0]
            let pagingItems = ItemManager.shared.getCollectionViewPagingItem(position: .BOTTOM, criteriaItem: startItem)
            if pagingItems.isEmpty { return }
            items = pagingItems + items
            
            var indexPaths: [IndexPath] = []
            for i in 0..<ItemManager.shared.countPerPage {
                indexPaths.append(IndexPath(row: i, section: 0))
            }
            performBatchUpdates {
                insertItems(at: indexPaths)
            }
        } else if indexPath.row >= items.count - 1 {
            Log.tag(.PAGING).d("Bottom")
            if items.isEmpty { return }
            let endItem = items[items.count - 1]
            let pagingItems = ItemManager.shared.getCollectionViewPagingItem(position: .TOP, criteriaItem: endItem)
            if pagingItems.isEmpty { return }
            items = items + pagingItems
            
            var indexPaths: [IndexPath] = []
            for item in pagingItems {
                if let index = items.firstIndex(of: item) {
                    indexPaths.append(IndexPath(row: index, section: 0))
                }
            }
            performBatchUpdates {
                insertItems(at: indexPaths)
            }
        }
    }
    
}
