import UIKit
import MessageUI

class InfoViewController: UIViewController {
    let defaults = UserDefaults.standard

    @IBOutlet weak var orderNumLabel: UILabel!
    @IBOutlet weak var createdDateLabel: UILabel!
    
    // Overall Info View
    @IBOutlet weak var infoView: UIView!
    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var streetAddressLabel: UILabel!
    @IBOutlet weak var zipCodeCityLabel: UILabel!
    @IBOutlet weak var orderStatusLabel: UILabel!
    @IBOutlet weak var deliveryInfoLabel: UILabel!
    @IBOutlet weak var infoButtonStackView: UIStackView!
    @IBOutlet weak var mailButton: UIButton!
    @IBOutlet weak var callButton: UIButton!
    @IBOutlet weak var sendMessageButton: UIButton!
    @IBOutlet weak var naviButton: UIButton!
    @IBOutlet weak var answersButton: UIButtonBadge!
    @IBOutlet weak var chatButton: UIButtonBadge!
    
    // Booked Info View
    @IBOutlet weak var bookedInfoView: UIView!
    @IBOutlet weak var bookedInfoView_padding: UIView! //20
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var timeRangeLabel: UILabel!
    @IBOutlet weak var installerNameLabel: UILabel!
    @IBOutlet weak var calendarButton: UIButton!
    
    // Product List View
    @IBOutlet weak var productListView: UIView!
    @IBOutlet weak var productTableView: UITableView!
    
    // Message View
    @IBOutlet weak var textUIView: UIView!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var textFieldUIView: UIView!
    @IBOutlet weak var textField: UITextField!
    
    // Cancel Job Button View
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    // Data
    var order = [String: Any]()
    var orderStatus: String?
    var orderId: Int?
    var orderNum: Int?
    var annoType: String?
    var productList = [[String: Any]]()
    var needUpdate: Bool = false
    var phoneNumber: String?
    var email: String?
    var customerAnswerList = [[String:Any]]()
    var customerChatMessages = [[String: Any]]()
        
    var startTime: Date?
    var endTime: Date?
    
    // Manager
    let jobManager = JobManager()
    let chatManager = ChatManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("InfoVC: viewDidLoad")
        
        //delegate
        productTableView.dataSource = self

        getOrder()
        getProductList()
        getPhonNumber()
        getBookedInfo()
        getEmailAddress()
        getChatMessages()
        
        initViews()
        initViewStyle()
        initButtons()
        initButtonStyle()
        
        fillOutForm()
        productTableView.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        print("InfoVC: viewWillAppear")
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToCustomerAnswers" {
            let vc = segue.destination as! CustomerAnswersViewController
            vc.orderNum = orderNum
            vc.orderId = orderId
        } else if segue.identifier == "goToChatView" {
            let vc = segue.destination as! ChatViewController
            vc.orderNum = orderNum ?? 0
            vc.orderId = orderId ?? 0
        }
    }
    
