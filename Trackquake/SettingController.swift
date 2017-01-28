//
//  SettingController.swift
//  Trackquake
//
//  Created by Lawrence Chen on 12/28/16.
//  Copyright © 2016 Lawrence Chen. All rights reserved.
//

import UIKit



class SettingController: UIViewController, UITableViewDataSource, SegmentCellDelegate {
    @IBOutlet var tableView: UITableView!
    
    var magnitude: ViewController.Magnitude = .all
    var timeFrame: ViewController.TimeFrame = .day
    
    let cellsList = ["magnitude", "time"]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "segmented", for: indexPath) as! SegmentCell
        if cell.segmentDelegate == nil {
            cell.segmentDelegate = self
        }
        var items:[String] = ["1", "2", "3", "4"]
        let cellType = cellsList[indexPath.row]
        cell.celltype = cellType
        var selectedIndex:Int = 0
        cell.magnitude = magnitude
        cell.time = timeFrame
        
        switch cellType{
        case "magnitude":
            items = ["All", "2.5+", "4.5+", "Significant"]
            cell.label.text = "Magnitude"
            switch magnitude{
            case .all:
                selectedIndex = 0
            case .two:
                selectedIndex = 1
            case .four:
                selectedIndex = 2
            case .significant:
                selectedIndex = 3
            }
        case "time":
            items = ["Past Hour", "Past Day", "Past Week", "Past Month"]
            cell.label.text = "Time Frame"
            switch timeFrame{
            case .hour:
                selectedIndex = 0
            case .day:
                selectedIndex = 1
            case .week:
                selectedIndex = 2
            case .month:
                selectedIndex = 3
            }
        default:
            return cell
        }
        for x in 0...3{
            cell.segment.setTitle(items[x], forSegmentAt:x)
            cell.segment.setEnabled(true, forSegmentAt: x)
        }
        /*
        if(timeFrame == .month && cellType == "magnitude"){
            cell.segment.setEnabled(false, forSegmentAt: 0)
        }else if(magnitude == .all && cellType == "time"){
            cell.segment.setEnabled(false, forSegmentAt: 3)
        }
        */
        cell.segment.selectedSegmentIndex = selectedIndex
        return cell
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func segmentChange(cellType: String, magnitude: ViewController.Magnitude, time: ViewController.TimeFrame){
        if(cellType == "magnitude"){
            self.magnitude = magnitude
        }
        if(cellType == "time"){
            self.timeFrame = time
        }
        if(timeFrame == .month){
            
        }
        tableView.reloadData()
        print (self.magnitude)
        print (self.timeFrame)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let newView = segue.destination as! ViewController
        if (segue.identifier == "doneButton"){
            newView.magnitude = magnitude
            newView.timeFrame = timeFrame
        }
    }

}
