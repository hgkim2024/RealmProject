//
//  ViewController.swift
//  RealmProject
//
//  Created by 김현구 on 4/9/24.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        ItemRepository.shared.deleteAll()
        ItemRepository.shared.autoAdd(17)
        
//        ItemRepository.shared.printAll()
        printPagingFromStartToEnd()
//        printPagingFromLast()
    }

    func printPagingFromStartToEnd() {
        if let firstItem = ItemRepository.shared.getFirst(),
           var dtos = ItemRepository.shared.pagingFromStartToEnd(startItemDto: firstItem.toDto()) {
            
            while true {
                if let lastItem = dtos.last {
                    let pageDtos = ItemRepository.shared.pagingFromStartToEnd(startItemDto: lastItem) ?? []
                    if pageDtos.isEmpty == true {
                        break
                    }
                    dtos += pageDtos
                } else {
                    break
                }
            }
            
            ItemRepository.shared.printDtos(dtos)
        }
    }
    
    func printPagingFromEndToStart() {
        if let lastItem = ItemRepository.shared.getLast(),
           var dtos = ItemRepository.shared.pagingFromEndToStart(endItemDto: lastItem.toDto()) {
            
            while true {
                if let firstItem = dtos.last {
                    let pageDtos = ItemRepository.shared.pagingFromEndToStart(endItemDto: firstItem) ?? []
                    if pageDtos.isEmpty == true {
                        break
                    }
                    dtos += pageDtos
                } else {
                    break
                }
            }
            
            ItemRepository.shared.printDtos(dtos)
        }
    }
}

