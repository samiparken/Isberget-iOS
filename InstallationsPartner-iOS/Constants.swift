struct K {
    
    static let INSTALLER = "Installatör"
    
    struct UserDefaults {
        static let isAppJustLaunched = "isAppJustLaunched"
        static let token = "token"
        static let baseUrl = "baseUrl"
        static let email = "email"
        static let password = "password"
        static let tokenExpiration = "tokenExpiration"
        static let user_id = "user_id"
        static let company_id = "company_id"
        static let usersInCompany = "usersInCompany"
        static let isInstaller = "isInstaller"
        static let stayLogin = "stayLogin"
        static let deviceToken = "deviceToken"
        static let applicationIconBadgeNumber = "applicationIconBadgeNumber"
        
        struct Settings {
            static let weekendSwitch = "weekendSwitch"
        }
    }
    
    struct Notification {
        static let newJob = "newJobs"
        static let jobAccepted = "{\"type\":\"jobAccepted\"}"
        static let bookJob = "{\"type\":\"bookJob\"}"
        static let jobUpdate = "jobUpdate"
        static let jobCancelled = "{\"type\":\"jobCancelled\"}"
    }
    
    struct Login {
        static let success = "success"
    }
    
    struct Task {
        static let Cell = "TaskCell"
        
        static let taskId = "task_id"
        static let orderId = "order_id"
        static let orderNum = "order_number_on_client"
        static let orderStatusId = "order_status_id"
        static let isDone = "isDone" //Bool
        
        static let taskCreatedAt = "task_created_at"
        static let orderUpdatedAt = "order_updated_at"
        static let installEndAt = "install_end_at"
        static let taskReportedAt = "task_reported_at"
        
        static let taskTypeId = "tasktypes_id"
        static let taskTypeText = "tasktypes_text"
        struct Types {
            static let notAccepted = "not_accepted_task"
            static let notBooked = "not_booked_task"
            static let notDone = "not_set_as_done_task"
            static let message = "customer_message"
        }
        
        static let reportedReasonId = "taskreasons_id"
        static let taskReasons = "taskreasons"
        struct Reason {
            static let id = "taskreasons_id"
            static let text = "taskreasons_text"
        }
    }
    
    struct Report {
        static let Cell = "ReportProductCell"
    }
    
    struct Chat {
        static let isActive = "isActive"
        static let linkCode = "linkCode"
        static let orderId = "orderId"
        static let orderNum = "orderNumber"
        static let Cell = "ChatCell"
        static let messages = "messages"
        static let lastUpdatedAt = "lastUpdatedAt"

        struct Message {
            static let text = "message"
            static let timestamp = "timestamp"
            static let sender = "sender"
            static let image = "base64Image"
            static let isRead = "is_read"
            static let isCustomer = "is_customer"
        }
    }
    
    struct JobAccept {
        static let type = "JobAccept"
        static let Cell = "JobAcceptCell"
    }
    
    struct JobBook {
        static let type = "JobBook"
        static let Cell = "JobBookCell"
    }
    
    struct JobToday {
        static let type = "JobToday"
        static let Cell = "JobTodayCell"
    }
    
    struct Info {
        static let Cell = "InfoProductCell"
    }
    
    struct Booking {
        static let Cell = "TimelineCell"
    }
    
    struct Setting {
        static let bugReportPhone = "0046735000096"
    }
    
    struct OrderStatusId  {
        static let unaccepted = 31
        static let unbooked = 2
        static let booking = 4
        static let booked = 11  // + 19
        static let done = 6
        // 3?
    }
    
    struct OrderStatus { //lowercase
        static let unaccepted = "inte accepterad än"
        static let unbooked = "tilldelad företag"
        static let booking = "inte bokad med kund"
        static let booked = "bokad med kund"
        static let done = "installation klar"
    }
    
    static let aDayInSeconds: Double = 86400
    static let aWeekInSeconds: Double = 604800
    static let aMonthInSeconds: Double = 2419200
    
    struct Annotation {
        static let unacceptedJob = "unacceptedJob"
        static let unbookedJob = "unbookedJob"
        static let bookingJob = "bookingJob"
        static let bookedJob = "bookedJob"
        static let doneJob = "doneJob"
        static let genericJob = "genericJob"
        static let genericCalendarJob = "calendarJob"
    }
    
    struct API {
        static let BaseUrl = "https://app.installationspartner.se"
//        static let BaseUrl = "http://dev.installationspartner.se"
//        static let BaseUrl = "http://test.installationspartner.se"
        
        /* LoginView */
        static let Login = "/token"
        static let GetUserData = "/api/account/GetUserData"
        static let GetUsersInCompany = "/api/account/getusersincompany"
        static let GetAllCompanyInfo = "/breeze/BreezeRoleBased/GetAllUserData"
        static let GetCompanyId = "/breeze/BreezeGeneric/GetCurrentUserCompaniesAndChildren?$orderby=company_name"
        static let GetCurrentUserCompaniesAndChildren = "/breeze/BreezeGeneric/GetCurrentUserCompaniesAndChildren"
        
        /* Reset Password */
        static let ResetPassword = "/api/account/forgotpassword"
        
        /* Generic API */
        static let GetOrder = "/breeze/BreezeBooking/AppGetOrderWithOrderId"
        
        /* Task View */
        static let RefreshTasks = "/breeze/BreezeBooking/RefreshTasks"
        static let GetTasks = "/breeze/BreezeBooking/GetTasks"
        static let ReportTask = "/breeze/BreezeBooking/ReportTask"
        static let SetTaskDone = "/breeze/BreezeBooking/SetTaskDone"
        
        /* Chat View */
        static let GetCustomerPageChat = "/breeze/BreezeBooking/AppGetCustomerPageChat"
        static let SendMessageToCustomerPage = "/breeze/BreezeBooking/SendMessageToCustomerPage"
        static let ReadMessageFromCustomerPage = "/breeze/BreezeBooking/ReadMessageFromCustomerPage"
        
        /* Message View (Removed)  */
        static let GetMessages = "/api/EffectiveInstallers/GetMessages"
        static let SetMessageRead = "/api/EffectiveInstallers/SetReadMessage"
        
        /* JobAccept View */
        static let GetUnaccepetedJobs = "/breeze/BreezeBooking/NativeAppGetUnacceptedInstallations"
        static let AcceptJob = "/breeze/BreezeBooking/SetJobAccepted"
        static let DeclineJob = "/breeze/BreezeBooking/SetJobRejected"
        
        /* JobBook View*/
        static let GetUnbookedJobs = "/breeze/BreezeBooking/NativeAppGetAcceptedInstallations" //bookedJobs
        static let BookJobConfirmedCustomer = "/breeze/BreezeCalendar/BookJobConfirmedCustomer"
        static let SendCustomerBookingProposal = "/breeze/BreezeCalendar/SendCustomerBookingProposal"
        
        /* for Booking & Booked jobs */
        // former name : GetEventsForCompanyByDate
        static let GetBookingAndBookedJobs = "/breeze/BreezeCalendar/NativeAppGetEventsForCompanyByDate"
        //Avboka
        static let DeleteEventFromCalendar = "/breeze/BreezeCalendar/NativeAppDeleteEvent"
        //Change Booking
        static let UpdateJob = "/breeze/BreezeCalendar/UpdateOrderData"
        
        /* Protocol View */
        static let PostProtocol = "/breeze/BreezeOrder/NativeAppSignInstallationProtocol"
        
        /* For Push Notification */
        static let UpdateDeviceToken = "/api/BreezeNativeApp/UpdateUserDeviceNotificationToken"
        
        /* Customer Answers */
        static let GetCustomerAnswers = "/breeze/BreezeCalendar/GetCustomerAnswerHistoryNew"
                
        static let BookJobInCalendar = "/breeze/BreezeCalendar/BookJobInCalendar"
        static let SearchedWithQuery = "/breeze/BreezeSearch/NativeAppGetSearchOrdersAsList"
        static let RejectJobWithId = "/breeze/BreezeBooking/SetJobRejected?"
        static let SetNewOrderComment = "/breeze/BreezeOrder/SetOrderMessage"
        static let GetUserRolesWithoutUserId = "/BreezeGeneric/GetUserRolesWithoutUserId"
        static let GetCompanyAddress = "/api/EffectiveInstallers/GetCompanyAddress"
        static let GetCompanyLocation = "/api/EffectiveInstallers/GetCompanyLocation"
        
        // /breeze/BreezeOrder/NativeAppGetInstallationProtocolPDF
    }
}

