//
//  CustomImageView.swift
//  GymGram2
//
//  Created by Kamel Shaaban on 27/02/2023.
//

import UIKit

var imageCache = [String: UIImage]()


class CustomImageView: UIImageView {
    
    var lastImageUrlUsedToLoadImage: String!
    
    func loadImage(with urlString: String) {
        
        //set image to nill
        self.image = nil
        
        //set lastImageUrlUsedToLoadImage
        lastImageUrlUsedToLoadImage = urlString
        
        // check if images exists in cache
        if let cachedImage = imageCache[urlString] {
            self.image = cachedImage
            return
        }
                
        // url for image location
        guard let url = URL(string: urlString) else { return }
        
        //fetch contents
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            
            // handle error
            if let error = error {
                print("Failed to load image with error", error.localizedDescription)
            }
            
            if self.lastImageUrlUsedToLoadImage != url.absoluteString {
                //print("if block exectued")
                return
            }
            
            guard let imageData = data else { return }
            
            // create image
            let photoImage = UIImage(data: imageData)
            
            //set key and value for image cache
            
            imageCache[url.absoluteString] = photoImage
            
            //set image
            DispatchQueue.main.async {
                self.image = photoImage
            }
        }.resume()
    }
}
