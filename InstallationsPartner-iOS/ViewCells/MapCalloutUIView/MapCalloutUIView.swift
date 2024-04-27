import UIKit
import MessageUI
import CoreLocation

class MapCalloutUIView: UIView {
    
    let jobManager = JobManager()
    
    @IBOutlet weak var mainView: UIView!
        
    @IBOutlet weak var orderNumLabel: UILabel!
    @IBOutlet weak var orderTypeLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var shippingStatusLabel: UILabel!
    @IBOutlet weak var installerLabel: UILabel!
    
    @IBOutlet weak var fullnameLabel: UILabel!
    @IBOutlet weak var streetAddressLabel: UILabel!
    @IBOutlet weak var zipCodeCityLabel: UILabel!
    @IBOutlet weak var orderStatusLabel: UILabel!
    
    @IBOutlet weak var infoButton: UIButtonBadge!
    @IBOutlet weak var bookingButton: UIButton!
    
    var viewType: String?
    var annoType: String?
    var order = [String: Any]()
    var orderId: Int?
    var orderNum: Int?
    var orderStatus: String?
    var phoneNumber: String?
    var coordinates: CLLocationCoordinate2D?
    var customerAnswerList = [[String:Any]]()

    func initView() {
        
        findOrder()
        getOrderId()
        getPhoneNumber()
        getCustomerAnswersBadge()
        
        initLabels()
        initDeliveryInfoLabel()
        initButtons()
    }
    
//MARK: - Init
    func findOrder() {
        self.order = singletonData.findJob(type: annoType, with: String(orderNum!))
    }
    
    func getOrderId() {
        self.orderStatus = ((order["OrderStatus"] as? String) ?? K.OrderStatus.done).lowercased()

        var orderIdKey: String?
        
        switch orderStatus {
        case K.OrderStatus.unaccepted,
             K.OrderStatus.unbooked:
            orderIdKey = "OrderId"
        case K.OrderStatus.booking,
             K.OrderStatus.booked,
             K.OrderStatus.done:
            orderIdKey = "Id"
        default:
            orderIdKey = "Id"
        }
        
        self.orderId = (order[orderIdKey!] as? Int) ?? 0
    }
    
    func initButtons() {
        bookingButton.isHidden = false
        
        switch annoType {
        case K.Annotation.unacceptedJob,
            K.Annotation.doneJob:
            bookingButton.isHidden = true
            break
            
        default:
            break
        }
    }
    
    func initLabels() {
        
        var fullNameKey: String?
        var streetAddressKey: String?
        var zipCodeKey: String?
        var cityKey: String?
        var orderStatusKey: String?
        var installerNameKey: String?
        let startDateKey: String = "Start"
        
        switch annoType {
        
        case K.Annotation.unacceptedJob, K.Annotation.unbookedJob:
            fullNameKey = "FullName"
            streetAddressKey = "StreetAdress"
            zipCodeKey = "ZipCode"
            cityKey = "City"
            orderStatusKey = "OrderStatus"
            installerNameKey = "InstallerName"
            
        case K.Annotation.bookingJob, K.Annotation.bookedJob, K.Annotation.doneJob:
            fullNameKey = "Description"
            streetAddressKey = "StreetAddress"
            zipCodeKey = "PostalAddress"
            cityKey = "CityAddress"
            orderStatusKey = "OrderStatus"
            installerNameKey = "ResourceName"

        default: break
        }
        
        orderNumLabel.text = "Order: #" + String(orderNum!)
        orderTypeLabel.text = (order["OrderType"] as? String) ?? ""
        
        fullnameLabel.text = (order[fullNameKey!] as! String)
        streetAddressLabel.text = (order[streetAddressKey!] as! String)
        zipCodeCityLabel.text = (order[zipCodeKey!] as! String) + " " + (order[cityKey!] as! String)
        
        orderStatusLabel.text = (order[orderStatusKey!] as! String)
        
        if let installerName = order[installerNameKey!] as? String {
            installerLabel.text = K.INSTALLER + ": " + installerName
        }
                
        if let dateString = (order[startDateKey]) as? String {
            let date = stringToDate(with: dateString)
            let formattedDate = dateToString_mdhm(with: date)
            dateLabel.text = "Datum: " + formattedDate
        }
    }
    
