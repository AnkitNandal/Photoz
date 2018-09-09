//
//  KRequest.swift
//  Photoz
//
//  Created by Ankit Nandal on 09/09/18.
//  Copyright © 2018 Ankit Nandal. All rights reserved.
//

import Foundation

public class KRequest: NSObject {
    
    /// Endpoint for request
    public var endpoint: String
    
    /// Body of the request
    public var body: RequestBody?
    
    /// HTTP method of the request
    public var method: HTTPMethod = .get
    
    // Path Parameters
    public var pathParams : PathParameters?
    
    /// URL of the request
    public var urlParams: ParametersDict?
    
    /// Headers of the request
    public var headers: HeadersDict?
    
    /// Content Type
    public var contentType : RequestContentType = .none
    
    /// Cache policy
    public var cachePolicy: URLRequest.CachePolicy = .reloadIgnoringLocalCacheData
    
    /// Timeout of the request
    public var timeout: TimeInterval = 30
    
    /// Initialize a new request
    ///
    /// - Parameters:
    ///   - method: HTTP Method request (if not specified, `.get` is used)
    ///   - endpoint: endpoint of the request
    public init(method: HTTPMethod, endpoint: String = "") {
        self.method = method
        self.endpoint = endpoint
    }
    
    public func getRequestMethod() -> String {
        return self.method.rawValue
    }
    
}

// MARK: - Provide default implementation of the Request
public extension KRequest {
    
    func headers(in service: KService) -> HeadersDict? {
        var headers: HeadersDict = service.headers // initial set is composed by service's current headers
        // append (and replace if needed) with request's headers
        self.headers?.forEach({ k,v in headers[k] = v })
        return headers
    }
    
    func url(in service: KService) throws -> URL {
        // Compose request URL by taking configuration's full url (service url + request endpoint)
        let baseURL = service.configuration.url.absoluteString.appending(self.endpoint)
        // Append request's endpoint and eventually:
        guard var url = URL(string: baseURL) else {
            throw NetworkError.invalidURL(baseURL)
        }
        
        if let pathParams  = self.pathParams {
            if pathParams.count > 0 {
                for (_, element) in pathParams.enumerated() {
                    url.appendPathComponent(element)
                }
            }
        }
        return url
    }
    
    public func urlRequest(in service: KService) throws -> URLRequest {
        // Compose default full url
        let requestURL = try self.url(in: service)
        // Setup cache policy, timeout and headers of the request
        let cachePolicy = self.cachePolicy
        let timeout = service.configuration.timeout
        let headers = self.headers(in: service)
        
        // Create the URLRequest object
        var urlRequest = URLRequest(url: requestURL, cachePolicy: cachePolicy, timeoutInterval: timeout)
        urlRequest.httpMethod = self.getRequestMethod()  // if not specified default HTTP method is GET
        urlRequest.allHTTPHeaderFields = headers
        
        if let body = self.body, let _ = self.body?.data {
            
            switch body.encoding { // set body if specified
            case .json:
                let bodyData = try body.json() // Default JSON
                urlRequest.httpBody = bodyData
                break
            case .rawData:
                let bodyData = try body.rawData() // raw Data
                urlRequest.httpBody = bodyData
                break
            case .rawString:
                let bodyData = try body.rawString(.utf8) // raw string encode using .utf8
                urlRequest.httpBody = bodyData
                break
            case .urlEncoded:
                let bodyData = try body.urlEncoded(.utf8) // URL encode string using .utf8
                urlRequest.httpBody = bodyData
                break
            }
            
        }
        
        return urlRequest
    }
}

public extension KRequest {
    
    public class func badRequestError() -> NSError {
        
        let userInfo: [AnyHashable : Any] =
            [
                NSLocalizedDescriptionKey :  NSLocalizedString("BadRequest", value: "Request can't create", comment: "") ,
                NSLocalizedFailureReasonErrorKey : NSLocalizedString("BadRequest", value: "Request can't create", comment: "")
        ]
        
        let err = NSError(domain: "HttpBadRequestErrorDomain", code: 400, userInfo: userInfo as? [String : Any])
        return err
    }
}
