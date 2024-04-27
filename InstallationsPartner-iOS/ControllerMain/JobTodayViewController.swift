import UIKit
import MapKit
import FSCalendar
import FloatingPanel

class JobTodayViewController: UIViewController {

    //UserDefault
    let defaults = UserDefaults.standard

    //Views
    @IBOutlet weak var mapView: MKMapView!
    var calendar: FSCalendar!

    @IBOutlet weak var selectedDateButton: UIButton!
    @IBOutlet weak var tabbarItem: UITabBarItem!
    
    //Manager
    let jobManager = JobManager()
    let tabbarManager = TabBarManager()
    
    //FloatingPanel
    let fpc = FloatingPanelController()
    
    //For AnnotationCalloutView
    var mapViewHeight: CGFloat?
    var isBeingSelected: Bool = false
    var isBeingViewAll: Bool = false
    var isYellowOn: Bool = true
    var isGreenOn: Bool = true
    var isGrayOn: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("JobTodayVc: viewDidLoad() Start")

        //Delegate
        mapView.delegate = self
        fpc.delegate = self

        //Init Components
        registerObservers()
                
        initFloatingPanel()
        initButtons()
        initCalendar()
        initAnnotations()
        
        singletonData.mapViewHeight = mapView.frame.height
        
        print("JobTodayVC: viewDidLoad() Done")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        print("JobTodayVC: viewWillAppear()")
        updateCalendar()    //shared calendar
        refreshPanel()
        refreshBadge()
        viewAllTodayJob()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let firstTouch = touches.first {
            let hitView = self.view.hitTest(firstTouch.location(in: self.view), with: event)

            if (hitView != calendar) && (calendar.scope == .month) {
                calendar.setScope(.week, animated: true)
            }
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    //MARK: - For Notification Observers
    
    // for Notification Observers
    let keySelectAnnotation = Notification.Name(rawValue: jobTodaySelectAnnotationKey)
    let keyDeselectAnnotation = Notification.Name(rawValue: jobTodayDeselectAnnotationKey)
    
    let keyAnnoRefresh = Notification.Name(rawValue: jobTodayAnnoRefreshKey)

    let keyRefreshCalendar = Notification.Name(rawValue: refreshCalendarKey)

    let keyJobCancelDone = Notification.Name(rawValue: jobCancelDoneKey)
    
    let keyFilterDidSave = Notification.Name(rawValue: filterDidSaveKey)
    
    // Register Observers for updates
    func registerObservers() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(JobBookViewController.filterDidSave(notification:)), name: keyFilterDidSave, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(JobTodayViewController.jobCanceled(notification:)), name: keyJobCancelDone, object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(JobTodayViewController.refreshAnnotations(notification:)), name: keyAnnoRefresh, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(JobTodayViewController.refreshCalendar(notification:)), name: keyRefreshCalendar, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(JobTodayViewController.selectAnnotation(notification:)), name: keySelectAnnotation, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(JobTodayViewController.deselectAnnotation(notification:)), name: keyDeselectAnnotation, object: nil)
    }
    
    @objc func filterDidSave(notification: NSNotification) {
        updateCalendar()
        refreshAnnotations()
        refreshPanel()
    }
    
    @objc func jobCanceled(notification: NSNotification) {
        mapView.removeAnnotationWithOrderNum(with: String(selectedOrderNum!))
    }
    
    @objc func refreshCalendar(notification: NSNotification) {
        calendar.removeFromSuperview()
        initCalendar()
    }
    
    @objc func refreshAnnotations(notification: NSNotification) {
        refreshAnnotations()
        jobManager.refreshCalendarEventDots()
        calendar.reloadData()
    }
    
    @objc func selectAnnotation(notification: NSNotification) {
        for anno in mapView.annotations {
            if anno.subtitle == String(selectedTodayOrderNum!) {
                mapView.selectAnnotation(anno, animated: true)
                fpc.move(to: .half, animated: true)
                return
            }
        }
    }
    @objc func deselectAnnotation(notification: NSNotification) {
        mapView.deselectAnnotation(selectedTodayAnnoView?.annotation, animated: true)
    }
    
