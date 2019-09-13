//
//  CustomCalloutView.swift
//  PhotoMap
//
//  Created by Kiryl Klimiankou on 8/8/19.
//  Copyright © 2019 Kiryl Klimiankou. All rights reserved.
//

import UIKit

class CustomCalloutView: UIView {
    
    @IBOutlet weak var buttonCenterYConstraint: NSLayoutConstraint!
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var detailButton: UIButton!
    @IBOutlet weak var photoImage: UIImageView!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    private func commonInit() {
        _ = R.nib.customCalloutView(owner: self)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(contentView)
        
        NSLayoutConstraint.activate([
            contentView.leadingAnchor.constraint(equalTo: leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: trailingAnchor),
            contentView.topAnchor.constraint(equalTo: topAnchor),
            contentView.bottomAnchor.constraint(equalTo: bottomAnchor)
            ])
        
        contentView.layer.cornerRadius = 20
        contentView.layer.borderColor = UIColor.gray.cgColor
        contentView.layer.borderWidth = 1
    }

    func setupViewForAdmin() {
        buttonCenterYConstraint.constant = -15
        editButton.isHidden = false
        deleteButton.isHidden = false
        layoutIfNeeded()
    }
}
