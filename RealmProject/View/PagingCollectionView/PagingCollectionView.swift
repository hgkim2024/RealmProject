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
    var isLoadingPage: Bool
    var lastContentOffset: CGFloat = 0
    var curScrollDirection: CollectionViewScrollDirection = .NONE
    var searchItem: ItemDto? = nil
    var initFlag = true
    var isSearchFlag = false
    let cellHeight: CGFloat = 45.0
    let scrollPreventHeight: CGFloat
    var isNextUpPage: Bool = true
    
    var isScrolledToBottom: Bool {
        return contentSize.height <= contentOffset.y + bounds.height + cellHeight
    }
    
    var isEqualCollectionViewItemSize: Bool {
        let lastSection = numberOfSections
        Log.tag(.PAGING).d("isEqual: \(lastSection == items.count), lastSection: \(lastSection), item count: \(items.count)")
        return lastSection == items.count
    }
    
    init(startPagingPosition: PagingPosition) {
        self.startPagingPosition = startPagingPosition
        isLoadingPage = startPagingPosition != .BOTTOM
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
        
        initFlag = false
    }
    
    // : Search - 검색 시 새로운 페이지로 로딩 -> 데이터가 많은 경우에 바로 로딩하기 위함
    func searchItem(item: ItemDto?) {
        isLoadingPage = false
        isSearchFlag = true
        isNextUpPage = true
        searchItem = item
        
        if let item {
            items = ItemManager.shared.getCollectionViewPagingItem(position: .CENTER, criteriaItem: item)
        }
        
        reloadData()
        
        if let item, let index = items.firstIndex(of: item) {
            scrollToItem(at: IndexPath(row: 0, section: index), at: .centeredVertically, animated: false)
//            layoutIfNeeded()
        }
        
        isSearchFlag = false
        isLoadingPage = true
    }
}

extension PagingCollectionView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return items.count
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        numberOfItemsInSection section: Int
    ) -> Int {
        return 1
    }
    
    func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath
    ) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PagingCollectionViewCell.identifier, for: indexPath) as! PagingCollectionViewCell
        cell.setItem(item: items[indexPath.section], searchItem: searchItem)
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
        if !isLoadingPage { return }
        if curScrollDirection == .NONE { return }
        
        if indexPath.section >= items.count - ItemManager.shared.countPerPage + 1
            && curScrollDirection == .DOWN {
            downPaging()
        } else if indexPath.section <= ItemManager.shared.countPerPage - 1
                    && curScrollDirection == .UP {
            upPaging()
        }
    }
    
    func upPaging() {
        Log.tag(.PAGING).d("upPaging")
        isLoadingPage = false
        if items.isEmpty { return }
        let startItem = items[0]
        let pagingItems = ItemManager.shared.getCollectionViewPagingItem(position: .BOTTOM, criteriaItem: startItem)
        if pagingItems.isEmpty {
            isLoadingPage = true
            isNextUpPage = false
            return
        }
        items.insert(contentsOf: pagingItems, at: 0)
        updateInsertItems(pagingItems: pagingItems)
    }
    
    func downPaging() {
        Log.tag(.PAGING).d("downPaging")
        isLoadingPage = false
        if items.isEmpty { return }
        if !isEqualCollectionViewItemSize { // : 새로운 Message 가 들어와 items 는 갱신 되었지만 CollectionView 에 갱신되지 않은 경우
            let startIndex = numberOfSections
            let endIndex = items.count - 1
            updateInsertItems(startIndex: startIndex, endIndex: endIndex)
            return
        }
        let endItem = items[items.count - 1]
        let pagingItems = ItemManager.shared.getCollectionViewPagingItem(position: .TOP, criteriaItem: endItem)
        if pagingItems.isEmpty {
            isLoadingPage = true
            return
        }
        items.append(contentsOf: pagingItems)
        updateInsertItems(pagingItems: pagingItems)
    }
    
    func updateInsertItems(pagingItems: [ItemDto]) {
        if pagingItems.isEmpty { return }
        if isEqualCollectionViewItemSize { return }
        if let startIndex = items.firstIndex(of: pagingItems.first!),
           let endIndex = items.firstIndex(of: pagingItems.last!){
            updateInsertItems(startIndex: startIndex, endIndex: endIndex)
        }
    }
    
    func updateInsertItems(startIndex: Int, endIndex: Int) {
        if isEqualCollectionViewItemSize { return }
        Log.tag(.PAGING).d("startIndex: \(startIndex), endIndex: \(endIndex)")
        performBatchUpdates { [weak self] in
            self?.insertSections(IndexSet(Array(startIndex...endIndex)))
        } completion: { [weak self] _ in
            self?.isLoadingPage = true
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y > lastContentOffset || contentSize.height <= contentOffset.y + bounds.height + cellHeight {
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