//MARK: - Init
    func initViews() {
        // Booked info view
        let orderStatus = ((order["OrderStatus"] as? String) ?? K.OrderStatus.done).lowercased()
        switch orderStatus {
            case K.OrderStatus.booked: refreshBookedInfoView(isOn: true)
            default: refreshBookedInfoView(isOn: false)
        }
    }
    
    func initViewStyle() {
        infoView.applyShadowAndRadius()
        bookedInfoView.applyShadowAndRadius()
        productListView.applyShadowAndRadius()
        textUIView.applyShadowAndRadius()
        
        textView.layer.cornerRadius = 15
        textView.dataDetectorTypes = UIDataDetectorTypes(rawValue: UIDataDetectorTypes.link.rawValue) //url detection
        textView.isEditable = false
        textView.tintColor = #colorLiteral(red: 0.9411764741, green: 0.4980392158, blue: 0.3529411852, alpha: 1)

        textFieldUIView.layer.cornerRadius = 15
        
        let textFieldPlaceholder = NSAttributedString(string: "   Skicka ett meddelande...", attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        textField.attributedPlaceholder = textFieldPlaceholder
    }
    
    func initButtons() {
        let orderStatus = ((order["OrderStatus"] as? String) ?? K.OrderStatus.done).lowercased()
        switch orderStatus {
        case K.OrderStatus.booking: cancelButton.isHidden = false
        case K.OrderStatus.booked:  cancelButton.isHidden = false
        default: cancelButton.isHidden = true
        }

        chatButtonDisabled()
        
        initCustomerAnswersButton()
    }
    
    func initCustomerAnswersButton() {

        //set customerAnswersBadge
        answersButton.hideBadge()
        let badge = (order["CustomerAnswersBadge"] as? String) ?? ""
        if( badge != "") {
            answersButton.showBadge(blink: false, text: badge)
        } else {
            answersButtonDisabled()
        }
    }

    
    func initButtonStyle() {
        mailButton.applyPanelButtonStyle()
        callButton.applyPanelButtonStyle()
        sendMessageButton.applyPanelButtonStyle()
        naviButton.applyPanelButtonStyle()
        calendarButton.applyPanelButtonStyle()
        cancelButton.applyPanelButtonStyle()
        
        answersButton.applyPanelButtonStyle()
        chatButton.applyPanelButtonStyle()
    }
    
    func getOrder() {
        self.order = selectedJob
        self.orderStatus = ((order["OrderStatus"] as? String) ?? K.OrderStatus.done).lowercased()

        var orderIdKey: String?
        var orderNumKey: String?
        
        switch orderStatus {
        case K.OrderStatus.unaccepted:
            orderIdKey = "OrderId"
            orderNumKey = "order_number_on_client"
            self.annoType = K.Annotation.unacceptedJob
        case K.OrderStatus.unbooked:
            orderIdKey = "OrderId"
            orderNumKey = "order_number_on_client"
            self.annoType = K.Annotation.unbookedJob
        case K.OrderStatus.booking:
            orderIdKey = "Id"
            orderNumKey = "Order_number_on_client"
            self.annoType = K.Annotation.bookingJob
        case K.OrderStatus.booked:
            orderIdKey = "Id"
            orderNumKey = "Order_number_on_client"
            self.annoType = K.Annotation.bookedJob
        case K.OrderStatus.done:
            orderIdKey = "Id"
            orderNumKey = "Order_number_on_client"
            self.annoType = K.Annotation.doneJob
        default:
            orderIdKey = "Id"
            orderNumKey = "Order_number_on_client"
            self.annoType = K.Annotation.doneJob
        }
        
        // for Generic Order Format
        switch selectedAnnoType {
        case K.Annotation.genericCalendarJob,
             K.Annotation.genericJob:
            orderIdKey = "OrderId"
            orderNumKey = "order_number_on_client"
        default:
            break
        }
        
        self.orderNum = (order[orderNumKey!] as? Int) ?? 0
        self.orderId = (order[orderIdKey!] as? Int) ?? 0
    }

//MARK: - Methods
    
    func answersButtonEnabled() {
        answersButton.tintColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        answersButton.backgroundColor = #colorLiteral(red: 0.1095948145, green: 0.3001712561, blue: 0.6087573171, alpha: 1)
        answersButton.isEnabled = true
    }
    func answersButtonDisabled() {
        answersButton.tintColor = #colorLiteral(red: 0.3333333433, green: 0.3333333433, blue: 0.3333333433, alpha: 1)
        answersButton.backgroundColor = #colorLiteral(red: 0.6666666865, green: 0.6666666865, blue: 0.6666666865, alpha: 1)
        answersButton.isEnabled = false
    }
    
    func chatButtonEnabled() {
        chatButton.tintColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        chatButton.backgroundColor = #colorLiteral(red: 0.1095948145, green: 0.3001712561, blue: 0.6087573171, alpha: 1)
        chatButton.isEnabled = true
    }
    func chatButtonDisabled() {
        chatButton.tintColor = #colorLiteral(red: 0.3333333433, green: 0.3333333433, blue: 0.3333333433, alpha: 1)
        chatButton.backgroundColor = #colorLiteral(red: 0.6666666865, green: 0.6666666865, blue: 0.6666666865, alpha: 1)
        chatButton.isEnabled = false
    }

    
    func getChatMessages() {
        chatButton.showBadge(blink: true, text: "...", withSize: 10)
        DispatchQueue.global(qos: .background).async {
            
            _ = self.chatManager.refreshChat(self.orderId!)
            let isChatValid = self.chatManager.isChatValid()
                        
            self.customerChatMessages = (singletonData.getCustomerPageChat[K.Chat.messages] as? [[String:Any]]) ?? [[:]]

            DispatchQueue.main.async {
                
                if (!isChatValid) {
                    self.chatButtonDisabled()
                    self.chatButton.hideBadge()
                    return
                }
                
                // Count Unread Messages
                var unreadMessageCounter: Int = 0
                for message in self.customerChatMessages {
                    let isRead = (message[K.Chat.Message.isRead] as? Bool) ?? false
                    let isCustomer = (message[K.Chat.Message.isCustomer] as? Bool) ?? false
                    if ( !isRead && isCustomer ) {
                        unreadMessageCounter += 1
                    }
                }
                
                // Show Badge
                if unreadMessageCounter > 0 {
                    let badge = String(unreadMessageCounter)
                    self.chatButtonEnabled()
                    self.chatButton.hideBadge()
                    self.chatButton.showBadge(blink: false, text: badge, withSize: 10)
                } else {
                    self.chatButtonEnabled()
                    self.chatButton.hideBadge()
                }
            }
        }
    }
    
    func getBookedInfo() {
                
        var installerNameKey: String?
        var startTimeKey: String?
        var endTimeKey: String?
                
        // for Generic Order Format
        switch selectedAnnoType {
        case K.Annotation.genericCalendarJob,
             K.Annotation.genericJob:
            installerNameKey = "InstallerName"
            startTimeKey = "StartAsDate"
            endTimeKey = "EndAsDate"
        default:
            installerNameKey = "ResourceName"
            startTimeKey = "Start"
            endTimeKey = "End"
        }
                
        //installer name
        installerNameLabel.text = (order[installerNameKey!] as? String) ?? ""
        
        // startTime ~ endTime
        let startString = (order[startTimeKey!] as? String) ?? "2000-01-01T08:00:00.000"
        let startDate = stringToDate(with: startString)
        let startHM = dateToString_hm(with: startDate)
                
        let endString = (order[endTimeKey!] as? String) ?? "2000-01-01T08:00:00.000"
        let endDate = stringToDate(with: endString)
        let endHM = dateToString_hm(with: endDate)

        timeRangeLabel.text = startHM + " ~ " + endHM
        
        // DateLabel
        let startYMD = dateToString_ymd(with: startDate)
        dateLabel.text = startYMD
    }
    
    func refreshBookedInfoView(isOn: Bool) {
        if isOn {
            bookedInfoView.isHidden = false
            bookedInfoView_padding.isHidden = false
        } else {
            bookedInfoView.isHidden = true
            bookedInfoView_padding.isHidden = true
        }
    }
        
    func getProductList() {
        productList = (self.order["ProductList"] as? [[String : Any]]) ?? []
    }
    
    func getPhonNumber() {
        var phoneNumberKey: String?

        switch orderStatus {
        case K.OrderStatus.unaccepted,
             K.OrderStatus.unbooked:
            phoneNumberKey = "PhoneNumber"
        case K.OrderStatus.booking,
             K.OrderStatus.booked,
             K.OrderStatus.done:
            phoneNumberKey = "Phone"
        default:
            phoneNumberKey = "Phone"
        }
        
        // for Generic Order Format
        switch selectedAnnoType {
        case K.Annotation.genericCalendarJob,
             K.Annotation.genericJob:
            phoneNumberKey = "PhoneNumber"
        default:
            break
        }
        
        let stringNumber = (order[phoneNumberKey!] as? String) ?? "0000000000"
        self.phoneNumber = stringNumber.onlyDigits()
    }
    
    func getEmailAddress() {
        self.email = (order["Email"] as? String) ?? "-"
    }
        
    func fillOutForm() {
        let createdDateKey: String = "OrderCreatedAsDate"
        var fullNameKey: String?
        var streetAddressKey: String?
        var zipCodeKey: String?
        var cityKey: String?
        let orderStatusKey: String = "OrderStatus"
        let deliveryInfoKey: String = "ConfirmedShippingDate"
        var installerNameKey: String?
        let startDateKey: String = "Start"
        let commentKey: String = "Comment"
        
        switch orderStatus {
        
        case K.OrderStatus.unaccepted,
             K.OrderStatus.unbooked:
            fullNameKey = "FullName"
            streetAddressKey = "StreetAdress"
            zipCodeKey = "ZipCode"
            cityKey = "City"
            installerNameKey = "InstallerName"
            
        case K.OrderStatus.booking,
             K.OrderStatus.booked,
             K.OrderStatus.done:
            fullNameKey = "Description"
            streetAddressKey = "StreetAddress"
            zipCodeKey = "PostalAddress"
            cityKey = "CityAddress"
            installerNameKey = "ResourceName"

        default:
            fullNameKey = "Description"
            streetAddressKey = "StreetAddress"
            zipCodeKey = "PostalAddress"
            cityKey = "CityAddress"
            installerNameKey = "ResourceName"
        }
        
        // for Generic Order Format
        switch selectedAnnoType {
        case K.Annotation.genericCalendarJob,
             K.Annotation.genericJob:
            fullNameKey = "FullName"
            streetAddressKey = "StreetAdress"
            zipCodeKey = "ZipCode"
            cityKey = "City"
            installerNameKey = "InstallerName"
        default:
            break
        }
        
        // title
        orderNumLabel.text = "Order: # " + String(self.orderNum!)
        let createdString = (order[createdDateKey] as? String) ?? "2000-01-01T00:00:00.000"
        let createdDate = stringToDate(with: createdString)
        let created = dateToString_ymdhms(with: createdDate)
        createdDateLabel.text = "Skapad: " + created
        
        // Info View
        fullNameLabel.text = (order[fullNameKey!] as? String) ?? "-"
        streetAddressLabel.text = (order[streetAddressKey!] as? String) ?? "-"
        let zipCode = (order[zipCodeKey!] as? String) ?? "-"
        let city = (order[cityKey!] as? String) ?? "-"
        zipCodeCityLabel.text = zipCode + " " + city
        
        let orderStatus = (order[orderStatusKey] as? String) ?? "-"
        orderStatusLabel.text = orderStatus
        
        let shippingDateString = (order[deliveryInfoKey] as? String) ?? nil
        if shippingDateString != nil {
            let shippingDate = stringToDate(with: shippingDateString!)
            if shippingDate < Date() {
                deliveryInfoLabel.text = "Levererat"
                deliveryInfoLabel.textColor = #colorLiteral(red: 0.1589285409, green: 0.7207738505, blue: 0.3077968417, alpha: 1)
            } else {
                let shippingYMD = dateToString_ymd(with: shippingDate)
                deliveryInfoLabel.text = "Leverans: " + shippingYMD
                deliveryInfoLabel.textColor = #colorLiteral(red: 0.1528630555, green: 0.305911988, blue: 0.5881598592, alpha: 1)
            }
        } else {
            deliveryInfoLabel.textColor = #colorLiteral(red: 0.924274087, green: 0.3933636844, blue: 0.276587218, alpha: 1)
            deliveryInfoLabel.text = "Inget leveransdatum"
        }
        
        //Text View
        textView.text = (order[commentKey] as? String) ?? "-"
    }

//MARK: - UI Actions
    @IBAction func closeButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
        
        if(!needUpdate) { return }
        
        switch self.annoType {
        case K.Annotation.unacceptedJob:
            self.jobManager.refreshUnacceptedJobs()
        case K.Annotation.unbookedJob:
            self.jobManager.refreshUnbookedJobs()
        default:
            self.jobManager.refreshBookingAndBookedJobs()
        }
    }
    
    @IBAction func answersButtonPressed(_ sender: Any) {
        self.performSegue(withIdentifier: "goToCustomerAnswers", sender: self)
    }
    
    @IBAction func chatButtonPressed(_ sender: Any) {

        // Clear badge number when entering ChatView
        self.chatButton.hideBadge()

        self.performSegue(withIdentifier: "goToChatView", sender: self)
    }
    
    @IBAction func mailButtonPressed(_ sender: Any) {
        
        if !isValidEmail(self.email!) {
            self.showAlert(title: "Not vaild email address", message:"")
        }
        
        let mail = MFMailComposeViewController()
        mail.delegate = self
        mail.setToRecipients([self.email!])
        mail.setSubject("")
        mail.setMessageBody("", isHTML: false)
        
        if MFMailComposeViewController.canSendMail() {
            self.present(UINavigationController(rootViewController: mail), animated: true, completion: nil)
        } else {
            self.showAlert(title: "Register your email on your iPhone.", message:"")
        }
    }
    
    @IBAction func callButtonPressed(_ sender: Any) {
        makeACall(with: self.phoneNumber!)
    }
    
    @IBAction func messageButtonPressed(_ sender: Any) {
        
        let composeVC = MFMessageComposeViewController()
        composeVC.messageComposeDelegate = self

        // Configure the fields of the interface.
        composeVC.recipients = [self.phoneNumber!]

        // Present the view controller modally.
        if MFMessageComposeViewController.canSendText() {
            self.present(composeVC, animated: true, completion: nil)
        }
    }
    
    @IBAction func naviButtonPressed(_ sender: Any) {
        let lon = order["lng"] as! Double
        let lat = order["lat"] as! Double
        guard let url = URL(string:"http://maps.apple.com/?daddr=\( lat),\(lon)&dirflg=d") else { return }
        UIApplication.shared.open(url)
    }
    
    @IBAction func sendButtonPressed(_ sender: Any) {
        needUpdate = true

        let userId = self.defaults.integer(forKey: K.UserDefaults.user_id)
        
        let user = singletonData.findInstaller(id: userId)
        let userName = (user["userDisplayName"] as! String)
        
        let comments = textView.text
        let timeStamp = dateToString_ymdhms(with: Date())
        let newComments = textField.text! + "\n- " + timeStamp + ", " + userName + "\n \n" + comments!
        
        // update view
        textView.text = newComments

        // update api
        let urlString = newComments.urlString()
        print(urlString)
        jobManager.setNewComments(orderId!, urlString)
        
        // clear TextField
        textField.text = ""
    }
    
    @IBAction func updateJobButtonPressed(_ sender: Any) {
        dismiss(animated: false, completion: nil)
        
        let keyName = Notification.Name(rawValue: jobBookingViewKey)
        NotificationCenter.default.post(name: keyName, object: nil)
        
    }	
    
    @IBAction func cancelJobButtonPressed(_ sender: Any) {
        var taskCompanyId :Int = 0
        
        if let id = order["Task_Company_Id"] as? Int {
            taskCompanyId = id
        } else if let stringId = order["Task_Company_Id"] as? String {
            taskCompanyId = Int(stringId)!
        } else {
            cancelButton.setTitle("Avboka", for: .normal)
            spinner.stopAnimating()
            return
        }
        
        jobManager.cancelJob(with: taskCompanyId)
        
        let keyName = Notification.Name(rawValue: jobCancelDoneKey)
        NotificationCenter.default.post(name: keyName, object: nil)
        
        DispatchQueue.main.asyncAfter(deadline: .now()+2) {
            self.dismiss(animated: true, completion: nil)
        }

    }
    @IBAction func cancelButtonTouchDown(_ sender: Any) {
        cancelButton.setTitle("", for: .normal)
        spinner.startAnimating()
    }
}

//MARK: - UITableViewDataSource
extension InfoViewController: UITableViewDataSource {
    
    //Num of Rows
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return productList.count
    }
        
    //Row content, called as many as the Number of Rows
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let product = productList[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: K.Info.Cell, for: indexPath)
            as! InfoProductCell   //Casting Cell
        
        cell.product = product
        cell.initCell()
                        
        return cell
    }
}

//MARK: - MFMessageComposeViewControllerDelegate
extension InfoViewController: MFMessageComposeViewControllerDelegate {
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        dismiss(animated: true, completion: nil)
    }
}

//MARK: - MFMailComposeViewControllerDelegate
extension InfoViewController: UINavigationControllerDelegate & MFMailComposeViewControllerDelegate  {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true,completion: nil)
    }
}
