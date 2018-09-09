//
//  PhotosInfo.swift
//  Photoz
//
//  Created by Ankit Nandal on 09/08/18.
//  Copyright © 2018 Ankit Nandal. All rights reserved.
//

import Foundation

struct PhotosInfo: Codable {
    var page,pages,perpage: Int?
    var total:String?
    var results: [PhotoList]?
    
    enum CodingKeys: String, CodingKey {
        case results = "photo"
        case page
        case pages
        case perpage
        case total
    }
}

struct PhotoList: Codable {
    let farm: Int?
    let id,title,owner,secret,server: String?
    let ispublic: Int?
    let isfriend: Int?
    let isfamily: Int?
}

extension PhotoList {
    var imagePath:String?{
        if let farmId = farm , let serverId = server, let photoId = id , let secterId = secret {
            return "https://farm\(farmId).staticflickr.com/\(serverId)/\(photoId)_\(secterId)_m.jpg"
        }
        return nil
    }
}
