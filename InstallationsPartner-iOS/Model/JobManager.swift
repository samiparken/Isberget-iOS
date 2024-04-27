import Foundation

class JobManager {
    let defaults = UserDefaults.standard

//MARK: - Init Methods
    
    func getInitialData() {
        let isInstaller = defaults.bool(forKey: K.UserDefaults.isInstaller)
        if (!isInstaller) {
            refreshTasks()
            refreshUnacceptedJobs()
        }
        refreshUnbookedJobs()
        refreshBookingAndBookedJobs()
    }

//MARK: - Refresh Methods
    
    func refreshUnacceptedJobs() {
        DispatchQueue.global(qos: .background).async {
            let c = self.defaults.string(forKey: K.UserDefaults.company_id)
            APIgetUnacceptedJobs(companyId: c!); semaphore.wait()

            // + error handling
            singletonData.isJobAcceptViewLoadedInitialData = false
                        
            DispatchQueue.main.async {
                self.updateAllBadges()
                
                //refresh anno
                let keyName = Notification.Name(rawValue: jobAcceptAnnoRefreshKey)
                NotificationCenter.default.post(name: keyName, object: nil)

                //reload panel data
                let keyName2 = Notification.Name(rawValue: jobAcceptPanelReloadKey)
                NotificationCenter.default.post(name: keyName2, object: nil)
            }
        }
    }
    
    func refreshUnbookedJobs() {
        DispatchQueue.global(qos: .background).async {
            let c = self.defaults.string(forKey: K.UserDefaults.company_id)
            APIgetUnbookedJobs(companyId: c!); semaphore.wait()
            
            // + error handling
            singletonData.isJobBookViewLoadedInitialData = false
            
            DispatchQueue.main.async {
                self.updateAllBadges()

                //refresh JobBook - unbooked anno
                let keyName = Notification.Name(rawValue: jobBookUnbookedAnnoRefreshKey)
                NotificationCenter.default.post(name: keyName, object: nil)

                //reload JobBook panel data
                let keyName2 = Notification.Name(rawValue: jobBookPanelReloadKey)
                NotificationCenter.default.post(name: keyName2, object: nil)
            }
        }
    }
    
    func refreshBookingAndBookedJobs() {
        DispatchQueue.global(qos: .background).async {
            let c = self.defaults.string(forKey: K.UserDefaults.company_id)
            APIgetBookingAndBookedJobs(
                companyId: c!,
                dateFrom: dateToString_ymd(with: Date()-(2*K.aWeekInSeconds))); semaphore.wait()
                        
            DispatchQueue.main.async {

                singletonData.isJobTodayViewLoadedInitialData = false
                                
                self.refreshTodayJobsWithDate()
                self.updateAllBadges()

                //refresh JobBook - booking and booked anno
                let keyName = Notification.Name(rawValue: jobBookBookingAndBookedAnnoRefreshKey)
                NotificationCenter.default.post(name: keyName, object: nil)

                //refresh JobToday anno
                let keyName2 = Notification.Name(rawValue: jobTodayAnnoRefreshKey)
                NotificationCenter.default.post(name: keyName2, object: nil)
                
                //reload JobToday panel data
                let keyName3 = Notification.Name(rawValue: jobTodayPanelReloadKey)
                NotificationCenter.default.post(name: keyName3, object: nil)
            }
        }
    }
        
    func refreshTasks() {
        let c = self.defaults.integer(forKey: K.UserDefaults.company_id)
        
        DispatchQueue.global(qos: .background).async {
            APIgetTasks(c); semaphore.wait()
            
            // error handling
            
            DispatchQueue.main.async {
                
                self.updateAllBadges()
                
                //TaskView: reloadData
                let keyName = Notification.Name(rawValue: taskViewReloadDataKey)
                NotificationCenter.default.post(name: keyName, object: nil)
            }
        }
    }


    func refreshTodayJobsWithDate() {
        //Preparation
        selectedTodayJobsWithDate = [[String:Any]]()
        
        // booking jobs
        let filteredJobs1 = filterJob( singletonData.getBookingJobs )
        for job in filteredJobs1 {
            let dateString = (job["Start"] as? String) ?? "2000-01-01T08:00:00.000"
            let jobDate = stringToDate(with: dateString)
            if isSameDay(jobDate, selectedDateOnCalendar) {
                selectedTodayJobsWithDate.append(job)
            }
        }
                
        // booked jobs
        let filteredJobs2 = filterJob( singletonData.getBookedJobs )
        for job in filteredJobs2 {
            let dateString = (job["Start"] as? String) ?? "2000-01-01T08:00:00.000"
            let jobDate = stringToDate(with: dateString)
            if isSameDay(jobDate, selectedDateOnCalendar) {
                selectedTodayJobsWithDate.append(job)
            }
        }
        
        // done jobs
        let filteredJobs3 = filterJob( singletonData.getDoneJobs )
        for job in filteredJobs3 {
            let dateString = (job["Start"] as? String) ?? "2000-01-01T08:00:00.000"
            let jobDate = stringToDate(with: dateString)
            if isSameDay(jobDate, selectedDateOnCalendar) {
                selectedTodayJobsWithDate.append(job)
            }
        }

    }

