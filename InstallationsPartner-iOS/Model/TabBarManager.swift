import Foundation

class TabBarManager {
    let defaults = UserDefaults.standard
    
    func getPushNotificationData() -> [String: Any] {
        
        // Parsing data
        let msgData = singletonData.pushNotificationData
        let data = msgData!.data(using: .utf8)!
        var jsonData = [String:Any]()
        do {
            let jsonObject = try JSONSerialization.jsonObject(with:data, options: [])
            jsonData = (jsonObject as! [String: Any])
        } catch {
            print("jsonData parsing error")
            return [:]
        }
        
        return jsonData
    }
    
    func getPushNotificationText() -> String {
        return singletonData.pushNotificationText ?? ""
    }
}
