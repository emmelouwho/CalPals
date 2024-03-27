//
//  ScheduleTableViewCell.swift
//  CalPals
//
//  Created by Emily Erwin on 3/26/24.
//

import Foundation
import UIKit

class ScheduleTableViewCell: UITableViewCell {
    var timeSlots: [UIView] = []
    var timeLabel: UILabel!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        setupTimeLabel()
        setupTimeSlots()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        selectionStyle = .none
        setupTimeLabel()
        setupTimeSlots()
    }
    
    private func setupTimeLabel() {
        timeLabel = UILabel()
        timeLabel.textAlignment = .left
        contentView.addSubview(timeLabel)
        
        // Layout constraints for the timeLabel
        timeLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            timeLabel.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 16),
            timeLabel.topAnchor.constraint(equalTo: contentView.topAnchor),
            timeLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            timeLabel.widthAnchor.constraint(equalToConstant: 40) // Set your desired width
        ])
    }
    
    
    private func setupTimeSlots() {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.alignment = .fill
        stackView.spacing = 0
        contentView.addSubview(stackView)
        
        // Layout constraints for the stackView
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.leftAnchor.constraint(equalTo: timeLabel.rightAnchor, constant: 8),
            stackView.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -16),
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
        
        // Creating time slots
        for _ in 0..<7 { 
            let slotView = UIView()
            slotView.layer.borderWidth = 1
            slotView.layer.borderColor = UIColor.lightGray.cgColor
            slotView.isUserInteractionEnabled = true
            stackView.addArrangedSubview(slotView)
            timeSlots.append(slotView)
        }
    }
    
    func timeSlotIndex(at location: CGPoint) -> Int? {
        for (index, slotView) in timeSlots.enumerated() {
            // Convert the slotView's frame to the cell's coordinate system
            let slotViewFrame = slotView.convert(slotView.bounds, to: contentView)
            
            // Check if the location of the gesture is within the slotView's frame
            if slotViewFrame.contains(location) {
                return index
            }
        }
        return nil
    }
    
    func configureWithHighlights(_ highlights: Set<Int>) {
        for (index, slotView) in timeSlots.enumerated() {
            if highlights.contains(index) {
                slotView.backgroundColor = .green
            } else {
                slotView.backgroundColor = .clear
            }
        }
    }
}
