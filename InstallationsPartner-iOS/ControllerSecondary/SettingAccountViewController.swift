import UIKit

class SettingAccountViewController: UIViewController {
    //UserDefault
    let defaults = UserDefaults.standard
    
    let resetPasswordManager = ResetPasswordManager()

    @IBOutlet weak var userNameView: UIView!
    @IBOutlet weak var addressView: UIView!
    @IBOutlet weak var emailView: UIView!
    @IBOutlet weak var resetPasswordView: UIView!
    
    @IBOutlet weak var userNameButton: UIButton!
    @IBOutlet weak var addressButton: UIButton!
    @IBOutlet weak var emailButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        initStyles()
        initButtonTitles()
    }
    
//MARK: - Init
    
    func initStyles() {
        userNameView.applyShadowAndRadius()
        addressView.applyShadowAndRadius()
        emailView.applyShadowAndRadius()
        resetPasswordView.applyShadowAndRadius()
    }
    
    func initButtonTitles() {
        
        let userName = "  " + (singletonData.getUserData?.userDisplayName)!
        userNameButton.setTitle(userName, for: .normal)
        
        let companyAddress: JSONgetCompanyAddress = singletonData.getCompanyAddress!
        guard let street = companyAddress.street_address else {return}
        guard let postal = companyAddress.postal_code else {return}
        guard let city = companyAddress.city_name else {return}
        
        let address = "  " + street + ", " + postal + " " + city
        addressButton.setTitle(address, for: .normal)
        
        let email = "  " + defaults.string(forKey: K.UserDefaults.email)!
        emailButton.setTitle(email, for: .normal)
    }
    
//MARK: - UI Actions
    
    @IBAction func closeButtonPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func resetPasswordButtonPressed(_ sender: Any) {
        let email = defaults.string(forKey: K.UserDefaults.email)!

        // + start spinner
        resetPasswordManager.requestReset(with: email)
        // + stop spinner
        
        self.showAlert(title:"E-post skickad", message:"Instruktioner har nu skickats till din e-postadress.")
    }
}
