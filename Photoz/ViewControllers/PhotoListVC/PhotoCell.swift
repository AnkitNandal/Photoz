//
//  PhotoCell.swift
//  Photoz
//
//  Created by Ankit Nandal on 09/09/18.
//  Copyright © 2018 Ankit Nandal. All rights reserved.
//

import Foundation
import UIKit

class PhotoCell: UICollectionViewCell {
    
    @IBOutlet weak var icon: UIImageView!
    var data:PhotoList?
    override func awakeFromNib() {
        super.awakeFromNib()
        let colorHex = getRandomColorHexs()
        self.backgroundColor = UIColor(hex:"\(colorHex)")
    }
    
    override func prepareForReuse() {
        self.icon.image = nil
        self.data = nil
    }
    
    func config(dataSource:PhotoList) {
        self.data = dataSource
    }
    
    func showDownloadedImage() {
        self.icon.showDownloadedImage(link: data?.imagePath)
    }
    
    func downloadImage() {
        self.icon.downloadImage(link: data?.imagePath)
    }
    
}

extension PhotoCell {
    static let identifier = "photoCell"
}
