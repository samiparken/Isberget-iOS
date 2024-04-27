

import UIKit
import Foundation

class ResetPasswordViewController: UIViewController {
    let defaults = UserDefaults.standard
    
    @IBOutlet weak var closeButton: UIBarButtonItem!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var emailTextField: UITextField!
    
    // For DebugMode
    @IBOutlet weak var debugStackView: UIStackView!
    @IBOutlet weak var hostTextField: UITextField!
    @IBOutlet weak var applyButton: UIButton!
    
    let resetPasswordManager = ResetPasswordManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //delegate
        emailTextField.delegate = self
                        
        sendButton.applyPanelButtonStyle()
        disableSend()
        
        //Init for Debug View
        debugStackView.isHidden = true
        applyButton.applyPanelButtonStyle()
    }
    
    private func enableSend() {
        sendButton.setTitleColor(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1), for: .normal)
        sendButton.backgroundColor = #colorLiteral(red: 0.1546343565, green: 0.3047484159, blue: 0.5878322721, alpha: 1)
        sendButton.isEnabled = true
    }
    private func disableSend() {
        sendButton.setTitleColor(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.6646646664), for: .normal)
        sendButton.backgroundColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
        sendButton.isEnabled = false
    }
    
    @IBAction func sendButtonPressed(_ sender: Any) {
        self.view.endEditing(true)
        // + start spinner
        resetPasswordManager.requestReset(with: emailTextField.text!)
        // + stop spinner
        
        showAlert(title:"E-post skickad", message:"Instruktioner har nu skickats till din e-postadress.")
    }
    
    @IBAction func closeButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }    

    var debugModeCounter: Int = 0
    @IBAction func logoButtonPressed(_ sender: Any) {
        debugModeCounter += 1
        if debugModeCounter > 5 {
            hostTextField.text = singletonData.baseUrl
            debugStackView.isHidden = false
        }
    }
    @IBAction func applyButtonPressed(_ sender: Any) {
        self.view.endEditing(true)
        singletonData.baseUrl = hostTextField.text
        self.defaults.set(singletonData.baseUrl, forKey: K.UserDefaults.baseUrl)
        showAlert(title: "Set Host", message: singletonData.baseUrl!)
    }
}

extension ResetPasswordViewController: UITextFieldDelegate {
    //When "Return"Key is hit on Keyboard
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        emailTextField.endEditing(true)
        return true
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        if (isValidEmail(emailTextField.text!)) {
            enableSend()
        } else {
            disableSend()
        }
    }

}
