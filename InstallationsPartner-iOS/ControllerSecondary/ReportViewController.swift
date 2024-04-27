import Foundation
import UIKit

class ReportViewController: UIViewController {
    
    //Views
    @IBOutlet weak var infoView: UIView!
    @IBOutlet weak var productTableView: UITableView!

    //Labels
    @IBOutlet weak var orderNumLabel: UILabel!
    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var streetAddressLabel: UILabel!
    @IBOutlet weak var zipCodeCityLabel: UILabel!
    @IBOutlet weak var orderStatusLabel: UILabel!
    @IBOutlet weak var deliveryInfoLabel: UILabel!
        
    //Buttons
    @IBOutlet weak var reportButton: UIButton!

    //Manager
    let jobManager = JobManager()
    let taskManager = TaskManager()
    
    //Reason Picker
    @IBOutlet weak var selectReason: UITextField!
    var pickerView = UIPickerView()
    @IBOutlet weak var inputTextField: UITextField!
    var reasonList = [[String: Any]]()
        
    //Data
    var order = [String:Any]()
    var orderStatus: String?
    var orderId: Int?
    var orderNum: Int?
    var annoType: String?
    var productList = [[String: Any]]()
    var needUpdate: Bool = false
    var phoneNumber: String?
    var email: String?

    var reasonId: Int?
    var reasonText: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //delegate
        productTableView.dataSource = self
        pickerView.delegate = self
        pickerView.dataSource = self
        inputTextField.delegate = self
        
        getOrder()
        getProductList()
        getTaskReasons()
        
        initReasonSelector()
        initViewStyle()
        initButtonStyle()
                
        fillOutForm()
        productTableView.reloadData()
    }

    
//MARK: - Init
    
    func initViewStyle() {
        
        infoView.applyShadowAndRadius()
    }
    
    func initButtonStyle() {
        
        reportButton.applyPanelButtonStyle()
        reportButtonDisabled()
    }
    
    func initReasonSelector() {
        selectReason.inputView = pickerView
        inputTextField.isHidden = true
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
    
    func getProductList() {
        productList = (self.order["ProductList"] as? [[String : Any]]) ?? []
    }
    
    func getTaskReasons() {
        reasonList = (selectedTask[K.Task.taskReasons] as! [[String : Any]])
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
    }
    
//MARK: - Methods
    
    func checkIfInput() {
        let selected = selectReason.text!
        
        if (selected == "Annat/fritext") {
            inputEnabled()
        } else {
            inputDisabled()
        }
    }
    
    func checkIfButton() {
        let selected = selectReason.text!

        if (selected == "Välj") {
            reportButtonDisabled()
        } else if ( selected == "Annat/fritext" && inputTextField.text == "" ) {
            reportButtonDisabled()
        } else {
            reportButtonEnabled()
        }
    }
    
    func inputEnabled() {
        inputTextField.isHidden = false
    }
    func inputDisabled() {
        inputTextField.isHidden = true
    }
    
    func reportButtonEnabled() {
        reportButton.setTitleColor(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1), for: .normal)
        reportButton.backgroundColor = #colorLiteral(red: 1, green: 0.8431372549, blue: 0, alpha: 1)
        reportButton.isEnabled = true
    }
    func reportButtonDisabled() {
        reportButton.setTitleColor(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.6646646664), for: .normal)
        reportButton.backgroundColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
        reportButton.isEnabled = false
    }
    
//MARK: - UIActions
    @IBAction func closeButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func reportButtonPressed(_ sender: Any) {

        print(order)
        let taskId = selectedTask[K.Task.taskId] as! Int
        let reasonText = (inputTextField.text) ?? ""
        
        taskManager.reportTask(taskId, reasonId!, reasonText)
        jobManager.refreshTasks()
        
        // Exception Handling
        if singletonData.reportTaskResponse == "\"success\"" {
            dismiss(animated: true, completion: nil)
        } else {
            self.showAlert(title: singletonData.reportTaskResponse, message: "")
        }
    }
}

//MARK: - UIPickerViewDelegate
extension ReportViewController: UIPickerViewDelegate {
    
}

//MARK: - UIPickerViewDataSource
extension ReportViewController: UIPickerViewDataSource {
    
    //Num of Columns
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    //Num of Rows
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return reasonList.count
    }
    
    //titleForRow
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        //name of installers
        return (reasonList[row][K.Task.Reason.text] as! String)
    }
    
    //didSelectRow
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectReason.text = (reasonList[row][K.Task.Reason.text] as! String)
        reasonId = (reasonList[row][K.Task.Reason.id] as! Int)
        
        selectReason.resignFirstResponder()
        checkIfInput()
        checkIfButton()
    }
}

//MARK: - UITextFieldDelegate
extension ReportViewController: UITextFieldDelegate{
    //When "Return"Key is hit on Keyboard
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        inputTextField.endEditing(true)
        return true //true if it's default behavior
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        checkIfButton()
    }
}


//MARK: - UITableViewDataSource
extension ReportViewController: UITableViewDataSource {
    
    //Num of Rows
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return productList.count
    }
        
    //Row content, called as many as the Number of Rows
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let product = productList[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: K.Report.Cell, for: indexPath)
            as! ReportProductCell   //Casting Cell
        
        cell.product = product
        cell.initCell()
                        
        return cell
    }
}
