import Foundation
import MapKit
let singletonData = DataManager.singletonData

var selectedJob = [String:Any]()

var selectedTask = [String:Any]()
var selectedTaskReasons = [[String:Any]]()

var selectedViewType: String?
var selectedAnnoType: String?
var selectedOrderId: Int?
var selectedOrderNum: Int?
var selectedPhoneNumber: String?
var selectedCoordinates: CLLocationCoordinate2D?

var selectedAcceptAnnoView: MKAnnotationView?
var selectedAcceptOrderId: Int?
var selectedAcceptOrderNum: Int?

var selectedBookAnnoView: MKAnnotationView?
var selectedBookOrderId: Int?
var selectedBookOrderNum: Int?

var selectedTodayAnnoView: MKAnnotationView?
var selectedTodayOrderId: Int?
var selectedTodayOrderNum: Int?

var selectedDateOnCalendar: Date = Date()
var selectedTodayJobsWithDate = [[String:Any]]()

class DataManager {
    static let singletonData = DataManager()
    
    let blankDate = Date(timeIntervalSince1970: 0)
    
    var baseUrl: String?
    var error: String?
    
    var pushNotificationData: String?
    var pushNotificationText: String?
    
    var screenWidth: CGFloat?
    var mapViewHeight: CGFloat?
    var currentLocation: CLLocation?

    var isJobAcceptViewLoadedInitialData: Bool = true
    var isJobBookViewLoadedInitialData: Bool = true
    var isJobTodayViewLoadedInitialData: Bool = true
    
    var listOfInstallers = [[String:Any]]()
    var onInstallersId = [Int]() // id list of ["on"] == true
    var isOn_delivered: Bool = true
    var isOn_deliveryDate: Bool = true
    var isOn_noDeliveryDate: Bool = true
    
    /*
     Usage:
     calendarEventDots["2020-10-04"]!["booking"] = 1
     calendarEventDots["2020-04-21"]!["booked"] = 1
     */
    var calendarEventDots = [String: [String: Int]]()    
    
//MARK: - JSON Data
    var login: JSONlogin?
    var resetPassword = [String: Any]()
    var getUserData: JSONgetUserData?
    var getUsersInCompany = [[String: Any]]()
    var getCompanyAddress: JSONgetCompanyAddress?
//    var getAllCompanyInfo: JSONgetAllCompanyInfo?
//    var getCurrentUserCompaniesAndChildren = [[String : Any]]()
    var getMessages = [[String: Any]]()
    var getTasks = [[String: Any]]()
    var getOrder = [String: Any]()
    var getUnacceptedJobs = [[String: Any]]()
    var getUnbookedJobs = [[String: Any]]()
    var getBookingJobs = [[String: Any]]()
    var getBookedJobs = [[String: Any]]()
    var getDoneJobs = [[String: Any]]()
    var getSearchJobs = [[String: Any]]()
    
    var customerAnswers = [Int: [[String:Any]]]()    //Key:Int = orderId
    var getCustomerPageChat = [String: Any]()

//MARK: - API Response
    var bookJobResponse: String = ""
    var suggestJobResponse: String = ""
    var cancelJobResponse: String = ""
    var postProtocolResponse: Int = 0 //success: 204 / error: 500
    var setTaskDoneResponse: String = ""
    var reportTaskResponse: String = ""
    var sendMessageToCustomerPageResponse: String = ""
    var readMessageFromCustomerPageResponse: String = ""
    
//MARK: - Methods
    
    func clearData() {
        getMessages = [[String: Any]]()
        getUnacceptedJobs = [[String: Any]]()
        getUnbookedJobs = [[String: Any]]()
        getBookingJobs = [[String: Any]]()
        getBookedJobs = [[String: Any]]()
        getDoneJobs = [[String: Any]]()
        getSearchJobs = [[String: Any]]()
    }
    
    func findInstaller(id: Int) -> [String:Any] {
        let installer = listOfInstallers.filter { ($0["userId"] as! Int) == id }
        return installer[0]
    }

    func findJob(type: String?, with orderNum: String?) -> [String:Any] {
        switch type {
        case K.Annotation.unacceptedJob:
            for job in getUnacceptedJobs {
                if ( (job["order_number_on_client"] as! Int) == Int(orderNum!)) {
                    return job
                }
            }
        case K.Annotation.unbookedJob:
            for job in getUnbookedJobs {
                if ( (job["order_number_on_client"] as! Int) == Int(orderNum!)) {
                    return job
                }
            }
        case K.Annotation.bookingJob:
            for job in getBookingJobs {
                if ( (job["Order_number_on_client"] as! Int) == Int(orderNum!)) {
                    return job
                }
            }
        case K.Annotation.bookedJob:
            for job in getBookedJobs {
                if ( (job["Order_number_on_client"] as! Int) == Int(orderNum!)) {
                    return job
                }
            }
        case K.Annotation.doneJob:
            for job in getDoneJobs {
                if ( (job["Order_number_on_client"] as! Int) == Int(orderNum!)) {
                    return job
                }
            }
        case .none:
            break
        case .some(_):
            break
        }
        return [:]
    }
    
    func findJob(orderId: Int) -> [String:Any] {
        var jobs = [[String:Any]]()
        
        jobs = getUnacceptedJobs.filter {
            ($0["OrderId"] as? Int) ?? 0 == orderId
        }
        if jobs.count > 0 { return jobs[0] }

        jobs = getUnbookedJobs.filter {
            ($0["OrderId"] as? Int) ?? 0 == orderId
        }
        if jobs.count > 0 { return jobs[0] }

        jobs = getBookingJobs.filter {
            ($0["Id"] as? Int) ?? 0 == orderId
        }
        if jobs.count > 0 { return jobs[0] }

        jobs = getBookedJobs.filter {
            ($0["Id"] as? Int) ?? 0 == orderId
        }
        if jobs.count > 0 { return jobs[0] }

        jobs = getDoneJobs.filter {
            ($0["Id"] as? Int) ?? 0 == orderId
        }
        if jobs.count > 0 { return jobs[0] }
        return [:]
    }
}
