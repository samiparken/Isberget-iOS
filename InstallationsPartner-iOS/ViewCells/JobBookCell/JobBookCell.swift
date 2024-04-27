//
//  JobBookCell.swift
//  InstallationsPartner-iOS
//
//  Created by Sam on 12/17/20.
//

import UIKit

class JobBookCell: UITableViewCell {

    let jobManager = JobManager()
    
    @IBOutlet weak var infoButton: UIButtonBadge!
    @IBOutlet weak var callButton: UIButton!
    @IBOutlet weak var calendarButton: UIButton!
    
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

        infoButton.applyPanelButtonStyle()
        callButton.applyPanelButtonStyle()
        calendarButton.applyPanelButtonStyle()

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

//MARK: - Init
    
    func initCell() {
        
        orderId = (order["OrderId"] as? Int) ?? 0
        orderNum = (order["order_number_on_client"] as? Int) ?? 0
                
        initLabels()
        initButtons()
        
        initOrderStatus()
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
    
    func initOrderStatus() {
        
        let orderStatus = ((order["OrderStatus"] as? String) ?? K.OrderStatus.done).lowercased()
        
        switch orderStatus {
        case K.OrderStatus.unbooked:
            self.backgroundColor = #colorLiteral(red: 0.9725490196, green: 0.5878753662, blue: 0.2035272419, alpha: 0.25) //light orange

        default:
            self.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        }
    }
    
//MARK: - UI Actions
    @IBAction func infoButtonPressed(_ sender: Any) {
        selectedViewType = K.JobBook.type
        selectedAnnoType = K.Annotation.unbookedJob
        selectedOrderNum = orderNum

        selectedBookOrderId = orderId
        selectedBookOrderNum = orderNum

        selectedJob = self.order
        
        let keyName = Notification.Name(rawValue: jobInfoKey)
        NotificationCenter.default.post(name: keyName, object: nil)
        
    }
    
    @IBAction func callButtonPressed(_ sender: Any) {
        
        let order = singletonData.findJob(type: K.Annotation.unbookedJob, with: String(orderNum!))
        
        let phoneNumberKey: String = "PhoneNumber"
                
        let stringNumber = (order[phoneNumberKey] as? String) ?? "0000000000"
        let digitStringNumber = stringNumber.onlyDigits()
        
        makeACall(with: digitStringNumber)
    }
    
    
    @IBAction func bookingButtonPressed(_ sender: Any) {
        
        selectedOrderNum = orderNum
        selectedAnnoType = K.Annotation.unbookedJob
        
        let keyName = Notification.Name(rawValue: jobBookingViewKey)
        NotificationCenter.default.post(name: keyName, object: nil)

    }
    
    
}
