//
//  RequestBody.swift
//  Photoz
//
//  Created by Ankit Nandal on 09/09/18.
//  Copyright © 2018 Ankit Nandal. All rights reserved.
//

import Foundation

public class RequestBody : NSObject {
    
    /// Data to carry out into the body of the request
    public var data: AnyObject? = nil
    
    /// Type of encoding to use
    public var encoding: Encoding = .json
    
    public required init(Data data:AnyObject?) {
        if let data = data {
            self.data = data
        }
    }
    
    /// Encoded data to carry out with the request
    ///
    /// - Returns: Data
    
    public func rawData() throws -> Data {
        if let data = self.data  {
            return data  as! Data
        }
        throw NetworkError.dataError()
    }
    
    public func rawString(_ encoding : String.Encoding?) throws -> Data {
        if let data = self.data, data is String {
            let encodedString = (data as! String).data(using: encoding ?? .utf8)
            guard let string = encodedString else {
                throw NetworkError.dataIsNotEncodable("")
            }
            return string
        }else{
            throw NetworkError.dataError()
        }
    }
    
    public func json() throws -> Data {
        if let data = self.data {
            return try JSONSerialization.data(withJSONObject: data, options: [])
        }else{
            throw NetworkError.dataError()
        }
    }
    
    public func urlEncoded(_ encoding : String.Encoding?) throws -> Data {
        if let data = self.data, data is ParametersDict {
            let encodedString = try (data as! ParametersDict).urlEncodedString()
            guard let encodedData = encodedString.data(using: encoding ?? .utf8) else {
                throw NetworkError.dataIsNotEncodable(encodedString)
            }
            return encodedData
        }else{
            throw NetworkError.dataError()
        }
    }
}



// MARK: - Dictionary Extension
public extension Dictionary  {
    
    /// Encode a dictionary as url encoded string
    ///
    /// - Parameter base: base url
    /// - Returns: encoded string
    /// - Throws: throw `.dataIsNotEncodable` if data cannot be encoded
    public func urlEncodedString(base: String = "") throws -> String {
        guard self.count > 0 else { return "" } // nothing to encode
        let items: [URLQueryItem] = self.flatMap { (key,value) in
            guard let v = value as Any? else { return nil } // skip item if no value is set
            return URLQueryItem(name: (key as? String)!, value: String(describing: v))
        }
        var urlComponents = URLComponents(string: base)!
        urlComponents.queryItems = items
        guard let encodedString = urlComponents.url else {
            throw NetworkError.dataIsNotEncodable(self)
        }
        return encodedString.absoluteString
    }
    
}
