/*
See LICENSE folder for this sample’s licensing information.

Abstract:
A custom cell view cell that has a red background by default, and a blue background when selected.
*/

import UIKit

/// - Tag: custom-collection-view-cell
class CustomCollectionViewCell: UICollectionViewCell {
    
    static public let reuseID = "CustomCollectionViewCell"
    @IBOutlet var iconView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let unselectedView = UIView(frame: bounds)
        unselectedView.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1) // change to white later
        unselectedView.layer.borderColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
        unselectedView.layer.borderWidth = 1

        self.backgroundView = unselectedView

        let selectedView = UIView(frame: bounds)
        selectedView.backgroundColor = #colorLiteral(red: 0.3411764801, green: 0.6235294342, blue: 0.1686274558, alpha: 1)
        self.selectedBackgroundView = selectedView
    }
}
