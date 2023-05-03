//
//  LoginViewController.swift
//  GymGram2
//
//  Created by Kamel Shaaban on 15/02/2023.
//

import UIKit
import FirebaseCore
import FirebaseAuth

class LoginViewController: UIViewController {
    
    let logoContainerView: UIView = {
        
        let view = UIView()
        let myImage = UIImage(imageLiteralResourceName: "gram2")
        let logoImageView = UIImageView(image: myImage)
        logoImageView.contentMode = .center
        view.addSubview(logoImageView)
        logoImageView.anchor(top: nil, left: nil, bottom: nil, right: nil, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 200, height: 50)
        
        logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        logoImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        view.backgroundColor = .white
        //view.backgroundColor = UIColor(red: 0/255, green: 120/255, blue: 175/255, alpha: 1)
        
        return view
    }()

    let emailTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Email"
        tf.backgroundColor = UIColor(white: 0, alpha: 0.03)
        tf.borderStyle = .roundedRect
        tf.font = UIFont.systemFont(ofSize: 14)
        tf.textColor = .black
        tf.addTarget(self, action: #selector(formValidation), for: .editingChanged)
        return tf
    }()
        
    let passwordTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Password"
        tf.backgroundColor = UIColor(white: 0, alpha: 0.03)
        tf.borderStyle = .roundedRect
        tf.font = UIFont.systemFont(ofSize: 14)
        tf.isSecureTextEntry = true
        tf.textColor = .black
        tf.addTarget(self, action: #selector(formValidation), for: .editingChanged)

        return tf
    }()

    let loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Login", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor(red: 149/255, green: 204/255, blue: 244/255, alpha: 1)
        button.addTarget(self, action: #selector(handleLogin), for: .touchUpInside)
        button.isEnabled = false
        button.layer.cornerRadius = 5
        return button
    
            
    }()
    
    let newAccountButton: UIButton = {
        let button = UIButton(type: .system)
        
        let attributedTitle = NSMutableAttributedString(string: "Do not have an account?  ", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        attributedTitle.append(NSAttributedString(string: "Sign UP", attributes:[NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor(red: 17/255, green: 154/255, blue: 237/255, alpha: 1)]))
        
        button.addTarget(self, action: #selector(handleShowSignUp), for: .touchUpInside)
        
        button.setAttributedTitle(attributedTitle, for: .normal)
        
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // background color

        view.backgroundColor = .white
        // hide nav bar
        //self.modalPresentationStyle = .fullScreen
        navigationController?.navigationBar.isHidden = true
        navigationController?.navigationBar.barStyle = .black

        view.addSubview(logoContainerView)
        logoContainerView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 150)
        //view.addSubview(logoContainerView)
        //logoContainerView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height:  150)
        configureViewComponents()
        
        view.addSubview(newAccountButton)
        newAccountButton.anchor(top: nil, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 50)
            

    }
    
    // MARK: Handlers
    
    @objc func handleShowSignUp() {
        let signUpVC = SignUpViewController()
        signUpVC.modalPresentationStyle = .fullScreen
        //signUpVC.modalPresentationStyle = .fullScreen
        navigationController?.pushViewController(signUpVC, animated: true)
    }
    
    @objc func handleLogin() {
        // properties
        guard
            let email = emailTextField.text,
            let password = passwordTextField.text else { return }
        
        //sign user in
        Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
            //handle error
            
            if let error = error {
                print("Unable to sign user in with error", error.localizedDescription)
                return
            }
            
            //handle success
            print("Successfuly signed user in")
            
            guard let mainTabVC = UIApplication.shared.connectedScenes.map({ $0 as? UIWindowScene }).compactMap({$0}).first?.windows.first?.rootViewController as? HomeTabViewController else { return }
            
            // configure VC in HomeTabVC
            mainTabVC.configureViewControllers()
            
            // dismiss logIn C
            self.dismiss(animated: true, completion: nil)
        }
    }
    @objc func formValidation() {
        // ensure email and password has text
        guard emailTextField.hasText,
              passwordTextField.hasText else {
            
            //handle case for above conditions not met
            loginButton.isEnabled = false
            loginButton.backgroundColor = UIColor(red: 149/255, green: 204/255, blue: 244/255, alpha: 1)
            return
        }
        
        //handle case for conditions were met
        loginButton.isEnabled = true
        loginButton.backgroundColor = UIColor(red: 17/255, green: 154/255, blue: 237/255, alpha: 1)
    }
    func configureViewComponents() {
        let stackView = UIStackView(arrangedSubviews: [emailTextField, passwordTextField, loginButton])
            
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.distribution = .fillEqually
        
            
        view.addSubview(stackView)
        stackView.anchor(top: logoContainerView.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 40, paddingLeft: 40, paddingBottom: 0, paddingRight: 40, width: 0, height: 140)
    }
}

