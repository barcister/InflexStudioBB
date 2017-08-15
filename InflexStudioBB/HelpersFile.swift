//
//  HelpersFile.swift
//  InflexStudioBB
//
//  Created by Barczi Bálint on 2017. 08. 15..
//  Copyright © 2017. Barczi Bálint. All rights reserved.
//

import Foundation
import UIKit

let imageCache = NSCache< AnyObject, AnyObject>()

extension UIImageView {
    
    
    func loadImageUsingCacheWithUrlString(urlString: String) {
        
        self.image = nil
        
        //check cache for image first
        if let cachedImage = imageCache.object(forKey: urlString as AnyObject) as? UIImage {
            self.image = cachedImage
            return
        }
        
        //otherwise fire off a new download
        let url = NSURL(string: urlString)
        URLSession.shared.dataTask(with: url! as URL, completionHandler: { (data, response, error) in
            
            //download hit an error so lets return out
            if error != nil {
                print(error!)
                return
            }
            
            DispatchQueue.main.async(execute: {
                
                if let downloadedImage = UIImage(data: data!) {
                    imageCache.setObject(downloadedImage, forKey: urlString as AnyObject)
                    
                    self.image = downloadedImage
                }
            })
            
        }).resume()
    }
}
extension UIView {
    
    func shake() {
        let animation = CABasicAnimation(keyPath: "position")
        animation.duration = 0.07
        animation.repeatCount = 3
        animation.autoreverses = true
        animation.fromValue = CGPoint(x: self.center.x - 10, y: self.center.y)
        //animation.fromValue = NSValue(CGPoint: CGPoint(x: self.center.x - 10, y: self.center.y))
        animation.toValue = CGPoint(x: self.center.x + 10, y: self.center.y)
        //animation.toValue = NSValue(CGPoint: CGPoint(x: self.center.x + 10, y:  self.center.y))
        self.layer.add(animation, forKey: "position")
    }
    func addBottomLayerToTheView(view:UIView, color: CGColor)
    {
        let bottomBorder = CALayer()
        bottomBorder.frame = CGRect(x: 0.0, y: view.frame.size.height - 1, width: view.frame.size.width, height: 1.0)
        bottomBorder.backgroundColor = color
        bottomBorder.opacity = 1.0
        view.layer.addSublayer(bottomBorder)
    }
    
}
