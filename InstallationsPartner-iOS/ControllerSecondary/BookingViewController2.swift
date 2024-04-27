import Foundation
import UIKit

class BookingViewController2: UIViewController {

    // Manager
    let jobManager = JobManager()
    let taskManager = TaskManager()
    let bookingManager = BookingManager()
    
    // Top Date Label
    @IBOutlet weak var dateLabel: UILabel!
    
    // Timeline selector
    @IBOutlet weak var timelineTableView: UITableView!
    var selectedCell: Int = 0  //0700
    
    // Installer Picker
    @IBOutlet weak var selectInstaller: UITextField!
    var pickerView = UIPickerView()

    // Start Time Picker
    @IBOutlet weak var startTimePicker: UIDatePicker!
    
    // End Time Picker
    @IBOutlet weak var endTimePicker: UIDatePicker!
    
    // Date
    var selectedDate: Date?
    var selectedDurationMin: Double = 180
    
    // Date Config
    let GMT: Double = Double(TimeZone.current.secondsFromGMT()) / 3600
    var GMTString: String?
    let dateFormatter = DateFormatter()
    
    // Duration
    @IBOutlet weak var durationLabel: UILabel!
    
    // Buttons
    @IBOutlet weak var bookButton: UIButton!
    @IBOutlet weak var suggestButton: UIButton!
    
    // Spinner
    @IBOutlet weak var spinnerView: UIView!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    var isUpdateMode: Bool = false
    var occupiedCell = [[String:Any]]()
    // [ "Start": Date,
    //   "Duration" : Double ]
    
    // For booking Endpoints
    var order = [String:Any]()
    var orderId: Int?
    var orderStatus: String?
    var orderStatusId: Int?
    var taskCompanyId: Int?
    var installerId: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //delegate
        timelineTableView.delegate = self
        timelineTableView.dataSource = self
        pickerView.delegate = self
        pickerView.dataSource = self
        
        // Register JobAcceptCell
        timelineTableView.register(UINib(nibName: K.Booking.Cell, bundle: nil), forCellReuseIdentifier: K.Booking.Cell)
   
        getOrder()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)

        initSpinner()
        initInstallerSelector()
        initDate()
        initDateLabel()
        initDatePicker()
        initButtons()
        initTimeline()
        refreshDuration()
    }
    
//MARK: - Init
    func initInstallerSelector() {
        selectInstaller.inputView = pickerView
        
        if ( isUpdateMode ) {
            selectInstaller.text = (order["ResourceName"] as! String)
            installerId = Int(order["ResourceId"] as! String)
        }
    }
    
    func initDate() {
        GMTString = String(format: "%+05d", Int(GMT) * 100)
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"  //ex) 2020-03-13 13:37:00 +0100
    }
    
    func initDatePicker() {
        
        var startDate: Date?
        var endDate: Date?
        
        if ( isUpdateMode ) {
            
            let startString = order["Start"] as! String
            let endString = order["End"] as! String
            
            startDate = stringToDate(with: startString)
            endDate = stringToDate(with: endString)

        } else {
            let ymd = dateToString_ymd(with: selectedDate!)
            let startDateString = ymd + " 07:00:00 " + GMTString!
            let endDateString = ymd + " 10:00:00 " + GMTString!

            startDate = dateFormatter.date(from: startDateString)
            endDate = dateFormatter.date(from: endDateString)
        }
        
        startTimePicker.setDate(startDate!, animated: true)
        endTimePicker.setDate(endDate!, animated: true)
    }
    
    func initDateLabel() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd, E"
        dateFormatter.locale = NSLocale(localeIdentifier: "sv") as Locale
        dateLabel.text = dateFormatter.string(from: selectedDate!)
        dateLabel.textColor = UIColor.white
    }
    
    func initButtons() {
        bookButton.applyPanelButtonStyle()
        suggestButton.applyPanelButtonStyle()
                
        bookButton.titleLabel?.lineBreakMode = NSLineBreakMode.byWordWrapping;

        if isUpdateMode {
            bookButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
            bookButton.setTitle(" Ändra\n Bokning", for: .normal)
            bookEnabled()
            
        } else {
            bookDisabled()
        }
    }
    
    func initSpinner() {
        spinnerView.isHidden = true
    }
    
    func initTimeline() {
        if isUpdateMode {
            
            let startString = order["Start"] as! String
            let endString = order["End"] as! String
            
            let startDate = stringToDate(with: startString)
            let endDate = stringToDate(with: endString)
                        
            let duration = (endDate.timeIntervalSince1970 - startDate.timeIntervalSince1970) / 60
            
            occupiedCell = bookingManager.calculateOccupiedCell(id: installerId!, selectedDate!)
            
            occupiedCell = occupiedCell.filter {
                ($0["Start"] as! Date) != startDate
                    && ($0["Duration"] as! Double) != duration }
        }
        timelineTableView.reloadData()
    }
    
    func getOrder() {
        self.order = singletonData.findJob(type: selectedAnnoType, with: String(selectedOrderNum!))

        // for Endpoints
        self.orderStatusId = (order["OrderStatusId"] as? Int) ?? 0
        
        if orderStatus == K.OrderStatus.booking
            || orderStatus == K.OrderStatus.booked {
            isUpdateMode = true
        }
        
        self.orderId = isUpdateMode
            ? (order["Id"] as? Int) ?? (order["OrderId"] as? Int) ?? 0
            : (order["OrderId"] as? Int) ?? 0

        self.taskCompanyId = (order["Task_Company_Id"] as? Int) ?? 0
    }
    
