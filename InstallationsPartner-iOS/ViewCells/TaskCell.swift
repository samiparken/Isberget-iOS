import Foundation
import UIKit

class TaskCell: UITableViewCell {
    
    //Views
    @IBOutlet weak var colorBarView: UIView!
    @IBOutlet weak var buttonStackContentView: UIStackView!
    
    //Labels
    @IBOutlet weak var taskTitleLabel: UILabel!
    @IBOutlet weak var orderNumLabel: UILabel!
    @IBOutlet weak var taskBodyLabel: UILabel!
    
    //Buttons
    @IBOutlet weak var actionButton: UIButton!
    @IBOutlet weak var reportButton: UIButton!
    @IBOutlet weak var chatButton: UIButton!
        
    //Manager
    let jobManager = JobManager()
    let chatManager = ChatManager()
    let taskManager = TaskManager()
    
    //Data
    var index: Int?
    var task = [String:Any]()
    var order = [String:Any]()
    var orderNum: Int?
    var orderId: Int?
    var annoType: String?
    var taskType: String?
    var isDone: Bool?
    
    func initCell() {
        findOrder()
        
        initView()
        initButtons()
        initLabels()
        initColorBar()
    }
    
    
//MARK: - Init
        
    func initView() {
        isDone = (task[K.Task.isDone] as? Bool) ?? false
        buttonStackContentView.isHidden = isDone!
        taskTitleLabel.isHidden = isDone!
    }
    
    func initButtons() {
        actionButton.applyPanelButtonStyle()
        reportButton.applyPanelButtonStyle()
        chatButton.applyPanelButtonStyle()
        
        switch taskType {
        case K.Task.Types.notAccepted:
            actionButton.setTitle("Acceptera Jobb", for: .normal)
            actionButton.backgroundColor = #colorLiteral(red: 0.1528630555, green: 0.305911988, blue: 0.5881598592, alpha: 1)
            actionButton.isHidden = false
            reportButton.isHidden = false
            chatButton.isHidden = true
            
        case K.Task.Types.notBooked:
            actionButton.setTitle("Boka Jobb", for: .normal)
            actionButton.backgroundColor = #colorLiteral(red: 0.9563724399, green: 0.5896455646, blue: 0.2074120045, alpha: 1)
            actionButton.isHidden = false
            reportButton.isHidden = false
            chatButton.isHidden = true

        case K.Task.Types.notDone:
            actionButton.setTitle("Klarmarkera", for: .normal)
            actionButton.backgroundColor = #colorLiteral(red: 0.2969552577, green: 0.7483060956, blue: 0.3735412955, alpha: 1)
            actionButton.isHidden = false
            reportButton.isHidden = false
            chatButton.isHidden = true
                    
        case K.Task.Types.message:
            actionButton.isHidden = true
            reportButton.isHidden = true
            chatButton.isHidden = false
            
        default:
            break;
        }
    }
    
    func initLabels() {

        var updatedTime: String = ""
        var dateUpdatedTime: Date?
                
        if isReportedWithReason() {
            switch taskType {
            case K.Task.Types.message:
                taskBodyLabel.text = "Läst"
                
            default:
                taskBodyLabel.text = "Reported"
            }
            updatedTime = (task[K.Task.taskReportedAt] as? String) ?? (task[K.Task.orderUpdatedAt] as! String)
            
        } else {
            switch taskType {
            case K.Task.Types.notAccepted:
                
                taskTitleLabel.text = "Påminnelse att acceptera jobb"
                taskBodyLabel.text = isDone!
                    ? "Denna order har accepterats"
                    : "Denna order har inte accepterats"
                updatedTime = (task[K.Task.taskReportedAt] as? String) ?? (task[K.Task.orderUpdatedAt] as! String)
                
            case K.Task.Types.notBooked:
                taskTitleLabel.text = "Påminnelse att boka jobb"
                taskBodyLabel.text = isDone!
                    ? "Denna order är bokad"
                    : "Denna order är inte bokad"
                updatedTime = (task[K.Task.taskReportedAt] as? String) ?? (task[K.Task.orderUpdatedAt] as! String)
                
            case K.Task.Types.notDone:
                taskTitleLabel.text = "Påminnelse att klarmarkera jobb"
                taskBodyLabel.text = isDone!
                    ? "Denna order är slutförd"
                    : "Denna order är installerad"
                updatedTime = (task[K.Task.taskReportedAt] as? String) ?? (task[K.Task.installEndAt] as! String)
            
            case K.Task.Types.message:
                taskTitleLabel.text = "Kundmeddelande"
                taskBodyLabel.text = isDone!
                    ? "Läst"
                    : "Mottaget"
                updatedTime = (task[K.Task.taskReportedAt] as? String) ?? (task[K.Task.taskCreatedAt] as! String)
                
            default:
                taskTitleLabel.text = "Default"
                taskBodyLabel.text = "Default"
                updatedTime = (task[K.Task.taskReportedAt] as? String) ?? (task[K.Task.orderUpdatedAt] as! String)
            }
        }
        orderNumLabel.text = "Order: # " + String(task[K.Task.orderNum] as! Int)

        // TaskBody timestamp
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
        if dateFormatterGet.date(from: updatedTime) != nil {
            dateUpdatedTime = stringToDate(with: updatedTime)
        } else {
            dateUpdatedTime = stringToDate2(with: updatedTime)
        }
        let timeAgoString = dateUpdatedTime!.timeAgoDisplay()
        taskBodyLabel.text = taskBodyLabel.text! + " " + timeAgoString
    }
        
