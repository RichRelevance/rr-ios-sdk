//
//  RCHAccountViewController.swift
//  RichRelevanceSDKDemo
//
//  Created by Ariana Antonio on 10/6/16.
//  Copyright © 2016 Raizlabs Inc. All rights reserved.
//

import UIKit

class RCHAccountViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet var accountTableView: UITableView!
    @IBOutlet var userIDTextField: UITextField!
    @IBOutlet var modalView: UIView!
    @IBOutlet var saveUserButton: UIButton!
    @IBOutlet var userCellLabel: UILabel!
    
    var userIDArray: [String]?
    var currentUser: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.tintColor = UIColor.white
        saveUserButton.layer.cornerRadius = 4
        modalView.isHidden = true
        
        guard let userIDArray = UserDefaults.standard.object(forKey: kRCHUserDefaultKeyUserIDs) as? [String] else {
            self.userIDArray = []
            return
        }
        self.userIDArray = userIDArray
        currentUser = UserDefaults.standard.string(forKey: kRCHUserDefaultKeyCurrentUser)
    }
    
    // MARK: Actions
    
    @IBAction func addUserSelected(_ sender: AnyObject) {
        modalView.isHidden = false
    }
    
    @IBAction func saveUserSelected(_ sender: AnyObject) {
        modalView.isHidden = true
        view.endEditing(true)
        guard let newUser = userIDTextField.text else {
            return
        }
        saveNewUser(withUser: newUser)
    }
    
    @IBAction func dismissModalSelected(_ sender: AnyObject) {
        modalView.isHidden = true
        view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        return true
    }
    
    func saveNewUser(withUser newUser: String) {
        let mutableUserArray: NSMutableArray = []
        if let userArray = UserDefaults.standard.object(forKey: kRCHUserDefaultKeyUserIDs) as? [String] {
            mutableUserArray.addObjects(from: userArray)
        }
        mutableUserArray.add(newUser)
        
        UserDefaults.standard.set(mutableUserArray, forKey: kRCHUserDefaultKeyUserIDs)
        UserDefaults.standard.synchronize()
        
        userIDArray?.insert(newUser, at: 0)
        switchCurrentUser(withUser: newUser)
    }
    
    func switchCurrentUser(withUser user: String) {
        UserDefaults.standard.set(user, forKey: kRCHUserDefaultKeyCurrentUser)
        UserDefaults.standard.synchronize()
        
        currentUser = user
        accountTableView.reloadData()
        
        // Configure user with API
        
        guard let currentAPIKey = UserDefaults.standard.string(forKey: kRCHUserDefaultKeyApiKey) else {
            print("Error getting current API key")
            return
        }

        let config = RCHAPIClientConfig(apiKey: "showcaseparent", apiClientKey: currentAPIKey, endpoint: RCHEndpointProduction, useHTTPS: true)
        config.apiClientSecret = "r5j50mlag06593401nd4kt734i"
        config.userID = user
        config.sessionID = UUID().uuidString
        
        RCHSDK.defaultClient().configure(config)
    }
    
    // MARK: - TableView data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userIDArray!.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "userCell", for: indexPath)
        
        let userID = (userIDArray?[indexPath.row])! as String
        cell.textLabel?.text = userID
        
        if userID == currentUser {
            cell.imageView?.image = UIImage(named: "icn-checked.pdf")
            
        } else {
            cell.imageView?.image = nil
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let userSelected = userIDArray?[indexPath.row] else {
            return
        }
        switchCurrentUser(withUser: userSelected)
    }
}
