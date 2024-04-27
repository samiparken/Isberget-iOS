import Foundation

protocol Endpoint {
    var httpMethod: String { get }
    var path: String { get }
    var headers: [String: Any]? { get }
    var body: [String: Any]? { get }
    var encodedBody: Data? { get }
    var params: [String: Any]? { get }
}

extension Endpoint {
    // a default extension that creates the full URL
    var url: String {
        switch httpMethod {
        case "GET":
            return singletonData.baseUrl! + path + "?" + params!.queryString
        case "POST":
            return singletonData.baseUrl! + path
        default:
            return singletonData.baseUrl!
        }
    }
}

enum EndpointCases: Endpoint {
    case login(email: String, password: String)
    case resetPassword(email: String)
    case getUserData
    case getUsersInCompany(companyId: String)
    case getCompanyAddress(companyId: String)
    case getAllCompanyInfo
    case getCurrentUserCompaniesAndChildren
    case getMessages(companyId: String, userId: String, isAdmin: Bool)
    case setMessageRead(messageId: Int)
    case getUnacceptedJobs(companyId: String)
    case getUnbookedJobs(companyId: String)
    case getBookingAndBookedJobs(_ companyId: String, _ dateFrom: String, _ dateTo: String)
    case declineJob(orderId: Int, userId: Int, message: String)
    case acceptJob(orderId: Int, userId: Int)
    case setNewOrderComments(orderId: Int, comments: String)
    case bookJob(orderId: Int, taskCompanyId: Int, installerId: Int, startDate: String, endDate: String)
    case suggestJobToCustomer(orderId: Int, taskCompanyId: Int, installerId: Int, startDate: String, endDate: String)
    case cancelJob(taskCompanyId: Int)
    case updateJob(_ date: String, _ startTime: String, _ endTime: String, _ installerId: Int, _ orderId: Int, _ orderStatusId: Int)
    case postProtocol(jsonData: Data)
    case updateDeviceToken(_ userId: Int, _ deviceId: String, _ deviceToken: String)
    case getCustomerAnswers(_ orderId: Int)
    case getTasks(_ companyId: Int)
    case getOrder(_ orderId: Int)
    case setTaskDone(_ taskId: Int)
    case reportTask(_ taskId: Int, _ reasonId: Int, _ reasonText: String)
    case getCustomerPageChat(_ orderId: Int)
    case sendMessageToCustomerPage(_ orderId: Int, _ message: String)
    case readMessageFromCustomerPage(_ orderId: Int)
    
    var httpMethod: String {
        switch self {
        case .login, .resetPassword, .postProtocol:
            return "POST"
        default:
            return "GET"
        }
    }
    
    var path: String {
        switch self {
        case .login:
            return K.API.Login
        case .resetPassword:
            return K.API.ResetPassword
        case .getUsersInCompany:
            return K.API.GetUsersInCompany
        case .getUserData:
            return K.API.GetUserData
        case .getCompanyAddress:
            return K.API.GetCompanyAddress
        case .getAllCompanyInfo:
            return K.API.GetAllCompanyInfo
        case .getCurrentUserCompaniesAndChildren:
            return K.API.GetCurrentUserCompaniesAndChildren
        case .getMessages:
            return K.API.GetMessages
        case .setMessageRead:
            return K.API.SetMessageRead
        case .getUnacceptedJobs:
            return K.API.GetUnaccepetedJobs
        case .getUnbookedJobs:
            return K.API.GetUnbookedJobs
        case .getBookingAndBookedJobs:
            return K.API.GetBookingAndBookedJobs
        case .declineJob:
            return K.API.DeclineJob
        case .acceptJob:
            return K.API.AcceptJob
        case .setNewOrderComments:
            return K.API.SetNewOrderComment
        case .bookJob:
            return K.API.BookJobConfirmedCustomer
        case .suggestJobToCustomer:
            return K.API.SendCustomerBookingProposal
        case .cancelJob:
            return K.API.DeleteEventFromCalendar
        case .postProtocol:
            return K.API.PostProtocol
        case .updateJob:
            return K.API.UpdateJob
        case .getCustomerAnswers:
            return K.API.GetCustomerAnswers
        case .updateDeviceToken:
            return K.API.UpdateDeviceToken
        case .getTasks:
            return K.API.GetTasks
        case .getOrder:
            return K.API.GetOrder
        case .setTaskDone:
            return K.API.SetTaskDone
        case .reportTask:
            return K.API.ReportTask
        case .getCustomerPageChat:
            return K.API.GetCustomerPageChat
        case .sendMessageToCustomerPage:
            return K.API.SendMessageToCustomerPage
        case .readMessageFromCustomerPage:
            return K.API.ReadMessageFromCustomerPage
        }
    }
    
