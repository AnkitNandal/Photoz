//
//  CommonMethods.swift
//  Photoz
//
//  Created by Ankit Nandal on 13/08/18.
//  Copyright © 2018 Ankit Nandal. All rights reserved.
//

import UIKit

func print(_ object: Any) {
    #if DEBUG
        Swift.print(object)
    #endif
}


func getRandomColorHexs(range: ClosedRange<Int> = 757575...757582) -> Int {
    let min = range.lowerBound
    let max = range.upperBound
    return Int(arc4random_uniform(UInt32(1 + max - min))) + min
}


