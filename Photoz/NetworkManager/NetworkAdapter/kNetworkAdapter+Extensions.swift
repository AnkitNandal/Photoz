//
//  kNetworkAdapter+Extensions.swift
//  Photoz
//
//  Created by Ankit Nandal on 09/09/18.
//  Copyright © 2018 Ankit Nandal. All rights reserved.
//

import Foundation

// MARK:- API Name Type
typealias APIName = kNetworkAdapter
extension APIName  {
    enum Of {
        static let search = "Search"
    }
}

// MARK:- Config Name Type
typealias ConfigName = kNetworkAdapter
extension ConfigName  {
    enum Resource {
        static let serverEndPoints = "ServerEndPoints"
        static let serverPlist = "Server"
        static let fileType = "plist"
    }
    enum Alert {
        static let noNetwork = "Yo are not connected to netwoorkk !"
    }
}


// MARK:- Service Type
typealias GetService = kNetworkAdapter
extension GetService  {
    
    public class func getService() -> KService? {
        if let baseUrl = ServiceEndPoint.getBaseUrl() {
            if let serviceConfig : KServiceConfig = KServiceConfig(baseUrl: baseUrl) {
                let service = KService(serviceConfig)
                return service
            }
        }
        return nil
    }
}


// MARK:- Service EndPoint
typealias ServiceEndPoint = kNetworkAdapter
extension ServiceEndPoint  {
    static let serverConfigs = ServiceEndPoint.readServerConfigs()
    
    public class func getBaseUrl() -> String? {
        if let baseEndPointDetails = ServiceEndPoint.serverConfigs {
            if let httpProtocol = baseEndPointDetails["protocol"], let host = baseEndPointDetails["host"] {
                let baseEndPoint = httpProtocol + ":" + "//"  + host
                return baseEndPoint
            }
        }
        return nil
    }
    
    public class func getAPIKey() -> String?{
        if let serverConfig = ServiceEndPoint.serverConfigs, let apiKey = serverConfig["apiKey"] {
            return apiKey
        }
        return nil
    }
    
    fileprivate class func readServerConfigs() -> [String : String]?{
        if let path = Bundle.main.path(forResource: ConfigName.Resource.serverPlist, ofType: ConfigName.Resource.fileType) {
            return NSDictionary(contentsOfFile: path) as? [String : String]
        }
        return nil
    }
}

// MARK:- API Rest End Points
typealias APIRestEndPoints = kNetworkAdapter
extension APIRestEndPoints  {
    static let endPoints = APIRestEndPoints.readApiRestEndPoints()
    
    fileprivate class func readApiRestEndPoints() -> [String : String]?{
        var restEndPoints: [String : String]?
        if let path = Bundle.main.path(forResource: ConfigName.Resource.serverEndPoints, ofType: ConfigName.Resource.fileType) {
            restEndPoints = NSDictionary(contentsOfFile: path) as? [String : String]
        }
        if let dict = restEndPoints {
            return dict
        }
        return nil
    }
    
    public class func getEndPoint(for key:String) -> String?{
        if let endPoints = APIRestEndPoints.endPoints {
            if let restEndPointString = endPoints[key] {
                return restEndPointString
            }
        }
        return nil
    }
}
