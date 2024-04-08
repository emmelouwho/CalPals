//
//  CreateEventViewController.swift
//  CalPals
//
//  Created by Emily Erwin on 3/13/24.
//

import UIKit

class CreateEventViewController: UIViewController, LocationChanger {
    var newEvent = Event()
    
    // MARK: - labels
    @IBOutlet weak var groupLabel: UILabel!
    @IBOutlet weak var latestLabel: UILabel!
    @IBOutlet weak var earliestLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    
    // MARK: - buttons
    @IBOutlet weak var groupButton: UIButton!
    @IBOutlet weak var earliestButton: UIButton!
    @IBOutlet weak var latestButton: UIButton!
    @IBOutlet weak var durationButton: UIButton!
    
    //MARK: - text fields
    @IBOutlet weak var eventNameTextField: UITextField!
    @IBOutlet weak var descriptionTextField: UITextField!
    
    //MARK: - switches
    @IBOutlet weak var mondaySwitch: UISwitch!
    @IBOutlet weak var tuesdaySwitch: UISwitch!
    @IBOutlet weak var wednesdaySwitch: UISwitch!
    @IBOutlet weak var thursdaySwitch: UISwitch!
    @IBOutlet weak var fridaySwitch: UISwitch!
    @IBOutlet weak var saturdaySwitch: UISwitch!
    @IBOutlet weak var sundaySwitch: UISwitch!
    
    // MARK: - main
    override func viewDidLoad() {
        newEvent = Event()
        
        // reseting all info
        eventNameTextField.text = ""
        descriptionTextField.text = ""
        locationLabel.text = "Location"
        
        // styling added
        addBorder(label: groupLabel)
        addBorder(label: latestLabel)
        addBorder(label: earliestLabel)
        addBorder(label: locationLabel)
        addBorder(label: durationLabel)
        
        // all menu button set up
        timeConstaintsSetUp(defaultTime: "12AM", button: earliestButton, optionClosure: {(action: UIAction) in self.newEvent.noEarlierThan = action.title})
        timeConstaintsSetUp(defaultTime: "11PM", button: latestButton,  optionClosure: {(action: UIAction) in self.newEvent.noLaterThan = action.title})
        groupSetUp()
        durationSetUp()
    }
    
    //MARK: - setup and formatting
    func addBorder(label: UILabel){
        label.layer.borderWidth = 1.0
        label.layer.borderColor = UIColor.systemGray6.cgColor
        label.layer.cornerRadius = 5.0
        label.clipsToBounds = true
    }
    
    func timeConstaintsSetUp(defaultTime: String, button: UIButton, optionClosure: @escaping UIActionHandler) {
        let actions = allTimes.reversed().map { title in
            if title == defaultTime {
                UIAction(title: title, state: .on, handler: optionClosure)
            } else {
                UIAction(title: title, handler: optionClosure)
            }
        }
        
        button.menu = UIMenu(children: actions)
    }
    
    func groupSetUp() {
        let optionClosure = {(action: UIAction) in print(action.title)}
        let groupOptions = ["group 1", "group 2", "group 3"]
        let actions = groupOptions.map { title in
            UIAction(title: title, handler: optionClosure)
        }
        
        groupButton.menu = UIMenu(children: actions)
    }
    
    func durationSetUp() {
        let optionClosure = {(action: UIAction) in print(action.title)}
        
        var timeList: [String] = []
        for hour in 0..<48 {
            if hour % 2 == 0 {
                if hour > 0 {
                    timeList.append("\(hour/2) hr")
                }
            } else {
                if hour > 1 {
                    timeList.append("\(hour/2) hr 30 min")
                } else {
                    timeList.append("30 min")
                }
            }
        }
        
        let durationOptions = timeList.reversed().map {  title in
            if title == "30 min" {
                UIAction(title: title, state: .on, handler: optionClosure)
            } else {
                UIAction(title: title, handler: optionClosure)
            }
        }
        durationButton.menu = UIMenu(children: durationOptions)
    }

    // MARK: - Button Pressed
    @IBAction func createEventButtonPressed(_ sender: Any) {
        newEvent.setBasic(name: eventNameTextField.text, location: locationLabel.text, group: groupButton.title(for: .normal), description: descriptionTextField.text, duration: durationButton.title(for: .normal) ?? "")
        newEvent.setDays(mon: mondaySwitch.isOn, tue: tuesdaySwitch.isOn, wed: wednesdaySwitch.isOn, thu: thursdaySwitch.isOn, fri: fridaySwitch.isOn, sat: saturdaySwitch.isOn, sun: sundaySwitch.isOn)
        
        let errorMessage = newEvent.validateEvent()
        if errorMessage != "" {
            let controller = UIAlertController(title: "Error Creating Event", message: errorMessage, preferredStyle: .alert)
            controller.addAction(UIAlertAction(title: "OK", style: .default))
            present(controller,animated: true)
        } else {
            let controller = UIAlertController(title: "Event Successfully Created!", message: newEvent.eventCreatedMessage(), preferredStyle: .alert)
            controller.addAction(UIAlertAction(title: "OK", style: .default) {_ in self.viewDidLoad()})
            present(controller,animated: true)
        }
        
    }
    
    // MARK: - handle segue for location
    func changeLocation(newLoc: String) {
        locationLabel.text = " \(newLoc)"
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "locationSegue",
           let destination = segue.destination as? LocationPickerViewController {
            destination.delegate = self
        }
            
    }
}
