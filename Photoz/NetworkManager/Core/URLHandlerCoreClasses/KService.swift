//
//  KService.swift
//  Photoz
//
//  Created by Ankit Nandal on 09/09/18.
//  Copyright © 2018 Ankit Nandal. All rights reserved.
//

import Foundation
import Alamofire


// Service is a concrete implementation of the any Service
public class KService: NSObject {
    
    /// Configuration
    public var configuration: KServiceConfig
    
    /// Session headers
    public var headers: HeadersDict
    
    /// Certificate Pinning is Enabled and Default is false
    public var certificatePinningEnabled : Bool = false
    
    /// Alamofire session Manager which used for certificate pinning
    public var manager : SessionManager?
    
    /// Alamofire request
    public var request : DataRequest?
    
    public var sessionConfiguration = URLSessionConfiguration.default
    
    public required init(_ configuration: KServiceConfig) {
        self.configuration = configuration
        self.headers = self.configuration.headers // fillup with initial headers
    }
    
    public func cancel(){
        print("Subclass must overrite cancel to method")
    }
    
    
    public func createRequest(_ request: KRequest?) -> URLRequest? {
        
        guard let createRequest = request else {
            return nil
        }
        
        // Adding API Key
        createRequest.urlParams?["api_key"] = kNetworkAdapter.getAPIKey()
        
        do {
            var urlRequest: URLRequest = try createRequest.urlRequest(in: self)
            // Remove percent Encoding from URL path Parameter when path parameter is added
            if let urlString  = urlRequest.url?.absoluteString.removingPercentEncoding {
                guard let finalUrl = URL(string: urlString) else {
                    throw NetworkError.invalidURL(urlString)
                }
                urlRequest.url = finalUrl
            }
            // Append Query Parameter using Alamofire as query parameter also ordered
            urlRequest = try URLEncoding.queryString.encode(urlRequest, with: createRequest.urlParams)
            //Print Request
            let contentType = "Content-Type"
            let requestContentType = createRequest.contentType
            switch requestContentType {
            case .encoded:
                urlRequest.addValue("application/x-www-form-urlencoded; charset=UTF-8", forHTTPHeaderField: contentType)
                // Need to used formURLEncoded Data parameter
                urlRequest = try URLEncoding().encode(urlRequest, with:createRequest.body?.data as? Parameters)
                break
            case .json:
                urlRequest.addValue("application/json", forHTTPHeaderField: contentType)
                break
            case .none:
                break
            case .multipart:
                break
            }
            return urlRequest
        } catch {
            return nil
        }
        
    }
    /// Execute a request and return response
    /// - Parameters:
    ///   - request: request to execute
    ///   - retry: retry attempts. If `nil` only one attempt is made. Default value is `nil`.
    /// - CompletionClosure: return response and successWithError
    public func execute(_ request: KRequest, retry: NSNumber?, completionClosure: CompletionClosure) {
        
        guard let resouceRequest = self.createRequest(request) else {
            self.sendBadRequestResponse(request, completionClosure: completionClosure)
            return
        }
        
        // Check Certificate Pinning
        if self.certificatePinningEnabled == false {
            self.manager = Alamofire.SessionManager(configuration: sessionConfiguration)
        } else {
            // Handle SSL Pinning
        }
        
        print("\n********\nAPI REQUEST:--- \(String(describing: resouceRequest.url))\n******\n")
        self.request = self.manager?.request(resouceRequest)
        
        self.request?.response(completionHandler: { [weak self] response in
            // Parse response
            guard let selfReference = self else {
                return
            }
            DispatchQueue.global(qos: .default).async {
                selfReference.createResponse(response: response.response, responseData: response.data, error: response.error as NSError?, request: request, completionClosure: completionClosure)
            }
            
        })
    }
    
    /// sendBadRequestResponse send error as request not able to create
    /// - Parameters:
    /// - request: request to execute  and
    /// - CompletionClosure: return response and successWithError
    
    public func sendBadRequestResponse(_ request:KRequest, completionClosure: CompletionClosure) {
        let error = KRequest.badRequestError()
        let status = NSNumber(value:error.code)
        let response : KResponse = KResponse.init(Data: nil, httpStatusCode: status.intValue , headers: nil, request: request)
        //        let kError : KError = KError.init(wlCode: status.intValue, message: error.localizedDescription)
        //        response.error = kError
        completionClosure?(response, false)
    }
    
    /// Handle Response and Create Response with server response, error and success with failure
    /// - Parameters:
    /// - response: HTTPURLResponse server response
    /// - error : Receive error
    /// - responseData : server response data
    /// - request : request which execute
    /// - Returns:
    /// - response : KResponse
    /// - error : server error
    /// - successWithError if server send succuss response with error
    
    public func response(response :HTTPURLResponse?, error :NSError?, responseData : Data?, request : KRequest) -> (response:KResponse?, error:NSError?, successWithError : Bool) {
        
        var status : NSNumber = NSNumber(value: 0) // TODO : If http status code not received used default
        if let statusCode = response?.statusCode {
            status = NSNumber(value: statusCode)
        }
        
        let response : KResponse = KResponse.init(Data: responseData, httpStatusCode: status.intValue , headers: response?.allHeaderFields as? HeadersDict, request: request)
        
        return (response, error,false)
    }
    
    public func createResponse(response : HTTPURLResponse?, responseData : Data?, error :NSError?, request:KRequest, completionClosure: CompletionClosure) {
        print("Subclass need to override createResponse: method to handle response with respective Service")
        let response = self.response(response: response, error: error, responseData:responseData,  request: request)
        completionClosure?(response.response, response.successWithError)
    }
    
}
