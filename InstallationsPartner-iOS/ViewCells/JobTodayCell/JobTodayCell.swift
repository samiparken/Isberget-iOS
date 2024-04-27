import UIKit

class JobTodayCell: UITableViewCell {

    let jobManager = JobManager()
    
    @IBOutlet weak var annoIcon: UIImageView!
    
    @IBOutlet weak var infoButton: UIButtonBadge!
    @IBOutlet weak var protocolButton: UIButton!
    @IBOutlet weak var naviButton: UIButton!
    
    @IBOutlet weak var orderTypeLabel: UILabel!

    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!

    @IBOutlet weak var fromCreatedLabel: UILabel!
    @IBOutlet weak var deliveryInfoLabel: UILabel!

    var order = [String:Any]()
    var orderId: Int?
    var orderNum: Int?
    var customerAnswerList = [[String:Any]]()

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
        infoButton.applyPanelButtonStyle()
        protocolButton.applyPanelButtonStyle()
        naviButton.applyPanelButtonStyle()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
//MARK: - Init
    
    func initCell() {
        orderId = (order["Id"] as? Int) ?? 0
        orderNum = (order["Order_number_on_client"] as? Int) ?? 0

        initLabels()
        initButtons()
        
        initOrderStatus()
    }
    
    func initLabels() {

        // OrderType + OrderNum
        let orderTypeText = NSMutableAttributedString(string: (order["OrderType"] as? String) ?? "OrderType", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 18)])
        orderTypeText.append(NSAttributedString(string: "  (#" + String(orderNum!) + ")", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 15), NSAttributedString.Key.foregroundColor: UIColor.darkGray]))
        orderTypeLabel.attributedText = orderTypeText
        
        let zipCode = (order["PostalAddress"] as? String) ?? "ZipCode"
        let city = (order["CityAddress"] as? String) ?? "City"
        addressLabel.text = zipCode + " " + city
        
        let dateString2 = (order["Start"] as? String) ?? "2000-01-01T08:00:00.000"
        let orderDate = stringToDate(with: dateString2)
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: orderDate)
        let min = calendar.component(.minute, from: orderDate)
        timeLabel.text = "Klockan " + String(format: "%02d:%02d", hour, min)
        
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
    
    func initOrderStatus() {
        
        let orderStatus = ((order["OrderStatus"] as? String) ?? K.OrderStatus.done).lowercased()
                
        protocolButton.isHidden = false

        switch orderStatus {
        case K.OrderStatus.booking:
            self.backgroundColor = #colorLiteral(red: 0.9634506106, green: 0.8003243804, blue: 0.3381164372, alpha: 0.25) //light yellow
            annoIcon.image = (#imageLiteral(resourceName: "gul"))
            protocolButton.isHidden = true

        case K.OrderStatus.booked:
            self.backgroundColor = #colorLiteral(red: 0.2888590991, green: 0.8347872496, blue: 0.483507216, alpha: 0.25) //light green
            annoIcon.image = (#imageLiteral(resourceName: "gron"))

        case K.OrderStatus.done:
            self.backgroundColor = #colorLiteral(red: 0.6738585234, green: 0.7104437947, blue: 0.7427173257, alpha: 0.25) //light gray
            annoIcon.image = (#imageLiteral(resourceName: "completed"))
            protocolButton.isHidden = true
            
        default:
            self.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        }

    }

    
//MARK: - UI Actions
    @IBAction func infoButtonPressed(_ sender: Any) {
        selectedViewType = K.JobToday.type
        selectedAnnoType = K.Annotation.bookedJob
        selectedOrderNum = orderNum

//        selectedTodayOrderId = orderId
//        selectedTodayOrderNum = orderNum

        selectedJob = self.order
        
        let keyName = Notification.Name(rawValue: jobInfoKey)
        NotificationCenter.default.post(name: keyName, object: nil)        
    }
    
    @IBAction func naviButtonPressed(_ sender: Any) {
        let job = singletonData.findJob(type: K.Annotation.bookedJob, with: String(orderNum!))
        let lon = job["lng"] as! Double
        let lat = job["lat"] as! Double
        guard let url = URL(string:"http://maps.apple.com/?daddr=\( lat),\(lon)&dirflg=d") else { return }
        UIApplication.shared.open(url)
    }

    @IBAction func protocolButtonPressed(_ sender: Any) {
        selectedViewType = K.JobToday.type
        selectedAnnoType = K.Annotation.bookedJob
        selectedOrderNum = orderNum
        
        let keyName = Notification.Name(rawValue: jobProtocolKey)
        NotificationCenter.default.post(name: keyName, object: nil)
    }
}
