import UIKit
import SwipeCellKit

class JobAcceptCell: SwipeTableViewCell {
    
    let jobManager = JobManager()
    
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var infoButton: UIButtonBadge!
    @IBOutlet weak var checkButton: UIButton!
    
    @IBOutlet weak var orderTypeLabel: UILabel!
    
    @IBOutlet weak var productListLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    
    @IBOutlet weak var deliveryInfoLabel: UILabel!
    @IBOutlet weak var fromCreatedLabel: UILabel!

    var order = [String:Any]()
    var orderId: Int?
    var orderNum: Int?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        deleteButton.applyPanelButtonStyle()
        infoButton.applyPanelButtonStyle()
        checkButton.applyPanelButtonStyle()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

    
    
//MARK: - Init
    func initCell() {
        self.orderId = (order["OrderId"] as? Int) ?? 0
        self.orderNum = (order["order_number_on_client"] as? Int) ?? 0
        
        initLabels()
        initButtons()
    }
    
    func initLabels() {
        
        // OrderType + OrderNum
        let orderTypeText = NSMutableAttributedString(string: (order["OrderType"] as! String), attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 18)])
        orderTypeText.append(NSAttributedString(string: "  (#" + String(orderNum!) + ")", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15), NSAttributedString.Key.foregroundColor: UIColor.darkGray]))
        orderTypeLabel.attributedText = orderTypeText
        
        // ProductList
        let productList: [[String:Any]] = (order["ProductList"] as! [[String : Any]])
        productListLabel.text = (productList[0]["ProductName"] as! String)
        addressLabel.text = (order["ZipCode"] as! String) + " " + (order["City"] as! String)

        // Distance
        let lat = order["lat"] as! Double
        let lon = order["lng"] as! Double
        let distance = getDistance_km(lat: lat, lon: lon)
        distanceLabel.text = String(format:"%.02f", distance) + " km"
        
        // FromCreated
        let dateString = order["OrderCreatedAsDate"] as! String
        fromCreatedLabel.setTimeAgo(with: dateString)
        
        // Delivery Info
        let shippingDateString = (order["ConfirmedShippingDate"] as? String) ?? nil
        deliveryInfoLabel.setDeliveryInfo(with: shippingDateString)
    }
    
    func initButtons() {
        // CustomerAnswersBadge
        infoButton.hideBadge()
        let badge = (order["CustomerAnswersBadge"] as? String) ?? ""
        if( badge != "") {
            infoButton.showBadge(blink: false, text: badge)
        }
    }
        
//MARK: - UI Actions
    
    @IBAction func deleteButtonPressed(_ sender: Any) {
        selectedViewType = K.JobAccept.type
        selectedAcceptOrderId = orderId
        selectedAcceptOrderNum = orderNum

        let keyName = Notification.Name(rawValue: jobAcceptDeclineJobKey)
        NotificationCenter.default.post(name: keyName, object: nil)
        
    }
        
    @IBAction func infoButtonPressed(_ sender: Any) {
        selectedViewType = K.JobAccept.type
        selectedAnnoType = K.Annotation.unacceptedJob
        selectedOrderNum = orderNum
        selectedAcceptOrderId = orderId
        selectedAcceptOrderNum = orderNum

        selectedJob = self.order
        
        let keyName = Notification.Name(rawValue: jobInfoKey)
        NotificationCenter.default.post(name: keyName, object: nil)
    }
        
    @IBAction func checkButtonPressed(_ sender: Any) {
        selectedViewType = K.JobAccept.type
        selectedAcceptOrderId = orderId
        selectedAcceptOrderNum = orderNum

        let keyName = Notification.Name(rawValue: jobAcceptAcceptJobKey)
        NotificationCenter.default.post(name: keyName, object: nil)
    }
    
}
