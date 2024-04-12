# Realm Project

<br>

## Realm 객체 생성에 대한 분석
- [Realm 객체 생성에 대한 분석 글 링크](https://www.notion.so/let-realm-try-Realm-02ebd09fa9634a43bf1a7f242287cccc?pvs=21)

<br>

## Realm Pagination 분석
- [Realm Pagination 분석 글 링크](https://www.notion.so/Realm-Pagination-3b63ec13e03f4a2c9e762c7ccc085e7b?pvs=4)

<br>

### Realm Pagination Test Code
- <code>ItemManager.testPaging()</code>
- 테스트 절차
    - n 개  데이터 생성
    - 정렬된 n 개 데이터 에서 m 개 씩 읽어와 k 번 출력

```Swift
// MARK: - n 개 데이터가 있을 때
let createSize = 100000

// MARK: - n 개 데이터 생성
ItemRepository.shared.autoAdd(createSize)

// MARK: - test paging 
printPagingFromStartToEnd()
//        printPagingFromEndToStart()
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
