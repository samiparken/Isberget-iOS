import UIKit
import MessageUI

class SettingViewController: UIViewController {
    //UserDefault
    let defaults = UserDefaults.standard

    let loginManager = LoginManager()
    
    //Views
    @IBOutlet weak var accountView: UIView!
    @IBOutlet weak var weekendSwitchView: UIView!
    @IBOutlet weak var bugReportView: UIView!
    @IBOutlet weak var contactInfoView: UIView!
    
    @IBOutlet weak var logoutButton: UIButton!
    @IBOutlet weak var weekendSwitch: UISwitch!
        
    @IBOutlet weak var appVersionLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
                
        initSwitches()
        initStyle()
        initLabels()
    }
    
//MARK: - Init
    func initSwitches() {
        weekendSwitch.isOn = defaults.bool(forKey: K.UserDefaults.Settings.weekendSwitch)
    }
    
    func initStyle() {
        accountView.applyShadowAndRadius()
        logoutButton.applyPanelButtonStyle()
        weekendSwitchView.applyShadowAndRadius()
        bugReportView.applyShadowAndRadius()
        contactInfoView.applyShadowAndRadius()
    }
    
    func initLabels() {
        appVersionLabel.text = "App Version: " + UIApplication.appVersion!
    }

//MARK: - UI Actions
    @IBAction func closeButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
        
    @IBAction func logoutButtonPressed(_ sender: Any) {
                
        // clear data
        loginManager.clearDataForLogout()

        // go to LoginView
        DispatchQueue.main.async {
            self.presentingViewController?.presentingViewController?.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func weekendSwitchChanged(_ sender: Any) {
        self.defaults.set(weekendSwitch.isOn, forKey: K.UserDefaults.Settings.weekendSwitch)

        // refresh calendar
        let keyName = Notification.Name(rawValue: refreshCalendarKey)
        NotificationCenter.default.post(name: keyName, object: nil)
    }
    
    @IBAction func bugReportButtonPressed(_ sender: Any) {
        
        let bodyTitle = "//Buggrapport//\n"
        let email = self.defaults.string(forKey: K.UserDefaults.email)! + "\n"
        let companyName = ((singletonData.getUserData?.companyName) ?? "" ) + "\n"
        let deciveVersion = "iOS" + UIDevice.current.systemVersion + "(" + UIDevice.modelName + ")\n"
        let appVersion = "AppVersion: " + UIApplication.appVersion! + "(" + UIApplication.buildNumber! + ")\n"
        let message = "Bug Description: \n"
        
        let composeVC = MFMessageComposeViewController()
        composeVC.messageComposeDelegate = self

        // Configure the fields of the interface.
        composeVC.recipients = [K.Setting.bugReportPhone]
        composeVC.body = bodyTitle + email + companyName + deciveVersion + appVersion + message

        // Present the view controller modally.
        if MFMessageComposeViewController.canSendText() {
            self.present(composeVC, animated: true, completion: nil)
        }
    }
}

//MARK: - MFMessageComposeViewControllerDelegate
extension SettingViewController: MFMessageComposeViewControllerDelegate {
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        dismiss(animated: true, completion: nil)
    }
}