//MARK: - Keys for Notification Observers

// Job Manager
let jobAcceptPanelReloadKey = "se.installationspartner.ios.jobAcceptPanelReloadKey"
let jobAcceptAnnoRefreshKey = "se.installationspartner.ios.jobAcceptAnnoRefreshKey"
let jobBookPanelReloadKey = "se.installationspartner.ios.jobBookPanelReloadKey"
let jobBookUnbookedAnnoRefreshKey = "se.installationspartner.ios.jobBookOrangeAnnoRefreshKey"
let jobBookBookingAndBookedAnnoRefreshKey = "se.installationspartner.ios.jobBookYelloGreenAnnoRefreshKey"
let jobTodayPanelReloadKey = "se.installationspartner.ios.jobTodayPanelReloadKey"
let jobTodayAnnoRefreshKey = "se.installationspartner.ios.jobTodayAnnoRefreshKey"

// Tabbar
let updateBadgesKey = "se.installationspartner.ios.updateBadges"
let updateBadge4Key = "se.installationspartner.ios.updateBadge4Key"
let pushNotificationMsgKey = "se.installationspartner.ios.pushNotificationMsgKey"
let jobBookingViewKey = "se.installationspartner.ios.jobjobBookingView"
let jobInfoKey = "se.installationspartner.ios.jobAcceptInfo"
let jobProtocolKey = "se.installationspartner.ios.jobProtocolKey"
let taskActionAlertKey = "se.installationspartner.ios.taskActionAlertKey"
let reportViewKey = "se.installationspartner.ios.reportViewKey"
let sendAMessageKey = "se.installationspartner.ios.sendAMessage"
let chatViewKey = "se.installationspartner.ios.chatViewKey"

