//
//  Storage.swift
//  Gymgram
//
//  Created by Kamel Shaaban on 11/12/2022.
//
import FirebaseStorage

public class StorageManager {
    static let shared = StorageManager()
    
    private let bucket = Storage.storage().reference()
    
    public enum StorageManagerError: Error {
        case faildToDownload
    }
    // func to let the user upload a post
    public func UploadUserPost(model: UserPost, completion: @escaping (Result<URL, Error>) -> Void) {
        
    }
    // func to let the user download a post
    
    public func downloadImage(with reference: String, completion: @escaping (Result<URL, StorageManagerError>) -> Void) {
        bucket.child(reference).downloadURL(completion: { url, error in guard let url = url, error == nil else { completion(.failure(.faildToDownload))
            return
        }
            
            completion(.success(url))
        })
    }
}
