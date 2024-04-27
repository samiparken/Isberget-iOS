import Foundation

//MARK: - API Calls

func APIreadMessageFromCustomerPage(_ orderId: Int) {
    let e = EndpointCases.readMessageFromCustomerPage(orderId)
    APIRequest(endpoint: e) { data, response in
        
        if let dataString = String(data: data!, encoding: .utf8), dataString != "" {
            print("dataString: \(dataString)")
            singletonData.readMessageFromCustomerPageResponse = dataString
        } else {
            singletonData.readMessageFromCustomerPageResponse = ""
        }
        
        semaphore.signal()
        return
    }
}

func APIsendMessageToCustomerPage(_ orderId: Int, _ message: String) {
    let e = EndpointCases.sendMessageToCustomerPage(orderId, message)
    APIRequest(endpoint: e) { data, response in
        
        if let dataString = String(data: data!, encoding: .utf8), dataString != "" {
            print("dataString: \(dataString)")
            singletonData.sendMessageToCustomerPageResponse = dataString
        } else {
            singletonData.sendMessageToCustomerPageResponse = ""
        }
        
        semaphore.signal()
        return
    }
}

func APIgetCustomerPageChat(_ orderId: Int) {
    let e = EndpointCases.getCustomerPageChat(orderId)
    APIRequest(endpoint: e) { data, response in
        // Decoding JSONData
        do {
            let jsonResponse = try JSONSerialization.jsonObject(with:data!, options: [])
            guard let jsonArray = jsonResponse as? [String: Any] else {
                semaphore.signal()
                return
            }
            print("jsonArray: \(jsonArray)")

            // Store JSON
            singletonData.getCustomerPageChat = jsonArray
        } catch {
            print("getCustomerPageChat Decoding Error")
        }
        semaphore.signal()
        return
    }
}

func APIgetOrder(_ orderId: Int) {
    let e = EndpointCases.getOrder(orderId)
    APIRequest(endpoint: e) { data, response in
        // Decoding JSONData
        do {
            let jsonResponse = try JSONSerialization.jsonObject(with:data!, options: [])
            guard let jsonArray = jsonResponse as? [[String: Any]] else {
                semaphore.signal()
                return
            }
            print("jsonArray: \(jsonArray)")
            if(jsonArray.count > 0) {
                singletonData.getOrder = jsonArray[0]
            }
        } catch {
            print("getOrder Decoding Error")
        }
        semaphore.signal()
        return
    }
}

func APIgetTasks(_ companyId: Int) {
    let e = EndpointCases.getTasks(companyId)
    APIRequest(endpoint: e) { data, response in
        // Decoding JSONData
        do {
            let jsonResponse = try JSONSerialization.jsonObject(with:data!, options: [])
            guard let jsonArray = jsonResponse as? [[String: Any]] else {
                semaphore.signal()
                return
            }
            print("jsonArray: \(jsonArray)")
            var dictArray = [[String: Any]]()
            for dict in jsonArray {
                dictArray.append(dict)
            }
            
            //sort
            dictArray.sort {
                ($0[K.Task.taskCreatedAt] as! String) > ($1[K.Task.taskCreatedAt] as! String)
            }

            singletonData.getTasks = dictArray
            
        } catch {
            print("getTasks Decoding Error")
        }
        semaphore.signal()
        return
    }
}

func APIsetTaskDone(taskId: Int) {
    let e = EndpointCases.setTaskDone(taskId)
    APIRequest(endpoint: e) { data, response in
        
        if let dataString = String(data: data!, encoding: .utf8), dataString != "" {
            print("dataString: \(dataString)")
            singletonData.setTaskDoneResponse = dataString
        } else {
            singletonData.setTaskDoneResponse = ""
        }
        
        semaphore.signal()
        return
    }
}

func APIreportTask(taskId: Int, reasonId: Int, reasonText: String) {
    let e = EndpointCases.reportTask(taskId, reasonId, reasonText)
    APIRequest(endpoint: e) { data, response in
        
        if let dataString = String(data: data!, encoding: .utf8), dataString != "" {
            print("dataString: \(dataString)")
            singletonData.reportTaskResponse = dataString
        } else {
            singletonData.reportTaskResponse = ""
        }

        semaphore.signal()
        return
    }
}