    var headers: [String: Any]? {
        var token: String = ""
        let defaults = UserDefaults.standard
        if let t = defaults.string(forKey: K.UserDefaults.token) {
            token = " " + t
        }
                
        switch self {
        case .login, .resetPassword:
            return ["Content-Type": "application/x-www-form-urlencoded;charset=UTF-8",
                    "Cache-Control": "no-cache",
                    "Accept": "application/json"]
        case .postProtocol:
            return ["Content-Type": "application/json",
                    "Cache-Control": "no-cache",
                    "Accept": "application/json",
                    "Authorization": "Bearer" + token]
        default:
            return ["Authorization": "Bearer" + token]
        }
    }
    
    var body: [String : Any]? {
        switch self {
        case .login(let email, let password):
            return ["grant_type": "password",
                    "username": email,
                    "password": password]
        case .resetPassword(let email):
            return ["email": email]
        case .postProtocol:
            return ["encoded": true]
        default:
            return [:]
        }
    }
    
    var encodedBody: Data? {
        switch self {
        case .postProtocol(let jsonData):
            return jsonData
        default:
            return Data()
        }
    }
    
    var params: [String : Any]? {
        switch self {
        case .getUsersInCompany(let companyId):
            return ["CompanyId":companyId]
        case .getCompanyAddress(let companyId):
            return ["companyId":companyId]
        case .getMessages(let companyId, let userId, let isAdmin):
            return ["companyId": companyId,
                    "userId": userId,
                    "isAdmin": isAdmin]
        case .setMessageRead(let messageId):
            return ["installer_actions_id": messageId]
        case .getUnacceptedJobs(let companyId):
            return ["param": companyId]
        case .getUnbookedJobs(let companyId):
            return ["param": companyId]
        case .getBookingAndBookedJobs(let companyId, let dateFrom, let dateTo):
            return ["param1": companyId,
                    "param2": dateFrom,
                    "param3": dateTo]
        case .declineJob(let orderId, let userId, let message):
            return ["param1": orderId,
                    "param2": userId,
                    "param3": message]
        case .acceptJob(let orderId, let userId):
            return ["param1": orderId,
                    "param2": userId]
        case .setNewOrderComments(let orderId, let comments):
            return ["param1": orderId,
                    "param2": comments]
        case .bookJob(let orderId, let taskCompanyId, let installerId, let startDate, let endDate):
            return ["param1": orderId,
                    "param2": taskCompanyId,
                    "param3": installerId,
                    "param4": installerId,
                    "param5": startDate,
                    "param6": endDate]
        case .suggestJobToCustomer(let orderId, let taskCompanyId, let installerId, let startDate, let endDate):
            return ["param1": orderId,
                    "param2": taskCompanyId,
                    "param3": installerId,
                    "param4": installerId,
                    "param5": startDate,
                    "param6": endDate]
        case .cancelJob(let taskCompanyId):
            return ["param": taskCompanyId]
        case .updateJob(let date, let startTime, let endTime, let installerId, let orderId, let orderStatusId):
            return ["param[date]": date,
                    "param[start]": startTime,
                    "param[end]": endTime,
                    "param[resourceId]": installerId,
                    "param[orderId]": orderId,
                    "param[orderStatusId]": orderStatusId]
        case .getCustomerAnswers(let orderId):
            return ["param": orderId]
        case .updateDeviceToken(let userId, let deviceId, let deviceToken):
            return ["userId": userId,
                    "deviceId": deviceId,
                    "devicePlatform": "ios",
                    "deviceToken": deviceToken ]
        case .getTasks(let companyId):
            return ["param": companyId]
        case .getOrder(let orderId):
            return ["orderId": orderId]
        case .setTaskDone(let taskId):
            return ["param": taskId]
        case .reportTask(let taskId, let reasonId, let reasonText):
            return ["param1": taskId,
                    "param2": reasonId,
                    "param3": reasonText]
        case .getCustomerPageChat(let orderId):
            return ["param": orderId]
        case .sendMessageToCustomerPage(let orderId, let message):
            return ["param1": orderId,
                    "param2": message]
        case .readMessageFromCustomerPage(let orderId):
            return ["param": orderId]
        default:
            return [:]
        }
    }
}
