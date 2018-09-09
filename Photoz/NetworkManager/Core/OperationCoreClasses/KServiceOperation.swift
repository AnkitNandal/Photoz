//
//  KServiceOperation.swift
//  Photoz
//
//  Created by Ankit Nandal on 09/09/18.
//  Copyright © 2018 Ankit Nandal. All rights reserved.
//

import Foundation

class KServiceOperation: KBaseOperation {
    override var isAsynchronous: Bool { return true }
    override var isExecuting: Bool { return state == .executing }
    override var isFinished: Bool { return state == .finished }
    
    var state = State.ready {
        willSet {
            willChangeValue(forKey: state.keyPath)
            willChangeValue(forKey: newValue.keyPath)
        }
        didSet {
            didChangeValue(forKey: state.keyPath)
            didChangeValue(forKey: oldValue.keyPath)
        }
    }
    
    enum State: String {
        case ready = "Ready"
        case executing = "Executing"
        case finished = "Finished"
        fileprivate var keyPath: String { return "is" + self.rawValue }
    }
    
    override func start() {
        if self.isCancelled {
            state = .finished
        } else {
            state = .ready
            execute()
        }
    }
    
    
    func execute() {
        guard let request = self.request else {return}
        self.service?.execute(request, retry: nil, completionClosure: { (response, error) in
            let parsedResponse = self.parsedResponse(response)
            self.delegate?.dataRecieved(operation: self, data: parsedResponse, isError: false)
            self.state = .finished
        })
    }
}