// Job Accept
let jobAcceptSelectedOnPanelKey = "se.installationspartner.ios.jobAcceptSelectedOnPanel"
let jobAcceptAllOnPanelKey = "se.installationspartner.ios.jobAcceptAllOnPanel"
let jobAcceptSelectAnnotationKey = "se.installationspartner.ios.jobAcceptSelectAnnotation"
let jobAcceptAcceptJobKey = "se.installationspartner.ios.jobAcceptAcceptJob"
let jobAcceptDeclineJobKey = "se.installationspartner.ios.jobAcceptDeclineJob"

// Job Book
let jobBookSelectedOnPanelKey = "se.installationspartner.ios.jobBookSelectedOnPanel"
let jobBookAllOnPanelKey = "se.installationspartner.ios.jobBookAllOnPanel"
let jobBookSelectAnnotationKey = "se.installationspartner.ios.jobBookSelectAnnotation"

// Job Today
let jobTodaySelectedOnPanelKey = "se.installationspartner.ios.jobTodaySelectedOnPanel"
let jobTodayAllWithDateOnPanelKey = "se.installationspartner.ios.jobTodayAllWithDateOnPanel"
let refreshJobTodayKey = "se.installationspartner.ios.refreshJobTodayKey"
let jobTodaySelectAnnotationKey = "se.installationspartner.ios.jobTodaySelectAnnotation"

// MapCalloutView
let jobAcceptDeselectAnnotationKey = "se.installationspartner.ios.jobAcceptDeselectAnnotation"
let jobBookDeselectAnnotationKey = "se.installationspartner.ios.jobBookDeselectAnnotation"
let jobTodayDeselectAnnotationKey = "se.installationspartner.ios.jobTodayDeselectAnnotation"

// FilterView
let filterDidSaveKey = "se.installationspartner.ios.filterInstallersAppliedKey"

// InfoView
let jobCancelDoneKey = "se.installationspartner.ios.jobCancelDoneKey"

// BookingView
let jobBookDoneKey = "se.installationspartner.ios.jobBookDoneBookingJob"

// SettingView
let refreshCalendarKey = "se.installationspartner.ios.refreshCalendarKey"

// TaskView
let taskViewReloadDataKey = "se.installationspartner.ios.taskViewReloadData"
let taskViewLoadingStartKey = "se.installationspartner.ios.taskViewLoadingStartKey"
let taskViewLoadingStopKey = "se.installationspartner.ios.taskViewLoadingStopKey"
let taskViewShowErrorAlertKey = "se.installationspartner.ios.taskViewShowErrorAlertKey"

//MARK: - Protocol Format
let PROTOCOL_JOB_TYPES = [
    [
        "val": 5,
        "name": "Generic",
        "key": "gen"
    ],
    [
        "val": 6,
        "name": "Ä.T.A",
        "key": "äta"
    ],
    [
        "val": 1,
        "name": "Luft-Luft",
        "key": "ll"
    ],
    [
        "val": 2,
        "name": "Luft-Vatten",
        "key": "lvfl"
    ],
    [
        "val": 3,
        "name": "Frånluft",
        "key": "lvfl"
    ],
    [
        "val": 4,
        "name": "Reklamation",
        "key": "reclaim"
    ]
]


