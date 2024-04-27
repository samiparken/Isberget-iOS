import UIKit

class FilterViewController: UIViewController {

    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var installerTableView: UITableView!
    
    @IBOutlet weak var deliveredSwitch: UISwitch!
    @IBOutlet weak var deliveryDateSwitch: UISwitch!
    @IBOutlet weak var noDeliveryDateSwitch: UISwitch!
    
    let jobManager = JobManager()
    
    var tempList = [[String:Any]]()
    var tempOnList = [Int]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //delegate
        installerTableView.delegate = self
        installerTableView.dataSource = self
        
        getCurrentFilter()
        initButtons()
    }
    
//MARK: - Init

    func initButtons() {
        saveButton.applyPanelButtonStyle()
    }
    
    func getCurrentFilter() {
        tempList = singletonData.listOfInstallers
        tempOnList = singletonData.onInstallersId
        
        deliveredSwitch.isOn = singletonData.isOn_delivered
        deliveryDateSwitch.isOn = singletonData.isOn_deliveryDate
        noDeliveryDateSwitch.isOn = singletonData.isOn_noDeliveryDate
    }
    
//MARK: - Methods
    
    
//MARK: - UI Actions

        
    @IBAction func saveButtonPressed(_ sender: Any) {
        singletonData.listOfInstallers = tempList
        singletonData.onInstallersId = tempOnList

        singletonData.isOn_delivered = deliveredSwitch.isOn
        singletonData.isOn_deliveryDate = deliveryDateSwitch.isOn
        singletonData.isOn_noDeliveryDate = noDeliveryDateSwitch.isOn

        jobManager.refreshTodayJobsWithDate()
        
        // Apply filtered jobs on Calendar & Map (for both)
        //                         Panel & Badge(for Today)
        let keyName = Notification.Name(rawValue: filterDidSaveKey)
        NotificationCenter.default.post(name: keyName, object: nil)
        jobManager.updateAllBadges()
        
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cancelButtonPresssed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}

//MARK: - UITableViewDelegate
extension FilterViewController: UITableViewDelegate {
    
}

//MARK: - UITableViewDataSource
extension FilterViewController: UITableViewDataSource {
    
    // Num of rows
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tempList.count
    }
    
    // Cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let installer = tempList[indexPath.row]
        let cell: SelectInstallerCell = tableView.dequeueReusableCell(withIdentifier: "SelectInstallerCell") as! SelectInstallerCell
        
        let on = installer["on"] as! Bool
        let name = installer["userDisplayName"] as! String

        cell.delegate = self
        cell.row = indexPath.row
        cell.setText(with: name)
        if on {
            cell.setOn()
        } else {
            cell.setOff()
        }
    
        return cell
    }
}

//MARK: - SelectInstallerCellDelegate
extension FilterViewController: SelectInstallerCellDelegate {
    
    func updateInstallerList(at row: Int, on: Bool) {
        tempList[row]["on"] = on ? true : false
        
        let targetId = tempList[row]["userId"] as! Int
        if on {
            tempOnList.append(targetId)
        } else {
            tempOnList = tempOnList.filter { $0 != targetId }
        }
    }
}
