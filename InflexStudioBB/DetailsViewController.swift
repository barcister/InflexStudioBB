//
//  DetailsViewController.swift
//  InflexStudioBB
//
//  Created by Barczi Bálint on 2017. 08. 15..
//  Copyright © 2017. Barczi Bálint. All rights reserved.
//

import UIKit

class DetailsViewController: UIViewController {
    
    @IBOutlet weak var selfieImageView: UIImageView!
    var selectedImage: UIImage

    override func viewDidLoad() {
        super.viewDidLoad()

      selfieImageView.image = selectedImage
    }



    

}
