//
//  LoginPageViewController.swift
//  Gymgram
//
//  Created by Kamel Shaaban on 11/11/2022.
//
//import FirebaseAuth
import UIKit

class LoginPageViewController: UIViewController {
    
    
    
    private let headerImageView: UIView = {
        //declare a variable that cant be chaged afterwards
        let headerView = UIView()
        headerView.clipsToBounds = true
        // eclare a variable for header images
        let backgroundImageView = UIImageView(image: UIImage(named: "gym"))
        headerView.addSubview(backgroundImageView)
        return headerView
    }()
    
    private let usernameEmail: UITextField = {
        //declare a text field for username and email
        let username = UITextField()
        //do some styling to username field
        username.placeholder = "Enter Your Username Or Your Email Please...."
        username.backgroundColor = .secondarySystemBackground
        username.returnKeyType = .continue
        username.autocapitalizationType = .none
        username.layer.cornerRadius = 10
        username.leftViewMode = .always
        username.autocorrectionType = .no
        username.leftView = UIView(frame: CGRect(x: 0,y: 0, width: 10, height: 0))
        username.layer.masksToBounds = true
        username.layer.borderColor = UIColor.secondaryLabel.cgColor
        username.layer.borderWidth = 1.5
        return username
    }()
    
    
    private let password: UITextField = {
        let pass = UITextField()
        pass.isSecureTextEntry = true
        pass.placeholder = "Enter Your Password Please"
        pass.backgroundColor = .secondarySystemBackground
        pass.returnKeyType = .continue
        pass.autocapitalizationType = .none
        pass.layer.cornerRadius = 10
        pass.leftViewMode = .always
        pass.autocorrectionType = .no
        pass.leftView = UIView(frame: CGRect(x: 0,y: 0, width: 10, height: 0))
        pass.layer.masksToBounds = true
        pass.layer.borderWidth = 1.5
        pass.layer.borderColor = UIColor.secondaryLabel.cgColor
        return pass
    }()
    
    private let loginButton: UIButton = {
        let loginB = UIButton()
        loginB.layer.cornerRadius = 10
        loginB.backgroundColor = .systemBlue
        loginB.setTitle("LogIn", for: .normal)
        loginB.setTitleColor(.white, for: .normal)
        loginB.layer.masksToBounds = true
        return loginB
    }()
    
