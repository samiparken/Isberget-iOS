import UIKit
import CoreLocation

class TaskViewController: UIViewController {
    
    //Views
    @IBOutlet weak var taskTableView: UITableView!
    
    //Controllers
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    //Labels
    @IBOutlet weak var noMessageLabel: UILabel!
    
    @IBOutlet weak var tabbarItem: UITabBarItem!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var loadingBG: UIView!
    
    //Managers
    let taskManager = TaskManager()

    var isFilterActive: Bool = true
    var newTasks = [[String:Any]]()
    var messageDistance = [Int: Double]()
    
    var initialLoad: Bool = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("TaskVC: viewDidLoad() Start")
        
        //Delegate
        taskTableView.dataSource = self  //for init
        taskTableView.delegate = self    //for interection
        
        registerObservers()
        
        //Prepare Screen
        initTableView()
        initRefreshControl()
        initLabels()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        print("TaskVC: viewWillAppear() Start")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print("TaskVC: viewDidAppear() Start")
    }
    
//MARK: - For Notification Observers

    let keyTaskViewReloadData = Notification.Name(rawValue: taskViewReloadDataKey)
    let keyTaskViewLoadingStart = Notification.Name(rawValue: taskViewLoadingStartKey)
    let keyTaskViewLoadingStop = Notification.Name(rawValue: taskViewLoadingStopKey)
    let ketTaskViewShowErrorAlert = Notification.Name(rawValue: taskViewShowErrorAlertKey)

    // Register Observers for updates
    func registerObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(TaskViewController.reloadData(notification:)), name: keyTaskViewReloadData, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(TaskViewController.loadingStart(notification:)), name: keyTaskViewLoadingStart, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(TaskViewController.loadingStop(notification:)), name: keyTaskViewLoadingStop, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(TaskViewController.showErrorAlert(notification:)), name: ketTaskViewShowErrorAlert, object: nil)
    }
    
    @objc func reloadData(notification: NSNotification) {
        if initialLoad {
            self.initialLoad = false
            self.spinner.stopAnimating()
            self.noMessageLabel.isHidden = false
            self.taskTableView.isHidden = false
        }
        newTasks = singletonData.getTasks.filter { ($0[K.Task.isDone] as! Bool) == false}
        taskTableView.reloadData()
    }
    
    @objc func loadingStart(notification: NSNotification) {
        self.loadingBG.isHidden = false
        self.spinner.startAnimating()
    }
    
    @objc func loadingStop(notification: NSNotification) {
        self.loadingBG.isHidden = true
        self.spinner.stopAnimating()
    }
    
    @objc func showErrorAlert(notification: NSNotification) {
        self.showAlert(title: "Error", message: "Det hittar inte beställningen.\nKontakta Kundservice.")
    }


//MARK: - Init
    func initRefreshControl() {
        // Refresh Control
        taskTableView.refreshControl = UIRefreshControl()
        taskTableView.refreshControl?.addTarget(self, action: #selector(didPullToRefresh), for: .valueChanged)
    }
                
    func initTableView() {
        taskTableView.backgroundColor = .clear
        taskTableView.isHidden = true
    }
    
    func initLabels() {
        noMessageLabel.isHidden = true
    }
    
//MARK: - Methods
    
    @objc private func didPullToRefresh() {
        taskManager.refreshTasks()
        
        DispatchQueue.main.asyncAfter(deadline: .now()+2) {
            self.taskTableView.refreshControl?.endRefreshing()
            self.refreshTabbarBadge()
            self.noMessageLabel.isHidden = false
            self.newTasks = singletonData.getTasks.filter { ($0[K.Task.isDone] as! Bool) == false}
            self.taskTableView.reloadData()
        }
    }
        
    func refreshTabbarBadge() {
        var i: Int = 0
        for task in singletonData.getTasks {
            i = task[K.Task.isDone] as! Bool ? i : i + 1
        }
        tabbarItem.badgeValue = i == 0 ? nil : String(i)
    }
    
//MARK: - UI Actions
    @IBAction func segmentedControlChanged(_ sender: Any) {
        switch segmentedControl.selectedSegmentIndex
        {
        case 0: //Nya
            isFilterActive = true
            noMessageLabel.text = "Inga nya uppgifter"
        case 1: //Alla
            isFilterActive = false
            noMessageLabel.text = "Inga uppgifter"
        default:
            break
        }
        noMessageLabel.isHidden = false
        self.taskTableView.reloadData()
    }
}	

//MARK: - UITableViewDataSource
extension TaskViewController: UITableViewDataSource {
    
    //Num of Rows
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if isFilterActive {
            return newTasks.count
        } else {
            return singletonData.getTasks.count
        }
    }
    
    //Row content, called as many as the Number of Rows
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let task = isFilterActive
            ? newTasks[indexPath.row]
            : singletonData.getTasks[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: K.Task.Cell, for: indexPath) as! TaskCell //Casting TaskCell
        
        if !noMessageLabel.isHidden {
            noMessageLabel.isHidden = true
        }
        
//        cell.isFilterActive = isFilterActive
//        cell.rowNum = indexPath.row
        cell.task = task
        cell.index = indexPath.row
        cell.initCell()
        return cell
    }
}

//MARK: - UITableViewDelegate
extension TaskViewController: UITableViewDelegate {

    //didSelectRow
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let message = singletonData.getMessages[indexPath.row]
//        if let id = message[K.Task.id] as? Int {
//            messageManager.setReadMessage(id)
//            singletonData.getMessages[indexPath.row][K.Task.read] = !(message[K.Task.read] as? Bool ?? false)
//            refreshTabbarBadge()
//            messageTableView.reloadData()
//        }
//    }
}
