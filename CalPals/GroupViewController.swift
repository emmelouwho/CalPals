//
//  GroupViewController.swift
//  CalPals
//
//  Created by Richie Wahidin on 4/2/24.
//

import UIKit
import CoreData

let appDelegate = UIApplication.shared.delegate as! AppDelegate
let context = appDelegate.persistentContainer.viewContext

protocol CreateGroupDelegate : AnyObject {
    func addGroup(groupImage:UIImage, groupName: String, events:[String], groupDescription: String)
}

class GroupViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CreateGroupDelegate {
    
//    class GroupTableViewCell: UITableViewCell {
//        var groupImage: UIImageView!
//        var groupName: UILabel!
//        var groupUpcomingEvents: UITableView!
//        var events: [String] = [] // Array to hold event names
//        
//        override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
//            super.init(style: style, reuseIdentifier: reuseIdentifier)
//            
//            groupImage = UIImageView()
//            groupName = UILabel()
//            groupUpcomingEvents = UITableView()
//            
//            contentView.addSubview(groupImage)
//            contentView.addSubview(groupName)
//            contentView.addSubview(groupUpcomingEvents)
//            
//            setupConstraints()
//        }
//        
//        required init?(coder aDecoder: NSCoder) {
//            super.init(coder: aDecoder)
//        }
//        
//        private func setupConstraints() {
//            // Add constraints for groupImage, groupName, and groupUpcomingEvents
//            // For example:
//            groupImage.translatesAutoresizingMaskIntoConstraints = false
//            groupName.translatesAutoresizingMaskIntoConstraints = false
//            groupUpcomingEvents.translatesAutoresizingMaskIntoConstraints = false
//            
//            NSLayoutConstraint.activate([
//                groupImage.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
//                groupImage.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
//                groupImage.widthAnchor.constraint(equalToConstant: 50),
//                groupImage.heightAnchor.constraint(equalToConstant: 50),
//                
//                groupName.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
//                groupName.leadingAnchor.constraint(equalTo: groupImage.trailingAnchor, constant: 8),
//                groupName.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
//                
//                groupUpcomingEvents.topAnchor.constraint(equalTo: groupName.bottomAnchor, constant: 8),
//                groupUpcomingEvents.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
//                groupUpcomingEvents.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
//                groupUpcomingEvents.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8)
//            ])
//        }
//        
//        override func layoutSubviews() {
//            super.layoutSubviews()
//            groupImage.layer.cornerRadius = groupImage.frame.size.width / 2
//            groupImage.clipsToBounds = true
//        }
//    }
    
//    class NoGroupsCell: UITableViewCell {
//        override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
//            super.init(style: style, reuseIdentifier: reuseIdentifier)
//            setupCell()
//        }
//        required init?(coder aDecoder: NSCoder) {
//            super.init(coder: aDecoder)
//            setupCell()
//        }
//        private func setupCell() {
//            textLabel?.text = "You are in no groups. Please create one or join via an invite link."
//            textLabel?.textAlignment = .center
//            textLabel?.numberOfLines = 0
//        }
//    }

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var noGroupsLabel: UILabel!
    
    var groupList:[NSManagedObject] = []
    var selectedCellIndexPath: IndexPath?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        tableView.dataSource = self
        tableView.delegate = self
        
        groupList = retrieveGroups()
        tableView.reloadData()
        tableView.rowHeight = 120
        
        // Create a UIBarButtonItem with a plus icon
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonTapped))
        // Set the UIBarButtonItem as the rightBarButtonItem of the navigation item
        navigationItem.rightBarButtonItem = addButton
        
        groupList = retrieveGroups()
        if groupList.isEmpty {
            noGroupsLabel.isHidden = false
        } else {
            noGroupsLabel.isHidden = true
        }
        tableView.reloadData()
    }
    
    func addGroup(groupImage: UIImage, groupName: String, events: [String], groupDescription: String) {
        let group = NSEntityDescription.insertNewObject(forEntityName: "GroupEntity", into: context)
        if let imageData = groupImage.pngData() {
            group.setValue(imageData, forKey: "groupImage")
        }
        group.setValue(groupName, forKey: "groupName")
        group.setValue(groupDescription, forKey: "groupDescription")
        group.setValue(events, forKey: "events")
        
        saveContext()
        groupList = retrieveGroups()
        if groupList.isEmpty {
            noGroupsLabel.isHidden = false
        } else {
            noGroupsLabel.isHidden = true
        }
        tableView.reloadData()
    }
    
    func retrieveGroups() -> [NSManagedObject] {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "GroupEntity")
        var fetchedResults:[NSManagedObject]? = nil
        do {
            try fetchedResults = context.fetch(request) as? [NSManagedObject]
        } catch {
                print("Error with retrieving data")
                abort()
        }
        return (fetchedResults)!
    }

    @objc func addButtonTapped() {
        // Perform segue to the destination view controller
        performSegue(withIdentifier: "CreateGroupSegue", sender: self)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groupList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GroupCell", for: indexPath)
        let group = groupList[indexPath.row] as! GroupEntity
        cell.textLabel?.text = group.groupName
        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 75, height: 75)) // Adjust the frame as needed
            if let imageData = group.groupImage, let image = UIImage(data: imageData) {
                imageView.image = image
            }
            imageView.layer.cornerRadius = imageView.frame.width / 2 // Make it a circle
            imageView.clipsToBounds = true // Clip to bounds
            cell.accessoryView = imageView // Set the image view as the accessory view of the cell
            return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            context.delete(groupList[indexPath.row])
            groupList.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            saveContext()
            if groupList.isEmpty {
                noGroupsLabel.isHidden = false
            } else {
                noGroupsLabel.isHidden = true
            }
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
    }

    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if selectedCellIndexPath == indexPath {
            selectedCellIndexPath = nil
        } else {
            selectedCellIndexPath = indexPath
        }
        tableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "CreateGroupSegue",
            let destination = segue.destination as? CreateGroupViewController
        {
            destination.delegate = self
        }
    }

    func saveContext () {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}
