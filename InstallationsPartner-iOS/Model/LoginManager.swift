
import Foundation
import UIKit

class LoginManager {
    let defaults = UserDefaults.standard
    
    func tryLogin(email: String, password: String) -> String {
        APIlogin(email: email, password: password); semaphore.wait()
        
        if let error = singletonData.login?.error_description {
            return error
        }
        
        if let error = singletonData.error {
            return error
        }
        
        //Set UserDefault
        self.defaults.set(singletonData.login?.access_token, forKey: K.UserDefaults.token)
        self.defaults.set(email, forKey: K.UserDefaults.email)
        self.defaults.set(password, forKey: K.UserDefaults.password)
        self.defaults.set(singletonData.login?.expires, forKey: K.UserDefaults.tokenExpiration)
        
        if(singletonData.login?.roles != K.INSTALLER) {
            APIgetUserData(); semaphore.wait()
            APIgetUsersInCompany(companyId: (singletonData.getUserData?.companyId!)!)
            APIgetCompanyAddress(companyId: (singletonData.getUserData?.companyId!)!)
            
            semaphore.wait()
            semaphore.wait()
            
            //Set UserDefault
            self.defaults.set(singletonData.getUserData?.userId, forKey: K.UserDefaults.user_id)
            self.defaults.set(singletonData.getUserData?.companyId, forKey: K.UserDefaults.company_id)
            self.defaults.set(singletonData.getUsersInCompany, forKey: K.UserDefaults.usersInCompany)
            self.defaults.set(false, forKey: K.UserDefaults.isInstaller)
            
        } else {
            APIgetUserData(); semaphore.wait()
//            self.getAllCompanyInfo(); semaphore.wait()
//            self.getCurrentUserCompaniesAndChildren(); semaphore.wait()
            APIgetUsersInCompany(companyId: (singletonData.getUserData?.companyId!)!)
            APIgetCompanyAddress(companyId: (singletonData.getUserData?.companyId!)!)
            semaphore.wait()
            semaphore.wait()
            
            //Set UserDefault
            self.defaults.set(singletonData.getUserData?.userId, forKey: K.UserDefaults.user_id)
            self.defaults.set(singletonData.getUserData?.companyId, forKey: K.UserDefaults.company_id)
            self.defaults.set(singletonData.getUsersInCompany, forKey: K.UserDefaults.usersInCompany)
            self.defaults.set(true, forKey: K.UserDefaults.isInstaller)
        }
        updateDeviceToken()
        return K.Login.success
    }
    
    func clearDataForLogout() {
        //store
        let baseUrl = defaults.string(forKey: K.UserDefaults.baseUrl)
        
        //clear userDefaults
        UserDefaults.resetDefaults()
        singletonData.clearData()
        
        // reset initial data flags
        singletonData.isJobAcceptViewLoadedInitialData = true
        singletonData.isJobBookViewLoadedInitialData = true
        singletonData.isJobTodayViewLoadedInitialData = true

        //recover
        singletonData.baseUrl = baseUrl
        self.defaults.set(baseUrl, forKey: K.UserDefaults.baseUrl)
    }
    
    // DeviceToken for Push Notification
    func updateDeviceToken() {
        let uid = defaults.integer(forKey: K.UserDefaults.user_id)
        let did = UIDevice.current.identifierForVendor?.uuidString
        let dToken = defaults.string(forKey: K.UserDefaults.deviceToken) ?? ""
        if( uid != 0 && did != "" && dToken != "") {
            print("APIupdateDeviceToken")
            APIupdateDeviceToken(uid, did!, dToken); semaphore.wait()
        }
    }
}