    func initDeliveryInfoLabel() {
        
        let shippingDateString = (order["ConfirmedShippingDate"] as? String) ?? nil
        if shippingDateString != nil {
            let shippingDate = stringToDate(with: shippingDateString!)
            if shippingDate < Date() {
                shippingStatusLabel.text = "Levererat"
                shippingStatusLabel.textColor = #colorLiteral(red: 0.1589285409, green: 0.7207738505, blue: 0.3077968417, alpha: 1)
            } else {
                let shippingYMD = dateToString_ymd(with: shippingDate)
                shippingStatusLabel.text = "Leverans: " + shippingYMD
                shippingStatusLabel.textColor = #colorLiteral(red: 0.1528630555, green: 0.305911988, blue: 0.5881598592, alpha: 1)
            }
        } else {
            shippingStatusLabel.textColor = #colorLiteral(red: 0.924274087, green: 0.3933636844, blue: 0.276587218, alpha: 1)
            shippingStatusLabel.text = "Inget leveransdatum"
        }
    }
    
    func getPhoneNumber() {
        var phoneNumberKey: String?
        
        switch annoType {
        case K.Annotation.unacceptedJob,
             K.Annotation.unbookedJob:
            phoneNumberKey = "PhoneNumber"
        case K.Annotation.bookingJob,
             K.Annotation.bookedJob,
             K.Annotation.doneJob :
            phoneNumberKey = "Phone"
        default: break
        }
        
        let stringNumber = (order[phoneNumberKey!] as? String) ?? "0000000000"
        self.phoneNumber = stringNumber.onlyDigits()
    }
    
    func getCustomerAnswersBadge() {
        
        // CustomerAnswersBadge
        infoButton.hideBadge()
        let badge = (order["CustomerAnswersBadge"] as? String) ?? ""
        if( badge != "") {
            infoButton.showBadge(blink: false, text: badge)
        }
    }
    
    
//MARK: - UI Actions
    @IBAction func closeButtonPressed(_ sender: Any) {
        self.removeFromSuperview()
        
        // Broadcast to deselect annotation
        if viewType == K.JobAccept.type {
            let keyName = Notification.Name(rawValue: jobAcceptDeselectAnnotationKey)
            NotificationCenter.default.post(name: keyName, object: nil)
        } else if viewType == K.JobBook.type {
            let keyName = Notification.Name(rawValue: jobBookDeselectAnnotationKey)
            NotificationCenter.default.post(name: keyName, object: nil)
        } else if viewType == K.JobToday.type {
            let keyName = Notification.Name(rawValue: jobTodayDeselectAnnotationKey)
            NotificationCenter.default.post(name: keyName, object: nil)
        }
    }
    
    @IBAction func callButtonPressed(_ sender: Any) {
        
        makeACall(with: self.phoneNumber!)
    }
    
    
    @IBAction func messageButtonPressed(_ sender: Any) {
        selectedPhoneNumber = self.phoneNumber
        
        let keyName = Notification.Name(rawValue: sendAMessageKey)
        NotificationCenter.default.post(name: keyName, object: nil)
    }
    
    @IBAction func naviButtonPressed(_ sender: Any) {

        let lon = order["lng"] as! Double
        let lat = order["lat"] as! Double

        guard let url = URL(string:"http://maps.apple.com/?daddr=\( lat),\(lon)&dirflg=d") else { return }
        UIApplication.shared.open(url)
    }
    
    @IBAction func infoButtonPressed(_ sender: Any) {
        
        selectedViewType = viewType
        selectedOrderNum = orderNum
        selectedAnnoType = annoType
        selectedCoordinates = coordinates
        
        selectedJob = self.order
        
        let keyName = Notification.Name(rawValue: jobInfoKey)
        NotificationCenter.default.post(name: keyName, object: nil)
    }
    
    
    @IBAction func bookingButtonPressed(_ sender: Any) {
        
        selectedOrderNum = orderNum
        selectedAnnoType = annoType

        let keyName = Notification.Name(rawValue: jobBookingViewKey)
        NotificationCenter.default.post(name: keyName, object: nil)
    }
}
