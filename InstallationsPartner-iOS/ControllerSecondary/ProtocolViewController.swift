import UIKit

class ProtocolViewController: UIViewController {
    
    // Order Number
    @IBOutlet weak var orderNumberLabel: UILabel!

    // Job Type View
    @IBOutlet weak var jobTypeView: UIView!
    @IBOutlet weak var selectJobType: UITextField!
    var pickerView = UIPickerView()
    
    // Heat Pump View
    @IBOutlet weak var heatPumpView: UIView!
    @IBOutlet weak var heatPumpDynamicStackView: UIStackView!
    @IBOutlet weak var heatPumpTableView: UITableView!

    // Check List View
    @IBOutlet weak var checkListView: UIView!
    @IBOutlet weak var checkListLabel: UILabel!
    @IBOutlet weak var checkListTableView: UITableView!
    @IBOutlet weak var viewForLvfl: UIView!
    
    // Other View
    @IBOutlet weak var otherView: UIView!
    @IBOutlet weak var commentTextView: UITextView!
    @IBOutlet weak var extraCostTextField: UITextField!
    @IBOutlet weak var checkBoxButton: UIButton!
    var isCheckBoxOn: Bool = false
    @IBOutlet weak var otherNameView: UIView!
    @IBOutlet weak var otherNameTextField: UITextField!
    @IBOutlet weak var otherPersonalNumberView: UIView!
    @IBOutlet weak var otherPersonalNumberTextField: UITextField!
    
    // Photo View
    @IBOutlet weak var photoView: UIView!
    @IBOutlet weak var photoButton: UIButton!
    var isPhotoOn: Bool = false
    let imagePicker = UIImagePickerController()
    
    // Sign View
    @IBOutlet weak var signView: UIView!
    var isSignOn: Bool = false
    @IBOutlet weak var signButton: UIButton!
    
    // Finish
    @IBOutlet weak var finishButton: UIButton!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    
    // Manager
    let jobManager = JobManager()
    let taskManager = TaskManager()
    
    // Data for Protocol
    var order = [String: Any]()
    
    var heatPumpList = PROTOCOL_HEATPUMPLIST
    var checkList = PROTOCOL_CHECKLIST
    
    var selectedProtocolTypeKey: String = "gen"
    var selectedCheckList = [[String:Any]]()
    var photoBase64: String?
    var signatureBase64: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //delegate
        pickerView.dataSource = self
        pickerView.delegate = self
        imagePicker.delegate = self
        checkListTableView.delegate = self
        checkListTableView.dataSource = self
        heatPumpTableView.dataSource = self

        findOrder()
        
        initViews()
        initLabels()
        initButtons()
        initJobTypeSelector()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        print("protocolView: viewWillAppear")

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToDrawingView" {
            let vc = segue.destination as! DrawingViewController
            vc.delegate = self
        }
    }
    
//MARK: - Init
    func initViews() {
        jobTypeView.applyShadowAndRadius()
        heatPumpView.applyShadowAndRadius()
        heatPumpView.isHidden = true
        checkListView.applyShadowAndRadius()
        checkListView.isHidden = true
        otherView.applyShadowAndRadius()
        photoView.applyShadowAndRadius()
        signView.applyShadowAndRadius()
        
        commentTextView.layer.cornerRadius = 15
        commentTextView.layer.borderWidth = 1
        commentTextView.layer.borderColor = UIColor.lightGray.cgColor
                
        refreshOtherPersonField(isOn: isCheckBoxOn)
    }
    
    func initLabels() {
        orderNumberLabel.text = "Order: # " + String(selectedOrderNum!)
    }
    
    func initButtons() {
        photoButton.imageView?.contentMode = UIView.ContentMode.scaleAspectFit
        signButton.imageView?.contentMode = UIView.ContentMode.scaleAspectFit
        finishButton.applyPanelButtonStyle()
    }
    
    func initJobTypeSelector() {
        selectJobType.inputView = pickerView
    }

