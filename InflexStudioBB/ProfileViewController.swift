//
//  ProfileViewController.swift
//  InflexStudioBB
//
//  Created by Barczi Bálint on 2017. 08. 05..
//  Copyright © 2017. Barczi Bálint. All rights reserved.
//

import UIKit
import Firebase
import FBSDKLoginKit

class ProfileViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var genderImageView: UIImageView!
    @IBOutlet weak var birthDateLabel: UILabel!
    @IBOutlet weak var heightField: UITextField!
    @IBOutlet weak var logOutButton: UIButton!
    @IBOutlet weak var deleteUserProfileButton: UIButton!
    
    var ref: DatabaseReference!
    var heightValue: Int?
    

    override func viewDidLoad() {
        super.viewDidLoad()

        setupViews()
        
        getUsersData()
    }
    
    func getUsersData() {
        
        guard let uid = Auth.auth().currentUser?.uid else {return}
        ref = Database.database().reference()
        ref.child("Users").child(uid).child("User data").observe(.childChanged, with: {
            snapshot in
            let value = snapshot.value as? NSDictionary
            let fullName = value?["fullName"] as? String
            let profileImageUrl = value?["profileImage"] as? String
            let birthDay = value?["birthDate"] as? String
            let gender = value?["gender"] as? String
            guard let height = value?["height"] as? String else {return}
            
            let user = User(fullName: fullName!, profileImage: profileImageUrl!, birthDate: birthDay!, sex: gender!, height: height)


                self.setLabels(user!)
                print("User Data: \(user!)")
        })
        
        
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        let ref = Database.database().reference()
        guard let uid = Auth.auth().currentUser?.uid else { return }


        
        let userRef = ref.child("Users").child(uid).child("User data")
        userRef.keepSynced(true)
        ref.child("Users").child(uid).child("User data").observeSingleEvent(of: .value, with: {
            snapshot in
            if let firebaseDic = snapshot.value as? [String: AnyObject] // unwrap it since its an optional
            {
                let fullName = firebaseDic["fullName"] as! String
                let profileImageUrl = firebaseDic["profileImage"] as! String
                let birthDay = firebaseDic["birthDate"] as! String
                let gender = firebaseDic["gender"] as! String
                let height = firebaseDic["height"] as! String
                //let profileImage = firebaseDic["Image"] as! String
                self.fullNameLabel.text = fullName
                self.birthDateLabel.text = birthDay
                
                let url = URL(string: profileImageUrl)
                let data = try? Data(contentsOf: url!)
                
                if let imageData = data {
                    let image = UIImage(data: imageData)
                    self.profileImageView.image = image
                }
                    self.heightField.text = String(height)

                if gender == "male" {
                    self.genderImageView.image = UIImage(named: "male")
                }
                else {
                    self.genderImageView.image = UIImage(named: "female")
                }
                
            }
            else
            {
                print("Error retrieving FrB data")
            }
            
        })
        
        
        
    }

    
    
    
    func setupViews() {
        
        
        // ToolBar
        let toolBar = UIToolbar()
        toolBar.barStyle = .default
        toolBar.isTranslucent = true
        toolBar.tintColor = UIColor.blue
        toolBar.sizeToFit()
        
        // Adding Button ToolBar
        let updateButton = UIBarButtonItem(title: "Kész", style: .done, target: self, action: #selector(self.updateClick))
        let spaceButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolBar.setItems([spaceButton, spaceButton, updateButton], animated: false)
        toolBar.isUserInteractionEnabled = true
        heightField.inputAccessoryView = toolBar
        
        heightField.delegate = self
        
        profileImageView.layer.cornerRadius = profileImageView.frame.height / 2
        profileImageView.layer.masksToBounds = true
     
        logOutButton.layer.cornerRadius = logOutButton.frame.height / 2
        logOutButton.layer.masksToBounds = true
        
        deleteUserProfileButton.layer.cornerRadius = deleteUserProfileButton.frame.height / 2
        deleteUserProfileButton.layer.masksToBounds = true
        
    }
    
    func updateClick() {
        guard let data = Int(heightField.text!) else {return}
        if heightField.text!.isEmpty || data <= 0 || data > 280 {
            let alert = UIAlertController(title: "Hiba történt", message: "Hiányzó vagy nem megfelelő adatokat adtál meg.", preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "Vissza", style: .cancel, handler: nil)
            alert.addAction(cancelAction)
            self.present(alert, animated: true, completion: nil)
        }
        else {
            guard let uid = Auth.auth().currentUser?.uid else {return}
            ref = Database.database().reference()
            let text = heightField.text!
            ref.child("Users").child(uid).child("User data").updateChildValues(["height": text])
            heightField.resignFirstResponder()
        }
        
    }
    

    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {

        if textField == heightField{
            let aSet = NSCharacterSet(charactersIn:"0123456789").inverted
            let compSepByCharInSet = string.components(separatedBy: aSet)
            let numberFiltered = compSepByCharInSet.joined(separator: "")
            return string == numberFiltered
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
    
    
    func setLabels(_ user: User) {

            self.fullNameLabel.text = user.fullName
            self.birthDateLabel.text = user.birthDate
            self.heightField.text = user.height
            let url = URL(string: user.profileImage)
            let data = try? Data(contentsOf: url!)
            
            if let imageData = data {
                let image = UIImage(data: imageData)
                self.profileImageView.image = image
            }
        

        
        print(user.fullName)

        
        
    }
    
    @IBAction func didTapLogoutButton(_ sender: Any) {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "LoginViewController")
        
        let alert = UIAlertController(title: "Biztosan ki szeretnél jelentkezni?", message: "Reméljük hamarosan újra látunk", preferredStyle: .alert)
        
        let signOutAction = UIAlertAction(title: "Kijelentkezés", style: .default) { _ in
            let firebaseAuth = Auth.auth()
            do {
                try firebaseAuth.signOut()
                self.present(vc, animated: true, completion: nil)
            } catch let signOutError as NSError {
                print ("Error signing out: %@", signOutError)
            }
        }
        let cancelAction = UIAlertAction(title: "Mégsem", style: .cancel, handler: nil)
        
        alert.addAction(signOutAction)
        alert.addAction(cancelAction)
        present(alert, animated: true)
        

        
    }

    @IBAction func didTapDeleteProfile(_ sender: Any) {
        let sb = UIStoryboard(name: "Main", bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "LoginViewController") as! ViewController
        guard let uid = Auth.auth().currentUser?.uid else {return}
        let alert = UIAlertController(title: "Biztosan törölni szeretnéd a fiókodat?", message: "Az összes listaelem és minden egyéb adat törlésre kerül", preferredStyle: .alert)
        let userDefaults = UserDefaults.standard
        
        let deleteAction = UIAlertAction(title: "Törlés", style: .default) { _ in
            let user = Auth.auth().currentUser
            
            user?.delete(completion: { (error) in
                if error != nil {
                    print(error!.localizedDescription)
                    let alert2 = UIAlertController(title: "Hiba történt", message: "Jelentkezz be újra a profilod eltávolításához.", preferredStyle: .alert)
                    let action = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
                    alert2.addAction(action)
                    self.present(alert2, animated: true)
                }
                    
                else {
                    let userRef = self.ref.child("Users").child(uid)
                    userRef.removeValue()
                    FBSDKLoginManager().logOut()
                    print("Account deleted")
                    self.present(vc, animated: true, completion: nil)
                    userDefaults.set(false, forKey: "alreadyAUser")
                    userDefaults.set(true, forKey: "firstTimeUsingApp")
                }
            })
        }
        let cancelAction = UIAlertAction(title: "Mégsem", style: .cancel, handler: nil)
        
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        present(alert, animated: true)

    }

}
