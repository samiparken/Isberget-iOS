import UIKit
import MessageUI

class TabBarViewController: UITabBarController {
    
    let defaults = UserDefaults.standard
    let tabBarManager = TabBarManager()
    let jobManager = JobManager()
    let taskManager = TaskManager()
    
    //Data
    var isInstallerOffset: Int = 0
    
    // for Notification Observers
    let keyUpdateBadges = Notification.Name(rawValue: updateBadgesKey)
    let keyUpdateBadge4 = Notification.Name(rawValue: updateBadge4Key)
    let keyTaskActionAlert = Notification.Name(rawValue: taskActionAlertKey)
    let keyChat = Notification.Name(rawValue: chatViewKey)
    let keyReport = Notification.Name(rawValue: reportViewKey)
    let keyInfo = Notification.Name(rawValue: jobInfoKey)
    let keyBooking = Notification.Name(rawValue: jobBookingViewKey)
    let keyMessage = Notification.Name(rawValue: sendAMessageKey)
    let keyProtocol = Notification.Name(rawValue: jobProtocolKey)
    let keyPushNotification = Notification.Name(rawValue: pushNotificationMsgKey)

    override func viewDidLoad() {
        super.viewDidLoad()
        // Data Init
        print("TabBarVC: viewDidLoad() Start")
        
        // start location service
        locationManager.coreLocation.startUpdatingLocation()
        initTabs()

        initListOfInstallers()
        registerObservers()
    }
        
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        print("TabBarVC: viewWillAppear()")

        jobManager.getInitialData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        print("TabBarVC: viewDidAppear()")
        clearBadges()
    }
        
//MARK: - Init
    func initTabs() {
        let isInstaller = defaults.bool(forKey: K.UserDefaults.isInstaller)
        isInstallerOffset = isInstaller ? 2 : 0
        if isInstaller {
            self.viewControllers![0].removeFromParent() //hide tab for JobTaskView
            self.viewControllers![0].removeFromParent() //hide tab for JobAcceptView
        }
    }
    
    func clearBadges() {
        let isInstaller = defaults.bool(forKey: K.UserDefaults.isInstaller)

        self.viewControllers![0].tabBarItem.badgeValue = nil
        self.viewControllers![1].tabBarItem.badgeValue = nil
        if(!isInstaller) {
            self.viewControllers![2].tabBarItem.badgeValue = nil
            self.viewControllers![3].tabBarItem.badgeValue = nil
        }
    }
    
    // for filtering
    func initListOfInstallers() {
        var allUsers = (self.defaults.array(forKey: K.UserDefaults.usersInCompany) as! [[String: Any]])
        var onUsersId = [Int]()
        
        let installerId = self.defaults.integer(forKey: K.UserDefaults.user_id)
        let isInstaller = self.defaults.bool(forKey: K.UserDefaults.isInstaller)
        
        if isInstaller {
            allUsers = allUsers.filter { ($0["userId"] as! Int) == installerId }
        }
        
        for (index, _) in allUsers.enumerated() {
            allUsers[index]["on"] = true
            onUsersId.append( (allUsers[index]["userId"] as! Int) )
        }
        
        singletonData.listOfInstallers = allUsers
        singletonData.onInstallersId = onUsersId
    }
    
//MARK: - Methods
    // with == 0: all tabs
    // with == 1~4: target tab
    func updateBadges(with: Int = 0) {
        let isInstaller = defaults.bool(forKey: K.UserDefaults.isInstaller)

        // Tab 1 Badge - Task
        if ((with == 0 || with == 1) && !isInstaller){
            var i: Int = 0
            for message in singletonData.getTasks {
                i = message[K.Task.isDone] as! Bool ? i : i + 1
            }
            self.viewControllers![0].tabBarItem.badgeValue = i == 0 ? nil : String(i)
        }
        
        // Tab 2 Badge - JobAccept
        if ((with == 0 || with == 2) && !isInstaller) {
            let count2 = filterJob( singletonData.getUnacceptedJobs ).count
            self.viewControllers![1].tabBarItem.badgeValue = count2 == 0 ? nil : String(count2)
        }
        
        // Tab 3 Badge - JobBook
        if (with == 0 || with == 3) {
            let count3 = filterJob( singletonData.getUnbookedJobs ).count
            self.viewControllers![2-isInstallerOffset].tabBarItem.badgeValue = count3 == 0 ? nil : String(count3)
        }
        
        // Tab 4 Badge - JobToday
        if (with == 0 || with == 4) {
            let count4 = selectedTodayJobsWithDate.count
            self.viewControllers![3-isInstallerOffset].tabBarItem.badgeValue = count4 == 0 ? nil : String(count4)
        }
    }
        
}

//MARK: - For Notification Observers
extension TabBarViewController {
        