func APIgetCustomerAnswers(_ orderId: Int) {
    let e = EndpointCases.getCustomerAnswers(orderId)
    APIRequest(endpoint: e) { data, response in
        // Decoding JSONData
        do {
            let jsonResponse = try JSONSerialization.jsonObject(with:data!, options: [])
            guard let jsonArray = jsonResponse as? [[String: Any]] else {
                semaphore.signal()
                return
            }
            print("jsonArray: \(jsonArray)")
            var answersArray = [[String:Any]]()
            for dict in jsonArray {
                let headerArray = [
                    "isHeader": true,
                    "headerText": (dict["DateTime"] as? String) ?? ""
                    ] as [String : Any]
                
                answersArray.append(headerArray)
                answersArray.append(contentsOf: (dict["Answers"] as! [[String : Any]]))
            }
            
            if answersArray.count > 0 {
                singletonData.customerAnswers[orderId] = answersArray
            } else {
                singletonData.customerAnswers[orderId] = []
            }
        } catch {
            print("getCustomerAnswers Decoding Error")
        }
        semaphore.signal()
        return
    }
}

func APIgetSearchJobs(companyId: String, dateFrom: Date, dateTo: Date) {
    let fromString = dateToString_ymd(with: dateFrom)
    let toString = dateToString_ymd(with: dateTo)

    let e = EndpointCases.getBookingAndBookedJobs(companyId, fromString, toString)
    APIRequest(endpoint: e) { data, response in
        // Decoding JSONData
        do {
            let jsonResponse = try JSONSerialization.jsonObject(with:data!, options: [])
            guard let jsonArray = jsonResponse as? [[String: Any]] else {
                semaphore.signal()
                return
            }
            print("jsonArray: \(jsonArray)")
            var searchJobs = [[String: Any]]()
            
            for dict in jsonArray {
                searchJobs.append(dict)
            }
            
            // filter unacceptedJobs with period
            for job in singletonData.getUnacceptedJobs {
                let jobDateString = (job["OrderCreatedAsDate"] as? String) ?? "2000-01-01T00:00:00.000"
                let jobDate = stringToDate(with: jobDateString)
                
                if ( dateFrom.timeIntervalSince1970 < jobDate.timeIntervalSince1970 ) && ( jobDate.timeIntervalSince1970 < dateTo.timeIntervalSince1970 ) {
                    searchJobs.append(job)
                }
            }
            
            // filter unbookedJobs with period
            for job in singletonData.getUnbookedJobs {
                let jobDateString = (job["OrderCreatedAsDate"] as? String) ?? "2000-01-01T00:00:00.000"
                let jobDate = stringToDate(with: jobDateString)
                
                if ( dateFrom.timeIntervalSince1970 < jobDate.timeIntervalSince1970 ) && ( jobDate.timeIntervalSince1970 < dateTo.timeIntervalSince1970 ) {
                    searchJobs.append(job)
                }
            }
            
            singletonData.getSearchJobs = searchJobs
        } catch {
            print("getBookingAndBookedJobs Decoding Error")
        }
        semaphore.signal()
        return
    }
}

func APIpostProtocol(jsonData: Data) {
    let e = EndpointCases.postProtocol(jsonData: jsonData)
    APIRequest(endpoint: e) { data, response in
        // Decoding JSONData
        singletonData.postProtocolResponse = 0
        if let httpResponse = response as? HTTPURLResponse {
            singletonData.postProtocolResponse = httpResponse.statusCode
        }
        semaphore.signal()
        return
    }
}

func APIupdateDeviceToken(_ userId: Int, _ deviceId: String, _ deviceToken: String) {
        
    let e = EndpointCases.updateDeviceToken(userId, deviceId, deviceToken)
    APIRequest(endpoint: e) { data, response in
        // Decoding JSONData
        
        semaphore.signal()
        return
    }
}


func APIupdateJob(date: String, start: String, end: String, installerId: Int, orderId: Int, orderStatusId: Int ) {
    let e = EndpointCases.updateJob(date, start, end, installerId, orderId, orderStatusId)
    APIRequest(endpoint: e) { data, response in
        
        semaphore.signal()
        return
    }
}