    func refreshCalendarEventDots() {
        var jobs = [[String:Any]]()
        let preset = ["booking" : 0, "booked" : 0, "done":0]
        singletonData.calendarEventDots = [String : [String: Int]]()

        jobs = filterJob( singletonData.getBookingJobs )
        for job in jobs {
            let dateString = (job["Start"] as? String) ?? "2000-01-01T08:00:00.000"
            let jobDate = stringToDate(with: dateString)
            let ymdString = dateToString_ymd(with: jobDate)
            singletonData.calendarEventDots[ymdString, default: preset]["booking"]! += 1
        }
        jobs = filterJob( singletonData.getBookedJobs )
        for job in jobs {
            let dateString = (job["Start"] as? String) ?? "2000-01-01T08:00:00.000"
            let jobDate = stringToDate(with: dateString)
            let ymdString = dateToString_ymd(with: jobDate)
            singletonData.calendarEventDots[ymdString, default: preset]["booked"]! += 1
        }
        jobs = filterJob( singletonData.getDoneJobs )
        for job in jobs {
            let dateString = (job["Start"] as? String) ?? "2000-01-01T08:00:00.000"
            let jobDate = stringToDate(with: dateString)
            let ymdString = dateToString_ymd(with: jobDate)
            singletonData.calendarEventDots[ymdString, default: preset]["done"]! += 1
        }
    }

//MARK: - Action Methods

    func declineJob(orderId: Int, message: String) {
        let u = Int(defaults.string(forKey: K.UserDefaults.user_id)!)
        
        DispatchQueue.global(qos: .background).async {
            APIdeclineJob(orderId: orderId, userId: u ?? 0, message: message); semaphore.wait()
            self.refreshUnacceptedJobs()
        }
    }
    
    func acceptJob(orderId: Int) {
        let u = Int(defaults.string(forKey: K.UserDefaults.user_id)!)
        
        DispatchQueue.global(qos: .background).async {
            APIacceptJob(orderId: orderId, userId: u ?? 0); semaphore.wait()
            self.refreshUnacceptedJobs()
            self.refreshUnbookedJobs()
        }
    }
    
    func bookJob(suggest: Bool, _ orderId: Int, _ taskCompanyId: Int, _ installerId: Int, _ startDate: Date, _ endDate: Date) {
        
        let start = dateToString_ymdhms(with: startDate)
        let end = dateToString_ymdhms(with: endDate)
        
        if suggest {
            APIsuggestJobToCustomer(orderId: orderId, taskCompanyId: taskCompanyId, installerId: installerId, startDate: start, endDate: end); semaphore.wait()
        } else {
            APIbookJob(orderId: orderId, taskCompanyId: taskCompanyId, installerId: installerId, startDate: start, endDate: end); semaphore.wait()
        }
    }
    
    func cancelJob(with taskCompanyId: Int) {
        APIcancelJob(taskCompanyId: taskCompanyId); semaphore.wait()
        refreshBookingAndBookedJobs()
        refreshUnbookedJobs()
    }
    
    func updateJob(startTime: Date, endTime: Date, installerId: Int, orderId: Int, orderStatudId: Int)
    {
        let date = dateToString_ymd(with: startTime)
        let start = dateToString_ymdThm(with: startTime)
        let end = dateToString_ymdThm(with: endTime)
        
        APIupdateJob(date: date, start: start, end: end, installerId: installerId, orderId: orderId, orderStatusId: orderStatudId); semaphore.wait()
        refreshBookingAndBookedJobs()
    }
    
    func setNewComments(_ orderId: Int, _ newComments: String) {
        APIsetNewOrderComments(orderId: orderId, comments: newComments)
    }
    
    func postProtocol(codableData: JSONpostProtocolBody) {
        let encoder = JSONEncoder()
        do {
            let data = try encoder.encode(codableData)
            APIpostProtocol(jsonData: data); semaphore.wait()
        } catch {
            print("Error: postProtocol JSONEncoding")
        }
    }
        
    func updateAllBadges() {
        let keyName = Notification.Name(rawValue: updateBadgesKey)
        NotificationCenter.default.post(name: keyName, object: nil)
    }
    
    func searchJobsWithPeriod(start: Date, end: Date) {
        let c = self.defaults.string(forKey: K.UserDefaults.company_id)

        APIgetSearchJobs(companyId: c!, dateFrom: start, dateTo: end); semaphore.wait()
    }
    
    func getCustomerAnswers(_ orderId: Int) {
        APIgetCustomerAnswers(orderId); semaphore.wait()
    }
    
    func getJob(_ orderId: Int) {
        APIgetOrder(orderId); semaphore.wait()
    }
}
