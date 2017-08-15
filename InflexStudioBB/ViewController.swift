//
//  ViewController.swift
//  InflexStudioBB
//
//  Created by Barczi Bálint on 2017. 08. 04..
//  Copyright © 2017. Barczi Bálint. All rights reserved.
//

import UIKit
import Firebase
import FBSDKLoginKit

class ViewController: UIViewController {
    
    var alreadyAUser: Bool = false
    
    @IBOutlet weak var facebookLoginButton: UIButton!
    
    var ref: DatabaseReference!
    var value2: String!
    var heightSet: Bool = false
    let userDefaults = UserDefaults.standard

    override func viewDidLoad() {
        super.viewDidLoad()
        
        facebookLoginButton.layer.cornerRadius = facebookLoginButton.frame.height / 2
        facebookLoginButton.layer.masksToBounds = true
        
        ref = Database.database().reference()
        checkUserState()
        facebookLoginButton.addTarget(self, action: #selector(facebookLogin), for: .touchUpInside)
    }
    
    func checkUserState() {
        
        Auth.auth().addStateDidChangeListener { (auth, user) in
            if user != nil {
                if self.userDefaults.bool(forKey: "firstTimeUsingApp") == true {
                    let sb = UIStoryboard(name: "Main", bundle: nil)
                    let vc = sb.instantiateViewController(withIdentifier: "tabBarController") as! UITabBarController
                    vc.selectedIndex = 1
                    self.present(vc, animated: true, completion: nil)
                }
                else {
                    self.performSegue(withIdentifier: "loggedIn", sender: self)
                }
                

                print("Logged in")
            }
            else {
                print("Not logged in")
            }
        }

        
    }
    
    func facebookLogin () {
        let fbLoginManager = FBSDKLoginManager()
        fbLoginManager.logIn(withReadPermissions: ["public_profile", "email", "user_birthday"], from: self) { (result, error) in
            if let error = error {
                print("Failed to login: \(error.localizedDescription)")
                return
            }
            
            guard let accessToken = FBSDKAccessToken.current() else {
                print("Failed to get access token")
                return
            }
            
            let credential = FacebookAuthProvider.credential(withAccessToken: accessToken.tokenString)
            

            
            
            Auth.auth().signIn(with: credential, completion: { (user, error) in
                if let error = error {
                    print("Login error: \(error.localizedDescription)")
                    let alertController = UIAlertController(title: "Login Error", message: error.localizedDescription, preferredStyle: .alert)
                    let okayAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                    alertController.addAction(okayAction)
                    self.present(alertController, animated: true, completion: nil)
                    
                    return
                }
                
                
                
                self.setUserData()

                
                self.checkUserState()
                
            })
            
        }
    }
    
    public func setUserData() {
        
        var ref: DatabaseReference!
        ref = Database.database().reference()
        
        
        
        
        if userDefaults.bool(forKey: "alreadyAUser") == true  {
            print("Already a user")
            alreadyAUser = true
            userDefaults.set(false, forKey: "firstTimeUsingApp")
            
        }
        else if userDefaults.bool(forKey: "alreadyAUser") == false{
            FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name,first_name, last_name , email, birthday, gender"]).start(completionHandler: { (connection, result, error) -> Void in
                if (error == nil){
                    let fbDetails = result as! NSDictionary
                    print(fbDetails)
                    let lastName = fbDetails["last_name"] as! String
                    let firstName = fbDetails["first_name"] as! String
                    let profileImage = fbDetails["id"] as! String
                    let gender = fbDetails["gender"] as! String
                    let birthDay = fbDetails["birthday"] as! String
                    let profileImageUrl = "https://graph.facebook.com/\(profileImage)/picture?width=640&height=640"
                    let fullName = "\(lastName) \(firstName)"
                    guard let uid = Auth.auth().currentUser?.uid else {return}
                    print("Uid of user: \(uid)")
                    ref.child("Users").child(uid).child("User data").setValue(["fullName": fullName, "profileImage": profileImageUrl, "birthDate": birthDay, "gender": gender, "height": "0"])
                    let sb = UIStoryboard(name: "Main", bundle: nil)
                    let vc = sb.instantiateViewController(withIdentifier: "tabBarController") as! UITabBarController
                    vc.selectedIndex = 1
                    self.present(vc, animated: true, completion: nil)
                    self.userDefaults.set(true, forKey: "alreadyAUser")
                    self.userDefaults.set(false, forKey: "firstTimeUsingApp")
                    
                }else{
                    print(error?.localizedDescription ?? "Not found")
                }
            })
        }
        print(alreadyAUser)
        
        

    }
    
    func userIsAlreadyRegistered()  -> Bool {
        
        var ref: DatabaseReference!
        ref = Database.database().reference()
        let uidValue = Auth.auth().currentUser?.uid
            
            var name: String!
            
            ref.child("Users").child(uidValue!).child("User data").observeSingleEvent(of: .value, with: {
                snapshot in
                if let firebaseDic = snapshot.value as? [String: AnyObject] {
                    let fullName = firebaseDic["fullName"] as! String
                    print("User Full name\(fullName)")
                    name = fullName
                    print("User Full name, second value: \(name)")
                }
            })
            if name != "" {
                print("User's name: True")
                print(name)
                return true
            }
            else {
                print("User's name: False")
                print(name)
                return false
        }


            
        
        

        
    }
    
    public func heightIsSet() -> Bool {
        
        let uid = Auth.auth().currentUser?.uid
            ref = Database.database().reference()
            ref.child("Users").child(uid!).child("User data").observe(.value, with: {
                snapshot in
                var value = snapshot.value as? NSDictionary

                let height = value?["height"] as? String
                
                if height == "" {
                    self.heightSet = false
                }
                else {
                    self.heightSet = true
                }
            })
        
        if heightSet == false {
            return false
        }
        else {
            return true
        }
        
        

        
    }



}

