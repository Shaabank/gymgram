//
//  SelectImageViewController.swift
//  GymGram2
//
//  Created by Kamel Shaaban on 20/02/2023.
//

import UIKit
import Photos

private let reuseIdentifier = "SelectPhotoCell"
private let headerIdentifier = "SelectPhotoHeader"

class SelectImageViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    // MARK: properties
    
    var images = [UIImage]()
    var assets = [PHAsset]()
    var selectedImage: UIImage?
    var header: SelectphotoheaderCollectionViewCell?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // register cel classes
        collectionView?.register(SelectPhotoCollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
        collectionView?.register(SelectphotoheaderCollectionViewCell.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: headerIdentifier)
        
        collectionView?.backgroundColor = .white
        
        //configure nav Buttons
        configureNavigationButtons()
        
        //fetch photos
        fetchPhotos()
    }
    // MARK: UICollectionViewFlowLayout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let width = view.frame.width
        return CGSize(width: width, height: width)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (view.frame.width - 3) / 4
        return CGSize(width: width, height: width)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 1
    }
    
    
    
    // MARK: UICollectionViewDataSource
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
        
    }
    
    override func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerIdentifier, for: indexPath) as! SelectphotoheaderCollectionViewCell
        
        self.header = header
        
        if let selectedImage = self.selectedImage {
            
            if let index = self.images.firstIndex(of: selectedImage) {
                
                let selectedAsset = self.assets[index]
                
                let imageManager = PHImageManager.default()
                let targetSize = CGSize(width: 700, height: 700)
                
                //request image
                imageManager.requestImage(for: selectedAsset, targetSize: targetSize, contentMode: .default, options: nil) { image, info in
                    header.photoImageView.image = image

                }
            }
        }
        
        return header
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! SelectPhotoCollectionViewCell
        
        cell.photoImageView.image = images[indexPath.row]
        return cell
            
        
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        self.selectedImage = images[indexPath.row]
        self.collectionView?.reloadData()
        
        let indexPath = IndexPath(item: 0, section: 0)
        collectionView.scrollToItem(at: indexPath, at: .bottom, animated: true)
        
    }
    
    // MARK: Handlers
    
    @objc func handleCanel() {
        self.dismiss(animated: true, completion: nil)
    }
    @objc func handleNext() {
        
        let uploadPostVC = UploadPostViewController()
        uploadPostVC.selectedImage = header?.photoImageView.image
        uploadPostVC.uploadAction = UploadPostViewController.UploadAction(index: 0)
        navigationController?.pushViewController(uploadPostVC, animated: true)
    }
    func configureNavigationButtons() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleCanel))
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Next", style: .plain, target: self, action: #selector(handleNext))
    }
    
    func getAssetFetchOptions() -> PHFetchOptions {
        
        let options = PHFetchOptions()
        
        // fetch limit
        options.fetchLimit = 45
        
        // sort photos by date
        let sortDescriptor = NSSortDescriptor(key: "creationDate", ascending: false)
        
        //set sort descriptor for options
        options.sortDescriptors = [sortDescriptor]
        
        
        return options

    }
    
    func fetchPhotos() {
        let allPhotos = PHAsset.fetchAssets(with: .image, options: getAssetFetchOptions())
        
        print("func running in selectImage VC  func fetchPhotots")
        //fetch photos on background
        
        DispatchQueue.global(qos: .background).async {
            
            allPhotos.enumerateObjects { asset, count, stop in
                
                
                print("Count is \(count)")
                
                let imageManager = PHImageManager.default()
                let targetSize = CGSize(width: 200, height: 200)
                let options = PHImageRequestOptions()
                options.isSynchronous = true
                
                
                // requet image
                imageManager.requestImage(for: asset, targetSize: targetSize, contentMode: .aspectFit, options: options) { (image, info) in
                    
                    if let image = image {
                        
                        // append image to data source
                        self.images.append(image)
                        
                        //append asset to data
                        self.assets.append(asset)
                        
                        // set selected image
                        if self.selectedImage == nil {
                            self.selectedImage = image
                        }
                        
                        //reload collection view with images once count has compleated
                        if count == allPhotos.count - 1 {
                            
                            // reload coolection view on main thread
                            DispatchQueue.main.async {
                                self.collectionView?.reloadData()
                            }
                        }
                        
                    }
                }
            }
        }

    }
}
