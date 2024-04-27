import UIKit
import MessageUI

class SettingContactInfoViewController: UIViewController {

    @IBOutlet weak var carlButton: UIButton!
    @IBOutlet weak var olofButton: UIButton!
    @IBOutlet weak var hansaemButton: UIButton!
    
    @IBOutlet weak var carlView: UIView!
    @IBOutlet weak var olofView: UIView!
    @IBOutlet weak var hansaemView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initViews()
    }
    
//MARK: - Init
    func initViews() {
        carlView.applyShadowAndRadius()
        olofView.applyShadowAndRadius()
        hansaemView.applyShadowAndRadius()
    }
    
//MARK: - Methods
    
    func showContactActionSheet(_ name: String, _ phone: String, _ email: String) {
        // TextFiled Alert
        let actionSheet = UIAlertController(title: "Vad vill du göra?\n-> \(name)", message: nil, preferredStyle: .actionSheet)
                
        // SMS Action
        let smsAction = UIAlertAction(title: "Skicka SMS", style: .default) { [self]_ in
            
            let composeVC = MFMessageComposeViewController()
            composeVC.messageComposeDelegate = self

            // Configure the fields of the interface.
            composeVC.recipients = [phone]

            // Present the view controller modally.
            if MFMessageComposeViewController.canSendText() {
                self.present(composeVC, animated: true, completion: nil)
            }
        }

        // email Action
        let emailAction = UIAlertAction(title: "Skicka epost", style: .default) { [self]_ in

            let mail = MFMailComposeViewController()
            mail.delegate = self
            mail.setToRecipients([email])
            mail.setSubject("")
            mail.setMessageBody("", isHTML: false)
            
            if MFMailComposeViewController.canSendMail() {
                self.present(UINavigationController(rootViewController: mail), animated: true, completion: nil)
            } else {
                self.showAlert(title: "Register your email on your iPhone.", message:"")
            }
        }
        
        // call Action
        let callAction = UIAlertAction(title: "Ringa", style: .default) {_ in
            makeACall(with: phone)
        }

        // Cancle Action
        let cancelAction = UIAlertAction(title: "Avbryt", style: .cancel, handler: nil)
        cancelAction.setValue(UIColor.red, forKey: "titleTextColor")

        actionSheet.addAction(smsAction)
        actionSheet.addAction(emailAction)
        actionSheet.addAction(callAction)
        actionSheet.addAction(cancelAction)

        self.present(actionSheet, animated: true)
    }
    
//MARK: - UI Actions
    @IBAction func closeButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func contactButtonPressed(_ sender: UIButton) {
        var name: String?
        var phone: String?
        var email: String?

        switch sender {
        case carlButton:
            name = "Carl Palsson"
            phone = "0046735000096"
            email = "carl.palsson@installationspartner.se"
            
        case olofButton:
            name = "Olof Watson"
            phone = "0046735360149"
            email = "olof.watson@installationspartner.se"
            
        case hansaemButton:
            name = "Han-Saem Park"
            phone = "0046793498227"
            email = "hansaem.park@frontedgeit.se"
            
        default:
            name = "Carl Palsson"
            phone = "0046735000096"
            email = "carl.palsson@installationspartner.se"
        }
        
        showContactActionSheet(name!, phone!, email!)
    }
}

//MARK: - MFMessageComposeViewControllerDelegate
extension SettingContactInfoViewController: MFMessageComposeViewControllerDelegate {
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        dismiss(animated: true, completion: nil)
    }
}

//MARK: - MFMailComposeViewControllerDelegate
extension SettingContactInfoViewController: UINavigationControllerDelegate & MFMailComposeViewControllerDelegate  {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true,completion: nil)
    }
}
