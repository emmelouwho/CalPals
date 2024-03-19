//
//  ScheduleViewController.swift
//  CalPals
//
//  Created by Emily Erwin on 3/18/24.
//

import UIKit

public let times = [
    "12AM", "1AM", "2AM", "3AM", "4AM", "5AM", "6AM", "7AM",
    "8AM", "9AM", "10AM", "11AM", "12PM", "1PM", "2PM", "3PM",
    "4PM", "5PM", "6PM", "7PM", "8PM", "9PM", "10PM", "11PM"
]

public let days = [
    "Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"
]

class ScheduleViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var headerCollectionView: UICollectionView!
    
    let textCellIdentifier = "TextCell"
    let headerCollectionCellIndentifier = "HeaderCollectionCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.allowsMultipleSelection = true
        
        tableView.delegate = self
        tableView.dataSource = self
        
        collectionView.delegate = self
        
        collectionView.dataSource = self
        
        // delete border once im done
        headerCollectionView.layer.borderColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
        headerCollectionView.layer.borderWidth = 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 336
        // 24 hrs in a day and we want to select in 30 min intervals
        // we actually need 336 selectable cells bc 24 x 2 = 48 x 7 = 336
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CustomCollectionViewCell.reuseID, for: indexPath)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) {
            cell.contentView.backgroundColor = #colorLiteral(red: 0.721568644, green: 0.8862745166, blue: 0.5921568871, alpha: 1)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) {
            cell.contentView.backgroundColor = nil
        }
    }
    
    // change the table view to collection view?
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return times.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: textCellIdentifier, for: indexPath)
        let row = indexPath.row
        cell.textLabel?.text = times[row]
        cell.textLabel?.font = UIFont.systemFont(ofSize: 13)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let row = indexPath.row
        print(times[row])
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 43
    }

}