func APIcancelJob(taskCompanyId: Int) {
    let e = EndpointCases.cancelJob(taskCompanyId: taskCompanyId)
    APIRequest(endpoint: e) { data, response in
        // Decoding JSONData
        if let dataString = String(data: data!, encoding: .utf8), dataString != "" {
            print("dataString: \(dataString)")
            singletonData.cancelJobResponse = dataString
        } else {
            singletonData.cancelJobResponse = ""
        }
        semaphore.signal()
        return
    }
}

func APIsuggestJobToCustomer(orderId: Int, taskCompanyId: Int, installerId: Int, startDate: String, endDate: String) {
    let e = EndpointCases.suggestJobToCustomer(orderId: orderId, taskCompanyId: taskCompanyId, installerId: installerId, startDate: startDate, endDate: endDate)
    APIRequest(endpoint: e) { data, response in
        // Decoding JSONData
        if let dataString = String(data: data!, encoding: .utf8), dataString != "" {
            print("dataString: \(dataString)")
            singletonData.suggestJobResponse = dataString
        } else {
            singletonData.suggestJobResponse = ""
        }
        semaphore.signal()
        return
    }
}

func APIbookJob(orderId: Int, taskCompanyId: Int, installerId: Int, startDate: String, endDate: String) {
    let e = EndpointCases.bookJob(orderId: orderId, taskCompanyId: taskCompanyId, installerId: installerId, startDate: startDate, endDate: endDate)
    APIRequest(endpoint: e) { data, response in
        // Decoding JSONData
        if let dataString = String(data: data!, encoding: .utf8), dataString != "" {
            print("dataString: \(dataString)")
            singletonData.bookJobResponse = dataString
        } else {
            singletonData.bookJobResponse = ""
        }
        semaphore.signal()
        return
    }
}

func APIsetNewOrderComments(orderId: Int, comments: String) {
    let e = EndpointCases.setNewOrderComments(orderId: orderId, comments: comments)
    APIRequest(endpoint: e) { data, response in
        semaphore.signal()
        return
    }
}

// the former name : GetEventsForCompanyByDate
// for booking(4) & booked(11) & done(6) jobs
// orderStatusId = 4, 11, 6
func APIgetBookingAndBookedJobs(companyId: String, dateFrom: String) {
    let e = EndpointCases.getBookingAndBookedJobs(companyId, dateFrom, "2099-12-31")
    APIRequest(endpoint: e) { data, response in
        // Decoding JSONData
        do {
            let jsonResponse = try JSONSerialization.jsonObject(with:data!, options: [])
            guard let jsonArray = jsonResponse as? [[String: Any]] else {
                semaphore.signal()
                return
            }
            print("jsonArray: \(jsonArray)")
            var bookingArray = [[String: Any]]()
            var bookedArray = [[String: Any]]()
            var doneArray = [[String: Any]]()
            
            for dict in jsonArray {
                switch ((dict["OrderStatus"] as? String) ?? K.OrderStatus.done).lowercased() {
                case K.OrderStatus.booking: bookingArray.append(dict)
                case K.OrderStatus.booked: bookedArray.append(dict)
                case K.OrderStatus.done: doneArray.append(dict)
                default: break
                }
            }
            
            bookingArray.sort {
                ($0["OrderCreatedAsDate"] as! String) > ($1["OrderCreatedAsDate"] as! String)
            }
            bookedArray.sort {
                ($0["OrderCreatedAsDate"] as! String) > ($1["OrderCreatedAsDate"] as! String)
            }
            doneArray.sort {
                ($0["OrderCreatedAsDate"] as! String) > ($1["OrderCreatedAsDate"] as! String)
            }
            singletonData.getBookingJobs = bookingArray
            singletonData.getBookedJobs = bookedArray
            singletonData.getDoneJobs = doneArray
        } catch {
            print("getBookingAndBookedJobs Decoding Error")
        }
        semaphore.signal()
        return
    }
}