    private let createNewAccountButton: UIButton = {
        let button = UIButton()
        button.setTitle("Create an Account", for: .normal)
        button.setTitleColor(.label, for: .normal)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        loginButton.addTarget(self, action: #selector(didLoginButton), for: .touchUpInside)
        createNewAccountButton.addTarget(self, action: #selector(didCreateAccountButton), for: .touchUpInside)
        usernameEmail.delegate = self
        password.delegate = self
        // call SubViews func
        addSubviews()
        view.backgroundColor = .systemBackground

        // Do any additional setup after loading the view.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // assign frames
        
        headerImageView.frame = CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height / 2.5)
        
        usernameEmail.frame = CGRect(x: 15, y: headerImageView.frame.origin.y + headerImageView.frame.size.height + 7, width: view.frame.size.width - 40 , height: 50)
        
        password.frame = CGRect(x: 15, y: usernameEmail.frame.origin.y + usernameEmail.frame.size.height + 7 , width: view.frame.size.width - 40, height: 50)
        
        loginButton.frame = CGRect(x: 15, y: password.frame.origin.y + password.frame.size.height + 7, width: view.frame.size.width - 40, height: 50)
        
        createNewAccountButton.frame = CGRect(x: 15, y: loginButton.frame.origin.y + loginButton.frame.size.height + 7, width: view.frame.size.width - 40, height: 20)


        configHeaderView()
    }
    private func configHeaderView() {
        guard headerImageView.subviews.count == 1 else {
            return
        }
        guard let backgroundView = headerImageView.subviews.first else {
            return
        }
        backgroundView.frame = headerImageView.bounds
        
        
        
    }
    
    // adding subviews holding by another view as any UIView manage multiple subviews
    private func addSubviews() {
        view.addSubview(headerImageView)
        view.addSubview(usernameEmail)
        view.addSubview(password)
        view.addSubview(loginButton)
        view.addSubview(createNewAccountButton)
    }
    
    @objc private func didLoginButton() {
        // here when the log in button get taped we turn down the keyboard for the passowrd and username
        password.resignFirstResponder()
        usernameEmail.resignFirstResponder()
        // check if the user enter text to the username or email and validate is no empty field and for the password we make sure the field is not empty and the pass count equal or more than 10
        guard let usernameEmail = usernameEmail.text, !usernameEmail.isEmpty, let pass = password.text, !pass.isEmpty, pass.count >= 10 else {
            return
        }
        
        // Login
        
        var username: String?
        var email: String?
        if usernameEmail.contains("@"), usernameEmail.contains("."){
            //email
            email = usernameEmail
        }
        else {
            //username
            username = usernameEmail
        }
        Authenticator.shared.loginUser(username: username, email: email, password: pass) {success in
            DispatchQueue.main.async {
                if success {
                    //logged in
                    self.dismiss(animated: true, completion: nil)
                }
                else {
                    //error occurred
                    let alert = UIAlertController(title: "Log In Error", message: "We were unable to log you in.?!", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
                    self.present(alert, animated: true)
                }
            }
        }
    }
    @objc private func didCreateAccountButton() {
        let signUpViewC = SignupPageViewController()
        signUpViewC.title = "Create a new account"
        present(UINavigationController(rootViewController: signUpViewC), animated: true)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}

extension LoginPageViewController: UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == usernameEmail {
            password.becomeFirstResponder()
        }
        else if textField == password {
            didLoginButton()
        }
        return true
    }
}


/*
import UIKit

class ExplorePageViewController: UIViewController{
      
    private let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.backgroundColor = .secondarySystemBackground
        return searchBar
    }()
    
    private var collectionView: UICollectionView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        navigationController?.navigationBar.topItem?.titleView = searchBar
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView?.delegate = self
        collectionView?.dataSource = self
        guard let collectionView = collectionView else {
            return
        }
        view.addSubview(collectionView)
    }
}

extension ExplorePageViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 0
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        return UICollectionViewCell()
    }
}
*/
/*
import UIKit
struct SettingCellModel {
    let title:String
    let handler: (() -> Void)
}
// final mean no one can subclass it
final class SettingViewController: UIViewController {
    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return tableView
    }()
    
    private var data = [[SettingCellModel]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureModels()
        view?.backgroundColor = .systemGreen
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    
    private func configureModels() {
        let section = [
            SettingCellModel(title: "Log Out") { [weak self] in
                self?.didTapLogOut()
                
            }
        ]
        data.append(section)
    }
    private func didTapLogOut() {
        
        let actionSheet = UIAlertController(title: "Log Out", message: "Are you sure you want to log out?", preferredStyle: .actionSheet) // i want to try to add the user name after the message ?
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        actionSheet.addAction(UIAlertAction(title: "Log Out", style: .destructive, handler: { _ in
            Authenticator.shared.logOut(completion: { success in
                DispatchQueue.main.async {
                    if success {
                        // display login page when the user log out successfully
                        let loginViewControl = LoginPageViewController()
                        loginViewControl.modalPresentationStyle = .fullScreen
                        self.present(loginViewControl, animated: true) {
                            self.navigationController?.popToRootViewController(animated: false)
                            self.tabBarController?.selectedIndex = 0
                        }
                    }
                    else {
                        //error Message if the user could not log out
                        fatalError("Sorry somthing went wrong you could not log out try again..!")
                    }
                }
                
            })
        }))
        
        // ( ? ) means i can assign default value nil or any other value
        actionSheet.popoverPresentationController?.sourceView = tableView
        actionSheet.popoverPresentationController?.sourceRect = tableView.bounds
        present(actionSheet, animated: true)
    }
}

extension SettingViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return data.count
    }
    
    // (_) underscore operator represents an unnamed parameter/lable  we used to call the function with out parameters lable i used _ to make the lable be nothing or ignored
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data[section].count
    }
    
    func tableView(_ tableView:UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = data[indexPath.section][indexPath.row].title
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath ) {
        tableView.deselectRow(at: indexPath, animated: true)
        data[indexPath.section][indexPath.row].handler()
        //model.handler()
        
    }
    
}
*/
/*
 
 import UIKit

 class NotificationPageViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
     private let tableView: UITableView = {
         let tableView = UITableView()
         tableView.register(UITableView.self, forCellReuseIdentifier: "cell")
         return tableView
     }()
     
     override func viewDidLoad() {
         super.viewDidLoad()
         title = "Notification Page"
         view.backgroundColor = .systemBackground
         view.addSubview(tableView)
         tableView.delegate = self
         tableView.dataSource = self
     }
     
     override func viewDidLayoutSubviews() {
         super.viewDidLayoutSubviews()
         tableView.frame = view.bounds
     }
     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
         return 0
     }
     
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
         let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
         return cell
     }
 }

 
 */
