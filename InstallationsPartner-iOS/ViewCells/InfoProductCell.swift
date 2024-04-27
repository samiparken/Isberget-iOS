import UIKit

class InfoProductCell: UITableViewCell {
    
    @IBOutlet weak var quantity: UILabel!
    @IBOutlet weak var productName: UILabel!
    @IBOutlet weak var productSKU: UILabel!

    var product = [String: Any]()
    
    func initCell() {
        productName.text = (product["ProductName"] as? String) ?? "-"
        productSKU.text = (product["ProductSKU"] as? String) ?? "-"
        quantity.text = String((product["Quantity"] as? Int) ?? 0)
    }
}
