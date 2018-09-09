//
//  KSearchOperation.swift
//  Photoz
//
//  Created by Ankit Nandal on 09/09/18.
//  Copyright © 2018 Ankit Nandal. All rights reserved.
//

import UIKit


//Search Operation Api Parameters.
class KSearchOperationParamters: NSObject {
    
    let query:String
    let page:Int
    
    init(query:String, pageNumber:Int) {
        self.query = query
        self.page = pageNumber
    }
}


// Operation that is used to fetch search response.
class KSearchOperation: KServiceOperation {
   
    var searchParams:KSearchOperationParamters?
    
    //Operation Initializer with paramters
    init(searchParameter:KSearchOperationParamters, executeOnService:KService?){
        //Initialize super to use self here
        super.init()
        self.searchParams = searchParameter
        service = executeOnService
        addParameters(searchParameter: searchParameter)
    }
    
    //MARK:- Set Parameters
    func addParameters(searchParameter:KSearchOperationParamters) {
        createRequest()
        addUrlParameters(searchParameter: searchParameter)
    }
    
    func createRequest() {
        request = KRequest(method: .get)
    }
    
    func addUrlParameters(searchParameter: KSearchOperationParamters) {
        var parameterDict:ParametersDict = ParametersDict()
        parameterDict["text"] = searchParameter.query
        parameterDict["page"] = searchParameter.page
        parameterDict["format"] = "json"
        parameterDict["nojsoncallback"] = "1"        
        parameterDict["method"] = kNetworkAdapter.getEndPoint(for: kNetworkAdapter.Of.search)
        request?.urlParams = parameterDict
    }
    
    
    //MARK:- Override Parent
    override func parsedResponse(_ response: KResponse!) -> Any? {
        guard let photos = response.responseJSON()?["photos"] as? Dictionary<String,Any> else {return nil}
        guard let data = try? JSONSerialization.data(withJSONObject: photos, options: .init(rawValue: 2)) else {return nil}
        
        do {
            let decoder = JSONDecoder()
            let photoData = try decoder.decode(PhotosInfo.self, from: data)
            return photoData
        } catch let err {
            print("Error", err)
        }
        return nil
    }
    
}


