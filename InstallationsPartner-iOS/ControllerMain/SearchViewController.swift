import Foundation
import UIKit

class SearchViewController: UIViewController {
    
    let jobManager = JobManager()
    
    //Search Bar
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var searchButton: UIButton!
    
    //Check Buttons
    @IBOutlet weak var unacceptedCheckButton: UIButton!
    @IBOutlet weak var unbookedCheckButton: UIButton!
    @IBOutlet weak var bookingCheckButton: UIButton!
    @IBOutlet weak var bookedCheckButton: UIButton!
    @IBOutlet weak var doneCheckButton: UIButton!
    var offOrderStatusList = [String]()
    
    //Period Picker
    @IBOutlet weak var periodButton: UIButton!
    @IBOutlet weak var segmentedControlView: UIView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var datePickerView: UIView!
    var datePicker = UIDatePicker()
    @IBOutlet weak var startPeriodTextField: UITextField!
    @IBOutlet weak var endPeriodTextField: UITextField!
    var isHiddenDatePicker: Bool = true
    var isFocusOnStartPeriod: Bool = true
    var isNewPeriod: Bool = true
    
    // SearchTableView
    @IBOutlet weak var spinnerView: UIView!
    @IBOutlet weak var searchTableView: UITableView!

    // TabbarItem for BadgeValue
    @IBOutlet weak var tabbarItem: UITabBarItem!
    
    var resultJobs = [[String:Any]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //delegate
        searchTableView.delegate = self
        searchTableView.dataSource = self
                
        initViews()
        initSegmentedControl()
        initDatePicker()
        initRefreshControl()
    }
    

//MARK: - Init
    func initViews() {
        segmentedControlView.isHidden = true
        datePickerView.isHidden = true
        spinnerView.isHidden = true
    }
    
    func initSegmentedControl() {
        let font = UIFont.boldSystemFont(ofSize: 12)
        let segAttribute: [NSAttributedString.Key: Any] = [.font: font, .foregroundColor: UIColor.darkGray]
        segmentedControl.setTitleTextAttributes(segAttribute, for: .normal)
        segmentedControl.setTitleTextAttributes(segAttribute, for: .selected)
    }
    
