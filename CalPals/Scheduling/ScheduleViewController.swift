//
//  ScheduleViewController.swift
//  CalPals
//
//  Created by Emily Erwin on 3/18/24.
//

import UIKit
import FirebaseDatabase
import FirebaseAuth

class ScheduleViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    var activityIndicator: UIActivityIndicatorView!
    var availabilityModel = AvailabilityModel()
    var isInitiallyHighlighting: Bool = true
    var lastToggledIndexPath: IndexPath?
    var lastToggledSlot: Int?
    
    let textCellIdentifier = "TextCell"
    let headerCollectionCellIndentifier = "HeaderCollectionCell"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.rowHeight = 30.0
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        
        // add gesture for table selection
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPressGesture(_:)))
        tableView.addGestureRecognizer(longPressGesture)
        
        // while loading data from firebase, show loading indicator and hide table
        activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator.center = self.view.center
        self.view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        tableView.isHidden = true
        
        // if we have a current user, go get their scheduling data from the database
        if let user = Auth.auth().currentUser {
            let uid = user.uid
            availabilityModel.addFirebaseDataToCurrent(forUser: uid) {
                [weak self]  in
                guard let strongSelf = self else { return }
                strongSelf.tableView.reloadData()
                strongSelf.activityIndicator.stopAnimating()
                strongSelf.tableView.isHidden = false
            }
        } else {
            activityIndicator.stopAnimating()
            tableView.isHidden = false
        }
    }
    
    func createHeaderView() -> UIView {
        let headerView = UIView()
        headerView.backgroundColor = .lightGray
        
        let stackView = UIStackView()
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        // Add day labels to the stack view
        for day in days {
            let label = UILabel()
            label.text = day
            label.textAlignment = .center
            stackView.addArrangedSubview(label)
        }
        headerView.addSubview(stackView)
        
        // Set stackView constraints
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: headerView.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: headerView.bottomAnchor),
            stackView.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 60),
            stackView.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -15)
        ])
        
        return headerView
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 48
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: textCellIdentifier, for: indexPath) as! ScheduleTableViewCell

        let hour24 = indexPath.row / 2
        var hour = hour24 > 12 ? hour24 - 12 : hour24
        if hour == 0 {
            hour = 12
        }
        let timeOfDay = hour24 < 12 ? "AM" : "PM"
        
        if indexPath.row % 2 == 0 {
            cell.timeLabel.text = String("\(hour) \(timeOfDay)")
        } else {
            cell.timeLabel.text = ""
        }
        
        cell.timeLabel?.font = UIFont.systemFont(ofSize: 13)
        
        let highlights = availabilityModel.highlightsForIndexPath(indexPath)
        cell.configureWithHighlights(highlights)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return createHeaderView()
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    @objc func handleLongPressGesture(_ gesture: UIGestureRecognizer) {
        let location = gesture.location(in: tableView)
        if let indexPath = tableView.indexPathForRow(at: location),
           let cell = tableView.cellForRow(at: indexPath) as? ScheduleTableViewCell {
            let cellLocation = tableView.convert(location, to: cell)
            
            if gesture.state == .began {
                if let slotIndex = cell.timeSlotIndex(at: cellLocation) {
                    // Determine the initial action based on the slot's current state
                    isInitiallyHighlighting = !availabilityModel.isSlotHighlighted(at: indexPath, slot: slotIndex)
                    availabilityModel.toggleHighlight(at: indexPath, slot: slotIndex)
                    lastToggledIndexPath = indexPath
                    lastToggledSlot = slotIndex
                    tableView.reloadRows(at: [indexPath], with: .none)
                }
            } else if gesture.state == .changed {
                if let slotIndex = cell.timeSlotIndex(at: cellLocation),
                   !(indexPath == lastToggledIndexPath && slotIndex == lastToggledSlot) {
                    // Only toggle if we've moved to a new slot
                    if isInitiallyHighlighting {
                        availabilityModel.highlightSlot(at: indexPath, slot: slotIndex)
                    } else {
                        availabilityModel.removeHighlight(at: indexPath, slot: slotIndex)
                    }
                    lastToggledIndexPath = indexPath
                    lastToggledSlot = slotIndex
                    tableView.reloadRows(at: [indexPath], with: .none)
                }
            } else if gesture.state == .ended || gesture.state == .cancelled {
                // Reset tracking properties
                lastToggledIndexPath = nil
                lastToggledSlot = nil
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let user = Auth.auth().currentUser {
            let uid = user.uid
            availabilityModel.storeDataInFireBase(forUser: uid)
        }
    }
}
