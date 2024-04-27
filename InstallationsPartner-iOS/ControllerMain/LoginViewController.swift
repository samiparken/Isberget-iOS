import UIKit

class LoginViewController: UIViewController {

    //UserDefault
    let defaults = UserDefaults.standard
    
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    @IBOutlet weak var mainStackView: UIStackView!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var stayLoginSwitch: UISwitch!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var appVersionLabel: UILabel!
        
    //Managers
    var loginManager = LoginManager()
        
    override func viewDidLoad() {
        super.viewDidLoad()

        emailTextField.delegate = self
        passwordTextField.delegate = self

        initData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        initScreenComponents()

        if let error = singletonData.error {
            self.showAlert(title: error, message: "")
            singletonData.error = nil
        } else {
            tryLoginWithToken()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "goToTabBarView" {
            stopSpinner()
        }
    }


//MARK: - Init
    func initData() {
        recoverBaseUrl()
        singletonData.screenWidth = view.frame.width
    }
    
    func initScreenComponents() {
        
        // Button Style
        loginButton.applyPanelButtonStyle()
        
        // StayLoginSwitch
        let onOff = defaults.bool(forKey: K.UserDefaults.stayLogin)
        stayLoginSwitch.setOn(onOff, animated: true)

        // Recover email & pw
        emailTextField.text = defaults.string(forKey: K.UserDefaults.email) ?? ""
        passwordTextField.text = defaults.string(forKey: K.UserDefaults.password) ?? ""
        
        // set LoginButton
        checkLoginButton()
        
        // appVersion
        appVersionLabel.text = "App Version: " + UIApplication.appVersion!
    }
    
    func recoverBaseUrl() {
        if let baseUrl = defaults.string(forKey: K.UserDefaults.baseUrl) {
            singletonData.baseUrl = baseUrl
        } else {
            singletonData.baseUrl = K.API.BaseUrl
            self.defaults.set(K.API.BaseUrl, forKey: K.UserDefaults.baseUrl)
        }
    }

    
//MARK: - Methods

    func tryLoginWithToken() {
        
        let stayLogin = defaults.bool(forKey: K.UserDefaults.stayLogin)
        let token = defaults.string(forKey: K.UserDefaults.token)
        let expire = checkExpirationDate()
        
        if(stayLogin) {
            emailTextField.text = defaults.string(forKey: K.UserDefaults.email)!
            passwordTextField.text = defaults.string(forKey: K.UserDefaults.password)!
            checkLoginButton()
        }
        
        if (stayLogin && expire && (token != nil)) {
            startSpinner()
            requestLogin()
        }
    }
    
    func requestLogin() {
        let result = loginManager.tryLogin(email: emailTextField.text!, password: passwordTextField.text!)

        if result == K.Login.success {
            // stayLoginSwitch
            self.defaults.set(stayLoginSwitch.isOn, forKey: K.UserDefaults.stayLogin)
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: "goToTabBarView", sender: self)
            }
        } else {
            stopSpinner()
            self.showAlert(title: result, message: "")
            singletonData.error = nil
        }
    }

    private func checkExpirationDate() -> Bool {
        guard let expireString = defaults.string(forKey: K.UserDefaults.tokenExpiration) else { return false }
        let expireDate = stringToDateForLogin(with: expireString)
        let today = Date()
        return today < expireDate
    }
    
    private func checkLoginButton() {
        if (isValidEmail(emailTextField.text!)) && (passwordTextField.text != "") {
            loginEnabled()
        } else {
            loginDisabled()
        }
    }
    private func loginEnabled() {
        loginButton.setTitleColor(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1), for: .normal)
        loginButton.backgroundColor = #colorLiteral(red: 0.1095948145, green: 0.3001712561, blue: 0.6087573171, alpha: 1)
        loginButton.isEnabled = true
    }
    private func loginDisabled() {
        loginButton.setTitleColor(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 0.6646646664), for: .normal)
        loginButton.backgroundColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
        loginButton.isEnabled = false
    }
    
    private func startSpinner() {
        spinner.startAnimating()
        mainStackView.isHidden = true
    }
    
    private func stopSpinner() {
        spinner.stopAnimating()
        mainStackView.isHidden = false
    }

    
//MARK: - UIActions
    @IBAction func loginButtonPressed(_ sender: Any) {
        loginButton.backgroundColor = #colorLiteral(red: 0.1095948145, green: 0.3001712561, blue: 0.6087573171, alpha: 1)
        requestLogin()
    }
    @IBAction func loginButtonTouchDown(_ sender: Any) {
        self.view.endEditing(true)
        spinner.startAnimating()
        mainStackView.isHidden = true
        loginButton.backgroundColor = #colorLiteral(red: 0.1095948145, green: 0.3001712561, blue: 0.6087262034, alpha: 0.8) //Opacity:80%
    }
}

//MARK: - UITextFieldDelegate
extension LoginViewController: UITextFieldDelegate {
    
    //When "Return"Key is hit on Keyboard
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        emailTextField.endEditing(true)
        passwordTextField.endEditing(true)
        return true //true if it's default behavior
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        checkLoginButton()
    }
}
