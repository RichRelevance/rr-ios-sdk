//
//  Copyright (c) 2016 Rich Relevance Inc. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.

import UIKit

class RCHAccountViewController: UIViewController {

    @IBOutlet var accountTableView: UITableView!
    
    var userIDs: [String] {
        get {
            return UserDefaults.standard.object(forKey: kRCHUserDefaultKeyUserIDs) as? [String] ?? []
        }
        set {
            UserDefaults.standard.set(newValue, forKey: kRCHUserDefaultKeyUserIDs)
            UserDefaults.standard.synchronize()
            accountTableView.reloadData()
        }
    }

    var currentUser: String? {
        get {
            return UserDefaults.standard.object(forKey: kRCHUserDefaultKeyCurrentUser) as? String
        }
        set {
            UserDefaults.standard.set(newValue, forKey: kRCHUserDefaultKeyCurrentUser)
            UserDefaults.standard.synchronize()
            accountTableView.reloadData()
        }
    }
    
    func saveNewUser(withUser newUser: String) {
        userIDs.insert(newUser, at: 0)
        currentUser = newUser
    }
    
    func switchCurrentUser(withUser user: String) {
        currentUser = user
        
        // Configure user with API
        
        guard let currentAPIKey = UserDefaults.standard.string(forKey: kRCHUserDefaultKeyApiKey) else {
            fatalError()
        }
        
        let config = RCHAPIClientConfig(apiKey: "showcaseparent", apiClientKey: currentAPIKey, endpoint: RCHEndpointProduction, useHTTPS: true)
        config.apiClientSecret = "r5j50mlag06593401nd4kt734i"
        config.userID = user
        config.sessionID = UUID().uuidString
        
        RCHSDK.defaultClient().configure(config)
    }

}

extension RCHAccountViewController: UITableViewDelegate, UITableViewDataSource {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.tintColor = UIColor.white
    }
    
    // MARK: Actions
    
    @IBAction func addUserSelected(_ sender: AnyObject) {
        let alertView = UIAlertController(title: "", message: "Add new User ID", preferredStyle: .alert)
        var inputTextField = UITextField()
        alertView.addTextField(configurationHandler: { textField -> Void in
            inputTextField = textField
            inputTextField.autocapitalizationType = .words
        })
        alertView.addAction(UIAlertAction(title: "Done", style: .default, handler: { (UIAlertAction) in
            let newUser = inputTextField.text
            self.currentUser = newUser
            self.userIDs.insert(newUser!, at: 0)
        }))
        alertView.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        present(alertView, animated: true, completion: nil)
    }
    
    // MARK: - TableView data source
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userIDs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "userCell", for: indexPath)

        let userID = userIDs[indexPath.row]
        cell.textLabel?.text = userID
        cell.accessoryType = userID == currentUser ? .checkmark : .none
        cell.tintColor = .white
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switchCurrentUser(withUser: userIDs[indexPath.row])
    }
}
