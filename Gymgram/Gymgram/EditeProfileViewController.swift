//
//  EditeProfileViewController.swift
//  Gymgram
//
//  Created by Kamel Shaaban on 08/12/2022.
//

import UIKit

struct EditProfileFormModel {
    let label: String
    let placeholder: String
    var value: String?
}

final class EditeProfileViewController: UIViewController, UITableViewDataSource {
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(FormTableViewCell.self, forCellReuseIdentifier: FormTableViewCell.identifier)
        return tableView
    }()
    
    private var models = [[EditProfileFormModel]]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //call teh func config to display the sections
        configureModels()
        view.backgroundColor = .systemBackground
        tableView.tableHeaderView = createTableHeaderView()
        tableView.dataSource = self
        view.addSubview(tableView)
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(didTapSave))
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(didTapCancel))

    }
    private func configureModels() {
        // username, name, bio
        let firstSectionLabels = ["Name", "Username", "Bio"]
        var firstSection = [EditProfileFormModel]()
        //for loop
        for label in firstSectionLabels {
            let model = EditProfileFormModel(label: label, placeholder: "Enter \(label)...", value: nil)
            firstSection.append(model)
            
        }
        models.append(firstSection)
        // email, gender , Mobile number
        let secondSectionLabels = ["Email", "Mobile", "Gender"]
        var secondSection = [EditProfileFormModel]()
        //for loop
        for label in secondSectionLabels {
            let model = EditProfileFormModel(label: label, placeholder: "Enter \(label)..", value: nil)
            secondSection.append(model)
            
        }
        models.append(secondSection)
    }
    // do override func to view the subview
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    
    
    // tableView
    private func createTableHeaderView() -> UIView {
        let header = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height/4).integral)
        let size = header.frame.size.height / 1.5
        let profilePhotoButton = UIButton(frame: CGRect(x: (view.frame.size.width-size)/2, y: (header.frame.size.height-size)/2, width: size, height: size))
        
        //add subview FOR USER  PHOTO
        header.addSubview(profilePhotoButton)
        profilePhotoButton.layer.masksToBounds = true
        profilePhotoButton.tintColor = .label
        profilePhotoButton.layer.cornerRadius = size/2.0
        profilePhotoButton.addTarget(self, action: #selector(didTapProfilePhotoButton), for: .touchUpInside)
        
        profilePhotoButton.setBackgroundImage(UIImage(systemName: "person.circle"), for: .normal)
        profilePhotoButton.layer.borderWidth = 1
        profilePhotoButton.layer.borderColor = UIColor.secondarySystemBackground.cgColor
        return header
    }
    
    @objc private func didTapProfilePhotoButton() {
        
        
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return models.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return models[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = models[indexPath.section][indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: FormTableViewCell.identifier, for: indexPath) as! FormTableViewCell
        cell.configure(with: model)
        cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        guard section == 1 else {
            return nil
        }
        return "About Me"
    }
    // save and store user data to database firebase
    @objc private func didTapSave(){
        dismiss(animated: true, completion: nil)
        
    }
    
    @objc private func didTapCancel(){
        dismiss(animated: true, completion: nil)
    }
    @objc private func didTapChangeProfilePicture(){
        let actionSheet = UIAlertController(title: "Profile Photo", message: "change Profile Photo", preferredStyle: .actionSheet)
        
        actionSheet.addAction(UIAlertAction(title: "Take Photo", style: .default, handler: { _ in }))
        
        actionSheet.addAction(UIAlertAction(title: "Chose from Library", style: .default, handler: { _ in }))
        
        actionSheet.addAction(UIAlertAction(title: "cancel", style: .cancel, handler: { _ in }))
        
        actionSheet.popoverPresentationController?.sourceView = view
        
        actionSheet.popoverPresentationController?.sourceRect = view.bounds
        
        present(actionSheet, animated: true)
    }

}


extension EditeProfileViewController: FormTableViewCellDelegate {
    func formTableViewCell(_ cell: FormTableViewCell, didUpdateField updatedModel: EditProfileFormModel) {
        // Update Model
        //updatedModel.label
        //print(updatedModel.value ?? "nil")
    }
    
    
}
