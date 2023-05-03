//
//  NewMessageC.swift
//  GymGram2
//
//  Created by Kamel Shaaban on 27/03/2023.
//

import UIKit
import FirebaseCore
import FirebaseAuth
import FirebaseDatabase

private let reuseIdentifier = "NewMessageCell"
class NewMessageC: UITableViewController {
    
    // MARK: - Properties
    var users = [User]()
    var messagesController: MessagesVC?
    
    // MARK: - Init
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureNavigationBar()
        // Register Cell
        tableView.register(NewMessage.self, forCellReuseIdentifier: reuseIdentifier)
        fetchUsers()
    }
    
    // MARK: - UITableView
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! NewMessage
        
        cell.user = users[indexPath.row]
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //print("Did select row")
        
        self.dismiss(animated: true) {
            let user = self.users[indexPath.row]
            self.messagesController?.showChatController(forUser: user)
        }
    }
    
    // MARK: HANDLERS
    @objc func handleCanel(){
        dismiss(animated: true, completion: nil)
    }
    
    func configureNavigationBar() {
        navigationItem.title = "New Message"
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleCanel))
        navigationItem.leftBarButtonItem?.tintColor = .black
    }
    
    // MARK: - API
    
    
    func fetchUsers() {
        USER_REF.observe(.childAdded) { DataSnapshot in
            //print(DataSnapshot)
            let uid = DataSnapshot.key
            
            if uid != Auth.auth().currentUser?.uid {
                Database.fetchUser(with: uid) { User in
                    self.users.append(User)
                    self.tableView.reloadData()
                }
            }
        }
    }

    
}
