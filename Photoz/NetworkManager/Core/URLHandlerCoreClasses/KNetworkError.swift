//
//  KNetworkError.swift
//  Photoz
//
//  Created by Ankit Nandal on 09/09/18.
//  Copyright © 2018 Ankit Nandal. All rights reserved.
//

import Foundation

public class NetworkError: NSObject {
    
    public class func dataIsNotEncodable(_ data : Any) -> Error {
        let userInfo: [String : Any] =
            [
                NSLocalizedDescriptionKey :  NSLocalizedString("DataNotEncodable", value: "Data is Not Encodable", comment: "") ,
                NSLocalizedFailureReasonErrorKey : NSLocalizedString("DataNotEncodable", value: "Data is Not Encodable", comment: "")
        ]
        let err = NSError(domain: "DataNotEncodable", code: 0, userInfo: userInfo)
        return err
    }
    
    public class func dataError() -> Error {
        let userInfo: [String : Any] =
            [
                NSLocalizedDescriptionKey :  NSLocalizedString("DataError", value: "Data is not found", comment: "") ,
                NSLocalizedFailureReasonErrorKey : NSLocalizedString("DataError", value: "Data is not found", comment: "")
        ]
        let err = NSError(domain: "DataError", code: 0, userInfo: userInfo)
        return err
    }
    
    
    public class func stringFailedToDecode(_: Data, encoding: String.Encoding) -> Error {
        let userInfo: [String : Any] =
            [
                NSLocalizedDescriptionKey :  NSLocalizedString("StringFailedToDecode", value: "String Failed to Decode", comment: "") ,
                NSLocalizedFailureReasonErrorKey : NSLocalizedString("StringFailedToDecode", value: "String Failed to Decode", comment: "")
        ]
        let err = NSError(domain: "StringFailedToDecode", code: 0, userInfo: userInfo)
        return err
    }
    public class func invalidURL(_ url: String) -> Error {
        let userInfo: [String : Any] =
            [
                NSLocalizedDescriptionKey :  NSLocalizedString("InvalidURL", value: "Invalid url", comment: "") ,
                NSLocalizedFailureReasonErrorKey : NSLocalizedString("InvalidURL", value: "Invalid url", comment: "")
        ]
        let err = NSError(domain: "InvalidURL", code: 0, userInfo: userInfo)
        return err
    }
    public class func error(_ response: KResponse) -> Error {
        let userInfo: [String : Any] =
            [
                NSLocalizedDescriptionKey :  NSLocalizedString("Error", value: "Error Received", comment: "") ,
                NSLocalizedFailureReasonErrorKey : NSLocalizedString("Error", value: "Error Received", comment: "")
        ]
        let err = NSError(domain: "Error", code: 0, userInfo: userInfo)
        return err
    }
    public class func noResponse(_ response : KResponse) -> Error{
        let userInfo: [String : Any] =
            [
                NSLocalizedDescriptionKey :  NSLocalizedString("NoResponse", value: "No Response", comment: "") ,
                NSLocalizedFailureReasonErrorKey : NSLocalizedString("NoResponse", value: "No Response", comment: "")
        ]
        let err = NSError(domain: "NoResponse", code: 0, userInfo: userInfo)
        return err
    }
    
}
