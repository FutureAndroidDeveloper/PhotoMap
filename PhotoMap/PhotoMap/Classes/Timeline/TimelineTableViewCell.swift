//
//  TimelineTableViewCell.swift
//  PhotoMap
//
//  Created by Kiryl Klimiankou on 8/30/19.
//  Copyright © 2019 Kiryl Klimiankou. All rights reserved.
//

import UIKit

class TimelineTableViewCell: UITableViewCell {
    
    @IBOutlet weak var postView: TablePostView!
    
    // MARK: Properties
    static let reuseIdentifier = "Cell"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