    // Register Observers for updates
    func registerObservers() {
        // Update All Badges
        NotificationCenter.default.addObserver(self, selector: #selector(TabBarViewController.updateAllBadges(notification:)), name: keyUpdateBadges, object: nil)
        
        // Update Badge4
        NotificationCenter.default.addObserver(self, selector: #selector(TabBarViewController.updateBadge4(notification:)), name: keyUpdateBadge4, object: nil)

        // Booking
        NotificationCenter.default.addObserver(self, selector: #selector(TabBarViewController.showBookingView(notification:)), name: keyBooking, object: nil)

        // Task Action Alert
        NotificationCenter.default.addObserver(self, selector: #selector(TabBarViewController.taskActionAlert(notification:)), name: keyTaskActionAlert, object: nil)
        
        // Report
        NotificationCenter.default.addObserver(self, selector: #selector(TabBarViewController.showReport(notification:)), name: keyReport, object: nil)
        
        // Chat
        NotificationCenter.default.addObserver(self, selector: #selector(TabBarViewController.showChat(notification:)), name: keyChat, object: nil)
        
        // Info
        NotificationCenter.default.addObserver(self, selector: #selector(TabBarViewController.showInfo(notification:)), name: keyInfo, object: nil)
        
        // SMS
        NotificationCenter.default.addObserver(self, selector: #selector(TabBarViewController.textAMessage(notification:)), name: keyMessage, object: nil)
        
        // Protocol
        NotificationCenter.default.addObserver(self, selector: #selector(TabBarViewController.showProtocol(notification:)), name: keyProtocol, object: nil)
        
        // Push Notification
        NotificationCenter.default.addObserver(self, selector: #selector(TabBarViewController.pushNotificationMsgHandler(notification:)), name: keyPushNotification, object: nil)
    }
    
    @objc func pushNotificationMsgHandler(notification: NSNotification) {

        let jsonData = tabBarManager.getPushNotificationData()
        let dataType = (jsonData["type"] as? String) ?? "none"
        
        let msgText = tabBarManager.getPushNotificationText()

        // Actions
        switch dataType {
        case K.Notification.newJob:
            jobManager.refreshUnacceptedJobs()
            self.showAlert(title: msgText, message: "")
            
        case K.Notification.jobUpdate:
            let dataOrderId = (jsonData["orderId"] as? Int) ?? 0
            
            // + have to get an updated order here.
            
            let showOrderAction = UIAlertAction(title: "Se", style: .default) { [self]_ in
                
                selectedJob = singletonData.findJob(orderId: dataOrderId)
                DispatchQueue.main.async {
                    
                    self.presentedViewController?.dismiss(animated: true, completion: nil)
                    
                    self.performSegue(withIdentifier: "goToInfoView", sender: self)
                }
            }
            self.showAlert(title: msgText, message: "", defaultButtonText: "Avbryt", actions: [showOrderAction])
            
        case K.Notification.jobAccepted: //means jobBooking -> jobBooked
            jobManager.refreshBookingAndBookedJobs()
            self.showAlert(title: msgText, message: "")
            
        case K.Notification.bookJob:
            self.showAlert(title: msgText, message: "")

        case K.Notification.jobCancelled:
            self.showAlert(title: msgText, message: "")

        default: break
        }
    }
    
    @objc func updateAllBadges(notification: NSNotification) {
        print("updateAllBadges()")
        updateBadges()
    }
    
    @objc func updateBadge4(notification: NSNotification) {
        print("updateBadge: Dagens Jobb")
        updateBadges(with: 4)
    }
    
    @objc func taskActionAlert(notification: NSNotification) {
                
        var alertTitle: String?
        let alertMessage = "Order: # " + String(selectedOrderNum!)
        
        switch selectedAnnoType {
        case K.Annotation.unacceptedJob:
            alertTitle = "Acceptera Jobb?"
        case K.Annotation.unbookedJob:
            alertTitle = "Boka Jobb?"
        case K.Annotation.bookedJob:
            alertTitle = "Klarmarkera?"
        case K.Annotation.genericCalendarJob:
            alertTitle = "Klarmarkera?"
        default:
            alertTitle = "Något gick fel. Klika Avbryt."
        }
        
        let action = UIAlertAction(title: "OK", style: .default) { [self]_ in
                        
            switch selectedAnnoType {
            case K.Annotation.unacceptedJob:
                selectedViewType = K.JobAccept.type
                selectedAcceptOrderId = (selectedJob["OrderId"] as! Int)
                selectedAcceptOrderNum = selectedOrderNum

                let taskId = (selectedTask[K.Task.taskId] as! Int)
                taskManager.setTaskDone(taskId)
                jobManager.refreshTasks()

                let keyName = Notification.Name(rawValue: jobAcceptAcceptJobKey)
                NotificationCenter.default.post(name: keyName, object: nil)
                
            case K.Annotation.unbookedJob:
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: "goToBookingView", sender: self)
                }
                                                
            case K.Annotation.bookedJob:
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: "goToProtocolView", sender: self)
                }

            case K.Annotation.genericCalendarJob:
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: "goToProtocolView", sender: self)
                }
                
            default:
                break
            }
        }
                
        self.showAlert(title: alertTitle!, message: alertMessage, defaultButtonText: "Avbryt", actions: [action])
    }
    
    @objc func showReport(notification: NSNotification) {
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "goToReportView", sender: self)
        }
    }

    @objc func showChat(notification: NSNotification) {
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "goToChatView", sender: self)
        }
    }
    
    @objc func showInfo(notification: NSNotification) {
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "goToInfoView", sender: self)
        }
    }
    
    @objc func showBookingView(notification: NSNotification) {
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "goToBookingView", sender: self)
        }
    }
    
    @objc func showProtocol(notification: NSNotification) {
        DispatchQueue.main.async {
            self.performSegue(withIdentifier: "goToProtocolView", sender: self)
        }
    }
    
    @objc func textAMessage(notification: NSNotification) {
        
        let composeVC = MFMessageComposeViewController()
        composeVC.messageComposeDelegate = self
        
        // Configure the fields of the interface.
        composeVC.recipients = [selectedPhoneNumber!]
        
        // Present the view controller modally.
        if MFMessageComposeViewController.canSendText() {
            self.present(composeVC, animated: true, completion: nil)
        }
    }
}

//MARK: - MFMessageComposeViewControllerDelegate
extension TabBarViewController: MFMessageComposeViewControllerDelegate {
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        dismiss(animated: true, completion: nil)
    }
}

