import UIKit

protocol JobBookPanelViewControllerDelegate {
    func updateOrangeAnno(isOn: Bool)
    func updateYellowAnno(isOn: Bool)
    func updateGreenAnno(isOn: Bool)
}

class JobBookPanelViewController: UIViewController {
    var delegate: JobBookPanelViewControllerDelegate?

    @IBOutlet weak var panelTableView: UITableView!
    
    @IBOutlet weak var unbookedButton: UIButton!
    @IBOutlet weak var bookingButton: UIButton!
    @IBOutlet weak var bookedButton: UIButton!
    
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var refreshButton: UIButton!
    
    var isUnbookedOn: Bool = true
    var isBookingOn: Bool = true
    var isBookedOn: Bool = true
        
    var isSelected: Bool = false
    var selectedJob = [String:Any]()

    let jobManager = JobManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Delegate
        panelTableView.delegate = self
        panelTableView.dataSource = self

        // Register JobBookCell
        panelTableView.register(UINib(nibName: K.JobBook.Cell, bundle: nil), forCellReuseIdentifier: K.JobBook.Cell)
        
        registerObservers()        
        initSpinner()
    }
    
    //MARK: - For Notification Observers
    
    // for Notification Observers
    let keySelectedOnPanel = Notification.Name(rawValue: jobBookSelectedOnPanelKey)
    let keyAllOnPanel = Notification.Name(rawValue: jobBookAllOnPanelKey)
    let keyReloadPanel = Notification.Name(rawValue: jobBookPanelReloadKey)

    
    // Register Observers for updates
    func registerObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(JobBookPanelViewController.showSelectedOnPanel(notification:)), name: keySelectedOnPanel, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(JobBookPanelViewController.showAllOnPanel(notification:)), name: keyAllOnPanel, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(JobBookPanelViewController.reloadPanel(notification:)), name: keyReloadPanel, object: nil)

    }
    
    @objc func reloadPanel(notification: NSNotification) {
        panelTableView.reloadData()
        stopSpinner()
    }

    @objc func showSelectedOnPanel(notification: NSNotification) {
        print("show Selected")
        isSelected = true
        
        let orderId = selectedBookAnnoView?.annotation?.subtitle!!
        selectedJob = singletonData.findJob(type: K.Annotation.unbookedJob, with: orderId)
        
        panelTableView.reloadData()
    }
    @objc func showAllOnPanel(notification: NSNotification) {
        print("show All")
        isSelected = false
        
        panelTableView.reloadData()
    }
    
//MARK: - Init
    
    func initSpinner() {
        if !singletonData.isJobBookViewLoadedInitialData {
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
        jobManager.refreshUnbookedJobs()
        jobManager.refreshBookingAndBookedJobs()
    }
    
    @IBAction func unbookedButtonPressed(_ sender: Any) {
        isUnbookedOn = !isUnbookedOn
        self.delegate?.updateOrangeAnno(isOn: isUnbookedOn)
        unbookedButton.setImage( isUnbookedOn ? #imageLiteral(resourceName: "orange") : #imageLiteral(resourceName: "orange-not"), for: .normal)
    }
    
    @IBAction func bookingButtonPressed(_ sender: Any) {
        isBookingOn = !isBookingOn
        self.delegate?.updateYellowAnno(isOn: isBookingOn)
        bookingButton.setImage( isBookingOn ? #imageLiteral(resourceName: "gul") : #imageLiteral(resourceName: "gul-not"), for: .normal)
    }
    
    @IBAction func bookedButtonPressed(_ sender: Any) {
        isBookedOn = !isBookedOn
        self.delegate?.updateGreenAnno(isOn: isBookedOn)
        bookedButton.setImage( isBookedOn ? #imageLiteral(resourceName: "gron") : #imageLiteral(resourceName: "gron-not"), for: .normal)
    }
}

//MARK: - UITableViewDataSource
extension JobBookPanelViewController: UITableViewDataSource {
    
    //Num of Rows
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isSelected ? 1 : filterJob( singletonData.getUnbookedJobs ).count
    }
    
    //Row Height
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 115
    }
    
    //Row content, called as many as the Number of Rows
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let job = isSelected ? selectedJob : filterJob( singletonData.getUnbookedJobs )[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: K.JobBook.Cell, for: indexPath)
            as! JobBookCell   //Casting Cell

        cell.order = job
        cell.initCell()
        
        return cell
    }
}

//MARK: - UITableViewDelegate
extension JobBookPanelViewController: UITableViewDelegate {
    
    // Handler for selection
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        if (!isSelected) {
            
            if (!isUnbookedOn) {
                isUnbookedOn = true
                self.delegate?.updateOrangeAnno(isOn: true)
                unbookedButton.setImage( #imageLiteral(resourceName: "orange"), for: .normal)
            }
            
            isSelected = true
            selectedJob = singletonData.getUnbookedJobs[indexPath.row]
            
            // Broadcast to select annotation
            selectedBookOrderNum = (selectedJob["order_number_on_client"] as! Int)
            let keyName = Notification.Name(rawValue: jobBookSelectAnnotationKey)
            NotificationCenter.default.post(name: keyName, object: nil)
        }
        panelTableView.reloadData()
    }
}