//MARK: - Init
    func initButtons() {
        
        // Button Config
        let largeConfig = UIImage.SymbolConfiguration(pointSize: 17, weight: .bold, scale: .large)
        let largeBoldGear = UIImage(systemName: "slider.horizontal.3", withConfiguration: largeConfig)
        let largeBoldViewfinder = UIImage(systemName: "viewfinder", withConfiguration: largeConfig)
        let largeBoldLocation = UIImage(systemName: "location.fill", withConfiguration: largeConfig)

        // FilterButton
        let filterButton = UIButton()
        filterButton.frame = CGRect(x: 15, y: 80, width: 40, height: 40)
        filterButton.setImage(largeBoldGear, for: .normal)
        filterButton.tintColor = #colorLiteral(red: 0.1546343565, green: 0.3047484159, blue: 0.5878322721, alpha: 1)
        filterButton.layer.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        filterButton.applyCircleStyle()
        filterButton.addTarget(self, action: #selector(JobTodayViewController.filterButtonPressed(_:)), for: .touchUpInside)
        self.mapView.addSubview(filterButton)
        
        // ViewAllButton
        let viewAllButton = UIButton()
        viewAllButton.frame = CGRect(x: singletonData.screenWidth! - 55, y: 80, width: 40, height: 40)
        viewAllButton.setImage(largeBoldViewfinder, for: .normal)
        viewAllButton.tintColor = #colorLiteral(red: 0.1546343565, green: 0.3047484159, blue: 0.5878322721, alpha: 1)
        viewAllButton.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        viewAllButton.applyCircleStyle()
        viewAllButton.addTarget(self, action: #selector(JobTodayViewController.viewAllButtonPressed(_:)), for: .touchUpInside)
        self.mapView.addSubview(viewAllButton)

        // CurrentLocationButton
        let currentLocationButton = UIButton()
        currentLocationButton.frame = CGRect(x: singletonData.screenWidth! - 55, y: 135, width: 40, height: 40)
        currentLocationButton.setImage(largeBoldLocation, for: .normal)
        currentLocationButton.tintColor = #colorLiteral(red: 0.1546343565, green: 0.3047484159, blue: 0.5878322721, alpha: 1)
        currentLocationButton.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        currentLocationButton.applyCircleStyle()
        currentLocationButton.addTarget(self, action: #selector(JobTodayViewController.currentLocationButtonPressed(_:)), for: .touchUpInside)
        self.mapView.addSubview(currentLocationButton)
    }
    
    func initCalendar() {
        
        let isWeekendOn = defaults.bool(forKey: K.UserDefaults.Settings.weekendSwitch)
        let offset: CGFloat = isWeekendOn ? 1 : (7/5)

        //Init calendarView
        calendar = FSCalendar(frame: CGRect(x: 0, y: 0 , width: view.frame.size.width * offset, height: 250))

        //Init appearance
        calendar.locale = NSLocale(localeIdentifier: "sv") as Locale
        calendar.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        calendar.scope = .week
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
        self.mapView.addSubview(calendar)
        
        //delegate
        calendar.delegate = self
        calendar.dataSource = self
        
        //init action
        calendar.select(selectedDateOnCalendar)
        setDateButtonWithDay(with: selectedDateOnCalendar)
    }
    

    func initFloatingPanel() {
       fpc.customStyle()
       
       // Set panelVC
       guard let panelVC = storyboard?.instantiateViewController(identifier: "JobTodayPanel") as? JobTodayPanelViewController else { return }
        panelVC.delegate = self
       fpc.set(contentViewController: panelVC)
       fpc.track(scrollView: panelVC.panelTableView)
       fpc.addPanel(toParent: self)
   }

    func initAnnotations() {
        mapView.initAnnotations(type: K.Annotation.bookingJob, isOn: isYellowOn, date: calendar.selectedDate!)
        mapView.initAnnotations(type: K.Annotation.bookedJob, isOn: isGreenOn, date: calendar.selectedDate!)
        mapView.initAnnotations(type: K.Annotation.doneJob, isOn: isGrayOn, date: calendar.selectedDate!)
    }
    
//MARK: - Methods

    func viewAllTodayJob() {
        let annos = self.mapView.annotations.filter {
            $0.title == K.Annotation.bookingJob
                || $0.title == K.Annotation.bookedJob
                || $0.title == K.Annotation.doneJob
        }
        isBeingViewAll = true
        self.mapView.showAnnotations(annos, animated: true)
    }

    func updateCalendar() {
        jobManager.refreshCalendarEventDots()
        setDateButtonWithDay(with: selectedDateOnCalendar)
        calendar.select(selectedDateOnCalendar) //shared calendar
        calendar.reloadData()
    }

    func refreshAnnotations() {
        mapView.refreshAnnotations(type: K.Annotation.bookingJob, isOn: isYellowOn, date: calendar.selectedDate!)
        mapView.refreshAnnotations(type: K.Annotation.bookedJob, isOn: isGreenOn, date: calendar.selectedDate!)
        mapView.refreshAnnotations(type: K.Annotation.doneJob, isOn: isGrayOn, date: calendar.selectedDate!)
    }

    func refreshPanel() {
        broadcastToShowAllWithDateOnPanel()
    }
    
    func refreshBadge() {
        // update "Dagens Jobb" Badge
        let keyName = Notification.Name(rawValue: updateBadge4Key)
        NotificationCenter.default.post(name: keyName, object: nil)
    }

    func setDateButtonWithDay(with date: Date) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        selectedDateButton.setTitle(dateFormatter.string(from: date), for:.normal)
    }

    func setDateButtonWithMonth(with date: Date) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM"
        selectedDateButton.setTitle(dateFormatter.string(from: date), for:.normal)
    }

    func broadcastToShowSelectedOnPanel() {
        if selectedTodayAnnoView!.annotation?.title == K.Annotation.bookedJob {
            fpc.move(to: .half, animated: true)
            let keyName = Notification.Name(rawValue: jobTodaySelectedOnPanelKey)
            NotificationCenter.default.post(name: keyName, object: nil)
        }
    }
    
    func broadcastToShowAllWithDateOnPanel() {
        let keyName = Notification.Name(rawValue: jobTodayAllWithDateOnPanelKey)
        NotificationCenter.default.post(name: keyName, object: nil)
    }
        
     func openCalloutView(with annoView: MKAnnotationView) {
        let nib = UINib(nibName:"MapCalloutUIView", bundle: nil)
        let calloutView = nib.instantiate(withOwner: self, options: nil).first as! MapCalloutUIView
        
        let annoType = annoView.annotation?.title!
        let orderNum = annoView.annotation?.subtitle!
        let coords = annoView.annotation?.coordinate

        calloutView.customStyle(viewType: K.JobToday.type)
        calloutView.annoType = annoType
        calloutView.orderNum = Int(orderNum!)
        calloutView.coordinates = coords
                
        calloutView.initView()

        mapView.addSubview(calloutView)
    }
    
    
//MARK: - UI Actions
    @IBAction func selectedDateButtonPressed(_ sender: Any) {
        let today = Date()
        calendar.select(today)
        selectedDateOnCalendar = today
        setDateButtonWithDay(with: today)
        calendar.setScope(.week, animated: true)
    }
    
    @IBAction func calendarButtonPressed(_ sender: Any) {

        if calendar.scope == .week {
            calendar.setScope(.month, animated: true)
            setDateButtonWithMonth(with: calendar.currentPage)
            
        } else {
            calendar.setScope(.week, animated: true)
            setDateButtonWithDay(with: calendar.selectedDate!)
        }
    }
    
    @IBAction func leftButtonPressed(_ sender: Any) {
        let isWeekendOn = defaults.bool(forKey: K.UserDefaults.Settings.weekendSwitch)
        let weekday = Calendar.current.component(.weekday, from: calendar.selectedDate!) // 2: monday, 6: friday

        if calendar.scope == .week {
            let offset = (!isWeekendOn) && (weekday == 2)
                ? K.aDayInSeconds * 3
                : K.aDayInSeconds
            calendar.select(calendar.selectedDate! - offset)
            setDateButtonWithDay(with: calendar.selectedDate!)
            selectedDateOnCalendar = calendar.selectedDate!
            jobManager.refreshTodayJobsWithDate()
            
            // signal
            refreshAnnotations()
            refreshPanel()
            refreshBadge()
            viewAllTodayJob()

        } else {
            let dateString = selectedDateButton.titleLabel!.text! + "-15"
            let targetDate = stringToDate3(with: dateString) - K.aMonthInSeconds
            calendar.setCurrentPage(targetDate, animated: true)
        }
    }
    
    @IBAction func rightButtonPressed(_ sender: Any) {
        let isWeekendOn = defaults.bool(forKey: K.UserDefaults.Settings.weekendSwitch)
        let weekday = Calendar.current.component(.weekday, from: calendar.selectedDate!) // 2: monday, 6: friday
        
        if calendar.scope == .week {
            let offset = (!isWeekendOn) && (weekday == 6)
                ? K.aDayInSeconds * 3
                : K.aDayInSeconds
            calendar.select(calendar.selectedDate! + offset)
            setDateButtonWithDay(with: calendar.selectedDate!)
            selectedDateOnCalendar = calendar.selectedDate!
            jobManager.refreshTodayJobsWithDate()
            
            // signal
            refreshAnnotations()
            refreshPanel()
            refreshBadge()
            viewAllTodayJob()
            
        } else {
            let dateString = selectedDateButton.titleLabel!.text! + "-15"
            let targetDate = stringToDate3(with: dateString) + K.aMonthInSeconds
            calendar.setCurrentPage(targetDate, animated: true)
        }
    }
    
    @objc func filterButtonPressed(_ sender: AnyObject) {
        let storyboard = UIStoryboard.init(name: "FilterView", bundle: nil)
        let settingVC = storyboard.instantiateViewController(withIdentifier: "FilterView") as! FilterViewController
        present(settingVC, animated: true, completion: nil)
    }
    
    @objc func viewAllButtonPressed(_ sender: AnyObject) {
        isBeingViewAll = true
        self.mapView.showAnnotations(self.mapView.annotations, animated: true)
        fpc.move(to: .tip, animated: true)
    }
    
    @objc func currentLocationButtonPressed(_ sender: AnyObject) {
        let selectedRegion = MKCoordinateRegion(center: mapView.userLocation.coordinate, latitudinalMeters: 5000, longitudinalMeters: 5000)
        mapView.setRegion(selectedRegion, animated: true)
        fpc.move(to: .tip, animated: true)
    }
}


