//
//  UIImageViewExtension.swift
//  Photoz
//
//  Created by Ankit Nandal on 09/09/18.
//  Copyright © 2018 Ankit Nandal. All rights reserved.
//

import Foundation
import UIKit

// Declare a global var to produce a unique address as the assoc object handle
var AssociatedObjectHandle: Void?

extension UIImageView{

    func downloadImage(link:String?) {
        guard let imageLink = link else {
            return
        }
        if let url = URL(string: imageLink){
            //set associated id to object to check its validity
            self.associatedID = url
            ImageDownloaderManager.shared.downloadImage(link: url, completionBlock: {[weak self] (image,url) in
                DispatchQueue.main.async {
                    if self?.associatedID == url{
                        self?.contentMode = .scaleAspectFill
                        self?.image = image
                        self?.setNeedsDisplay()
                    } else {
                       // Different Image
                    }
                }
            })
        } else {
            //error
        }
    }
    
    
    func showDownloadedImage(link:String?) {
        guard let imageLink = link , let url = URL(string: imageLink) else {
            return
        }
        self.image = ImageDownloaderManager.shared.getDownloadedImage(link: url)
    }
    
    // Attach URL to runtime to map UIImageview
    var associatedID:URL {
        get{
            return objc_getAssociatedObject(self, &AssociatedObjectHandle) as! URL
        } set{
            objc_setAssociatedObject(self, &AssociatedObjectHandle, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}