    func initColorBar() {
        switch taskType {
        case K.Task.Types.notAccepted:
            colorBarView.backgroundColor = #colorLiteral(red: 0.1528630555, green: 0.305911988, blue: 0.5881598592, alpha: 1)
            
        case K.Task.Types.notBooked:
            colorBarView.backgroundColor = #colorLiteral(red: 0.9563724399, green: 0.5896455646, blue: 0.2074120045, alpha: 1)

        case K.Task.Types.notDone:
            colorBarView.backgroundColor = #colorLiteral(red: 0.2969552577, green: 0.7483060956, blue: 0.3735412955, alpha: 1)
                    
        case K.Task.Types.message:
            colorBarView.backgroundColor = #colorLiteral(red: 0.9254901961, green: 0.3960784314, blue: 0.2784313725, alpha: 1)
            
        default:
            break
        }
    }
    
    func findOrder() {
        orderNum = task[K.Task.orderNum] as? Int
        orderId = task[K.Task.orderId] as? Int
                                   
        taskType = (task[K.Task.taskTypeText] as! String)
        
        let orderStatusId = task[K.Task.orderStatusId] as! Int
        switch orderStatusId
        {
        case K.OrderStatusId.unaccepted:
            annoType = K.Annotation.unacceptedJob
        case K.OrderStatusId.unbooked:
            annoType = K.Annotation.unbookedJob
        case K.OrderStatusId.booking:
            annoType = K.Annotation.bookingJob
        case K.OrderStatusId.booked:
            annoType = K.Annotation.bookedJob
        case K.OrderStatusId.done:
            annoType = K.Annotation.doneJob
        default:
            break
        }
    }
    
    
//MARK: - Methods
    
    func isReportedWithReason() -> Bool {
        return ((task[K.Task.reportedReasonId] as! Int) > 0) && isDone!
                ? true : false
    }
    
//MARK: - UI Actions
    @IBAction func actionButtonPressed(_ sender: Any) {
        
        selectedTask = task
        selectedOrderNum = orderNum
        selectedJob = singletonData.findJob(orderId: orderId!)
        if (selectedJob.count > 0) {
            selectedAnnoType = annoType
        } else {

            // TaskView.loadingStart
            let keyName1 = Notification.Name(rawValue: taskViewLoadingStartKey)
            NotificationCenter.default.post(name: keyName1, object: nil)

            jobManager.getJob(orderId!)
            selectedJob = singletonData.getOrder
            selectedAnnoType = (annoType == K.Annotation.bookedJob)
                ? K.Annotation.genericCalendarJob
                : K.Annotation.genericJob

            //TaskView.loadingStop
            let keyName2 = Notification.Name(rawValue: taskViewLoadingStopKey)
            NotificationCenter.default.post(name: keyName2, object: nil)

        }
        
        let keyName = Notification.Name(rawValue: taskActionAlertKey)
        NotificationCenter.default.post(name: keyName, object: nil)
    }
    
