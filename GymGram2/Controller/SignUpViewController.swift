//
//  SignUpViewController.swift
//  GymGram2
//
//  Created by Kamel Shaaban on 15/02/2023.
//
import UIKit
import FirebaseCore
import FirebaseStorage
import FirebaseAuth
import FirebaseDatabase

class SignUpViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var imageSelected = false
    
    let plusPhotoButton: UIButton = {
        let button = UIButton(type: .system)
        button.accessibilityLabel = "photoButton"
        button.setImage(UIImage(imageLiteralResourceName: "upload-logo").withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(handleSelectProfilePhoto), for: .touchUpInside)
        return button
    }()
    
    let emailTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Email@.com"
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
        tf.isSecureTextEntry = true
        tf.backgroundColor = UIColor(white: 0, alpha: 0.03)
        tf.borderStyle = .roundedRect
        tf.font = UIFont.systemFont(ofSize: 14)
        tf.textColor = .black
        tf.addTarget(self, action: #selector(formValidation), for: .editingChanged)
        return tf
    }()
    
    let fullNameTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Full Name..."
        tf.backgroundColor = UIColor(white: 0, alpha: 0.03)
        tf.borderStyle = .roundedRect
        tf.font = UIFont.systemFont(ofSize: 14)
        tf.textColor = .black
        tf.addTarget(self, action: #selector(formValidation), for: .editingChanged)

        return tf
    }()
        
    let usernameTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Username..."
        tf.backgroundColor = UIColor(white: 0, alpha: 0.03)
        tf.borderStyle = .roundedRect
        tf.font = UIFont.systemFont(ofSize: 14)
        tf.textColor = .black
        tf.addTarget(self, action: #selector(formValidation), for: .editingChanged)

        return tf
    }()
    
    let signUpButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("SignUP", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor(red: 149/255, green: 204/255, blue: 244/255, alpha: 1)
        button.layer.cornerRadius = 5
        button.isEnabled = false
        button.addTarget(self, action: #selector(handleShowSignUp), for: .touchUpInside)
        return button
    
            
    }()
    
    let haveAccountButton: UIButton = {
        let button = UIButton(type: .system)
        
        let attributedTitle = NSMutableAttributedString(string: "Already have an account?  ", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        attributedTitle.append(NSAttributedString(string: "Sign In", attributes:[NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 14), NSAttributedString.Key.foregroundColor: UIColor(red: 17/255, green: 154/255, blue: 237/255, alpha: 1)]))
        button.addTarget(self, action: #selector(handleShowLogin), for: .touchUpInside)
        button.setAttributedTitle(attributedTitle, for: .normal)
        
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        view.addSubview(plusPhotoButton)
        plusPhotoButton.anchor(top: view.topAnchor, left: nil, bottom: nil, right: nil, paddingTop: 40, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 140, height: 140)
        
        plusPhotoButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        configureViewComponents()
        
        view.addSubview(haveAccountButton)
        haveAccountButton.anchor(top: nil, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 0, height: 50)

    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        //selected image
        guard let profileImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else {
            imageSelected = false
            return
        }
        
        //set image selected to true
        imageSelected = true
        
        //configure plus photo button with selected image
        plusPhotoButton.layer.cornerRadius = plusPhotoButton.frame.width / 2
        plusPhotoButton.layer.masksToBounds = true
        plusPhotoButton.layer.borderColor = UIColor.black.cgColor
        plusPhotoButton.layer.borderWidth = 2
        plusPhotoButton.setImage(profileImage.withRenderingMode(.alwaysOriginal), for: .normal)
        
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func handleSelectProfilePhoto() {
        
        //COnfigureImage picker
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        
        
        // present image picker
        self.present(imagePicker, animated: true, completion: nil)
    }
    @objc func handleShowLogin() {
        _ = navigationController?.popViewController(animated: true)
    }
    
    @objc func handleShowSignUp() {
        
        guard let email = emailTextField.text else { return }
        guard let password = passwordTextField.text else { return }
        guard let fullName = fullNameTextField.text else { return }
        guard let username = usernameTextField.text?.lowercased() else { return }
        

        Auth.auth().createUser(withEmail: email, password: password) { (authResult, error) in

            
            // handle error
            if let error = error {
                print("DEBUG:  K Failed to create user with error: ", error.localizedDescription)
                return
            }
            print("user created successfuly")
            // set profile image
            guard let profileImg = self.plusPhotoButton.imageView?.image else { return }
            
            //upload data
            guard let uploadData = profileImg.jpegData(compressionQuality: 0.3) else { return }
            
            // place image in database
            let filename = NSUUID().uuidString
            
            //user ID

            
            // update
            let storageRef = Storage.storage().reference().child("profile_images").child(filename)
            storageRef.putData(uploadData, metadata: nil, completion: { (metadata, error) in
                
                // handle error
                if let error = error {
                    print(" Kamel Faild to upload image to firebase  storage with error", error.localizedDescription)
                    return
                }
                print("profile image upload successfuly.")
                
                // profile image URL
                storageRef.downloadURL(completion: { (downloadURL, error) in
                    guard let profileImageUrl = downloadURL?.absoluteString else {
                        print("DEBUG: Profile Image URL is nil")
                        return
                    }
                    
                    //user Id
                    guard let uid = authResult?.user.uid else { return }
                    //guard let fcmToken = messaging.messagin().fcmToken else { return }
                    
                    let dictionaryValues = ["name": fullName,
                                            "username": username,
                                            "profileImageUrl": profileImageUrl]
                    
                    let values = [uid: dictionaryValues]
                    
                    //****** save user info to database
                    
                    Database.database().reference().child("authResult").updateChildValues(values, withCompletionBlock: { (error, ref) in
                        print("Successfully created user and saved indformation to database")
                        
                        guard let mainTabVC = UIApplication.shared.connectedScenes.map({ $0 as? UIWindowScene }).compactMap({$0}).first?.windows.first?.rootViewController as? HomeTabViewController else { return }
                        
                        // configure VC in HomeTabVC
                        mainTabVC.configureViewControllers()
                        
                        // dismiss logIn C
                        // ******** configure view controllers in maintabvc
                        //mainTabVC.configureViewControllers()
                        //mainTabVC.isInitialLoad = true
                    
                    //******* dismiss login controoler
                        self.dismiss(animated: true, completion: nil)
                    })
                })
            })
        }
    }
    @objc func formValidation() {
        guard
            emailTextField.hasText,
            passwordTextField.hasText,
            fullNameTextField.hasText,
            usernameTextField.hasText,
            imageSelected == true else {
                signUpButton.isEnabled = false
                signUpButton.backgroundColor = UIColor(red: 149/255, green: 204/255, blue: 244/255, alpha: 1)
                return
        }
        
        signUpButton.isEnabled = true
        signUpButton.backgroundColor = UIColor(red: 17/255, green: 154/255, blue: 236/255, alpha: 1)
        
    }
    
    func configureViewComponents() {
        let stackView = UIStackView(arrangedSubviews: [emailTextField, fullNameTextField, usernameTextField, passwordTextField, signUpButton])
            
        stackView.axis = .vertical
        stackView.spacing = 10
        stackView.distribution = .fillEqually
            
        view.addSubview(stackView)
        stackView.anchor(top: plusPhotoButton.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 24 , paddingLeft: 40, paddingBottom: 0, paddingRight: 40, width: 0, height: 240)
    }
    

}
