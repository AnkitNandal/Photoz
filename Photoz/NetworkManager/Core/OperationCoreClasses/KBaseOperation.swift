//
//  KBaseOperation.swift
//  Photoz
//
//  Created by Ankit Nandal on 09/09/18.
//  Copyright © 2018 Ankit Nandal. All rights reserved.
//

import Foundation

protocol KOperationDelegate {
    func dataRecieved(operation:KBaseOperation,data:Any?,isError:Bool)
}

class KBaseOperation: Operation {
    var service:KService?
    var request:KRequest?
    var delegate:KOperationDelegate?
    
    func parsedResponse(_ response: KResponse!) -> Any? {
        return nil
    }
    
    deinit {
        print("Operation Deinit")
    }
}
