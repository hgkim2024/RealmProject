# Realm Project

<br>

## Realm 객체 생성에 대한 분석
- [Realm 객체 생성에 대한 분석 글 링크](https://www.notion.so/let-realm-try-Realm-02ebd09fa9634a43bf1a7f242287cccc?pvs=21)

<br>

## Realm Pagination 분석
- [Realm Pagination 분석 글 링크](https://www.notion.so/Realm-Pagination-3b63ec13e03f4a2c9e762c7ccc085e7b?pvs=4)

<br>

### Pagination Test Code
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

