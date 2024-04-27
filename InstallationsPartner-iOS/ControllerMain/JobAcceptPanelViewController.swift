import UIKit
//import SwipeCellKit

protocol JobAcceptPanelViewControllerDelegate {
    func updateBlueAnno(isOn: Bool)
    func updateOrangeAnno(isOn: Bool)
    func updateYellowAnno(isOn: Bool)
    func updateGreenAnno(isOn: Bool)
}

class JobAcceptPanelViewController: UIViewController {
    
    var delegate: JobAcceptPanelViewControllerDelegate?
    
    //Views
    @IBOutlet var panelTableView: UITableView!
    
    //Buttons
    @IBOutlet weak var notAcceptedButton: UIButton!
    @IBOutlet weak var acceptedButton: UIButton!
    @IBOutlet weak var sentToCustomerButton: UIButton!
    @IBOutlet weak var bookedButton: UIButton!
    
    @IBOutlet weak var refreshButton: UIButton!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    var isUnacceptedOn: Bool = true
    var isUnbookedOn: Bool = false
    var isBookingOn: Bool = false
    var isBookedOn: Bool = false
    
    var isSelected: Bool = false
    var selectedJob = [String:Any]()
    
    let jobManager = JobManager()
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Delegate
        panelTableView.delegate = self
        panelTableView.dataSource = self

        // Register JobAcceptCell
        panelTableView.register(UINib(nibName: K.JobAccept.Cell, bundle: nil), forCellReuseIdentifier: K.JobAccept.Cell)
        
        registerObservers()
        initSpinner()
    }
    
//MARK: - For Notification Observers
    
    // for Notification Observers
    let keySelectedOnPanel = Notification.Name(rawValue: jobAcceptSelectedOnPanelKey)
    let keyAllOnPanel = Notification.Name(rawValue: jobAcceptAllOnPanelKey)
    let keyReloadPanel = Notification.Name(rawValue: jobAcceptPanelReloadKey)
    
    // Register Observers for updates
    func registerObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(JobAcceptPanelViewController.showSelectedOnPanel(notification:)), name: keySelectedOnPanel, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(JobAcceptPanelViewController.showAllOnPanel(notification:)), name: keyAllOnPanel, object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(JobAcceptPanelViewController.reloadPanel(notification:)), name: keyReloadPanel, object: nil)
    }
    
    @objc func reloadPanel(notification: NSNotification) {
        panelTableView.reloadData()
        stopSpinner()
    }
    
    @objc func showSelectedOnPanel(notification: NSNotification) {
        print("show Selected")
        isSelected = true
        
        let orderId = selectedAcceptAnnoView?.annotation?.subtitle!!
        selectedJob = singletonData.findJob(type: K.Annotation.unacceptedJob, with: orderId)
                
        panelTableView.reloadData()
    }
    @objc func showAllOnPanel(notification: NSNotification) {
        print("show All")
        isSelected = false

        panelTableView.reloadData()
    }
//MARK: - Init
    func initSpinner() {
        if !singletonData.isJobAcceptViewLoadedInitialData {
            stopSpinner()
        } else {
            startSpinner()
        }
    }

//MARK: - Methods
    func startSpinner() {
        refreshButton.isHidden = true
        spinner.startAnimating()
    }
    
    func stopSpinner(){
        refreshButton.isHidden = false
        spinner.stopAnimating()
    }
    
