import UIKit

class ChatViewController: UIViewController {
        
    //Loading Spinner
    @IBOutlet weak var loadingBG: UIView!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    @IBOutlet weak var chatTableView: UITableView!
    @IBOutlet weak var orderNumLabel: UILabel!
    @IBOutlet weak var textingView: UIView!
    @IBOutlet weak var textingToSend: UITextField!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var notActiveMessageLabel: UILabel!
    
    //Managerr
    let chatManager = ChatManager()
    
    //Data
    var messages = [[String:Any]]()
    var orderId: Int = 0
    var orderNum: Int = 0
    var isActive: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //delegate
        chatTableView.dataSource = self
        chatTableView.delegate = self    //for interection

        refreshTableView(isInit: true)
    }

    override func viewWillAppear(_ animated: Bool) {
        getIsActive()
        
        initButtons()
        initTextingView()
        initLabel()
        loadingStop()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let result = chatManager.readMessageFromCustomer(orderId)
        print("readMessageFromCustomerPageResponse: \(result)")
    }
    
    
//MARK: - Init
        
    func getIsActive() {
        self.isActive = (singletonData.getCustomerPageChat[K.Chat.isActive] as? Bool ?? false)
    }
        
    func initLabel() {
        let orderNumString = String(orderNum)
        orderNumLabel.text = "Order: # " + orderNumString
        
        notActiveMessageLabel.isHidden = self.isActive ? true : false
    }
    
    func initButtons() {
        sendButton.applyCircleStyle()
        
        sendButton.isEnabled = self.isActive ? true : false
        sendButton.backgroundColor = self.isActive ? #colorLiteral(red: 0.2506503761, green: 0.5161324143, blue: 0.8887386918, alpha: 1) : #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
    }
    
    func initTextingView() {
        textingView.layer.borderWidth = 0.5
        textingView.layer.borderColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        textingView.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
    }
    
    
//MARK: - Methods
    
    func getMessageData() {
        messages = (singletonData.getCustomerPageChat[K.Chat.messages] as? [[String:Any]]) ?? [[:]]
    }

    func refreshTableView(isInit: Bool) {
        getMessageData()
        chatTableView.reloadData()
        if !isInit {
            chatTableView.scrollTableViewToBottom(animated: true)
        }
    }
    
    func isDateHeader(_ index: Int) -> Bool {
        if ( index == 0 ) {
            return true
        } else {
            let prevDateString = (messages[index-1][K.Chat.Message.timestamp] as? String) ?? ""
            let prevDate = stringToDate(with: prevDateString)

            let currDateString = (messages[index][K.Chat.Message.timestamp] as? String) ?? ""
            let currDate = stringToDate(with: currDateString)
                        
            if isSameDay(prevDate, currDate) { return false }
            else { return true }
        }
    }
    
    func isTimestamp(_ index: Int) -> Bool {
        if ( index == (messages.count - 1) ) {
            return true
        } else {
            let nextDateString = (messages[index+1][K.Chat.Message.timestamp] as? String) ?? ""
            let nextDate = stringToDate(with: nextDateString)

            let currDateString = (messages[index][K.Chat.Message.timestamp] as? String) ?? ""
            let currDate = stringToDate(with: currDateString)
                        
            if isSameTimeInMinute(currDate, nextDate) { return false }
            else { return true }
        }
    }
    
    func loadingStart() {
        self.loadingBG.isHidden = false
        self.spinner.startAnimating()
    }
    
    func loadingStop() {
        self.loadingBG.isHidden = true
        self.spinner.stopAnimating()
    }
    
//MARK: - UI Actions
    
    @IBAction func closeButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func sendButtonPressed(_ sender: Any) {
        
        let messageToSend = (textingToSend.text) ?? ""
        var sendResult: Bool = false
        var refreshResult: Bool = false
        
        if (messageToSend == "") {
            showAlert(title: "Nothing to send", message: "Type something")
            return
        } else {
            sendResult = chatManager.sendMessageToCustomer(orderId,messageToSend)
        }
        
        if !sendResult {
            showAlert(title: "Something went wrong", message: "Try again")
            loadingStop()
            return
        } else {
            textingToSend.text = ""
            refreshResult = chatManager.refreshChat(orderId)
        }
        
        if refreshResult {
            refreshTableView(isInit: false)
        }
        loadingStop()
    }
    
    @IBAction func sendButtonTouchDown(_ sender: Any) {
        loadingStart()
    }
}

//MARK: - UITableViewDataSource
extension ChatViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (messages[0].count == 0) { return 0 }
        else { return messages.count }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
                
        let cell = tableView.dequeueReusableCell(withIdentifier: K.Chat.Cell, for: indexPath) as! ChatCell //Casting ChatCell
        cell.isDateHeader = isDateHeader(indexPath.row)
        cell.isTimestamp = isTimestamp(indexPath.row)
        cell.message = messages[indexPath.row]
        cell.initCell()
        return cell
    }    
}

//MARK: - UITableViewDelegate
extension ChatViewController: UITableViewDelegate {

}
