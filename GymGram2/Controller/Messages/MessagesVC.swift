//
//  MessagesVC.swift
//  GymGram2
//
//  Created by Kamel Shaaban on 27/03/2023.
//

import UIKit
import FirebaseCore
import FirebaseAuth
import FirebaseDatabase

private let reuseIdentifier = "MessagesCell"

class MessagesVC: UITableViewController {
    // MARK: - Properties
    
    var messages = [Message]()
    var messagesDictionary = [String: Message]()
    // MARK: - Init
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureNavigationBar()
        // Register Cell
        tableView.register(MessagesTableViewCell.self, forCellReuseIdentifier: reuseIdentifier)
        fetchMessages()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        tabBarController?.tabBar.isHidden = false
    }
    
    // MARK: - UITableView
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 75
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as! MessagesTableViewCell
        cell.message = messages[indexPath.row]
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let message = messages[indexPath.row]
        let chatPartnerId = message.getChatPartnerId()
        Database.fetchUser(with: chatPartnerId) { User in
            self.showChatController(forUser: User)
        }
    }
    
    // MARK: - Handlers
    @objc func handleNewMessage() {
        let newMessageController = NewMessageC()
        newMessageController.messagesController = self
        let navigationController = UINavigationController(rootViewController: newMessageController)
        self.present(navigationController, animated: true, completion: nil)
    }
    
    func showChatController(forUser user: User) {
        let chatController = ChatC(collectionViewLayout: UICollectionViewFlowLayout())
        chatController.user = user
        navigationController?.pushViewController(chatController, animated: true)
    }
    func configureNavigationBar() {
        navigationItem.title = "Messages"
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(handleNewMessage))
    }
    
    // MARK: - API
    
    func fetchMessages() {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        
        self.messages.removeAll()
        self.messagesDictionary.removeAll()
        self.tableView.reloadData()
        
        USER_MESSAGES_REF.child(currentUid).observe(.childAdded) { DataSnapshot in
            //print(DataSnapshot)
            let uid = DataSnapshot.key
            
            USER_MESSAGES_REF.child(currentUid).child(uid).observe(.childAdded) { DataSnapshot in
                //print(DataSnapshot)
                
                let messageId = DataSnapshot.key
                
                self.fetchMessage(withMessageId: messageId)
                
            }
        }
    }
    
    func fetchMessage(withMessageId messageId: String) {
        MESSAGES_REF.child(messageId).observeSingleEvent(of: .value) { DataSnapshot in
            
            guard let dictionary = DataSnapshot.value as? Dictionary<String, AnyObject> else { return }
                
            let message = Message(dictionary: dictionary)
            let chatPartnerId = message.getChatPartnerId()
            self.messagesDictionary[chatPartnerId] = message
            self.messages = Array(self.messagesDictionary.values)
            
            
            self.tableView?.reloadData()
        }
    }
}
