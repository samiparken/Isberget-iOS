import UIKit
import MapKit
import FloatingPanel

class JobAcceptViewController: UIViewController {

    //Views
    @IBOutlet weak var mapView: MKMapView!
    var tableView = UITableView()
     
    //FloatingPanel
    let fpc = FloatingPanelController()
    
    //TabBarItem
    @IBOutlet weak var tabbarItem: UITabBarItem!
    
    //Buttons
    @IBOutlet weak var settingsButton: UIButton!
    @IBOutlet weak var viewAllButton: UIButton!
    @IBOutlet weak var currentLocationButton: UIButton!
    
    //Manager
    let jobManager = JobManager()

    //For AnnotationCalloutView
    var isBeingSelected: Bool = false
    var isBeingViewAll: Bool = false
    var isBlueOn: Bool = true
    var isOrangeOn: Bool = false
    var isYellowOn: Bool = false
    var isGreenOn: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("JobAcceptVC: viewDidLoad() Start")

        //Delegate
        mapView.delegate = self
        fpc.delegate = self
        
        //Init Components
        initFloatingPanel()
        initAnnotations()
        initButtons()
        registerObservers()
        
        singletonData.mapViewHeight = mapView.frame.height
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)        
        viewAllUnacceptedJob()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
//MARK: - For Notification Observers

    // for Notification Observers
    let keySelectAnnotation = Notification.Name(rawValue: jobAcceptSelectAnnotationKey)
    let keyDeselectAnnotation = Notification.Name(rawValue: jobAcceptDeselectAnnotationKey)
    let keyAcceptJob = Notification.Name(rawValue: jobAcceptAcceptJobKey)
    let keyDeclineJob = Notification.Name(rawValue: jobAcceptDeclineJobKey)
    
    let keyAnnoRefresh = Notification.Name(rawValue: jobAcceptAnnoRefreshKey)

    let keyFilterDidSave = Notification.Name(rawValue: filterDidSaveKey)

    
    // Register Observers for updates
    func registerObservers() {

        NotificationCenter.default.addObserver(self, selector: #selector(JobBookViewController.filterDidSave(notification:)), name: keyFilterDidSave, object: nil)
        
        // Select & Deselect Annotation
        NotificationCenter.default.addObserver(self, selector: #selector(JobAcceptViewController.selectAnnotation(notification:)), name: keySelectAnnotation, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(JobAcceptViewController.deselectAnnotation(notification:)), name: keyDeselectAnnotation, object: nil)

        // Accept & Decline Job
        NotificationCenter.default.addObserver(self, selector: #selector(JobAcceptViewController.tryAcceptJob(notification:)), name: keyAcceptJob, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(JobAcceptViewController.tryDeclineJob(notification:)), name: keyDeclineJob, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(JobAcceptViewController.refreshAnnotations(notification:)), name: keyAnnoRefresh, object: nil)
    }

    @objc func filterDidSave(notification: NSNotification) {
        refreshAnnotations()
        broadcastToShowAllOnPanel()
    }
    
    @objc func refreshAnnotations(notification: NSNotification) {
        refreshAnnotations()
    }

    @objc func tryAcceptJob(notification: NSNotification) {
        requestAcceptJob()        
    }
    
    @objc func tryDeclineJob(notification: NSNotification) {
        requestDeclineJob()
    }
    
    @objc func selectAnnotation(notification: NSNotification) {
        for anno in mapView.annotations {
            if anno.subtitle == String(selectedAcceptOrderNum!) {
                mapView.selectAnnotation(anno, animated: true)
                fpc.move(to: .half, animated: true)
                return
            }
        }
    }
    @objc func deselectAnnotation(notification: NSNotification) {
        mapView.deselectAnnotation(selectedAcceptAnnoView?.annotation, animated: true)
    }
}

//MARK: - Init
extension JobAcceptViewController {
    func initButtons() {
        
        // Button Config
        let largeConfig = UIImage.SymbolConfiguration(pointSize: 17, weight: .bold, scale: .large)
        let largeBoldGear = UIImage(systemName: "slider.horizontal.3", withConfiguration: largeConfig)
        let largeBoldViewfinder = UIImage(systemName: "viewfinder", withConfiguration: largeConfig)
        let largeBoldLocation = UIImage(systemName: "location.fill", withConfiguration: largeConfig)

        // FilterButton
        let filterButton = UIButton()
        filterButton.frame = CGRect(x: 15, y: 15, width: 40, height: 40)
        filterButton.setImage(largeBoldGear, for: .normal)
        filterButton.tintColor = #colorLiteral(red: 0.1546343565, green: 0.3047484159, blue: 0.5878322721, alpha: 1)
        filterButton.layer.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        filterButton.applyCircleStyle()
        filterButton.addTarget(self, action: #selector(JobAcceptViewController.filterButtonPressed(_:)), for: .touchUpInside)
        self.mapView.addSubview(filterButton)
        
        // ViewAllButton
        let viewAllButton = UIButton()
        viewAllButton.frame = CGRect(x: singletonData.screenWidth! - 55, y: 15, width: 40, height: 40)
        viewAllButton.setImage(largeBoldViewfinder, for: .normal)
        viewAllButton.tintColor = #colorLiteral(red: 0.1546343565, green: 0.3047484159, blue: 0.5878322721, alpha: 1)
        viewAllButton.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        viewAllButton.applyCircleStyle()
        viewAllButton.addTarget(self, action: #selector(JobTodayViewController.viewAllButtonPressed(_:)), for: .touchUpInside)
        self.mapView.addSubview(viewAllButton)

        // CurrentLocationButton
        let currentLocationButton = UIButton()
        currentLocationButton.frame = CGRect(x: singletonData.screenWidth! - 55, y: 70, width: 40, height: 40)
        currentLocationButton.setImage(largeBoldLocation, for: .normal)
        currentLocationButton.tintColor = #colorLiteral(red: 0.1546343565, green: 0.3047484159, blue: 0.5878322721, alpha: 1)
        currentLocationButton.backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        currentLocationButton.applyCircleStyle()
        currentLocationButton.addTarget(self, action: #selector(JobTodayViewController.currentLocationButtonPressed(_:)), for: .touchUpInside)
        self.mapView.addSubview(currentLocationButton)
    }
    
     func initFloatingPanel() {
        fpc.customStyle()
        
        // Set panelVC
        guard let panelVC = storyboard?.instantiateViewController(identifier: "JobAcceptPanel") as? JobAcceptPanelViewController else { return }
        panelVC.delegate = self
        fpc.set(contentViewController: panelVC)
        fpc.track(scrollView: panelVC.panelTableView)
        fpc.addPanel(toParent: self)
    }

     func initAnnotations() {
        mapView.initAnnotations(type: K.Annotation.unacceptedJob, isOn: isBlueOn)
        mapView.initAnnotations(type: K.Annotation.unbookedJob, isOn: isOrangeOn)
        mapView.initAnnotations(type: K.Annotation.bookingJob, isOn: isYellowOn)
        mapView.initAnnotations(type: K.Annotation.bookedJob, isOn: isGreenOn)
    }
}
 
//MARK: - methods

extension JobAcceptViewController {
    
    func viewAllUnacceptedJob() {
        let annos = self.mapView.annotations.filter {
            $0.title == K.Annotation.unacceptedJob
        }
        isBeingViewAll = true
        self.mapView.showAnnotations(annos, animated: true)
    }
    
    func refreshAnnotations() {
        mapView.refreshAnnotations(type: K.Annotation.unacceptedJob, isOn: isBlueOn)
        mapView.refreshAnnotations(type: K.Annotation.unbookedJob, isOn: isOrangeOn)
        mapView.refreshAnnotations(type: K.Annotation.bookingJob, isOn: isYellowOn)
        mapView.refreshAnnotations(type: K.Annotation.bookedJob, isOn: isGreenOn)        
    }
    
    func previewTabbarBadge(offset: Int) {
        let count = singletonData.getUnacceptedJobs.count + offset
        tabbarItem.badgeValue = count <= 0 ? nil : String(count)
    }
    
    func broadcastToShowAllOnPanel() {
        let keyName = Notification.Name(rawValue: jobAcceptAllOnPanelKey)
        NotificationCenter.default.post(name: keyName, object: nil)
    }
    
    func requestAcceptJob() {
        self.jobManager.acceptJob(orderId: selectedAcceptOrderId!)

        let subviews = mapView.subviews
        for view in subviews where view is MapCalloutUIView {
            fpc.move(to: .tip, animated: true)
            view.removeFromSuperview()
            
            // showAllOnPanel()
            // Broadcast to show all on Panel
            broadcastToShowAllOnPanel()
        }
        mapView.removeAnnotationWithOrderNum(with: String(selectedAcceptOrderNum!))
        previewTabbarBadge(offset: -1)
    }
    
    func requestDeclineJob() {
        
        // TextFiled Alert
        let alertTextField = UIAlertController(title: "Skriv ett meddelande", message: "", preferredStyle: .alert)
        alertTextField.addTextField(configurationHandler: nil)

        // Cancle Action
        let cancelAction = UIAlertAction(title: "Avbryt", style: .cancel, handler: nil)

        // Save Action
        let saveAction = UIAlertAction(title: "Neka jobb", style: .default) { [self] _ in
            let input = alertTextField.textFields?.first
            let message = input!.text ?? ""
            DispatchQueue.global(qos: .background).async {
                self.jobManager.declineJob(orderId: selectedAcceptOrderId!, message: message)
            }
            
            let subviews = mapView.subviews
            for view in subviews where view is MapCalloutUIView {
                fpc.move(to: .tip, animated: true)
                view.removeFromSuperview()
                
                // showAllOnPanel()
                // Broadcast to show all on Panel
                broadcastToShowAllOnPanel()
            }
            mapView.removeAnnotationWithOrderNum(with: String(selectedAcceptOrderNum!))
            previewTabbarBadge(offset: -1)
        }

        alertTextField.addAction(saveAction)
        alertTextField.addAction(cancelAction)

        DispatchQueue.main.async {
            self.present(alertTextField, animated: true)
        }
    }

     func openCalloutView(with annoView: MKAnnotationView) {
        let nib = UINib(nibName:"MapCalloutUIView", bundle: nil)
        let calloutView = nib.instantiate(withOwner: self, options: nil).first as! MapCalloutUIView
         
        let annoType = annoView.annotation?.title!
        let orderNum = annoView.annotation?.subtitle!
        let coords = annoView.annotation?.coordinate

        calloutView.customStyle(viewType: K.JobAccept.type)
        calloutView.annoType = annoType
        calloutView.orderNum = Int(orderNum!)
        calloutView.coordinates = coords
        
        calloutView.initView()
        
        mapView.addSubview(calloutView)
    }
}

//MARK: - UI Actions

extension JobAcceptViewController {
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

extension JobAcceptViewController: MKMapViewDelegate {
        
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
        case K.Annotation.unacceptedJob:
            annotationView?.image = #imageLiteral(resourceName: "bla-orange")
        case K.Annotation.unbookedJob:
            annotationView?.image = #imageLiteral(resourceName: "orange-orange")
        case K.Annotation.bookingJob:
            annotationView?.image = #imageLiteral(resourceName: "gul-orange")
        case K.Annotation.bookedJob:
            annotationView?.image = #imageLiteral(resourceName: "gron-orange")
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
        
        selectedAcceptAnnoView = view
        
        if(Int(currentCoords.latitude * 10000) == Int(selectedCoords!.latitude * 10000)){
            openCalloutView(with: selectedAcceptAnnoView!)
            // Broadcast to show one on Panel
            if view.annotation?.title == K.Annotation.unacceptedJob {
                fpc.move(to: .half, animated: true)
                let keyName = Notification.Name(rawValue: jobAcceptSelectedOnPanelKey)
                NotificationCenter.default.post(name: keyName, object: nil)
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
        broadcastToShowAllOnPanel()
    }
    
    // Region Changed
    func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
        print("mapView: regionWillChangeAnimated")
        
        let subviews = mapView.subviews
        for view in subviews where view is MapCalloutUIView {
            fpc.move(to: .tip, animated: true)
            view.removeFromSuperview()
            
            // showAllOnPanel()
            // Broadcast to show all on Panel
            broadcastToShowAllOnPanel()
        }
    }

    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        print("mapView: regionDidChangeAnimated")
        if (isBeingSelected) {
            //Zoom Finished
            isBeingSelected = false
            openCalloutView(with: selectedAcceptAnnoView!)
            
            // Broadcast to show one on Panel
            if selectedAcceptAnnoView!.annotation?.title == K.Annotation.unacceptedJob {
                fpc.move(to: .half, animated: true)
                let keyName = Notification.Name(rawValue: jobAcceptSelectedOnPanelKey)
                NotificationCenter.default.post(name: keyName, object: nil)
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
extension JobAcceptViewController: FloatingPanelControllerDelegate {
    
}

//MARK: - JobAcceptPanelViewControllerDelegate
extension JobAcceptViewController: JobAcceptPanelViewControllerDelegate {
    func updateBlueAnno(isOn: Bool) {
        if isBlueOn != isOn {
            isBlueOn = isOn
            if isBlueOn {
                mapView.addAnnotations(type: K.Annotation.unacceptedJob)
            } else {
                mapView.removeAnnotations(type: K.Annotation.unacceptedJob)
            }
        }
    }
    
    func updateOrangeAnno(isOn: Bool) {
        if isOrangeOn != isOn {
            isOrangeOn = isOn
            if isOrangeOn {
                mapView.addAnnotations(type: K.Annotation.unbookedJob)
            } else {
                mapView.removeAnnotations(type: K.Annotation.unbookedJob)
            }
        }
    }
    
    func updateYellowAnno(isOn: Bool) {
        if isYellowOn != isOn {
            isYellowOn = isOn
            if isYellowOn {
                mapView.addAnnotations(type: K.Annotation.bookingJob)
            } else {
                mapView.removeAnnotations(type: K.Annotation.bookingJob)
            }
        }
    }
    
    func updateGreenAnno(isOn: Bool) {
        if isGreenOn != isOn {
            isGreenOn = isOn
            if isGreenOn {
                mapView.addAnnotations(type: K.Annotation.bookedJob)
            } else {
                mapView.removeAnnotations(type: K.Annotation.bookedJob)
            }
        }
    }
}
