//
//  PagingCollectionViewCell.swift
//  RealmProject
//
//  Created by 김현구 on 4/18/24.
//

import Foundation
import UIKit

class PagingCollectionViewCell: UICollectionViewCell {
    
    let label: UILabel
    
    override init(frame: CGRect) {
        label = UILabel()
        super.init(frame: frame)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.textColor = .black
        
        addSubview(label)
        
        NSLayoutConstraint.activate([
            label.centerYAnchor.constraint(equalTo: centerYAnchor),
            label.leadingAnchor.constraint(equalTo: leadingAnchor),
            label.trailingAnchor.constraint(equalTo: trailingAnchor),
        ])
    }
    
    func setItem(item: ItemModel, searchItem: ItemModel?) {
        label.text = "\(item.number)"
        
        if item.isEqual(searchItem) {
            label.textColor = .white
            backgroundColor = .orange
        } else {
            label.textColor = .black
            backgroundColor = .clear
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