func APIgetUnbookedJobs(companyId: String) {
    let e = EndpointCases.getUnbookedJobs(companyId: companyId)
    APIRequest(endpoint: e) { data, response in
        // Decoding JSONData
        do {
            let jsonResponse = try JSONSerialization.jsonObject(with:data!, options: [])
            guard let jsonArray = jsonResponse as? [[String: Any]] else {
                semaphore.signal()
                return
            }
            print("jsonArray: \(jsonArray)")
            var dictArray = [[String: Any]]()
            for dict in jsonArray {
                dictArray.append(dict)
            }
            dictArray.sort {
                ($0["OrderCreatedAsDate"] as! String) > ($1["OrderCreatedAsDate"] as! String)
            }
            singletonData.getUnbookedJobs = dictArray
        } catch {
            print("JSONgetUnbookedJobs Decoding Error")
        }
        semaphore.signal()
        return
    }
}

func APIgetUnacceptedJobs(companyId: String) {
    let e = EndpointCases.getUnacceptedJobs(companyId: companyId)
    APIRequest(endpoint: e) { data, response in
        // Decoding JSONData
        do {
            let jsonResponse = try JSONSerialization.jsonObject(with:data!, options: [])
            guard let jsonArray = jsonResponse as? [[String: Any]] else {
                semaphore.signal()
                return
            }
            print("jsonArray: \(jsonArray)")
            var dictArray = [[String: Any]]()
            for dict in jsonArray {
                dictArray.append(dict)
            }
            
            //sort
            dictArray.sort {
                ($0["OrderCreatedAsDate"] as! String) > ($1["OrderCreatedAsDate"] as! String)
            }

            singletonData.getUnacceptedJobs = dictArray
        } catch {
            print("JSONgetMessages Decoding Error")
        }
        semaphore.signal()
        return
    }
}

func APIresetPassword(email: String) {
    let e = EndpointCases.resetPassword(email: email)
    APIRequest(endpoint: e) { data, response in
        
        // Decoding JsonData
        do {
            if let dataString = String(data: data!, encoding: .utf8), dataString != "" {
                let jsonResponse = try JSONSerialization.jsonObject(with:data!, options: [])
                guard let jsonArray = jsonResponse as? [String: Any] else {
                    semaphore.signal()
                    return
                }
                print("jsonArray: \(jsonArray)")
                singletonData.resetPassword = jsonArray
            }
        } catch {
            print("JSONresetPassword Decoding Error")
        }
        semaphore.signal()
        return
    }
}

func APIacceptJob(orderId: Int, userId: Int) {
    let e = EndpointCases.acceptJob(orderId: orderId, userId: userId)
    APIRequest(endpoint: e) { data, response in
        
        if let dataString = String(data: data!, encoding: .utf8), dataString != "" {
            print("dataString: \(dataString)")
            semaphore.signal()
            return
        }
    }
}

func APIdeclineJob(orderId: Int, userId: Int, message: String) {
    let e = EndpointCases.declineJob(orderId: orderId, userId: userId, message: message)
    APIRequest(endpoint: e) { data, response in
        
        if let dataString = String(data: data!, encoding: .utf8), dataString != "" {
            print("dataString: \(dataString)")
            semaphore.signal()
            return
        }
    }
}
/* using GetTasks instead
func APIgetMessages(companyId: String, userId: String, isAdmin: Bool) {
    let e = EndpointCases.getMessages(companyId: companyId, userId: userId, isAdmin: isAdmin)
    APIRequest(endpoint: e) { data, response in
        // Decoding JSONData
        do {
            let jsonResponse = try JSONSerialization.jsonObject(with:data!, options: [])
            guard let jsonArray = jsonResponse as? [[String: Any]] else {
                semaphore.signal()
                return
            }
            print("jsonArray: \(jsonArray)")
            var dictArray = [[String: Any]]()
            for dict in jsonArray {
                dictArray.append(dict)
            }
            singletonData.getMessages = dictArray
        } catch {
            print("JSONgetMessages Decoding Error")
        }
        semaphore.signal()
        return
    }
}
*/
/*
func APIsetMessageRead(messageId: Int) {
    let e = EndpointCases.setMessageRead(messageId: messageId)
    APIRequest(endpoint: e) { data, response in
        semaphore.signal()
        return
    }
}
*/
/* using GetUserData instead */
//    func getCurrentUserCompaniesAndChildren() {
//        let endpointGetCurrentUserCompaniesAndChildren = EndpointCases.getCurrentUserCompaniesAndChildren
//        APIRequest(endpoint: endpointGetCurrentUserCompaniesAndChildren) { data in
//            // Decoding JSONData
//            do {
//                let jsonResponse = try JSONSerialization.jsonObject(with:data!, options: [])
//                guard let jsonArray = jsonResponse as? [[String: Any]] else {
//                    semaphore.signal()
//                    return
//                }
//                print("jsonResponse: \(jsonResponse)")
//                var dictArray = [[String: Any]]()
//                for dict in jsonArray {
//                    dictArray.append(dict)
//                }
//                singletonData.getCurrentUserCompaniesAndChildren = dictArray
//            } catch {
//                print("JSONgetCurrentUserCompaniesAndChildren Decoding Error")
//            }
//            semaphore.signal()
//            return
//        }
//    }