//MARK: - MKMapViewDelegate
extension JobTodayViewController: MKMapViewDelegate {
    
    // For Each Annotations
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {

        // Current Location (Blue Dot)
        if annotation === mapView.userLocation {
            return mapView.view(for: annotation)
        }

        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "AnnotationView")
        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "AnnotationView")
        }

        switch annotation.title {
        case K.Annotation.bookingJob:
            annotationView?.image = #imageLiteral(resourceName: "gul-orange")
        case K.Annotation.bookedJob:
            annotationView?.image = #imageLiteral(resourceName: "gron-orange")
        case K.Annotation.doneJob:
            annotationView?.image = #imageLiteral(resourceName: "completed")
        case .none:
            break
        case .some(_):
            break
        }
        
        annotationView?.frame = CGRect(x: 0, y: 0, width: 22, height: 30)

        annotationView?.canShowCallout = false
        annotationView?.isEnabled = true
        
        return annotationView
    }
    
    
    // Annotation Selected
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
                
        // Zoom-in Region
        let currentCoords = mapView.camera.centerCoordinate
        let selectedCoords = view.annotation?.coordinate
        let selectedRegion = MKCoordinateRegion(center: selectedCoords!, latitudinalMeters: 5000, longitudinalMeters: 5000)
        mapView.setRegion(selectedRegion, animated: true)
        
        // Selected UserLocation
        if view.annotation === mapView.userLocation { return }

        selectedTodayAnnoView = view
        
        if(Int(currentCoords.latitude * 10000) == Int(selectedCoords!.latitude * 10000)){
            openCalloutView(with: selectedTodayAnnoView!)
            
            // Broadcast to show one on Panel
            if selectedTodayAnnoView!.annotation?.title == K.Annotation.bookedJob {
                broadcastToShowSelectedOnPanel()
            }
        } else {
            isBeingSelected = true
        }
    }
        
    // Annotation Deselected
    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        print("mapView: didDeselect")
        
        fpc.move(to: .tip, animated: true)
        let subviews = mapView.subviews
        for view in subviews where view is MapCalloutUIView {
            view.removeFromSuperview()
        }
        
        // Broadcast to show all on Panel
        broadcastToShowAllWithDateOnPanel()
    }
    
    // Region Changed
    func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
        print("mapView: regionWillChangeAnimated")
        
        let subviews = mapView.subviews
        for view in subviews where view is MapCalloutUIView {
            fpc.move(to: .tip, animated: true)
            view.removeFromSuperview()
            
            // Broadcast to show all on Panel
            broadcastToShowAllWithDateOnPanel()
        }
    }

    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        print("mapView: regionDidChangeAnimated")

        //Zoom Finished
        if (isBeingSelected) {
            isBeingSelected = false
            openCalloutView(with: selectedTodayAnnoView!)
                    
            // Broadcast to show one on Panel
            if selectedTodayAnnoView!.annotation?.title == K.Annotation.bookedJob {
                broadcastToShowSelectedOnPanel()
            }
        } else if(isBeingViewAll) {
            isBeingViewAll = false
            
            let currentCoords = mapView.camera.centerCoordinate
            print(currentCoords)
            
            let viewRegion = MKCoordinateRegion(
                center: mapView.camera.centerCoordinate,
                latitudinalMeters: mapView.camera.centerCoordinateDistance * 0.4,
                longitudinalMeters: mapView.camera.centerCoordinateDistance * 0.4)
                
                mapView.setRegion(viewRegion, animated: true)
        }
    }
    
}

