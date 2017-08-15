//
//  BmiModel.swift
//  InflexStudioBB
//
//  Created by Barczi Bálint on 2017. 08. 10..
//  Copyright © 2017. Barczi Bálint. All rights reserved.
//

import Foundation
import UIKit
import Firebase

struct BmiModel {
    let ref: DatabaseReference!
    let key: String!
    let date: Date!
    let weight: String!
    let imageUrl: String!
    
}
