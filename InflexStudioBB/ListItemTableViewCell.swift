//
//  ListItemTableViewCell.swift
//  InflexStudioBB
//
//  Created by Barczi Bálint on 2017. 08. 11..
//  Copyright © 2017. Barczi Bálint. All rights reserved.
//

import UIKit

class ListItemTableViewCell: UITableViewCell {
    
    @IBOutlet weak var bmiLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var weightLabel: UILabel!
    @IBOutlet weak var customImageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
       
        customImageView.layer.cornerRadius = customImageView.frame.height / 2
        customImageView.layer.masksToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
