//
//  SettingsViewController.swift
//  Gymgram
//
//  Created by Kamel Shaaban on 04/12/2022.
//

// import safariServices to use links and this links will open by safari browser
import SafariServices
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
        data.append([SettingCellModel(title: "Edit Profile") { [weak self] in self?.didTapEditProfile()},
                     
                     SettingCellModel(title: "Save post") { [weak self] in self?.didTapSavePost()},
                     
                     SettingCellModel(title: "Invite Friend") { [weak self] in self?.didTapInviteFriend()},
                     
        ])
        
        data.append([SettingCellModel(title: "Help / Feedback ") { [weak self] in
            self?.openURL(type: .help)

            }
        ])
        
        data.append([SettingCellModel(title: "Log Out") { [weak self] in
            self?.didTapLogOut()

            }
        ])
        
    }
    enum SettingsURLType {
        case help
    }
    
    private func didTapEditProfile(){
        let viewController = EditeProfileViewController()
        viewController.title = "Edit Your Profile"
        let navViewController = UINavigationController(rootViewController: viewController)
        navViewController.modalPresentationStyle = .fullScreen
        present(navViewController, animated: true)
        
    }
    
    private func didTapSavePost(){
        
    }
    
    private func didTapInviteFriend(){
        // display share form to invite freind
    }
    
    private func openURL(type: SettingsURLType){
        let urlString: String
        switch type {
        case .help: urlString = "https://developer.apple.com/videos/developer-tools/"
        }
        
        guard let url = URL(string: urlString) else {
            return
        }
        
        let viewController = SFSafariViewController(url: url)
        present(viewController, animated: true)
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
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = data[indexPath.section][indexPath.row].title
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath ) {
        tableView.deselectRow(at: indexPath, animated: true)
        data[indexPath.section][indexPath.row].handler()
        //model.handler()
        
    }
    
}
