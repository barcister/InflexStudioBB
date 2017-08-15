//
//  File.swift
//  InflexStudioBB
//
//  Created by Barczi Bálint on 2017. 08. 04..
//  Copyright © 2017. Barczi Bálint. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import FBSDKLoginKit

class User: NSObject {
    
    //MARK: Properties
    
    var fullName: String
    var profileImage: String
    var birthDate: String
    var sex: String
    var height: String
    
    //MARK: Initialization
    
    init?(fullName: String, profileImage: String, birthDate: String, sex: String, height: String) {
        
        
        
        self.fullName = fullName
        self.profileImage = profileImage
        self.birthDate = birthDate
        self.sex = sex
        self.height = height
        
    }
    

    
    
}