    @IBAction func reportButtonPressed(_ sender: Any) {
        
        selectedTask = task
        selectedJob = singletonData.findJob(orderId: orderId!)
        
        if (selectedJob.count > 0) {
            selectedAnnoType = annoType
        } else {
            // TaskView.loadingStart
            let keyName1 = Notification.Name(rawValue: taskViewLoadingStartKey)
            NotificationCenter.default.post(name: keyName1, object: nil)

            jobManager.getJob(orderId!)
            selectedJob = singletonData.getOrder
            selectedAnnoType = (annoType == K.Annotation.bookedJob)
                ? K.Annotation.genericCalendarJob
                : K.Annotation.genericJob
            
            //TaskView.loadingStop
            let keyName2 = Notification.Name(rawValue: taskViewLoadingStopKey)
            NotificationCenter.default.post(name: keyName2, object: nil)

        }
        
        let keyName = Notification.Name(rawValue: reportViewKey)
        NotificationCenter.default.post(name: keyName, object: nil)
    }
        
    @IBAction func chatButtonPressed(_ sender: Any) {
        
        // TaskView.loadingStart
        let keyName1 = Notification.Name(rawValue: taskViewLoadingStartKey)
        NotificationCenter.default.post(name: keyName1, object: nil)
        
        DispatchQueue.global(qos: .background).async { [self] in
            
            // Get CustomerChatModel
            let isRefreshChatSuccess = self.chatManager.refreshChat(self.orderId!)
            
            // Refresh Tasks
            self.taskManager.refreshTasks()
            
            DispatchQueue.main.async {
                
                //Reload TaskView
                let keyName3 = Notification.Name(rawValue: taskViewReloadDataKey)
                NotificationCenter.default.post(name: keyName3, object: nil)
                
                //TaskView.loadingStop
                let keyName = Notification.Name(rawValue: taskViewLoadingStopKey)
                NotificationCenter.default.post(name: keyName, object: nil)
                
                if isRefreshChatSuccess {
                    
                    selectedOrderId = self.orderId
                    selectedOrderNum = self.orderNum
                    
                    //To do: show Chat modal
                    let keyName2 = Notification.Name(rawValue: chatViewKey)
                    NotificationCenter.default.post(name: keyName2, object: nil)
                    
                } else {
                    
                    //TaskView.showErrorAlerrt
                    let keyName3 = Notification.Name(rawValue: taskViewShowErrorAlertKey)
                    NotificationCenter.default.post(name: keyName3, object: nil)
                    
                }
            }
        }
    }
    
    @IBAction func infoButtonPressed(_ sender: Any) {
        
        //Todo: get orderNum & annoType from message JSON object
        selectedJob = singletonData.findJob(orderId: orderId!)
        selectedOrderNum = orderNum
        
        if (selectedJob.count > 0) {
            selectedAnnoType = annoType
            
            //Load JobInfoView
            let keyName = Notification.Name(rawValue: jobInfoKey)
            NotificationCenter.default.post(name: keyName, object: nil)
            
        } else {
            
            // TaskView.loadingStart
            let keyName1 = Notification.Name(rawValue: taskViewLoadingStartKey)
            NotificationCenter.default.post(name: keyName1, object: nil)
            
            DispatchQueue.global(qos: .background).async {
                
                self.jobManager.getJob(self.orderId!)
                selectedJob = singletonData.getOrder
                selectedAnnoType = (self.annoType == K.Annotation.bookedJob)
                    ? K.Annotation.genericCalendarJob
                    : K.Annotation.genericJob
                print(singletonData.getOrder)
                
                DispatchQueue.main.async {

                    //TaskView.loadingStop
                    let keyName2 = Notification.Name(rawValue: taskViewLoadingStopKey)
                    NotificationCenter.default.post(name: keyName2, object: nil)

                    if (selectedJob.count > 0) {
                        
                        //Load JobInfoView
                        let keyName = Notification.Name(rawValue: jobInfoKey)
                        NotificationCenter.default.post(name: keyName, object: nil)

                    } else {

                        //TaskView.showErrorAlerrt
                        let keyName3 = Notification.Name(rawValue: taskViewShowErrorAlertKey)
                        NotificationCenter.default.post(name: keyName3, object: nil)

                    }
                }
            }
        }
    }
}