//MARK: - FloatingPanelControllerDelegate
extension JobTodayViewController: FloatingPanelControllerDelegate {
    
}


//MARK: - FSCalendarDelegate
extension JobTodayViewController: FSCalendarDelegate {

    // Select
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        
        if(calendar.scope == .month) {
            calendar.setScope(.week, animated: true)
        }
        
        setDateButtonWithDay(with: date)
        selectedDateOnCalendar = date
        jobManager.refreshTodayJobsWithDate()
        
        // signal
        refreshAnnotations()
        refreshPanel()
        refreshBadge()
        viewAllTodayJob()
    }

    //Auto Layout
    func calendar(_ calendar: FSCalendar, boundingRectWillChange bounds: CGRect, animated: Bool) {
        calendar.frame = CGRect(origin: calendar.frame.origin, size: bounds.size)
    }

    // Change
    func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
        setDateButtonWithMonth(with: calendar.currentPage)
    }

    // Valid for selection
    func calendar(_ calendar: FSCalendar, shouldSelect date: Date, at monthPosition: FSCalendarMonthPosition) -> Bool {
        let month = Calendar.current.component(.month, from: date)
        let month2 = Calendar.current.component(.month, from: calendar.currentPage)
        if ( month == month2 ) { return true }
        else { return false }
    }
    
    func minimumDate(for calendar: FSCalendar) -> Date {
        return Date() - (2*K.aWeekInSeconds)
    }
}

