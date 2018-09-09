//
//  KResponse.swift
//  Photoz
//
//  Created by Ankit Nandal on 09/09/18.
//  Copyright © 2018 Ankit Nandal. All rights reserved.
//

import Foundation
public class KResponse:NSObject {
    public func toString(_ encoding: String.Encoding?) -> String? {
        guard let d = self.responseData else { return nil }
        return String(data: d, encoding: encoding ?? .utf8)
    }
    
    public func responseJSON() -> [AnyHashable : Any]?{
        guard let d = self.responseData else { return nil }
        do {
            return try JSONSerialization.jsonObject(with: d, options: [.allowFragments]) as? [AnyHashable: Any]
        } catch {
            return nil
        }
    }
    
    /// Headers of the request
    public var headers: HeadersDict? = [:]
    
    /// Raw data of the response
    public var responseData: Data? = nil
    
    /// Request executed
    public let request: KRequest
    
    /// Status Code
    public var httpStatusCode : NSInteger
    
    /// Error
    public var error : AnyObject? = nil
    
    /// success With Errors
    public var successWithErrors : Array? = []
    
    /// Initialize a new response from Alamofire response
    ///
    /// - Parameters:
    ///   - response: response
    ///   - request: request
    public required init(Data data: Data? = nil, httpStatusCode : NSInteger, headers:HeadersDict? = nil, request: KRequest) {
        
        if let responseData = data {
            self.responseData = responseData
        }
        
        self.httpStatusCode = httpStatusCode
        
        
        if let headersFields = headers {
            self.headers = headersFields
        }
        
        self.request = request
    }
}