let PROTOCOL_HEATPUMPLIST = [
    [
        "name": ""
    ],[
        "serialNumber": "",
        "type": 1  //inne-del
    ],[
        "serialNumber": "",
        "type": 2  //ute-del
    ],[
        "add": true
    ]
]


let PROTOCOL_CHECKLIST = [
    "ll" : [
        [
            "key" : "runOffCheck",
            "title" : "Testat avrinning från innedelen?",
            "value" : -1
        ],[
            "key" : "heatPumpOperationWalkthrough",
            "title" : "Instruerat hur värmepumpen fungerar",
            "value" : -1
        ],[
            "key" : "installationCompleted",
            "title" : "Är installationen klar?",
            "value" : -1
        ],[
            "key" : "installedWithPlug",
            "title" : "Installeras med stickpropp?",
            "value" : -1
        ],[
            "key" : "customerElectrician",
            "title" : "Kund ordnar själv med elektriker?",
            "value" : -1
        ]
    ],
    
    "lvfl" : [
        [
            "key" : "filterInstalled",
            "title" : "Smutsfiler monterat?",
            "value" : -1
        ],[
            "key" : "circulationPumpVerified",
            "title" : "Kontrollerat cirkulationspump?",
            "value" : -1
        ],[
            "key" : "manometerPressure",
            "title" : "Kontrollerat manometertryck?",
            "value" : -1
        ],[
            "key" : "ventilatedBuilding",
            "title" : "Luftat huset samt nya pannan?",
            "value" : -1
        ],[
            "key" : "valveCheck",
            "title" : "Kontrollera att eventuella avstängningsventiler i cirkulationssystemet är öppna?",
            "value" : -1
        ],[
            "key" : "circulationPumpRate",
            "title" : "Cirkulationspump hastighet %?",
            "value" : "",
            "input" : true
        ],[
            "key" : "spillWaterCheck",
            "title" : "Kontrollerat att spillvatten (skvallerrör) är anslutna till golvbrunn alernativt golv?",
            "value" : -1
        ],[
            "key" : "instructionWalkthrough",
            "title" : "Genomgång samt klistrat instuktionen till kunden på pannan?",
            "value" : -1
        ],[
            "key" : "floorHeating",
            "title" : "Kopplades det in Golvvärme vid installation",
            "value" : -1
        ],[
            "key" : "floorHeatingInstallationOnly",
            "title" : "Kopplades den nya pannan endast mot Golvvärme?",
            "value" : -1
        ],[
            "key" : "controlSystemParametersCheck",
            "title" : "Ställdes värmekurvan in efter rätt län i Sverige?",
            "value" : -1
        ],[
            "key" : "clearUp",
            "title" : "Är det grovstädat?",
            "value" : -1
        ],[
            "key" : "ppElectricalInstallation",
            "title" : "Är elinstallationen gjord av Polarpumpen?",
            "value" : -1
        ],[
            "key" : "cableThickness",
            "title" : "Vilken kvadrat på kabel är dragen vid installation?",
            "value" : "",
            "input" : true
        ],[
            "key" : "inPower",
            "title" : "Kontrollerat ineffekt?",
            "value" : -1
        ],[
            "key" : "switchCheck",
            "title" : "Kontrollera så att alla switchar står rätt (kolla lathund eller instruktionsbok)?",
            "value" : -1
        ],[
            "key" : "pumpStartCheck",
            "title" : "Kontrollera så att pumpen startar, det tar mellan 5-10 min för kompressor att starta.",
            "value" : -1
        ],[
            "key" : "installationNotCompleted",
            "title" : "Återstår någonting utav Installationen eller saknades något?",
            "value" : -1
        ]
    ],
    
    "reclaim" : [
        [
            "key" : "productError",
            "title" : "Var det fel på produkten?",
            "value" : -1
        ],[
            "key" : "installationError",
            "title" : "Var det fel på installationen?",
            "value" : -1
        ],[
            "key" : "productMisplaced",
            "title" : "Är produkten felplacerad?",
            "value" : -1
        ],[
            "key" : "buildingError",
            "title" : "Kan huset ha orsakat driftstoppet?",
            "value" : -1
        ],[
            "key" : "errorSolved",
            "title" : "Är felet åtgärdat?",
            "value" : -1
        ]
    ]
]
