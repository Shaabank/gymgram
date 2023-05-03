//
//  NotificationsTableViewController.swift
//  GymGram2
//
//  Created by Kamel Shaaban on 17/02/2023.
//

import UIKit
import FirebaseCore
import FirebaseAuth
import FirebaseDatabase


private let reuseIdentifer = "NotificationCell"

class NotificationsTableViewController: UITableViewController, NotificationCellDelegate {


    // MARK: - Properties
    var timer: Timer?

    var currentKey: String?


    var notifications = [Notification]()

    override func viewDidLoad() {
        super.viewDidLoad()

        //clear lines
        tableView.separatorColor  = .clear

        // Nav Title
        navigationItem.title = "Notifications"

        // register cell class
        tableView.register(NotificationTableViewCell.self, forCellReuseIdentifier:  reuseIdentifer)

        //fetch notification
        fetchNotifications()

    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }



    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return notifications.count
    }
//    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
//        if notifications.count > 4 {
//            if indexPath.item == notifications.count - 1 {
//                fetchNotifications()
//            }
//        }
//    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifer, for: indexPath) as! NotificationTableViewCell
        cell.contentView.isUserInteractionEnabled = false

        let notification = notifications[indexPath.row]
        cell.notification = notification
        cell.delegate = self
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let notification = notifications[indexPath.row]
        //print("User that sent notification is \(notification.user.username)")

        let userProfileVC = ProfileCollectionViewController(collectionViewLayout: UICollectionViewFlowLayout())
        userProfileVC.user = notification.user
        navigationController?.pushViewController(userProfileVC, animated: true)
    }

    // MARK: Notification CEll DELEGATE Protocol
    func handleFollowTapped(for cell: NotificationTableViewCell) {
        //print("Handle follow tapped")

        guard let user = cell.notification?.user else { return }

        if user.isFollowed {
            //handle unfollow user
            user.unfollow()
            cell.followButton.configure(didFollow: false)



        } else {
            //handle follow user
            user.follow()
            cell.followButton.configure(didFollow: true)

        }
    }

    func handlePostTapped(for cell: NotificationTableViewCell) {
        //print("Handle post tapped")

        guard let post = cell.notification?.post else { return }

        let feedController = HomaPageCollectionViewController(collectionViewLayout: UICollectionViewFlowLayout())
        feedController.viewSinglePost = true
        feedController.post = post
        navigationController?.pushViewController(feedController, animated: true)
    }

    // MARK: Handlers
    func handleReloadTable() {
        self.timer?.invalidate()

        self.timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(handleSortNotifications), userInfo: nibName, repeats: false)
    }

    @objc func handleSortNotifications() {
        self.notifications.sort { (notification1, notification2) -> Bool in
            return notification1.creationDate > notification2.creationDate
        }
        self.tableView.reloadData()
    }


    // MARK: Fetch API

    func fetchNotifications(withNotificationId notificationId: String, dataSnapshot snapshot: DataSnapshot) {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        guard let dictionary = snapshot.value as? Dictionary<String, AnyObject> else { return }
        guard let uid = dictionary["uid"] as? String else { return }

        Database.fetchUser(with: uid) { User in
            //if notification is for post
            if let postId = dictionary["postId"] as? String {
                Database.fetchPost(with: postId) { Post in
                    let notification = Notification(user: User, post: Post, dictionary: dictionary)
                    self.notifications.append(notification)
                    self.handleReloadTable()
                }
            }
            NOTIFICATIONS_REF.child(currentUid).child(notificationId).child("checked").setValue(1)
        }
    }


    func fetchNotifications() {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }

        if currentKey == nil {
            NOTIFICATIONS_REF.child(currentUid).queryLimited(toLast: 5).observeSingleEvent(of: .value) { snapshot in
                guard let first = snapshot.children.allObjects.first as? DataSnapshot else { return }
                guard let allObjects = snapshot.children.allObjects as? [DataSnapshot] else { return }

                allObjects.forEach { snapshot in
                    let notificationId = snapshot.key
                    self.fetchNotifications(withNotificationId: notificationId, dataSnapshot: snapshot)
                }
                self.currentKey = first.key
            }
        } else {
            NOTIFICATIONS_REF.child(currentUid).queryOrderedByKey().queryEnding(atValue: self.currentKey).queryLimited(toLast: 6).observeSingleEvent(of: .value) { snapshot in
                guard let first = snapshot.children.allObjects.first as? DataSnapshot else { return }
                guard let allObjects = snapshot.children.allObjects as? [DataSnapshot] else { return }

                allObjects.forEach({ (snapshot) in
                    let notificationId = snapshot.key

                    if notificationId != self.currentKey {
                        self.fetchNotifications(withNotificationId: notificationId, dataSnapshot: snapshot)
                    }
                })
                self.currentKey = first.key
            }
        }
    }
}