//MARK: - Methods
    
    func refreshDuration() {
        selectedDurationMin = (endTimePicker.date.timeIntervalSince1970 - startTimePicker.date.timeIntervalSince1970) / 60
        if ( selectedDurationMin > 0 ) {
            durationLabel.text = String(Int(selectedDurationMin)) + " minuter"
        }
        else {
            durationLabel.text = "0 minut"
        }
    }
    
    func checkIfEnable() {
        if (selectInstaller.text != "Välj") && (durationLabel.text != "0 minut") {
            bookEnabled()
        } else {
            bookDisabled()
        }
    }
    
    private func bookEnabled() {
        bookButton.setTitleColor(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1), for: .normal)
        bookButton.backgroundColor = #colorLiteral(red: 0, green: 0.854619801, blue: 0.440415442, alpha: 1)
        bookButton.isEnabled = true
        
        suggestButton.setTitleColor(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1), for: .normal)
        suggestButton.backgroundColor = #colorLiteral(red: 0.9922186732, green: 0.7991269231, blue: 0.2083972692, alpha: 1)
        suggestButton.isEnabled = true

    }
    private func bookDisabled() {
        bookButton.setTitleColor(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.6646646664), for: .normal)
        bookButton.backgroundColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
        bookButton.isEnabled = false

        suggestButton.setTitleColor(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.6646646664), for: .normal)
        suggestButton.backgroundColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
        suggestButton.isEnabled = false
    }
    
    private func isSelectedTask() -> Bool {
        let taskOrderId = (selectedTask[K.Task.orderId] as? Int) ?? 0
        return taskOrderId == orderId ? true : false
    }
    
//MARK: - UI Actions
    @IBAction func backButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func startTimeChanged(_ sender: Any) {
        if startTimePicker.date > endTimePicker.date {
            startTimePicker.date = endTimePicker.date
        }
        refreshDuration()
        checkIfEnable()

        let calendar = Calendar.current
        let startTime = startTimePicker.date
        let hour = calendar.component(.hour, from: startTime)
        selectedCell = hour - 7 //start from 7
        timelineTableView.reloadData()
        }
    
    @IBAction func endTimeChanged(_ sender: Any) {
        if startTimePicker.date > endTimePicker.date {
            endTimePicker.date = startTimePicker.date
        }
        
        refreshDuration()
        checkIfEnable()
        timelineTableView.reloadData()
    }
    
    
    @IBAction func bookButtonPressed(_ sender: Any) {
        
        if isUpdateMode {
            jobManager.updateJob(startTime: startTimePicker.date, endTime: endTimePicker.date, installerId: installerId!, orderId: orderId!, orderStatudId: 11)
            
            spinnerView.isHidden = true
            spinner.stopAnimating()

            // refresh JobTodayView
            let keyName = Notification.Name(rawValue: refreshJobTodayKey)
            NotificationCenter.default.post(name: keyName, object: nil)
            
            self.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)

        } else {
            jobManager.bookJob(suggest: false, orderId!, taskCompanyId!, installerId!, startTimePicker.date, endTimePicker.date)
            
            spinnerView.isHidden = true
            spinner.stopAnimating()
            
            let response = singletonData.bookJobResponse
            if response != "\"success\"" {
                showAlert(title: response, message: "")
            } else {
                // if success, dismiss the view and update the screen
                let keyName = Notification.Name(rawValue: jobBookDoneKey)
                NotificationCenter.default.post(name: keyName, object: nil)
                
                jobManager.refreshUnbookedJobs()
                jobManager.refreshBookingAndBookedJobs()
                                
                if (isSelectedTask())
                {
                    let taskId = (selectedTask[K.Task.taskId] as! Int)
                    taskManager.setTaskDone(taskId)
                    jobManager.refreshTasks()
                }
                                
                self.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
            }
        }
    }
    @IBAction func bookButtonTouchDown(_ sender: Any) {
        spinnerView.isHidden = false
        spinner.startAnimating()
    }
    
    @IBAction func suggestButtonPressed(_ sender: Any) {
    
        if isUpdateMode {
            jobManager.updateJob(startTime: startTimePicker.date, endTime: endTimePicker.date, installerId: installerId!, orderId: orderId!, orderStatudId: 4)
            
            spinnerView.isHidden = true
            spinner.stopAnimating()

            // refresh JobTodayView
            let keyName = Notification.Name(rawValue: refreshJobTodayKey)
            NotificationCenter.default.post(name: keyName, object: nil)
            
            self.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)

        } else {
            jobManager.bookJob(suggest: true, orderId!, taskCompanyId!, installerId!, startTimePicker.date, endTimePicker.date)
            
            spinnerView.isHidden = true
            spinner.stopAnimating()
            
            let response = singletonData.suggestJobResponse
            if response != "\"success\"" {
                showAlert(title: response, message: "")
            } else {
                // if success, dismiss the view and update the screen
                
                let keyName = Notification.Name(rawValue: jobBookDoneKey)
                NotificationCenter.default.post(name: keyName, object: nil)
                
                jobManager.refreshUnbookedJobs()
                jobManager.refreshBookingAndBookedJobs()
                                
                if (isSelectedTask())
                {
                    let taskId = (selectedTask[K.Task.taskId] as! Int)
                    taskManager.setTaskDone(taskId)
                    jobManager.refreshTasks()
                }

                self.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
            }
        }
    }
    @IBAction func suggestButtonTouchDown(_ sender: Any) {
        spinnerView.isHidden = false
        spinner.startAnimating()
    }
}

