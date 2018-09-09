//
//  kNetworkAdapter.swift
//  Photoz
//
//  Created by Ankit Nandal on 09/09/18.
//  Copyright © 2018 Ankit Nandal. All rights reserved.
//

import UIKit
import Alamofire
import NotificationBannerSwift

/**
 Network Request Completion Block
 */
typealias NACompletionBlock = (_:Any?,_ isError:Bool) -> ()


// MARK:- Network Adapter Class
class kNetworkAdapter: NSObject,KOperationDelegate {
   
    /// Shared instance to be used for specific purposed only.
    /// ##Singletons should not be used too much##.
    
    static let shared = kNetworkAdapter()
    
    // Banner used to show n/w connection status
    var networkConnectionBanner:StatusBarNotificationBanner?
    
    
    // We should use our Server for host to listen to reachability
    let reachabilityManager = Alamofire.NetworkReachabilityManager(host: "www.google.com")
    
    //Service Completion Block 
    var serviceCompletionBlock:NACompletionBlock?
    
    // Holds network Operation Maganer class instance that schedules and executes n/w operations.
    let networkOperationMaganer = KNetworkOperationMaganer.shared
    
    // MARK:- Photo Search API
    func getPhotosSearchResult(searchTerm:String,pageNo:Int, completionBlock:@escaping NACompletionBlock) {
        let searchParams = KSearchOperationParamters(query: searchTerm, pageNumber: pageNo)
        let searchOperation = KSearchOperation(searchParameter: searchParams,executeOnService:GetService.getService())
        searchOperation.delegate = self
        serviceCompletionBlock = completionBlock
        networkOperationMaganer.enqueOperation(op: searchOperation)
    }
    
    
    //MARK:- N/W Response Delegate
    func dataRecieved(operation: KBaseOperation, data: Any?, isError: Bool) {
        serviceCompletionBlock?(data,isError)
    }
    
    
    deinit {
        print("N/W Class Deinit")
    }
}

// Shared instance of n/w Adapter Calls
extension kNetworkAdapter {
    
    // Network Availability Listner
    func startNetworkReachabilityObserver() {
        
        reachabilityManager?.listener = { status in
            switch status {
                
            case .notReachable:
                print("The network is not reachable")
                self.networkDisconnected()
            case .unknown :
                print("It is unknown whether the network is reachable")
                
            case .reachable(.ethernetOrWiFi):
                print("The network is reachable over the WiFi connection")
                self.networkReConnected()
                
            case .reachable(.wwan):
                print("The network is reachable over the WWAN connection")
                self.networkReConnected()
            }
        }
        
        // start listening
        reachabilityManager?.startListening()
    }
    
    func networkDisconnected() {
        networkConnectionBanner = StatusBarNotificationBanner(title: ConfigName.Alert.noNetwork, style: .warning)
        networkConnectionBanner?.show()
    }
    
    func networkReConnected() {
        guard networkConnectionBanner != nil else {return}
        networkConnectionBanner?.dismiss()
        networkConnectionBanner = nil
    }
}


// It handles n/w operations that are to be scheduled.
class KNetworkOperationMaganer {
    
    static let shared = KNetworkOperationMaganer()
    
    let maxConcurrentOperations = 3
    
    let operationQueue:OperationQueue
    
    init() {
        self.operationQueue = OperationQueue()
        self.operationQueue.maxConcurrentOperationCount = maxConcurrentOperations
    }
    
    func enqueOperation(op:KBaseOperation) {
        self.operationQueue.addOperation(op)
    }
    
}