    func initDatePicker() {
        
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.locale = NSLocale(localeIdentifier: "sv") as Locale
        
        //toolbar
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        //bar button
        let doneButton = UIBarButtonItem(title: "klar", style: .done, target: nil, action: #selector(datePickerDonePressed))
        toolbar.setItems([doneButton], animated: true)
        
        //assign toolbar
        startPeriodTextField.inputAccessoryView = toolbar
        endPeriodTextField.inputAccessoryView = toolbar

        // assign date picker to the text field
        startPeriodTextField.inputView = datePicker
        endPeriodTextField.inputView = datePicker
        
        setPeriod(month: 1)
    }
    
    func initRefreshControl() {
        // Refresh Control
        searchTableView.refreshControl = UIRefreshControl()
        searchTableView.refreshControl?.addTarget(self, action: #selector(didPullToRefresh), for: .valueChanged)
    }

//MARK: - Methods
    
    @objc private func didPullToRefresh() {
        // + hit search button
        
        DispatchQueue.main.asyncAfter(deadline: .now()+2) {
            self.searchTableView.refreshControl?.endRefreshing()
            // + refresh badge
            self.searchTableView.reloadData()
        }
    }
    
    func setPeriod(month: Int) {
        let today = Date()

        switch month {
        case 1:
            periodButton.setTitle(" En månad sedan", for: .normal)
        case 3:
            periodButton.setTitle(" 3 månader sedan", for: .normal)
        default:
            periodButton.setTitle(" Period", for: .normal)
        }

        let monthAgo = today - ( K.aMonthInSeconds * Double(month))
//        let monthLater = today + ( K.aMonthInSeconds * Double(month))
        
        let agoString = dateToString_ymd(with: monthAgo)
        let laterString = dateToString_ymd(with: today)
        
        startPeriodTextField.text = agoString
        endPeriodTextField.text = laterString
    }
    
    func updateBadge(with value: Int) {
        tabbarItem.badgeValue = value <= 0 ? nil : String(value)
    }
    
    func prepareSearchRequest() {
        self.view.endEditing(true)
        spinnerView.isHidden = false
        let startDate = stringToDate3(with: startPeriodTextField.text!)
        let endDate = stringToDate3(with: endPeriodTextField.text!)
        let keyword = (searchTextField.text ?? "").lowercased()
        DispatchQueue.global(qos: .background).async {
            self.searchRequest(keyword, startDate, endDate)
        }
    }
    
    func searchRequest(_ keyword: String, _ startDate: Date, _ endDate: Date) {
        if isNewPeriod {
            isNewPeriod = false
            jobManager.searchJobsWithPeriod(start: startDate, end: endDate)
        }
        
        //filter jobs with Status
        resultJobs = singletonData.getSearchJobs
        
        // Filter(keyword)
        if keyword != "" {
            resultJobs = resultJobs.filter {
                
                //filter(orderNum)
                String(($0["Order_number_on_client"] as? Int) ?? 0).contains(keyword)
                    || String(($0["order_number_on_client"] as? Int) ?? 0).contains(keyword)
                    
                //filter(CustomerName)
                    || (($0["FullName"] as? String) ?? "").lowercased().contains(keyword)
                    || (($0["Description"] as? String) ?? "").lowercased().contains(keyword)
            }
        }
        
        // filter (OrderStatus)
        for status in offOrderStatusList {
            resultJobs = resultJobs.filter { ($0["OrderStatus"] as! String).lowercased() != status }
        }
        
        DispatchQueue.main.async {
            //searchTableView.reloadData()
            self.searchTableView.reloadData()

            //updateBadge
            self.updateBadge(with: self.resultJobs.count)
            
            // spinner stop
            self.spinnerView.isHidden = true
        }
    }

//MARK: - UI Actions
    @objc func datePickerDonePressed() {
        let dateString = dateToString_ymd(with: datePicker.date)
        if isFocusOnStartPeriod {
            startPeriodTextField.text = dateString
        } else {
            endPeriodTextField.text = dateString
        }
        self.view.endEditing(true)
    }
    
    @IBAction func orderStatusCheckButtonPressed(_ sender: UIButton) {
        var orderStatus: String?
        
        switch sender {
        case unacceptedCheckButton:
            orderStatus = K.OrderStatus.unaccepted
        case unbookedCheckButton:
            orderStatus = K.OrderStatus.unbooked
        case bookingCheckButton:
            orderStatus = K.OrderStatus.booking
        case bookedCheckButton:
            orderStatus = K.OrderStatus.booked
        case doneCheckButton:
            orderStatus = K.OrderStatus.done
        default:
            return
        }
        
        let count = (offOrderStatusList.filter {$0 == orderStatus} ).count
        if count != 0 {
            sender.setChecked()
            offOrderStatusList = offOrderStatusList.filter {$0 != orderStatus}
        } else {
            sender.setUnchecked()
            offOrderStatusList.append(orderStatus!)
        }
    }
    
    @IBAction func searchTextFieldChanged(_ sender: Any) {
        if searchTextField.text == "" {
            resultJobs = [[String:Any]]()
            searchTableView.reloadData()
        }
    }
    @IBAction func searchTextFieldActionTriggered(_ sender: Any) {
        prepareSearchRequest()
    }
    @IBAction func searchButtonPressed(_ sender: Any) {
        prepareSearchRequest()
    }

    @IBAction func periodButtonPressed(_ sender: Any) {
        segmentedControlView.isHidden = !segmentedControlView.isHidden
        
        datePickerView.isHidden = segmentedControlView.isHidden
            ? true
            : isHiddenDatePicker
    }
    
    @IBAction func segmentedControlValueChanged(_ sender: Any) {
        let index = segmentedControl.selectedSegmentIndex
        isNewPeriod = true

        switch index {
        case 0: //+-1month
            isHiddenDatePicker = true
            datePickerView.isHidden = true
            setPeriod(month: 1)
            
        case 1: //+-3months
            isHiddenDatePicker = true
            datePickerView.isHidden = true
            setPeriod(month: 3)

        case 2: //Period
            isHiddenDatePicker = false
            datePickerView.isHidden = false
            setPeriod(month: 0)
            
        default: break
        }
    }
    
    @IBAction func startPeriodEditBegin(_ sender: Any) {
        isFocusOnStartPeriod = true
        isNewPeriod = true
        let startDate = stringToDate3(with: startPeriodTextField.text!)
        let endDate = stringToDate3(with: endPeriodTextField.text!)
        
        datePicker.date = startDate
        datePicker.minimumDate = nil
        datePicker.maximumDate = endDate
    }
    
    @IBAction func endPeriodEditBegin(_ sender: Any) {
        isFocusOnStartPeriod = false
        isNewPeriod = true
        let startDate = stringToDate3(with: startPeriodTextField.text!)
        let endDate = stringToDate3(with: endPeriodTextField.text!)

        datePicker.date = endDate
        datePicker.minimumDate = startDate
        datePicker.maximumDate = nil
    }
}

//MARK: - UITableViewDelegate
extension SearchViewController: UITableViewDelegate {
    
}

//MARK: - UITableViewDataSource
extension SearchViewController: UITableViewDataSource {
    
    //Num of rows
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return resultJobs.count
    }
    
    //Cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let job = resultJobs[indexPath.row]
        
        let cell: SearchCell = tableView.dequeueReusableCell(withIdentifier: "SearchCell") as! SearchCell
        
        cell.job = job
        cell.initCell()
        
        return cell
    }
}
