import Foundation
import UIKit

class SearchCell: UITableViewCell {

    let jobManager = JobManager()
    
    @IBOutlet weak var infoButton: UIButtonBadge!
    
    @IBOutlet weak var dotImageView: UIImageView!
    @IBOutlet weak var orderNumLabel: UILabel!
    @IBOutlet weak var orderType: UILabel!
    @IBOutlet weak var customerName: UILabel!
    @IBOutlet weak var productListLabel: UILabel!
    
    var doneInit:Bool = false
    var job = [String:Any]()
    var viewType: String?
    var orderNum: Int?
    var orderId: Int?
    var annoType: String?
    
    func initCell() {
        initButtonStyle()
        initButtons()
        initLabels()
    }

//MARK: - Init
    
    func initButtonStyle() {
        infoButton.applyPanelButtonStyle()
    }
    
    func initLabels() {
        
        var dotImage: UIImage?
        var orderIdKey: String?
        var orderNumKey: String?
        let orderTypeKey: String = "OrderType"
        var fullNameKey: String?
        let productListKey: String = "ProductList"

        let orderStatus = ((job["OrderStatus"] as? String) ?? K.OrderStatus.done).lowercased()
        switch orderStatus {
        
        case K.OrderStatus.unaccepted:
            dotImage = #imageLiteral(resourceName: "dot-bla")
            self.annoType = K.Annotation.unacceptedJob
            orderIdKey = "OrderId"
            orderNumKey = "order_number_on_client"
            fullNameKey = "FullName"

        case K.OrderStatus.unbooked:
            dotImage = #imageLiteral(resourceName: "dot-orange")
            self.annoType = K.Annotation.unbookedJob
            orderIdKey = "OrderId"
            orderNumKey = "order_number_on_client"
            fullNameKey = "FullName"
            
        case K.OrderStatus.booking:
            dotImage = #imageLiteral(resourceName: "dot-gul")
            self.annoType = K.Annotation.bookingJob
            orderIdKey = "Id"
            orderNumKey = "Order_number_on_client"
            fullNameKey = "Description"

        case K.OrderStatus.booked:
            dotImage = #imageLiteral(resourceName: "dot-gron")
            self.annoType = K.Annotation.bookedJob
            orderIdKey = "Id"
            orderNumKey = "Order_number_on_client"
            fullNameKey = "Description"
            
        case K.OrderStatus.done:
            dotImage = #imageLiteral(resourceName: "dot-grey")
            self.annoType = K.Annotation.doneJob
            orderIdKey = "Id"
            orderNumKey = "Order_number_on_client"
            fullNameKey = "Description"

        default:    //OrderStatusId == 3
            dotImage = #imageLiteral(resourceName: "dot-grey")
            self.annoType = K.Annotation.doneJob
            orderIdKey = "Id"
            orderNumKey = "Order_number_on_client"
            fullNameKey = "Description"
        }
        
        self.dotImageView.image = dotImage
        self.orderId = (job[orderIdKey!] as! Int)
        self.orderNum = (job[orderNumKey!] as! Int)
        orderNumLabel.text = "Order: # " + String(orderNum!)
        orderType.text = (job[orderTypeKey] as! String)
        customerName.text = (job[fullNameKey!] as! String)
        
        let productList: [[String:Any]] = (job[productListKey] as! [[String : Any]])
        productListLabel.text = (productList[0]["ProductName"] as! String)
    }
    
    func initButtons() {
        // CustomerAnswersBadge
        infoButton.hideBadge()
        let badge = (job["CustomerAnswersBadge"] as? String) ?? ""
        if( badge != "") {
            infoButton.showBadge(blink: false, text: badge)
        }
    }
    
//MARK: - UI Actions
    @IBAction func infoButtonPressed(_ sender: Any) {
        selectedOrderNum = orderNum
        selectedAnnoType = annoType
        
        selectedJob = self.job
        
        let keyName = Notification.Name(rawValue: jobInfoKey)
        NotificationCenter.default.post(name: keyName, object: nil)
    }
}

