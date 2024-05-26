# Realm Structure

<br>

## Realm 객체 생성에 대한 분석
- [Realm 객체 생성에 대한 분석 글 링크](https://www.notion.so/let-realm-try-Realm-02ebd09fa9634a43bf1a7f242287cccc?pvs=21)

<br>

## Realm Pagination 분석
- [Realm Pagination 분석 글 링크](https://www.notion.so/Realm-Pagination-3b63ec13e03f4a2c9e762c7ccc085e7b?pvs=4)

<br>

## CollectionView 와 Realm 을 이용한 Pagination 테스트
- [CollectionView Paging 설명 글](https://www.notion.so/CollectionView-Paging-879f83aaa79c43c99262248db314984b?pvs=4)
- PagingCollectionView 생성 시 startPagingPosition 을 top, bottom 으로 설정할 수 있다.
- top 은 아래로 페이징(일반 게시글 페이징), bottom 은 위로 페이징(채팅방 페이징)이다.
```swift
let collectionView = PagingCollectionView(startPagingPosition: .BOTTOM)
```

<br>

- Collection View Search Paging
```swift
extension PagingCollectionViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let searchText = searchController.searchBar.text else { return }
        Log.tag(.DB).tag(.SEARCH).d(searchText)
        let itemDto = ItemManager.shared.getItem(number: Int(searchText) ?? -1)
        collectionView.searchItem(item: itemDto)
    }
}
```

<br>

- searchItem
    - Search 시 성능 개선을 위해 Search Item 위치에 새로운 페이지로 로딩한다.
```swift
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
```

<br>

## Realm Notification Token
- [Realm Notification Token 설명 글](https://www.notion.so/Realm-Notification-Token-1b4b652aa5c4471298a0015063a1e0f0?pvs=4)
- 아래 Class 를 이용하여 Notifcation Token 을 등록하면 설정된 Table 의 CRUD Event 를 받을 수 있다.

```swift
class RealmTokenWorker<T: Object>: RealmBackgroundWorker {
    private var token: NotificationToken?
    
    init(_ query: @escaping () -> Results<T>?,_ keyPaths: [String]? = nil, _ block: @escaping (RealmCollectionChange<Results<T>>) -> Void) {
        super.init()
        start { [weak self] in
            self?.token = query()?.observe(keyPaths: keyPaths, block)
        }
    }

    deinit {
      token?.invalidate()
    }
}
```

<br>
