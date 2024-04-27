import Foundation
class ChatManager {
    
    func isRefreshChatSuccess() -> Bool {
        let orderId = (singletonData.getCustomerPageChat[K.Chat.orderId] as? Int) ?? 0
        return orderId != 0 ? true : false
    }
    
    func isChatValid() -> Bool {
        let linkCode = (singletonData.getCustomerPageChat[K.Chat.linkCode] as? String) ?? ""
        return linkCode != "" ? true : false
    }
    
    func isChatActive() -> Bool {
        let isActive = (singletonData.getCustomerPageChat[K.Chat.isActive] as? Bool) ?? false
        return isActive
    }
    
    func refreshChat(_ orderId: Int) -> Bool {
        singletonData.getCustomerPageChat = [String:Any]()
        APIgetCustomerPageChat(orderId); semaphore.wait()        
        return isRefreshChatSuccess()
    }
    
    func sendMessageToCustomer(_ orderId: Int, _ message: String) -> Bool{
        
        APIsendMessageToCustomerPage(orderId, message); semaphore.wait()
        
        if singletonData.sendMessageToCustomerPageResponse == "true" {
            return true
        } else {
            return false
        }
    }
    
    func readMessageFromCustomer(_ orderId: Int) -> Bool {
        APIreadMessageFromCustomerPage(orderId); semaphore.wait()
        
        if singletonData.readMessageFromCustomerPageResponse == "true" {
            return true
        } else {
            return false
        }
    }
}
