//
//  NewDataViewController.swift
//  InflexStudioBB
//
//  Created by Barczi Bálint on 2017. 08. 09..
//  Copyright © 2017. Barczi Bálint. All rights reserved.
//

import UIKit
import Firebase

class NewDataViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate,
UINavigationControllerDelegate {
    
    @IBOutlet weak var datePickerField: UITextField!
    @IBOutlet weak var weightPickerField: UITextField!
    @IBOutlet weak var customImageView: UIImageView!
    @IBOutlet weak var uploadButton: UIButton!
    
    let imagePicker = UIImagePickerController()
    
    var ref: DatabaseReference!
    var storageRef: StorageReference!

    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        
        
    }
    
    func handleTap() {
        let alert = UIAlertController(title: "Válaszd ki a feltöltendő fotót", message: "A következő forrásokból tudsz választani", preferredStyle: .actionSheet)
        let cameraAction = UIAlertAction(title: "Kamera", style: .default) { _ in
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
                let imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                imagePicker.sourceType = UIImagePickerControllerSourceType.camera;
                imagePicker.allowsEditing = false
                self.present(imagePicker, animated: true, completion: nil)
            }
            else {
                print("Not available")
            }
        }
        let libraryAction = UIAlertAction(title: "Fotókönyvtár", style: .default) { _ in
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary) {
                let imagePicker = UIImagePickerController()
                imagePicker.delegate = self
                imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary
                imagePicker.allowsEditing = false
                self.present(imagePicker, animated: true, completion: nil)
            }
        }
        let cancelAction = UIAlertAction(title: "Mégsem", style: .cancel, handler: nil)
        alert.addAction(cameraAction)
        alert.addAction(libraryAction)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
        
        
        
    }
    
    
    func setupViews() {
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.handleTap))
        customImageView.isUserInteractionEnabled = true
        customImageView.addGestureRecognizer(tapGesture)
        customImageView.layer.cornerRadius = customImageView.frame.height / 2
        customImageView.layer.masksToBounds = true
        uploadButton.layer.cornerRadius = uploadButton.frame.height / 2
        uploadButton.layer.masksToBounds = true
        datePickerField.delegate = self
        weightPickerField.delegate = self
        pickerSetup()
        imagePicker.delegate = self
        ref = Database.database().reference()
        let blueColor = UIColor.blue.cgColor
        weightPickerField.addBottomLayerToTheView(view: weightPickerField, color: blueColor)
        datePickerField.addBottomLayerToTheView(view: datePickerField, color: blueColor)
        
        
    }
    
    func pickerSetup() {
        var picker = UIDatePicker()
        picker = UIDatePicker()
        datePickerField.inputView = picker
        picker.addTarget(self, action: #selector(self.handleDatePicker), for: UIControlEvents.valueChanged)
        picker.datePickerMode = .date
        

    }
    func handleDatePicker(_ picker: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy MM dd"
        datePickerField.text = dateFormatter.string(from: picker.date)
        datePickerField.resignFirstResponder()
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if textField == weightPickerField{
            let aSet = NSCharacterSet(charactersIn:"0123456789").inverted
            let compSepByCharInSet = string.components(separatedBy: aSet)
            let numberFiltered = compSepByCharInSet.joined(separator: "")
            return string == numberFiltered
        }
        else if textField == datePickerField {
            return false
        }
        
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
    
    
    
    //MARK: - Delegates
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        var image = info[UIImagePickerControllerOriginalImage] as! UIImage
        customImageView.image = image
        self.dismiss(animated: true, completion: nil)
    }
    

    @IBAction func didTapUploadButton(_ sender: Any) {
        
        if datePickerField.text == "" || weightPickerField.text == "" {
            let alert = UIAlertController(title: "Hiba történt", message: "Nem töltötted ki az adatokat. Töltsd ki őket és próbálkozz újra!", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Vissza", style: .default, handler: nil)
            alert.addAction(okAction)
            self.present(alert, animated: true, completion: nil)
        }
        else {
            guard let uid = Auth.auth().currentUser?.uid else {return}
            let storageReference = Storage.storage().reference()
            let imageName = "displayImage.png"
            var urlForImage = ""
            let uploadDate = datePickerField.text
            let weight = weightPickerField.text
            let data = storageReference.child(uid).child("Pictures").child(uploadDate!).child(imageName)
            
            if let imageData = UIImagePNGRepresentation(self.customImageView.image!)  {
                data.putData(imageData, metadata: nil, completion: { (metadata, error) in
                    if let error = error {
                        print(error)
                        return
                    }
                    
                    if let imageUrl = metadata?.downloadURL()?.absoluteString {
                        
                        urlForImage = imageUrl
                        print("Item successfully uploaded")
                        
                    }

                })
                self.ref.child("Users").child(uid).child("WeightData").childByAutoId().setValue(["weight": weight, "uploadDate": uploadDate!,"imageUrl": urlForImage])
                let vc = ListTableViewController()
                vc.viewWillAppear(true)
                
                self.performSegue(withIdentifier: "unwindToVC1", sender: self)
            }
        }


        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }



}
