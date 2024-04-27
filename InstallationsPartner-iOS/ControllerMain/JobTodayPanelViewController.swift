import UIKit

protocol JobTodayPanelViewControllerDelegate {
    func updateYellowAnno(isOn: Bool)
    func updateGreenAnno(isOn: Bool)
    func updateGrayAnno(isOn: Bool)
}

class JobTodayPanelViewController: UIViewController {
    var delegate: JobTodayPanelViewControllerDelegate?

    @IBOutlet weak var panelTableView: UITableView!
    
    @IBOutlet weak var bookingButton: UIButton!
    @IBOutlet weak var bookedButton: UIButton!
    @IBOutlet weak var doneButton: UIButton!
    
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var refreshButton: UIButton!
    
    var isBookingOn: Bool = true
    var isBookedOn: Bool = true
    var isDoneOn: Bool = true
    
    var isSelected: Bool = false
    var selectedJob = [String:Any]()
    
    let jobManager = JobManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //Delegate
        panelTableView.delegate = self
        panelTableView.dataSource = self

        // Register JobTodayCell
        panelTableView.register(UINib(nibName: K.JobToday.Cell, bundle: nil), forCellReuseIdentifier: K.JobToday.Cell)
        
        registerObservers()
        initSpinner()
    }
    
    
    //MARK: - For Notification Observers
    
    // for Notification Observers
    let keySelectedOnPanel = Notification.Name(rawValue: jobTodaySelectedOnPanelKey)
    let keyAllOnPanel = Notification.Name(rawValue: jobTodayAllWithDateOnPanelKey)
    let keyReloadPanel = Notification.Name(rawValue: jobTodayPanelReloadKey)
    let keyRefreshJobToday = Notification.Name(rawValue: refreshJobTodayKey)

    // Register Observers for updates
    func registerObservers() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(JobTodayPanelViewController.showSelectedOnPanel(notification:)), name: keySelectedOnPanel, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(JobTodayPanelViewController.showAllOnPanel(notification:)), name: keyAllOnPanel, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(JobTodayPanelViewController.reloadPanel(notification:)), name: keyReloadPanel, object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(JobTodayPanelViewController.refreshJobToday(notification:)), name: keyRefreshJobToday, object: nil)
    }

    // Refresh JobTodayView
    @objc func refreshJobToday(notification: NSNotification) {
        refreshView()
    }
    
    @objc func reloadPanel(notification: NSNotification) {
        panelTableView.reloadData()
        stopSpinner()
    }
    
    @objc func showSelectedOnPanel(notification: NSNotification) {
        print("show Selected")
        isSelected = true
        
        let orderNum = selectedTodayAnnoView?.annotation?.subtitle!!
        let job1 = singletonData.findJob(type: K.Annotation.bookingJob, with: orderNum)
        let job2 = singletonData.findJob(type: K.Annotation.bookedJob, with: orderNum)
        let job3 = singletonData.findJob(type: K.Annotation.doneJob, with: orderNum)

        selectedJob = job1.count > 0 ? job1
                    : job2.count > 0 ? job2 : job3
        
        panelTableView.reloadData()
    }
    @objc func showAllOnPanel(notification: NSNotification) {
        print("show All")
        isSelected = false
        
        panelTableView.reloadData()
    }
    
//MARK: - Init
    func initSpinner() {
        if !singletonData.isJobTodayViewLoadedInitialData {
            stopSpinner()
        } else {
            startSpinner()
        }
    }

//MARK: - Methods
    func refreshView() {
        startSpinner()
        jobManager.refreshBookingAndBookedJobs()
    }
    
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
        refreshView()
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
    
    @IBAction func doneButtonPressed(_ sender: Any) {
        isDoneOn = !isDoneOn
        self.delegate?.updateGrayAnno(isOn: isDoneOn)
        doneButton.setImage( isDoneOn ? #imageLiteral(resourceName: "completed") : #imageLiteral(resourceName: "completed-not"), for: .normal)
    }
}

//MARK: - UITableViewDataSource
extension JobTodayPanelViewController: UITableViewDataSource {
    
    //Num of Rows
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isSelected ? 1 : filterJob( selectedTodayJobsWithDate ).count
    }
    
    //Row Height
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {
        return 115
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let job = isSelected ? selectedJob : filterJob( selectedTodayJobsWithDate )[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: K.JobToday.Cell, for: indexPath)
            as! JobTodayCell   //Casting Cell
        
        cell.order = job
        cell.initCell()
                
        return cell
    }
}

//MARK: - UITableViewDelegate

extension JobTodayPanelViewController: UITableViewDelegate {
    
    // Handler for selection
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        if (!isSelected) {
            
            isSelected = true
            let cell = tableView.cellForRow(at: indexPath) as! JobTodayCell

            selectedJob = filterJob( selectedTodayJobsWithDate )[indexPath.row]
            
            // Broadcast to select annotation
            selectedTodayOrderNum = cell.orderNum
            let keyName = Notification.Name(rawValue: jobTodaySelectAnnotationKey)
            NotificationCenter.default.post(name: keyName, object: nil)
        }
        panelTableView.reloadData()
    }    
}
