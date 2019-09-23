//
//  CategoryMarker.swift
//  PhotoMap
//
//  Created by Kiryl Klimiankou on 9/16/19.
//  Copyright © 2019 Kiryl Klimiankou. All rights reserved.
//

import UIKit

class CategoryMarker: UIView {
    
    @IBOutlet weak var mainImageView: UIImageView!
    @IBOutlet var contentView: UIView!
    
    var color: UIColor = .black {
        didSet {
            recolor()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
        recolor()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
        recolor()
    }
    
    private func setupView() {
        Bundle.main.loadNibNamed("CategoryMarker", owner: self, options: nil)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.backgroundColor = .clear
        addSubview(contentView)
        
        NSLayoutConstraint.activate([
            contentView.leadingAnchor.constraint(equalTo: leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: trailingAnchor),
            contentView.topAnchor.constraint(equalTo: topAnchor),
            contentView.bottomAnchor.constraint(equalTo: bottomAnchor)
            ])
    }
    
    private func recolor() {
        let templateImage = mainImageView.image?.withRenderingMode(.alwaysTemplate)
        mainImageView.image = templateImage
        mainImageView.tintColor = color
    }
}

