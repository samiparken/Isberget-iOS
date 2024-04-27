import UIKit

class CustomerAnswersViewController: UIViewController {

    // Manager
    let jobManager = JobManager()

    // Data
    var orderNum: Int?
    var orderId: Int?
    var answerList = [[String:Any]]()

    // View
    @IBOutlet weak var answersTableView: UITableView!

    // label
    @IBOutlet weak var orderNumLabel: UILabel!
    
    // Spinner View
    @IBOutlet weak var loadingBG: UIView!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        answersTableView.dataSource = self

        initLabels()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print("CustomerAnswersView: viewDidAppear")
          loadingStop()
          initCustomerAnswers()
    }
    
    
//MARK: - Init
    func initLabels() {
        orderNumLabel.text = "Order: # " + String(orderNum ?? 0)
                
    }
    
    func initCustomerAnswers() {

        loadingStart()
        
        DispatchQueue.global(qos: .background).async {
            
            if singletonData.customerAnswers[self.orderId!] == nil {
                self.jobManager.getCustomerAnswers(self.orderId!)
            }
            
            self.answerList = singletonData.customerAnswers[self.orderId!] ?? []

            DispatchQueue.main.async {
                self.loadingStop()
                
                if self.answerList.count > 0 {
                    
                    self.answersTableView.reloadData()
                                        
                } else {

                    // + error handling
                }
            }
        }
    }


//MARK: - Methods
    
    func loadingStart() {
        self.loadingBG.isHidden = false
        self.spinner.startAnimating()
    }
    
    func loadingStop() {
        self.loadingBG.isHidden = true
        self.spinner.stopAnimating()
    }

    
//MARK: - UI Actions
    @IBAction func closeButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
}


//MARK: - UITableViewDataSource
extension CustomerAnswersViewController: UITableViewDataSource {
    
    // Num of Rows
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return answerList.count
    }
    
    // Cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let answerSet = answerList[indexPath.row]
        
        let cell: CustomerAnswerCell = tableView.dequeueReusableCell(withIdentifier: "CustomerAnswerCell") as! CustomerAnswerCell
        
        cell.answerSet = answerSet
        cell.initCell()
        
        return cell
    }
}
