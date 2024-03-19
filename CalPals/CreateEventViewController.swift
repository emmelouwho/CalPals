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
    @IBOutlet weak var startLabel: UILabel!
    @IBOutlet weak var repeatsLabel: UILabel!
    @IBOutlet weak var latestLabel: UILabel!
    @IBOutlet weak var earliestLabel: UILabel!
    @IBOutlet weak var endLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    
    // MARK: - buttons
    @IBOutlet weak var groupButton: UIButton!
    @IBOutlet weak var repeatButton: UIButton!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var endButton: UIButton!
    @IBOutlet weak var noLaterButton: UIButton!
    @IBOutlet weak var noEarlierButton: UIButton!
    
    //MARK: - text fields
    @IBOutlet weak var eventNameTextField: UITextField!
    @IBOutlet weak var descriptionTextField: UITextField!
    @IBOutlet weak var durationTextField: UITextField!
    
    // MARK: - main
    override func viewDidLoad() {
        newEvent = Event()
        
        // reseting all info
        eventNameTextField.text = ""
        descriptionTextField.text = ""
        durationTextField.text = ""
        groupButton.setTitle("", for: .normal)
        repeatButton.setTitle("Never", for: .normal)
        
        startButton.setTitle(formatDate(date: Date()), for: .normal)
        endButton.setTitle(formatDate(date: Date()), for: .normal)
        noLaterButton.setTitle(formatTime(date: Date()), for: .normal)
        noEarlierButton.setTitle(formatTime(date: Date()), for: .normal)
        
        // styling added
        addBorder(label: groupLabel)
        addBorder(label: startLabel)
        addBorder(label: repeatsLabel)
        addBorder(label: latestLabel)
        addBorder(label: earliestLabel)
        addBorder(label: endLabel)
        addBorder(label: locationLabel)
    }
    
    func addBorder(label: UILabel){
        label.layer.borderWidth = 1.0
        label.layer.borderColor = UIColor.systemGray6.cgColor
        label.layer.cornerRadius = 5.0
        label.clipsToBounds = true
    }

    // MARK: - Button Pressed
    @IBAction func groupButtonPressed(_ sender: Any) {
        let controller = UIAlertController(title: "Select group", message: "Please choose a group for this event to be assigned to", preferredStyle: .actionSheet)
        
        //TODO: replace once state is added for each user
        let groupOptions = ["group 1", "group 2", "group 3"]
        for group in groupOptions {
            controller.addAction(UIAlertAction(title: group, style: .default, handler: {action in self.groupButton.setTitle(action.title, for: .normal)}))
        }
        present(controller,animated: true)
    }
    
    @IBAction func repeatButtonPressed(_ sender: Any) {
        let controller = UIAlertController(title: "Select one", message: "Please choose how often you would like for this to repeat", preferredStyle: .actionSheet)
        
        for option in repeatOptions {
            controller.addAction(UIAlertAction(title: option, style: .default, handler: {action in self.repeatButton.setTitle(action.title, for: .normal)}))
        }
        present(controller,animated: true)
    }

    @IBAction func startButtonPressed(_ sender: Any) {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.addTarget(self, action: #selector(startDateChange(datePicker: )), for: UIControl.Event.valueChanged)
        let controller = getDateAlert(datePicker: datePicker)
        present(controller, animated: true, completion: nil)
    }
    
    @IBAction func endButtonPressed(_ sender: Any) {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.addTarget(self, action: #selector(endDateChange(datePicker: )), for: UIControl.Event.valueChanged)
        let controller = getDateAlert(datePicker: datePicker)
        present(controller, animated: true, completion: nil)
    }
    
    
    @IBAction func noEarlierButtonPressed(_ sender: Any) {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .time
        datePicker.addTarget(self, action: #selector(noEarlierDateChange(datePicker: )), for: UIControl.Event.valueChanged)
        let controller = getDateAlert(datePicker: datePicker)
        present(controller, animated: true, completion: nil)
    }
    
    @IBAction func noLaterButtonPressed(_ sender: Any) {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .time
        datePicker.addTarget(self, action: #selector(noLaterDateChange(datePicker: )), for: UIControl.Event.valueChanged)
        let controller = getDateAlert(datePicker: datePicker)
        present(controller, animated: true, completion: nil)
    }
    
    @IBAction func createEventButtonPressed(_ sender: Any) {
        newEvent.setBasic(name: eventNameTextField.text, location: locationLabel.text, group: groupButton.title(for: .normal), description: descriptionTextField.text, repeats: repeatButton.title(for: .normal), duration: durationTextField.text ?? "")
        
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
    
    // MARK: - Make date alert scroller
    func getDateAlert(datePicker: UIDatePicker) -> UIAlertController {
        let alertController = UIAlertController(title: "\n\n\n\n\n\n\n\n\n", message: nil, preferredStyle: .actionSheet)
        
        datePicker.preferredDatePickerStyle = .wheels
        alertController.view.addSubview(datePicker)
        
        alertController.addAction(UIAlertAction(title: "Select", style: .default) { _ in
            print("Selected Date: \(datePicker.date)")
        })
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        return alertController
    }
    
    // MARK: - Date Changers
    @objc func startDateChange(datePicker: UIDatePicker){
        newEvent.startDate = datePicker.date
        startButton.setTitle(formatDate(date: datePicker.date), for: .normal)
    }
    
    @objc func endDateChange(datePicker: UIDatePicker){
        newEvent.endDate = datePicker.date
        endButton.setTitle(formatDate(date: datePicker.date), for: .normal)
    }
    
    @objc func noEarlierDateChange(datePicker: UIDatePicker){
        newEvent.noEarlierThan = datePicker.date
        noEarlierButton.setTitle(formatTime(date: datePicker.date), for: .normal)
    }
    
    @objc func noLaterDateChange(datePicker: UIDatePicker){
        newEvent.noLaterThan = datePicker.date
        noLaterButton.setTitle(formatTime(date: datePicker.date), for: .normal)
    }
    
    
    // MARK: - Formatters
    func formatTime(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
    
    func formatDate(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd yyyy"
        return formatter.string(from: date)
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
