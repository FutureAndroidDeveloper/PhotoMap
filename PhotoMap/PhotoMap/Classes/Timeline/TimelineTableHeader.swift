//
//  TimelineTableHeader.swift
//  PhotoMap
//
//  Created by Kiryl Klimiankou on 8/30/19.
//  Copyright © 2019 Kiryl Klimiankou. All rights reserved.
//

import UIKit

class TimelineTableHeader: UIView {
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var topSeparator: UIView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    private func setupView() {
        Bundle.main.loadNibNamed("TimelineTableHeader", owner: self, options: nil)
        contentView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(contentView)
        
        NSLayoutConstraint.activate([
            contentView.leadingAnchor.constraint(equalTo: leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: trailingAnchor),
            contentView.topAnchor.constraint(equalTo: topAnchor),
            contentView.bottomAnchor.constraint(equalTo: bottomAnchor)
            ])
    }
}
