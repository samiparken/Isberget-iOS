import Foundation
import UIKit
import FSCalendar

class BookingViewController: UIViewController {

    //UserDefault
    let defaults = UserDefaults.standard

    var calendar: FSCalendar!
    
    @IBOutlet weak var monthLabel: UILabel!
    @IBOutlet weak var confirmButton: UIButton!
    @IBOutlet weak var dateLabel: UILabel!
    
    var order = [String:Any]()
    var orderStatusId: Int?
    var orderStatus: String?
    var isUpdateMode: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //init Data
        
        initCalendar()
        getOrder()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        //init UI
        
        initButtons()
        checkIfUpdate()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToBooking2" {
            let vc = segue.destination as! BookingViewController2
            
            if isUpdateMode {
                let startString = order["Start"] as! String
                let startDate = stringToDate(with: startString)
                vc.selectedDate = (calendar.selectedDate == nil) ? startDate : calendar.selectedDate
            } else {
                vc.selectedDate = calendar.selectedDate
            }
            vc.orderStatusId = self.orderStatusId
            vc.orderStatus = self.orderStatus
        }
    }
    
//MARK: - Init
    func initCalendar() {
        
        let isWeekendOn = defaults.bool(forKey: K.UserDefaults.Settings.weekendSwitch)
        let offset: CGFloat = isWeekendOn ? 1 : (7/5)

        //Init calendarView
        calendar = FSCalendar(frame: CGRect(x: 0, y: 130 , width: view.frame.size.width * offset, height: 250))

        //Init appearance
        calendar.locale = NSLocale(localeIdentifier: "sv") as Locale
        calendar.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        calendar.scope = .month
        calendar.firstWeekday = 2
        calendar.scrollDirection = .horizontal
        calendar.appearance.headerDateFormat = "MMM yy"
        calendar.clipsToBounds = true
        calendar.appearance.todayColor = #colorLiteral(red: 0.8516124842, green: 0.3614110815, blue: 0.2571793721, alpha: 0.75)
        calendar.headerHeight = 0.0
        calendar.weekdayHeight = 20.0
        calendar.appearance.weekdayTextColor = #colorLiteral(red: 0.1546343565, green: 0.3047484159, blue: 0.5878322721, alpha: 1)
        calendar.appearance.headerMinimumDissolvedAlpha = 0.0
        calendar.placeholderType = .none
        
        //Set calendarView
        self.view.addSubview(calendar)
        
        //delegate
        calendar.delegate = self
        calendar.dataSource = self
        
        //init action
        let today = Date()
//        calendar.select(today)
        setMonthLabel(with: today)
    }
    
    func initButtons() {
        confirmButton.applyPanelButtonStyle()
        if let _ = calendar.selectedDate {
        } else {
            confirmDisabled()
        }
    }
    
    func checkIfUpdate() {
        if orderStatus == K.OrderStatus.booking
            || orderStatus == K.OrderStatus.booked {
            isUpdateMode = true
            self.performSegue(withIdentifier: "goToBooking2", sender: self)
        }
    }
    
    func getOrder() {
        self.order = singletonData.findJob(type: selectedAnnoType, with: String(selectedOrderNum!))

        self.orderStatusId = (order["OrderStatusId"] as? Int) ?? 0
        self.orderStatus = ((order["OrderStatus"] as? String) ?? K.OrderStatus.done).lowercased()
    }
    
//MARK: - Methods
    
    func setMonthLabel(with date: Date){
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM"
        monthLabel.text = dateFormatter.string(from: date)
    }
    
    func setDateLabel(with date: Date) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd, E"
        dateFormatter.locale = NSLocale(localeIdentifier: "sv") as Locale
        dateLabel.text = dateFormatter.string(from: date)
        dateLabel.textColor = UIColor.black
    }
    
    private func confirmEnabled() {
        confirmButton.setTitleColor(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1), for: .normal)
        confirmButton.backgroundColor = #colorLiteral(red: 0.1095948145, green: 0.3001712561, blue: 0.6087573171, alpha: 1)
        confirmButton.isEnabled = true
    }
    private func confirmDisabled() {
        confirmButton.setTitleColor(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.6646646664), for: .normal)
        confirmButton.backgroundColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
        confirmButton.isEnabled = false
    }

    
//MARK: - UI Actions
    @IBAction func closeButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func confirmButtonPressed(_ sender: Any) {
        self.performSegue(withIdentifier: "goToBooking2", sender: self)
    }
    
    @IBAction func leftButtonPressed(_ sender: Any) {
        let dateString = monthLabel.text! + "-15"
        let targetDate = stringToDate3(with: dateString) - K.aMonthInSeconds
        calendar.setCurrentPage(targetDate, animated: true)
    }
    
    @IBAction func rightButtonPressed(_ sender: Any) {
        let dateString = monthLabel.text! + "-15"
        let targetDate = stringToDate3(with: dateString) + K.aMonthInSeconds
        calendar.setCurrentPage(targetDate, animated: true)
    }
}

//MARK: - FSCalendarDelegate
extension BookingViewController: FSCalendarDelegate {

    // Select
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        confirmEnabled()
        setDateLabel(with: date)
    }

    //Auto Layout
    func calendar(_ calendar: FSCalendar, boundingRectWillChange bounds: CGRect, animated: Bool) {
        calendar.frame = CGRect(origin: calendar.frame.origin, size: bounds.size)
    }

    // Change
    func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
        setMonthLabel(with: calendar.currentPage)
    }

    // Valid for selection
    func calendar(_ calendar: FSCalendar, shouldSelect date: Date, at monthPosition: FSCalendarMonthPosition) -> Bool {
        let month = Calendar.current.component(.month, from: date)
        let month2 = Calendar.current.component(.month, from: calendar.currentPage)
        if ( month == month2 ) { return true }
        else { return false }
    }
    
    func minimumDate(for calendar: FSCalendar) -> Date {
        return Date()
    }
}

//MARK: - FSCalendarDataSource
extension BookingViewController: FSCalendarDataSource {
    
    // Event Image for custom dots
    func calendar(_ calendar: FSCalendar, imageFor date: Date) -> UIImage? {
        
        let ymdString = dateToString_ymd(with: date)
        if let targetDate = singletonData.calendarEventDots[ymdString] {

            let colorDotImage: UIImage = calendar.generateColorDotImage(date: targetDate)
            
            return colorDotImage
        } else {
            return nil
        }
    }
}


