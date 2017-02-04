//
//  EarthquakeCell.swift
//  Trackquake
//
//  Created by Lawrence Chen on 1/11/17.
//  Copyright © 2017 Lawrence Chen. All rights reserved.
//

import UIKit

class EarthquakeCell: UITableViewCell {

    @IBOutlet var mainLabel: UILabel!
    @IBOutlet var locationLabel: UILabel!
    @IBOutlet var timeLabel: UILabel!
    @IBOutlet var magLabel: UILabel!
    var coordinates: [Double] = [0, 0];
    var idString: String = "";
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