//func APIgetAllCompanyInfo() {
//    let e = EndpointCases.getAllCompanyInfo
//    APIRequest(endpoint: e) { data in
//        // Decoding JSONData
//        do {
//            if let dataString = String(data: data!, encoding: .utf8) {
//                print("dataString: \(dataString)")
//                let dataJSON = dataString.data(using: .utf8)!
//                let decodedData = try JSONDecoder().decode(JSONgetAllCompanyInfo.self, from: dataJSON)
//                
//                singletonData.getAllCompanyInfo = decodedData
//            }
//        } catch {
//            print("JSONgetAllCompanyInfo Decoding Error")
//        }
//        semaphore.signal()
//        return
//    }
//}

func APIgetCompanyAddress(companyId: String) {
    let e = EndpointCases.getCompanyAddress(companyId: companyId)
    APIRequest(endpoint: e) { data, response in
        // Decoding JSONData
        do {
            if let dataString = String(data: data!, encoding: .utf8) {
                print("dataString: \(dataString)")
                let dataJSON = dataString.data(using: .utf8)!
                let decodedData = try JSONDecoder().decode(JSONgetCompanyAddress.self, from: dataJSON)
                
                singletonData.getCompanyAddress = decodedData
            }
        } catch {
            print("JSONgetCompanyAddress Decoding Error")
        }
        semaphore.signal()
        return
    }
}

func APIgetUsersInCompany(companyId: String) {
    let e = EndpointCases.getUsersInCompany(companyId: companyId)
    APIRequest(endpoint: e) { data, response in
        // Decoding JSONData
        do {
            let jsonResponse = try JSONSerialization.jsonObject(with:data!, options: [])
            guard let jsonArray = jsonResponse as? [[String: Any]] else {
                semaphore.signal()
                return
            }
            print("jsonArray: \(jsonArray)")
            var dictArray = [[String: Any]]()
            for dict in jsonArray {
                dictArray.append(dict)
            }
            
            singletonData.getUsersInCompany = dictArray
            
        } catch {
            print("JSONgetUsersInCompany Decoding Error")
        }
        semaphore.signal()
        return
    }
}

func APIgetUserData() {
    let e = EndpointCases.getUserData
    APIRequest(endpoint: e) { data, response in
        // Decoding JSONData
        do {
            if let dataString = String(data: data!, encoding: .utf8) {
                print("dataString: \(dataString)")
                let dataJSON = dataString.data(using: .utf8)!
                let decodedData = try JSONDecoder().decode(JSONgetUserData.self, from: dataJSON)
                
                singletonData.getUserData = decodedData
                
            }
        } catch {
            print("JSONgetUserData Decoding Error")
        }
        semaphore.signal()
        return
    }
}

func APIlogin(email: String, password: String) {
    let e = EndpointCases.login(email: email, password: password)
    APIRequest(endpoint: e) { data, response in
        // Decoding JsonData
        do {
            if let dataString = String(data: data!, encoding: .utf8) {
                print("dataString: \(dataString)")
                let dataJSON = dataString.data(using: .utf8)!
                let decoder = JSONDecoder()
                decoder.keyDecodingStrategy = .custom { keys in
                    let lastComponent = keys.last!.stringValue.split(separator: ".").last!
                    return AnyKey(stringValue: String(lastComponent))!
                }
                let decodedData = try decoder.decode(JSONlogin.self, from: dataJSON)
                
                singletonData.login = decodedData
            }
        } catch {
            print("JSONlogin Decoding Error")
        }
        semaphore.signal()
        return
    }
}
