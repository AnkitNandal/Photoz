//
//  ImageDownloader.swift
//  Photoz
//
//  Created by Ankit Nandal on 09/09/18.
//  Copyright © 2018 Ankit Nandal. All rights reserved.
//

import Foundation
import UIKit

typealias IDCompletionHandler = (UIImage?,URL?)-> ()

// Image Download Manager
class ImageDownloaderManager {
    
    static var  shared = ImageDownloaderManager()
    
    var imageSource : Dictionary<URL,ImagesDownloader> = [:]
    let cache = NSCache<NSString, UIImage>()
    
    
    private init() {}
    
    func downloadImage(link:URL,completionBlock:@escaping IDCompletionHandler) {
        
        //Check:
        // 1. Image Exists in Cache
        // 2. If image is being Downloaded
        //3. Download Image
        if let image = self.getDownloadedImage(link: link) {
            completionBlock(image, link)
        } else if let _ = imageSource[link]?.isDownloading{
            //print("Image is being downloaded)")
            return
        } else {
            //Initiate new download and keep it
            let downloader = ImagesDownloader(link: link)
            //Callback once image Downloaded
            downloader.downloded = {[weak self]  imageUrl in
                if let imageURL = imageUrl {
                    guard let image = self?.imageSource[imageURL]?.image else {return}
                    let key = imageURL.absoluteString.md5() as NSString
                    self?.cache.setObject(image, forKey: key)
                    completionBlock(image, imageUrl)
                    self?.imageSource[imageURL] = nil
                } else {
                    guard let url = imageUrl else {return}
                    self?.imageSource[url] = nil
                }
            }
            imageSource[link] = downloader
        }
    }
    
    func getDownloadedImage(link:URL) -> UIImage?{
        let key = link.absoluteString.md5()
        if let image = cache.object(forKey: key as NSString) {
            return image
        }
        return nil
    }
}


class ImagesDownloader {
    var isDownloading:Bool = false
    var image:UIImage?
    var url:URL?
    var sessionTask = URLSessionTask()
    var downloded:((URL?) -> ())?
    
    init(link:URL) {
        self.isDownloading = true
        self.downloadImage(link: link)
    }
    
    private  func downloadImage(link:URL){
        print("Downloading Starts")
        sessionTask = URLSession.shared.dataTask(with: link) {[weak self] (data, response, error) in
            guard let strongSelf = self else {return}
            if error == nil && data != nil{
                guard let imageData = data else{return}
                guard let imageDataExists = UIImage(data:imageData) else{return}
                guard let imageURL = response?.url else{return}
                strongSelf.url = imageURL
                strongSelf.image = strongSelf.decodeImage(oldImage: imageDataExists)
                strongSelf.downloded?(imageURL)
                strongSelf.isDownloading = false
            } else {
                strongSelf.downloded?(nil)
            }
        }
        sessionTask.resume()
    }
    
    // Render UIIMage on CG so that It will ba cached on background thread
    func decodeImage(oldImage:UIImage) -> UIImage{
        let width = oldImage.size.width
        let height = oldImage.size.height
        var newImage:UIImage
        UIGraphicsBeginImageContextWithOptions(CGSize(width: width, height: height), true, 0)
        oldImage.draw(in: CGRect(x: 0, y: 0, width: width, height: height))
        newImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return newImage
    }
}
