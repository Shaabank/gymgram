//
//  HomeTabViewController.swift
//  GymGram2
//
//  Created by Kamel Shaaban on 17/02/2023.
//

import UIKit
import FirebaseCore
import FirebaseAuth
import FirebaseDatabase


class HomeTabViewController: UITabBarController, UITabBarControllerDelegate {
    
    // MARK: properties
    
    let dot = UIView()
    var notificationIDs = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // delegate
        self.delegate = self
        
        // configure VCs
        configureViewControllers()
        
        // configure notification dot
        configureNotificationDot()
        // observe notifi
        observeNotifications()
        // user logged in
        checkIfUserIsLoggedIn()

    }
    
    // functions
    func configureViewControllers() {
        //home Page
        //let homeSelected = UIImage(imageLiteralResourceName: "home_selected")
        //let homeUnSelected = UIImage(imageLiteralResourceName: "home_unselected")
        
        let feedVC = configureNavController(unselectedImage: #imageLiteral(resourceName: "home_unselected"), selectedImage: #imageLiteral(resourceName: "home_selected"), rootViewController: HomaPageCollectionViewController(collectionViewLayout: UICollectionViewFlowLayout()))
        //search
        let searchVC = configureNavController(unselectedImage: #imageLiteral(resourceName: "search_unselected"), selectedImage: #imageLiteral(resourceName: "search_selected"), rootViewController: SearchTableViewController())
        
        //select image C
        let selectImageVC = configureNavController(unselectedImage: #imageLiteral(resourceName: "plus_unselected"), selectedImage: #imageLiteral(resourceName: "plus_unselected"))
        //let uploadPostVC = configureNavController(unselectedImage: #imageLiteral(resourceName: "plus_unselected"), selectedImage: #imageLiteral(resourceName: "plus_unselected"), rootViewController: UploadPostViewController())
        
        
        //Notification
        let notificationVC = configureNavController(unselectedImage: #imageLiteral(resourceName: "like_unselected"), selectedImage: #imageLiteral(resourceName: "like_selected"), rootViewController: NotificationsTableViewController())
        //profile
        let  profileVC = configureNavController(unselectedImage: #imageLiteral(resourceName: "profile_unselected"), selectedImage: #imageLiteral(resourceName: "profile_selected"), rootViewController: ProfileCollectionViewController(collectionViewLayout: UICollectionViewFlowLayout()))
        
        // VC to be added to tab bar
        viewControllers = [feedVC, searchVC, selectImageVC, notificationVC, profileVC]
        
        // tab bar color
        tabBar.tintColor = .blue

    }
        
    // configure navigation controller
        
    func configureNavController(unselectedImage: UIImage, selectedImage: UIImage, rootViewController: UIViewController =
                                UIViewController()) -> UINavigationController {
        
        //construct nav controller
        let navController = UINavigationController(rootViewController: rootViewController)
        navController.tabBarItem.image = unselectedImage
        navController.tabBarItem.selectedImage = selectedImage
        navController.navigationBar.tintColor = .red
            
        //return
        return navController
    }
    
        func configureNotificationDot() {
            if UIDevice().userInterfaceIdiom == .phone {
                let tabBarHeight = tabBar.frame.height
                
                if UIScreen.main.nativeBounds.height == 2436 {
                    //configure dot for iphone x
                    dot.frame = CGRect(x: view.frame.width / 5 * 3, y: view.frame.height - tabBarHeight, width: 6, height: 6)
                } else {
                    dot.frame = CGRect(x: view.frame.width / 5 * 3, y: view.frame.height, width: 6, height: 6)
                }
                
                // create dot
                dot.center.x = (view.frame.width / 5 * 3 + (view.frame.width / 5) / 2)
                dot.backgroundColor = UIColor(red: 233/255, green: 30/255, blue: 99/255, alpha: 1)
                dot.layer.cornerRadius = dot.frame.width / 2
                self.view.addSubview(dot)
                dot.isHidden = true
            }
        }
    
        
    //  MARK: UITabBarController
        
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        let index = viewControllers?.firstIndex(of: viewController)
        
        if index == 2 {
            let selectImageVC = SelectImageViewController(collectionViewLayout: UICollectionViewFlowLayout())
            let navController = UINavigationController(rootViewController: selectImageVC)
            navController.navigationBar.tintColor = .black
            
            
            present(navController, animated: true, completion: nil)
            
            return false
        } else if index == 3 {
            //print("Did select notification controller")
            dot.isHidden = true
            return true
        }
        
        return true
    }
    // MARK: API
    
    func checkIfUserIsLoggedIn() {
        if Auth.auth().currentUser == nil {
            DispatchQueue.main.async {
                // present login C
                let loginVC = LoginViewController()
                let navController = UINavigationController(rootViewController: loginVC)
                navController.modalPresentationStyle = .fullScreen
                self.present(navController, animated: true, completion: nil)
            }
        return
        }
    }
    
    func observeNotifications() {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        self.notificationIDs.removeAll()
        NOTIFICATIONS_REF.child(currentUid).observeSingleEvent(of: .value) { DataSnapshot in
                //print(DataSnapshot)
            guard let allObjects = DataSnapshot.children.allObjects as? [DataSnapshot] else { return }
            allObjects.forEach { DataSnapshot in
                let notificationId = DataSnapshot.key
                
                NOTIFICATIONS_REF.child(currentUid).child(notificationId).child("checked").observeSingleEvent(of: .value) { DataSnapshot in
                    guard let checked = DataSnapshot.value as? Int else { return }
                    
                    if checked == 0 {
                        //print("Notification has not been checked")
                        self.dot.isHidden = false
                    } else {
                        //print("Notification has been checked")
                        self.dot.isHidden = true
                    }
                }
            }
        }
    }
}