//MARK: - Methods
    func findOrder() {
        let annoType = selectedAnnoType
        let orderNum = String(selectedOrderNum!)
        self.order = singletonData.findJob(type: annoType, with: orderNum)
    }
    
    func increaseSpaceOnHeatPumpView() {
        let newView = UIView()
        newView.heightAnchor.constraint(equalToConstant: 65).isActive = true
        heatPumpDynamicStackView.addArrangedSubview(newView)
    }
    
    func decreaseSpaceOnHeatPumpView() {
        
        let subviews = heatPumpDynamicStackView.arrangedSubviews
        heatPumpDynamicStackView.removeArrangedSubview(subviews[0])
        
    }
    
    func refreshOtherPersonField(isOn: Bool) {
        otherNameView.isHidden = isOn ? false : true
        otherPersonalNumberView.isHidden = isOn ? false : true
    }
    
    func refreshCheckBox(isOn: Bool) {
                
        if isOn {
            checkBoxButton.setImage(UIImage(systemName: "checkmark.square"), for: .normal)
            checkBoxButton.setTitleColor(#colorLiteral(red: 0.08834790438, green: 0.2386234403, blue: 0.4872178435, alpha: 1), for: .normal)
        } else {
            checkBoxButton.setImage(UIImage(systemName: "square"), for: .normal)
            checkBoxButton.setTitleColor(#colorLiteral(red: 0.6666666865, green: 0.6666666865, blue: 0.6666666865, alpha: 1), for: .normal)
        }
    }
    
    func showCameraActionSheet() {
        // TextFiled Alert
        let actionSheet = UIAlertController(title: "Lägg till bild", message: nil, preferredStyle: .actionSheet)
                
        // Camera Action
        let cameraAction = UIAlertAction(title: "Ta en bild", style: .default) { [self]_ in
            isPhotoOn = true
            imagePicker.sourceType = .camera
            present(imagePicker, animated: true, completion: nil)
        }

        // Library Action
        let libraryAction = UIAlertAction(title: "Välj från biblioteket", style: .default) { [self]_ in
            isPhotoOn = true
            imagePicker.sourceType = .photoLibrary
            present(imagePicker, animated: true, completion: nil)
        }
        
        // Delete Image Action
        let deleteAction = UIAlertAction(title: "Ta bort bild", style: .default) { [self]_ in
            isPhotoOn = false
            let image = UIImage(systemName: "camera.fill")
            photoButton.setImage(image, for: .normal)
            photoButton.setTitle(" Klicka här för att lägga till bild", for: .normal)
        }
        deleteAction.setValue(UIColor.red, forKey: "titleTextColor")

        // Cancle Action
        let cancelAction = UIAlertAction(title: "Avbryt", style: .cancel, handler: nil)

        actionSheet.addAction(cameraAction)
        actionSheet.addAction(libraryAction)
        if(isPhotoOn) { actionSheet.addAction(deleteAction) }
        actionSheet.addAction(cancelAction)

        self.present(actionSheet, animated: true)
    }
    
    func showDrawingScreen() {
        self.performSegue(withIdentifier: "goToDrawingView", sender: self)
    }
    
    func clearDrawingScreen() {
        isSignOn = false
        let image = UIImage(systemName: "pencil.tip")
        signButton.setImage(image, for: .normal)
        signButton.setTitle(" Klicka här för att skriva under", for: .normal)
    }
    
    func showSignActionSheet() {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
                
        // new Sign Action
        let newAction = UIAlertAction(title: "Signera igen", style: .default) { [self]_ in
            showDrawingScreen()
        }

        // delete Sign Action
        let deleteAction = UIAlertAction(title: "Ta bort signaturen", style: .default) { [self]_ in
            clearDrawingScreen()
        }
        deleteAction.setValue(UIColor.red, forKey: "titleTextColor")

        // Cancle Action
        let cancelAction = UIAlertAction(title: "Avbryt", style: .cancel, handler: nil)

        actionSheet.addAction(newAction)
        actionSheet.addAction(deleteAction)
        actionSheet.addAction(cancelAction)

        self.present(actionSheet, animated: true)
    }
    
    func refreshCheckListTableView() {
        if selectedProtocolTypeKey == "lvfl" {
            viewForLvfl.isHidden = false
        } else {
            viewForLvfl.isHidden = true
        }
        checkListTableView.reloadData()
    }
        
    func findProtocolTypeValue(name: String) -> Int {
        for type in PROTOCOL_JOB_TYPES {
            if type["name"] as! String == name {
                return type["val"] as! Int
            }
        }
        return 0
    }
    
    func findProtocolTypeKey(name: String) -> String {
        for type in PROTOCOL_JOB_TYPES {
            if name == type["name"] as! String {
                return type["key"] as! String
            }
        }
        return ""
    }

    func organizeJSONcheckList(typeVal: Int) -> ProtocolCheckList {
        let comment = commentTextView.text!
            + (extraCostTextField.text! == ""
                ? ""
                : "\n\nExtra avgifter:\n\(extraCostTextField.text!)")
        let extraCost =  (Int(extraCostTextField.text!)) ?? 0

        switch typeVal {
        
        case 1:
            let list = ProtocolCheckList (
                extraWork: extraCost,
                comment: comment,
                certNumber: nil,
                
                runOffCheck: (selectedCheckList[0]["value"] as! Int),
                heatPumpOperationWalkthrough: (selectedCheckList[1]["value"] as! Int),
                installationCompleted: (selectedCheckList[2]["value"] as! Int),
                installedWithPlug: (selectedCheckList[3]["value"] as! Int),
                customerElectrician: (selectedCheckList[4]["value"] as! Int)
            )
            return list
            
        case 2...3:
            let list = ProtocolCheckList (
                extraWork: extraCost,
                comment: comment,
                certNumber: nil,
                
                filterInstalled: (selectedCheckList[0]["value"] as! Int),
                circulationPumpVerified: (selectedCheckList[1]["value"] as! Int),
                manometerPressure: (selectedCheckList[2]["value"] as! Int),
                ventilatedBuilding: (selectedCheckList[3]["value"] as! Int),
                valveCheck: (selectedCheckList[4]["value"] as! Int),
                circulationPumpRate: (selectedCheckList[5]["value"] as! String), //%
                spillWaterCheck: (selectedCheckList[6]["value"] as! Int),
                instructionWalkthrough: (selectedCheckList[7]["value"] as! Int),
                floorHeating: (selectedCheckList[8]["value"] as! Int),
                floorHeatingInstallationOnly: (selectedCheckList[9]["value"] as! Int),
                controlSystemParametersCheck: (selectedCheckList[10]["value"] as! Int),
                clearUp: (selectedCheckList[11]["value"] as! Int),
                ppElectricalInstallation: (selectedCheckList[12]["value"] as! Int),
                cableThickness: (selectedCheckList[13]["value"] as! String),
                inPower: (selectedCheckList[14]["value"] as! Int),
                switchCheck: (selectedCheckList[15]["value"] as! Int),
                pumpStartCheck: (selectedCheckList[16]["value"] as! Int),
                installationNotCompleted: (selectedCheckList[17]["value"] as! Int)

            )
            return list
            
        case 4:
            let list = ProtocolCheckList (
                extraWork: extraCost,
                comment: comment,
                certNumber: nil,
                
                productError: (selectedCheckList[0]["value"] as! Int),
                installationError: (selectedCheckList[1]["value"] as! Int),
                productMisplaced: (selectedCheckList[2]["value"] as! Int),
                buildingError: (selectedCheckList[3]["value"] as! Int),
                errorSolved: (selectedCheckList[4]["value"] as! Int)
            )
            return list

        default:
            let list = ProtocolCheckList (
                extraWork: extraCost,
                comment: comment
            )
            return list
        }
    }
    
    func organizeJSONheatPump(typeVal: Int) -> [ProtocolHeatPump]  {
        var list = [ProtocolHeatPump]()
        var pumpName: String = ""
        var pumps = [Pump]()
        
        switch typeVal {
        case 1...4:
            
            for item in heatPumpList {
                
                if let name = item["name"] {
                    if pumps.count > 0 {
                        let heatPump = ProtocolHeatPump (
                            name: pumpName,
                            serialNumbers: pumps
                        )
                        list.append(heatPump)
                    }
                                        
                    pumpName = name as! String
                    pumps = [Pump]()
                    continue
                    
                } else if let type = item["type"] {
                    let pumptype = PumpType(
                        val: (type as! Int) == 1 ? 1 : 2,
                        name: (type as! Int) == 1 ? "inne-del" : "ute-del"
                    )
                    
                    let pump = Pump (
                        serialNumber: (item["serialNumber"] as! String),
                        type: pumptype
                    )
                    pumps.append(pump)
                } else {
                    continue
                }
            }
            
            if pumps.count > 0 {
                let heatPump = ProtocolHeatPump (
                    name: pumpName,
                    serialNumbers: pumps
                )
                list.append(heatPump)
            }
            
            return list
        default:
            return list
        }
    }
    
    func isValidHeatPump() -> Bool  {
        for item in heatPumpList {
            if let name = item["name"],
               (name as! String) == "" {
                return false
            } else if let number = item["serialNumber"],
                      (number as! String) == "" {
                showAlert(title:"Avsluta värmepump", message:"")
                return false
            }
        }
        return true
    }
    
    func isValidCheckList() -> Bool {
        for item in selectedCheckList {
            if let _ = item["input"] {
                if (item["value"] as! String) == "" {
                    return false
                }
            } else if (item["value"] as! Int) == -1 {
                return false
            }
        }
        return true
    }
    
    func tryPostProtocol() {

        // 1. INPUT VALIDATION
//        if !isValidHeatPump() {
//            showAlert(title:"Avsluta checklista", message:"")
//            return
//        }
        
        if !isValidCheckList() {
            showAlert(title:"Vänligen fyll i hela checklistan.", message:"")
            return
        }
        
        if !isPhotoOn {
            showAlert(title:"Du måste ta en bild på installationen.", message:"")
            return
        }
        
        if !isSignOn {
            showAlert(title:"Du måste få installationen signerad.", message:"")
            return
        }
        
        // 2. SETUP JSON
        let orderId = (order["Id"] as! Int)
        let installerName = (order["ResourceName"] as! String)
        let signName = isCheckBoxOn
            ? "Ställföreträdares namn: \(otherNameTextField.text!)"
            : order["Description"] as! String
        let protocolType = ProtocolType(
            val: findProtocolTypeValue(name: selectJobType.text!),
            name: selectJobType.text!
        )
        let protocolCheckList = organizeJSONcheckList(typeVal: protocolType.val!)
        let protocolHeatPump = organizeJSONheatPump(typeVal: protocolType.val!)
        
        //root body
        let protocolBody = JSONpostProtocolBody (
            OrderId: orderId,
            installationProtocolType: protocolType,
            InstallerName: installerName,
            otherSignature: isCheckBoxOn,
            SignatureName: signName,
            signaturePersonalNumber: otherPersonalNumberTextField.text!,
            
            //Base64
            signatureData: signatureBase64,
            PhotoBase64: photoBase64,
            
            //Litss
            checkList: protocolCheckList,
            heatPumps: protocolHeatPump
        )
        
//SHOW JSON STRING
//        let encoder = JSONEncoder()
//        encoder.outputFormatting = .prettyPrinted
//        do {
//            let data = try encoder.encode(protocolBody)
//            print(String(data: data, encoding: .utf8)!)
//        } catch {
//            print("error")
//        }
        
        // 3. post Protocol API
        jobManager.postProtocol(codableData: protocolBody)

    }
    
    private func isSelectedTask() -> Bool {
        let taskOrderId = (selectedTask[K.Task.orderId] as? Int) ?? -1
        let orderId = (order["Id"] as? Int) ?? (order["OrderId"] as? Int) ?? 0
        return taskOrderId == orderId ? true : false
    }

//MARK: - UI Action
    @IBAction func closeButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func checkBoxButtonPressed(_ sender: Any) {
        isCheckBoxOn = !isCheckBoxOn
        
        refreshOtherPersonField(isOn: isCheckBoxOn)
        refreshCheckBox(isOn: isCheckBoxOn)
    }

    @IBAction func cameraButtonPressed(_ sender: Any) {
        showCameraActionSheet()
    }

    @IBAction func signButtonPressed(_ sender: Any) {
        if isSignOn {
            showSignActionSheet()
        } else {
            showDrawingScreen()
        }
    }

    @IBAction func finishButtonPressed(_ sender: Any) {
        tryPostProtocol()
        
        // CHECK RESULT  (success: 204 / error: 500)
        let statusCode = singletonData.postProtocolResponse
        switch statusCode {
        case 204:
            showAlert(title: "Success", message: "")
            
            if (isSelectedTask())
            {
                let taskId = (selectedTask[K.Task.taskId] as! Int)
                taskManager.setTaskDone(taskId)
                jobManager.refreshTasks()
            }
            
            // refresh JobTodayView
            let keyName = Notification.Name(rawValue: refreshJobTodayKey)
            NotificationCenter.default.post(name: keyName, object: nil)
            
            self.dismiss(animated: true, completion: nil)
            
        default:
            showAlert(title: "Protokollet kunde inte slutföras", message: "")
            finishButton.setTitle("Signera", for: .normal)
            spinner.stopAnimating()
        }
    }
    @IBAction func finishButtonTouchDown(_ sender: Any)
    {
        spinner.startAnimating()
        finishButton.setTitle("", for: .normal)
        finishButton.setTitle("", for: .highlighted)
    }
}

//MARK: - DrawingViewControllerDelegate
extension ProtocolViewController: DrawingViewControllerDelegate {

    func updateSignature(_ image: UIImage) {
        let cgImage = image.cgImage
        let rotatedImage = UIImage(cgImage: cgImage!, scale: image.scale, orientation: .left)
        signButton.setTitle("", for: .normal)
        signButton.setImage(rotatedImage, for: .normal)

        let targetSize = CGSize(width: 150, height: 150)
        let scaledImage = rotatedImage.scalePreservingAspectRatio(targetSize)
        signatureBase64 = "data:image/jpeg;base64," + convertImageToBase64String(img: scaledImage)
        
        isSignOn = true
    }
}

//MARK: - UIImagePickerControllerDelegate & UINavigationControllerDelegate
extension ProtocolViewController: UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        imagePicker.dismiss(animated: true, completion: nil)

        guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else { return }
        
        let targetSize = CGSize(width: 300, height: 300)
        let scaledImage = image.scalePreservingAspectRatio(targetSize)
        
        photoButton.setTitle("", for: .normal)
        photoButton.setImage(image, for: .normal)
        photoBase64 = "data:image/jpeg;base64," + convertImageToBase64String(img: scaledImage)
    }
}
//MARK: - UIPickerViewDelegate
extension ProtocolViewController: UIPickerViewDelegate {

}