//MARK: - UI Actions
    @IBAction func refreshButtonPressed(_ sender: Any) {
        startSpinner()
        jobManager.refreshUnacceptedJobs()
    }
    
    @IBAction func notAcceptedButtonPressed(_ sender: Any) {
        isUnacceptedOn = !isUnacceptedOn
        self.delegate?.updateBlueAnno(isOn: isUnacceptedOn)
        notAcceptedButton.setImage( isUnacceptedOn ? #imageLiteral(resourceName: "bla") : #imageLiteral(resourceName: "bla-not"), for: .normal)
    }
    
    @IBAction func acceptedButtonPressed(_ sender: Any) {
        isUnbookedOn = !isUnbookedOn
        self.delegate?.updateOrangeAnno(isOn: isUnbookedOn)
        acceptedButton.setImage( isUnbookedOn ? #imageLiteral(resourceName: "orange") : #imageLiteral(resourceName: "orange-not"), for: .normal)
    }
        
    @IBAction func sentToCustomerButtonPressed(_ sender: Any) {
        isBookingOn = !isBookingOn
        self.delegate?.updateYellowAnno(isOn: isBookingOn)
        sentToCustomerButton.setImage( isBookingOn ? #imageLiteral(resourceName: "gul") : #imageLiteral(resourceName: "gul-not"), for: .normal)
    }
    
    @IBAction func bookedButtonPressed(_ sender: Any) {
        isBookedOn = !isBookedOn
        self.delegate?.updateGreenAnno(isOn: isBookedOn)
        bookedButton.setImage( isBookedOn ? #imageLiteral(resourceName: "gron") : #imageLiteral(resourceName: "gron-not"), for: .normal)
    }
}

//MARK: - UITableViewDataSource
extension JobAcceptPanelViewController: UITableViewDataSource {
    
    //Num of Rows
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isSelected ? 1 : filterJob( singletonData.getUnacceptedJobs ).count
    }
    
    //Row Height
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 115
    }
    
    //Cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let job = isSelected ? selectedJob : filterJob(  singletonData.getUnacceptedJobs )[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: K.JobAccept.Cell, for: indexPath)
            as! JobAcceptCell   //Casting Cell

        cell.order = job
        cell.initCell()
        //cell.delegate = self //for SwipeTableViewCellDelegate
        
        return cell
    }
}

//MARK: - UITableViewDelegate
extension JobAcceptPanelViewController: UITableViewDelegate {
    
    // Handler for selection
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        if (!isSelected) {
            isSelected = true
            selectedJob = singletonData.getUnacceptedJobs[indexPath.row]

            // Broadcast to select annotation
            selectedAcceptOrderId = (selectedJob["OrderId"] as! Int)
            selectedAcceptOrderNum = (selectedJob["order_number_on_client"] as! Int)
            let keyName = Notification.Name(rawValue: jobAcceptSelectAnnotationKey)
            NotificationCenter.default.post(name: keyName, object: nil)
        }
        panelTableView.reloadData()
    }
}

/*
//MARK: - SwipeTableViewCellDelegate
extension JobAcceptPanelViewController: SwipeTableViewCellDelegate {
    
    // SwipeCell Animation Kit
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else { return nil }
        
        let infoAction = SwipeAction(style: .destructive, title: "Info") { action, indexPath in
            print("Info Action")
        }
        let declineAction = SwipeAction(style: .destructive, title: "Avvisa") { action, indexPath in
            print("Decline Action")
        }
        let acceptAction = SwipeAction(style: .destructive, title: "Acceptera") { action, indexPath in
            print("Accept Action")
        }
        
        // customize the action appearance
        let largeConfig = UIImage.SymbolConfiguration(pointSize: 20, weight: .bold, scale: .large)
        let actionFont = UIFont.systemFont(ofSize: 13)
        infoAction.image = UIImage(systemName: "info", withConfiguration: largeConfig)
        infoAction.backgroundColor = #colorLiteral(red: 0.1843097845, green: 0.3722758202, blue: 0.7247112249, alpha: 1)
        infoAction.font = actionFont
        
        declineAction.image = UIImage(systemName: "xmark", withConfiguration: largeConfig)
        declineAction.backgroundColor = #colorLiteral(red: 0.9159181714, green: 0.3209913671, blue: 0.2143411934, alpha: 1)
        declineAction.font = actionFont
        
        acceptAction.image = UIImage(systemName: "checkmark", withConfiguration: largeConfig)
        acceptAction.backgroundColor = #colorLiteral(red: 0, green: 0.854619801, blue: 0.440415442, alpha: 1)
        acceptAction.font = actionFont
        
        return [acceptAction, declineAction, infoAction]
    }
    
    // Customize the behavior of the swipe actions
    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeOptions {
        var options = SwipeOptions()
        options.expansionStyle = .none
        options.transitionStyle = .border
                
        return options
    }
}
*/
