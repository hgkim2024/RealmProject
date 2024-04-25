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
    var searchItem: ItemDto? = nil
    var initFlag = true
    var isSearchFlag = false
    let cellHeight: CGFloat = 45.0
    let scrollPreventHeight: CGFloat
    var isNextUpPage: Bool = true
    
    init(startPagingPosition: PagingPosition) {
        self.startPagingPosition = startPagingPosition
        applyEndDisplayFlag = startPagingPosition != .BOTTOM
        scrollPreventHeight = cellHeight * 10
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
        
        initFlag = false
    }
    
    // : Search - 검색 시 새로운 페이지로 로딩 -> 데이터가 많은 경우에 바로 로딩하기 위함
    func searchItem(item: ItemDto?) {
        applyEndDisplayFlag = false
        isSearchFlag = true
        isNextUpPage = true
        searchItem = item
        
        if let item {
            items = ItemManager.shared.getCollectionViewPagingItem(position: .CENTER, criteriaItem: item)
        }
        
        reloadData()
        
        if let item, let index = items.firstIndex(of: item) {
            scrollToItem(at: IndexPath(row: index, section: 0), at: .centeredVertically, animated: false)
        }
        
        isSearchFlag = false
        applyEndDisplayFlag = true
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
        cell.setItem(item: items[indexPath.row], searchItem: searchItem)
        return cell
    }
    
    // : Cell Size
    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        sizeForItemAt indexPath: IndexPath
    ) -> CGSize {
        let size = collectionView.bounds.size
        return CGSize(width: size.width, height: cellHeight)
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
            downPaging()
        } else if indexPath.row <= ItemManager.shared.countPerPage - 1
                    && curScrollDirection == .UP {
            upPaging()
        }
    }
    
    func upPaging() {
        Log.tag(.PAGING).d("Top")
        applyEndDisplayFlag = false
        if items.isEmpty { return }
        let startItem = items[0]
        let pagingItems = ItemManager.shared.getCollectionViewPagingItem(position: .BOTTOM, criteriaItem: startItem)
        if pagingItems.isEmpty {
            applyEndDisplayFlag = true
            isNextUpPage = false
            return
        }
        items = pagingItems + items
        updateInsertItems(pagingItems: pagingItems)
    }
    
    func downPaging() {
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
        updateInsertItems(pagingItems: pagingItems)
    }
    
    func updateInsertItems(pagingItems: [ItemDto]) {
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
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y > lastContentOffset {
            curScrollDirection = .DOWN
        } else if scrollView.contentOffset.y < lastContentOffset {
            curScrollDirection = .UP
        }
        
        if !initFlag && !isSearchFlag && isNextUpPage
        && scrollView.contentOffset.y <= scrollPreventHeight {
            if lastContentOffset <= scrollPreventHeight {
                lastContentOffset = scrollPreventHeight
            }
            
            // : Up Paging 시 scrollView.contentOffset.y <= 0 이 경우 Page 추가 시 Scroll Position 이 자동으로 Top 으로 이동한다.
            // : 아래 코드는 Up Paging 시 Scroll Position 을 유지하기 위한 용도 이다.
            scrollView.contentOffset = CGPoint(x: 0, y: lastContentOffset)
            upPaging()
        }
        
        lastContentOffset = scrollView.contentOffset.y
    }
}