//MARK: - UIPickerViewDataSource
extension ProtocolViewController: UIPickerViewDataSource {

    //Num of Columns
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    //Num of Rows
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        //number of job types
        return PROTOCOL_JOB_TYPES.count
    }
    
    //titleForRow
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        //name of installers
        return (PROTOCOL_JOB_TYPES[row]["name"] as? String) ?? "-"
    }
    
    //didSelectRow
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectJobType.text = (PROTOCOL_JOB_TYPES[row]["name"] as? String) ?? "-"
        
        if selectJobType.text == "Generic"
        || selectJobType.text == "Ä.T.A" {
            heatPumpView.isHidden = true
            checkListView.isHidden = true
        } else {
            heatPumpView.isHidden = false
            checkListView.isHidden = false
        }
        
        selectJobType.resignFirstResponder()
        
        selectedProtocolTypeKey = findProtocolTypeKey(name: selectJobType.text!)
        selectedCheckList = (checkList[selectedProtocolTypeKey]) ?? [["value": 0]]
        
        refreshCheckListTableView()
    }
}

//MARK: - UITableViewDelegate
extension ProtocolViewController: UITableViewDelegate {
    
    
}

//MARK: - UITableViewDataSource
extension ProtocolViewController: UITableViewDataSource {
    
    // Num of Rows
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        // HEATPUMP
        if tableView == heatPumpTableView {
            return heatPumpList.count //for extraCell
        } else {
        // CHECKLIST
            let key = findProtocolTypeKey(name: selectJobType.text!)
            print(key)
            if let list = checkList[key] {
                return list.count
            } else {
                return 0
            }
        }
    }
    
    // Cell for each
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // HEATPUMP
        if tableView == heatPumpTableView {
            
            let currentPump = heatPumpList[indexPath.row]
            
            //title for heatpump
            if let _ = currentPump["name"] {
                let cell: heatPumpCell = tableView.dequeueReusableCell(withIdentifier: "heatPumpCell") as! heatPumpCell

                cell.row = indexPath.row
                cell.initView()
                cell.cellLabel.text = "Värmepump"
                cell.delegate = self
                return cell
    
            //inne/ute for heatpump
            } else if let _ = currentPump["serialNumber"]{
            
                let cell: heatPumpCell = tableView.dequeueReusableCell(withIdentifier: "heatPumpCell") as! heatPumpCell
                cell.row = indexPath.row
                cell.initView()
                let type = (currentPump["type"] as! Int)
                
                cell.cellLabel.text = type == 1 ? "Innedel" : "Utedel"
                cell.delegate = self
                return cell

            // add button
            } else {
                let cell: heatPumpAddCell = tableView.dequeueReusableCell(withIdentifier: "heatPumpAddCell") as! heatPumpAddCell
                cell.row = indexPath.row
                cell.delegate = self
                return cell
            }
        } else {
            // CHECKLIST
            guard let list = checkList[selectedProtocolTypeKey] else {
                let cell: yesNoCell = tableView.dequeueReusableCell(withIdentifier: "yesNoCell") as! yesNoCell
                return cell}
            
            if list[indexPath.row]["input"] != nil {
                let cell: answerCell = tableView.dequeueReusableCell(withIdentifier: "answerCell") as! answerCell
                
                cell.questionLabel.text = (list[indexPath.row]["title"] as! String)
                cell.row = indexPath.row
                cell.delegate = self
                
                return cell
            } else {
                let cell: yesNoCell = tableView.dequeueReusableCell(withIdentifier: "yesNoCell") as! yesNoCell
                
                cell.questionLabel.text = (list[indexPath.row]["title"] as! String)
                cell.row = indexPath.row
                cell.delegate = self
                
                return cell
            }
        }
    }
}