//MARK: - FSCalendarDataSource
extension JobTodayViewController: FSCalendarDataSource {
    
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



//MARK: - JobTodayPanelViewControllerDelegate
extension JobTodayViewController: JobTodayPanelViewControllerDelegate {
    func updateYellowAnno(isOn: Bool) {
        if isYellowOn != isOn {
            isYellowOn = isOn
            if isYellowOn {
                mapView.addAnnotations(type: K.Annotation.bookingJob, date: calendar.selectedDate!)
            } else {
                mapView.removeAnnotations(type: K.Annotation.bookingJob)
            }
        }
    }
    
    func updateGreenAnno(isOn: Bool) {
        if isGreenOn != isOn {
            isGreenOn = isOn
            if isGreenOn {
                mapView.addAnnotations(type: K.Annotation.bookedJob, date: calendar.selectedDate!)
            } else {
                mapView.removeAnnotations(type: K.Annotation.bookedJob)
            }
        }
    }
    
    func updateGrayAnno(isOn: Bool) {
        if isGrayOn != isOn {
            isGrayOn = isOn
            if isGrayOn {
                mapView.addAnnotations(type: K.Annotation.doneJob, date: calendar.selectedDate!)
            } else {
                mapView.removeAnnotations(type: K.Annotation.doneJob)
            }
        }
    }

}