//MARK: - UIPickerViewDelegate
extension BookingViewController2: UIPickerViewDelegate {
    
}

//MARK: - UIPickerViewDataSource
extension BookingViewController2: UIPickerViewDataSource {
    
    //Num of Columns
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    //Num of Rows
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        //number of installers
        return singletonData.getUsersInCompany.count
    }
    
    //titleForRow
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        //name of installers
        return (singletonData.getUsersInCompany[row]["userDisplayName"] as? String) ?? "-"
    }
    
    //didSelectRow
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectInstaller.text = (singletonData.getUsersInCompany[row]["userDisplayName"] as? String) ?? "-"
        installerId = (singletonData.getUsersInCompany[row]["userId"] as? Int) ?? 0
        occupiedCell = bookingManager.calculateOccupiedCell(id: installerId!, selectedDate!)
        
        print(occupiedCell)
        
        selectInstaller.resignFirstResponder()
        timelineTableView.reloadData()
        checkIfEnable()
    }
}

//MARK: - UITableViewDelegate
extension BookingViewController2: UITableViewDelegate {
    
    // didSelect
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedCell = indexPath.row
        timelineTableView.reloadData()
        
        let ymd = dateToString_ymd(with: selectedDate!)
        let startDateString = ymd + String(format: " %02d", selectedCell+7) + ":00:00 " + GMTString!
        let endDateString = ymd + String(format: " %02d", selectedCell+10) + ":00:00 " + GMTString!
        let startDate = dateFormatter.date(from: startDateString)
        let endDate = dateFormatter.date(from: endDateString)
        
        startTimePicker.setDate(startDate!, animated: true)
        endTimePicker.setDate(endDate!, animated: true)
        refreshDuration()
        checkIfEnable()
    }
}

//MARK: - UITableViewDataSource
extension BookingViewController2: UITableViewDataSource {
    
    // Number of Rows
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 12
    }
    
    // Height for row
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return timelineTableView.frame.height / 12
    }
    
    // Cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
                
        let cell = tableView.dequeueReusableCell(withIdentifier: K.Booking.Cell, for: indexPath)
            as! TimelineCell   //Casting Cell

        cell.cellWidth = timelineTableView.frame.width
        cell.cellHeight = timelineTableView.frame.height / 12
        cell.hour = indexPath.row + 7// start from 0700
        
        if ( selectedCell == indexPath.row ) {
            cell.setColorArea(startTime: startTimePicker.date, durationMin: selectedDurationMin)
        } else {
            cell.removeColorArea()
        }

        cell.removeOccupiedArea()
        cell.occupiedArea(occupiedCell)
        
        cell.hourLabel.text = String(indexPath.row + 7)
        
        return cell
    }
}
