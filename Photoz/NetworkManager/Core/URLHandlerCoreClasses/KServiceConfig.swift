//
//  KServiceConfig.swift
//  Photoz
//
//  Created by Ankit Nandal on 09/09/18.
//  Copyright © 2018 Ankit Nandal. All rights reserved.
//

import Foundation

public typealias CompletionClosure = ((_ response: KResponse?, _ successWithError: Bool) ->())?

/// Define the parameter's dictionary
public typealias ParametersDict = [String : Any]

/// Define the Path parameter's Array
public typealias PathParameters = Array<String>

/// Define the header's dictionary
public typealias HeadersDict = [String: String]


public enum HTTPMethod:String {
    case get
    case post
    case put
    case patch
    case delete
}

public enum RequestContentType:String {
    case none
    case json
    case encoded
    case multipart
}

/// Encoding type
///
/// - raw: no encoding, data is sent as received
/// - json: json encoding
/// - urlEncoded: url encoded string
/// - custom: custom serialized data
@objc public enum Encoding : Int {
    case rawData
    case rawString
    case json
    case urlEncoded
}

public class KServiceConfig : NSObject {
    
    /// base host url
    var url: URL
    
    ///  global headers must be included in each session of the service
    var headers: HeadersDict = [:]
    
    // Cache policy apply to each request
    /// By default is `.useProtocolCachePolicy`.
    public var cachePolicy: URLRequest.CachePolicy = .useProtocolCachePolicy
    
    /// Global timeout for any request. If to change then override it in Request
    /// Default value is 30 seconds.
    public var timeout: TimeInterval = 30
    
    
    /// Initialize a new service configuration
    ///
    /// - Parameters:
    ///   - urlString: base url of the service
    public required init?(baseUrl urlString: String) {
        guard let url = URL(string: urlString) else { return nil }
        self.url = url
    }
}
