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

enum CollectionViewScrollDirection {
    case UP
    case DOWN
    case NONE
}

class PagingCollectionView: UICollectionView {
    
    let startPagingPosition: PagingPosition
    var items: [ItemDto]
    var applyEndDisplayFlag: Bool
    var lastContentOffset: CGFloat = 0
    var curScrollDirection: CollectionViewScrollDirection = .NONE
    
    init(startPagingPosition: PagingPosition) {
        self.startPagingPosition = startPagingPosition
        applyEndDisplayFlag = startPagingPosition != .BOTTOM
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
        
        if !applyEndDisplayFlag {
            applyEndDisplayFlag = true
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
        didEndDisplaying cell: UICollectionViewCell,
        forItemAt indexPath: IndexPath
    ) {
        if !applyEndDisplayFlag { return }
        if curScrollDirection == .NONE { return }
        
        if indexPath.row >= items.count - ItemManager.shared.countPerPage + 1 
            && curScrollDirection == .DOWN {
            Log.tag(.PAGING).d("Bottom")
            applyEndDisplayFlag = false
            if items.isEmpty { return }
            let endItem = items[items.count - 1]
            let pagingItems = ItemManager.shared.getCollectionViewPagingItem(position: .TOP, criteriaItem: endItem)
            if pagingItems.isEmpty {
                applyEndDisplayFlag = true
                return
            }
            items = items + pagingItems
            
            var indexPaths: [IndexPath] = []
            for item in pagingItems {
                if let index = items.firstIndex(of: item) {
                    indexPaths.append(IndexPath(row: index, section: 0))
                }
            }
            performBatchUpdates {
                insertItems(at: indexPaths)
            } completion: { [weak self] _ in
                self?.applyEndDisplayFlag = true
            }
        } else if indexPath.row <= ItemManager.shared.countPerPage - 1
                    && curScrollDirection == .UP {
            Log.tag(.PAGING).d("Top")
            applyEndDisplayFlag = false
            if items.isEmpty { return }
            let startItem = items[0]
            let pagingItems = ItemManager.shared.getCollectionViewPagingItem(position: .BOTTOM, criteriaItem: startItem)
            if pagingItems.isEmpty {
                applyEndDisplayFlag = true
                return
            }
            items = pagingItems + items
            
            var indexPaths: [IndexPath] = []
            for i in 0..<ItemManager.shared.countPerPage {
                indexPaths.append(IndexPath(row: i, section: 0))
            }
            
            performBatchUpdates {
                insertItems(at: indexPaths)
            } completion: { [weak self] _ in
                self?.applyEndDisplayFlag = true
            }
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if !applyEndDisplayFlag { return }
        if scrollView.contentOffset.y > lastContentOffset {
            curScrollDirection = .DOWN
        } else if scrollView.contentOffset.y < lastContentOffset {
            curScrollDirection = .UP
        }
        
        lastContentOffset = scrollView.contentOffset.y
    }
}