//MARK: - heatPumpCellDelegate
extension ProtocolViewController: heatPumpCellDelegate {
    func updateHeatPumpText(at row: Int, text: String) {
        if let _ = heatPumpList[row]["name"] {
            heatPumpList[row]["name"] = text
        } else {
            heatPumpList[row]["serialNumber"] = text
        }
    }
    
    func deleteCell(at row: Int) {
        decreaseSpaceOnHeatPumpView()
        heatPumpList.remove(at: row)
        heatPumpTableView.reloadData()
    }
}

//MARK: - heatPumpAddCellDelegate
extension ProtocolViewController: heatPumpAddCellDelegate {
    
    func addInnedel(at row: Int) {
        let newDel = [
                        "serialNumber": "",
                        "type": 1
                    ] as [String : Any]

        increaseSpaceOnHeatPumpView()
        heatPumpList.insert(newDel, at: row)
        heatPumpTableView.reloadData()
    }
    
    func addUtedel(at row: Int) {
        let newDel = [
                        "serialNumber": "",
                        "type": 2
                    ] as [String : Any]

        increaseSpaceOnHeatPumpView()
        heatPumpList.insert(newDel, at: row)
        heatPumpTableView.reloadData()
    }
}

//MARK: - yesNoCellDelegate
extension ProtocolViewController: yesNoCellDelegate {
    func updateCheckList(_ at: Int, _ value: Int) {
        selectedCheckList[at]["value"] = value
    }
}

//MARK: - answerCellDelegate
extension ProtocolViewController: answerCellDelegate {
    func updateCheckList(_ at: Int, _ value: String) {
        selectedCheckList[at]["value"] = value
        print(selectedCheckList[at]["value"])
    }
}
