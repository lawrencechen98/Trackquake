//
//  SegmentCell.swift
//  Trackquake
//
//  Created by Lawrence Chen on 12/29/16.
//  Copyright © 2016 Lawrence Chen. All rights reserved.
//

import UIKit

protocol SegmentCellDelegate {
    func segmentChange(cellType: String, magnitude: ViewController.Magnitude, time: ViewController.TimeFrame)
}

class SegmentCell: UITableViewCell {

    @IBOutlet var label: UILabel!
    @IBOutlet var segment: UISegmentedControl!
    var segmentDelegate: SegmentCellDelegate?
    
    var magnitude:ViewController.Magnitude = .all
    var time: ViewController.TimeFrame = .month
    var celltype = "magnitude"

    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    @IBAction func segmentChanged(_ sender: UISegmentedControl) {
        
        if (celltype == "magnitude"){
            switch segment.selectedSegmentIndex{
            case 0:
                magnitude = .all
            case 1:
                magnitude = .two
            case 2:
                magnitude = .four
            case 3:
                magnitude = .significant
            default:
                return
            }
        }
        if (celltype == "time"){
            switch segment.selectedSegmentIndex{
            case 0:
                time = .hour
            case 1:
                time = .day
            case 2:
                time = .week
            case 3:
                time = .month
            default:
                return
            }
        }
        if let delegate = segmentDelegate {
            delegate.segmentChange(cellType: celltype, magnitude: magnitude, time: time)
        }
    }


    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
