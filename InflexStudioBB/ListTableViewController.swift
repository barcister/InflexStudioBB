//
//  ListTableViewController.swift
//  InflexStudioBB
//
//  Created by Barczi Bálint on 2017. 08. 10..
//  Copyright © 2017. Barczi Bálint. All rights reserved.
//

import UIKit
import Firebase

class ListTableViewController: UITableViewController, UIGestureRecognizerDelegate {
    
    var activityIndicator: UIActivityIndicatorView!
    
    var dataModel = [BmiModel]()
    var userHasHeightValue: Bool = false
    var ref: DatabaseReference!
    var heightValue: Double?
    var bmiValue: Double?
    var values = [Double]()
    let newView = UIView()
    var imageView = UIImageView()
    let cellId = "cell"
    var tapGesture = UITapGestureRecognizer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(ListTableViewController.handleTap(_:)))
        newView.addGestureRecognizer(tapGesture)
        if is3DTouchAvailable(){
            let gestureRec = DeepPressGestureRecognizer(target: self, action: #selector(ListTableViewController.deepPressHandler(_:)), threshold: 0.75)
            tableView.addGestureRecognizer(gestureRec)
        }
        else {
            let longPressGesture:UILongPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(ListTableViewController.handleLongPress(_:)))
            self.tableView.addGestureRecognizer(longPressGesture)
        }
        
        
            guard let uid = Auth.auth().currentUser?.uid else {return}
            self.ref = Database.database().reference()
            self.ref.child("Users").child(uid).child("WeightData").queryOrderedByKey().observe(.childAdded, with: {
                snapshot in
                if let firebaseDic = snapshot.value as? [String: AnyObject] // unwrap it since its an optional
                {
                    let weight = firebaseDic["weight"] as! String
                    let dateString = firebaseDic["uploadDate"] as! String
                    let imageUrl = firebaseDic["imageUrl"] as! String
                    let date = self.GetDateFromString(DateStr: dateString)
                    let ref = snapshot.ref
                    let key = snapshot.key
                    let newData = BmiModel(ref: ref, key: key, date: date, weight: weight, imageUrl: imageUrl)
                    self.dataModel.insert(newData, at: 0)
                    print(self.dataModel)
                    self.tableView.backgroundView = nil
                    self.do_table_refresh()
                }

            })
            print(self.dataModel)
            print(self.dataModel.count)
            
            }
    
    
    func deepPressHandler(_ value: DeepPressGestureRecognizer)
    {
        if value.state == UIGestureRecognizerState.began
        {
            let alert = UIAlertController(title: "Biztosan eltávolítod az elemet?", message: "A művelet nem vonható vissza", preferredStyle: .alert)
            guard let uid = Auth.auth().currentUser?.uid else {return}
            
            let location = value.location(in: self.view)
            if let indexPath = self.tableView.indexPathForRow(at: location) {
                let deleteAction = UIAlertAction(title: "Törlés", style: .destructive, handler: { (action) in
                    let data = self.dataModel[indexPath.row]
                    let id = data.key
                    self.dataModel.remove(at: indexPath.row)
                    self.tableView.deleteRows(at: [indexPath], with: .fade)
                    self.ref.child("Users").child(uid).child("WeightData").child(id!).removeValue()
                    self.checkForData()
                })
                let cancelAction = UIAlertAction(title: "Mégsem", style: .cancel, handler: nil)
                alert.addAction(deleteAction)
                alert.addAction(cancelAction)
                self.present(alert, animated: true, completion: nil)
        }

        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        userHasHeightValueSet()
        checkForData()
        print(dataModel)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! ListItemTableViewCell
        
        newView.frame = CGRect(x: 0, y: cell.frame.origin.y, width: self.view.frame.width - 10, height:  self.view.frame.height / 2.5 )
        imageView = UIImageView(frame: CGRect(x: 5, y: cell.frame.origin.y, width: self.view.frame.width - 10, height: self.view.frame.height / 2.5))
        imageView.contentMode = .scaleAspectFill
        imageView.image = cell.customImageView.image
        imageView.layer.cornerRadius = newView.frame.height / 8
        imageView.layer.masksToBounds = true
        newView.addSubview(imageView)
        newView.bringSubview(toFront: imageView)
        newView.backgroundColor = .clear
        self.view.addSubview(newView)
        self.view.bringSubview(toFront: newView)
        print(indexPath.row)
       

        

    }
    
    func handleTap(_ recognizer: UIGestureRecognizer) {
        self.imageView.image = nil
        self.imageView.removeFromSuperview()
        self.newView.removeFromSuperview()
        
    }
    

    func checkForData() {
        
        let messageLabel = UILabel(frame: CGRect(x: 0, y: 0, width: view.bounds.size.width, height: view.bounds.size.height))
        if dataModel.count == 0 && userHasHeightValue == true {
            messageLabel.text = "Vigyél föl új mérést!"
            messageLabel.textColor = UIColor.black
            messageLabel.numberOfLines = 0
            messageLabel.textAlignment = .center
            messageLabel.font = UIFont.systemFont(ofSize: 14, weight: 10)
            messageLabel.sizeToFit()
            tableView.backgroundView = messageLabel
            tableView.separatorStyle = UITableViewCellSeparatorStyle.none
            print(Auth.auth().currentUser!.uid)
        }
            
        else if userHasHeightValue == false {
            messageLabel.text = "Add meg a magasságod!"
            messageLabel.textColor = UIColor.black
            messageLabel.numberOfLines = 0
            messageLabel.textAlignment = .center
            messageLabel.font = UIFont.systemFont(ofSize: 14, weight: 10)
            messageLabel.sizeToFit()
            tableView.backgroundView = messageLabel
            tableView.separatorStyle = UITableViewCellSeparatorStyle.none
        }
        else if dataModel.count > 0{
            tableView.backgroundView = nil
        }
    }
    
    func do_table_refresh()
    {
        DispatchQueue.main.async(execute: {
            self.tableView.reloadData()
            //self.retrieveHeight(data: dataModel)
            return
        })
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows

        
        return dataModel.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! ListItemTableViewCell
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        dataModel.sort(by: { $0.date.compare($1.date) == .orderedDescending})
        let modelData = dataModel[indexPath.row]
        
        //print(date)
        retrieveHeight(cell: cell, indexpath: indexPath)
        
        
        let weight = modelData.weight
        
        if let customImageUrl = modelData.imageUrl {
            cell.customImageView.loadImageUsingCacheWithUrlString(urlString: customImageUrl)
        }
        
        cell.weightLabel.text = "\(weight!)kg"
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy.MM.dd"
        let dateString = dateFormatter.string(from: modelData.date!)
        cell.dateLabel.text = "Dátum: \(dateString)"


        return cell
    }
    
    func calculateBMI(massInKilograms mass: Double, heightInCentimeters height: Double) -> Double{
        return mass / ((height * height) / 10000)
    }
    
    func userHasHeightValueSet() {
        let ref = Database.database().reference()
        let uid = Auth.auth().currentUser?.uid
        print(uid!)
        ref.child("Users").child(uid!).child("User data").observeSingleEvent(of: .value, with: {
            snapshot in
            if let firebaseDic = snapshot.value as? [String: AnyObject] // unwrap it since its an optional
            {
                
                let height = firebaseDic["height"] as! String
                if height == "" || height == "0"{
                    self.userHasHeightValue = false
                }
                else {
                    self.userHasHeightValue = true
                }
            }
            else
            {
                print("Error retrieving FrB data")
            }
            
            
        })
        
    }
    
    func retrieveHeight(cell: ListItemTableViewCell, indexpath: IndexPath) {
        let ref = Database.database().reference()
        let uid = Auth.auth().currentUser?.uid
        let data = dataModel[indexpath.row]
        
        
        let userRef = ref.child("Users").child(uid!).child("User data")
        userRef.keepSynced(true)
        ref.child("Users").child(uid!).child("User data").observeSingleEvent(of: .value, with: {
            snapshot in
            if let firebaseDic = snapshot.value as? [String: AnyObject] // unwrap it since its an optional
            {
                
                let height = firebaseDic["height"] as! String
                print("User height: \(height)")
                self.heightValue = Double(height)
                print(self.heightValue!)
                let weight = Double(data.weight)
                self.bmiValue = self.calculateBMI(massInKilograms: weight!, heightInCentimeters: self.heightValue!)
                self.values.insert(self.bmiValue!, at: 0)
                print(self.bmiValue!)
                cell.bmiLabel.text = String(format: "%.2f", self.bmiValue!)
                
            }
            else
            {
                print("Error retrieving FrB data")
            }
            
            
        })
        
        
        
        
    }
    
    
    func handleLongPress(_ longPressGestureRecognizer: UILongPressGestureRecognizer) {
        let alert = UIAlertController(title: "Biztosan eltávolítod az elemet?", message: "A művelet nem visszavonható", preferredStyle: .alert)
        guard let uid = Auth.auth().currentUser?.uid else {return}

            if longPressGestureRecognizer.state == UIGestureRecognizerState.began {
                longPressGestureRecognizer.minimumPressDuration = 1.0
                let touchPoint = longPressGestureRecognizer.location(in: self.view)
                if let indexPath = self.tableView.indexPathForRow(at: touchPoint) {
                    let deleteAction = UIAlertAction(title: "Törlés", style: .destructive, handler: { (action) in
                        let data = self.dataModel[indexPath.row]
                        let id = data.key
                        self.dataModel.remove(at: indexPath.row)
                        self.tableView.deleteRows(at: [indexPath], with: .fade)
                        self.ref.child("Users").child(uid).child("WeightData").child(id!).removeValue()
                        self.checkForData()
                    })
                    let cancelAction = UIAlertAction(title: "Mégsem", style: .cancel, handler: nil)
                    alert.addAction(deleteAction)
                    alert.addAction(cancelAction)
                    self.present(alert, animated: true, completion: nil)
                }
                
            }
        


    }
        
        func is3DTouchAvailable() -> Bool
        {
            return self.traitCollection.forceTouchCapability == UIForceTouchCapability.available
        }
 
    @IBAction func unwindToVC1(segue:UIStoryboardSegue) { }

    func GetDateFromString(DateStr: String)-> Date
    {
        let calendar = NSCalendar(identifier: NSCalendar.Identifier.gregorian)
        let DateArray = DateStr.components(separatedBy: " ")
        let components = NSDateComponents()
        components.year = Int(DateArray[0])!
        components.month = Int(DateArray[1])!
        components.day = Int(DateArray[2])! + 1
        let date = calendar?.date(from: components as DateComponents)

        
        return date!
    }
    
}

extension ListItemTableViewCell {
    
    var indexPath: IndexPath? {
        return (superview as? UITableView)?.indexPath(for: self)
    }
}
