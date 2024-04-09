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
        printPagingFromStart()
//        printPagingFromLast()
    }

    func printPagingFromStart() {
        if let firstItem = ItemRepository.shared.getFirst(),
           var dtos = ItemRepository.shared.pagingFromStart(startItemDto: firstItem.toDto()) {
            
            while true {
                if let lastItem = dtos.last {
                    let pageDtos = ItemRepository.shared.pagingFromStart(startItemDto: lastItem) ?? []
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
    
    func printPagingFromLast() {
        if let lastItem = ItemRepository.shared.getLast(),
           var dtos = ItemRepository.shared.pagingFromLast(endItemDto: lastItem.toDto()) {
            
            while true {
                if let firstItem = dtos.last {
                    let pageDtos = ItemRepository.shared.pagingFromLast(endItemDto: firstItem) ?? []
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

