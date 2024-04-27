import UIKit

class ReportProductCell: UITableViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var quantityLabel: UILabel!
    
    var product = [String: Any]()

    func initCell() {
        nameLabel.text = (product["ProductName"] as? String) ?? "-"
        quantityLabel.text = String((product["Quantity"] as? Int) ?? 0)
    }
    
}
