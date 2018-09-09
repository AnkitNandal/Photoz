//
//  ApplicationSetup.swift
//  Photoz
//
//  Created by Ankit Nandal on 09/09/18.
//  Copyright © 2018 Ankit Nandal. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import FTLinearActivityIndicator

class ApplicationSetup {
    
    static let shared = ApplicationSetup()
    
    private init() {}
    
    func config() {
        UINavigationBar.appearance().barStyle = .black
        kNetworkAdapter.shared.startNetworkReachabilityObserver()
        UIApplication.configureLinearNetworkActivityIndicatorIfNeeded()
    }
    
    func shouldShowNetworkActivity(_ shouldShow:Bool) {
        DispatchQueue.main.async {
            UIApplication.shared.isNetworkActivityIndicatorVisible = shouldShow
        }
    }
    
    
    
}
