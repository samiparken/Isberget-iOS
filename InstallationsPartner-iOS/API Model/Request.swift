import Foundation

let semaphore = DispatchSemaphore(value: 0)

func APIRequest(endpoint: Endpoint, completion: @escaping (Data?, URLResponse?) -> Void) {
    
    // URL
    let url = URL(string: endpoint.url)!
    var urlRequest = URLRequest(url: url)
    
    // HTTP Method
    urlRequest.httpMethod = endpoint.httpMethod
    
    // Header fields
    endpoint.headers?.forEach({ header in
        urlRequest.setValue(header.value as? String, forHTTPHeaderField: header.key)
    })
    
    // Body fields
    if let _ = endpoint.body!["encoded"] {
        urlRequest.httpBody = endpoint.encodedBody
    } else {
        urlRequest.httpBody = endpoint.body!.queryString.data(using: .utf8)
    }
    
    urlRequest.timeoutInterval = 60.0
    
    print("\n")
    print("ENDPOINT: \(endpoint)")
    print("urlRequest: \(urlRequest)")
    print("headers: \(endpoint.headers!)")
    print("body: \(endpoint.body!)")
    print("body.queryString: \(endpoint.body!.queryString)")
    print("body.encodedJson: \(endpoint.encodedBody!)")
    
    //URLRequest
    let session = URLSession.shared
    let task = session.dataTask(with: urlRequest) { (data, response, error) in
        // Error Handling
        if let error = error {
            print("urlRequest Error: \(error)")
            singletonData.error = "No response from Server"
            semaphore.signal()
        } else {
            completion(data, response)
        }
    }
    task.resume()
}
