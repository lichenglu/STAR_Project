//
//  STFirebaseDB.swift
//  STAR
//
//  Created by chenglu li on 28/9/2016.
//  Copyright © 2016 Chenglu_Li. All rights reserved.
//

import Foundation
import Firebase

let DB_BASE = FIRDatabase.database().reference()
let STORAGE_BASE = FIRStorage.storage().reference()

class STFirebaseDB {
	
	static let db = STFirebaseDB()
	
	// DB References
	private let _REF_BASE = DB_BASE
	private let _REF_USERS = DB_BASE.child("users")
	
	// Storage References
	private let _REF_STORAGE_BASE = STORAGE_BASE
	private let _REF_STORAGE_USERS = STORAGE_BASE.child("users")
	
	var refBase: FIRDatabaseReference {
		return _REF_BASE
	}
	
	var refUser: FIRDatabaseReference {
		return _REF_USERS
	}
	
	var refStorageUsers: FIRStorageReference {
		return _REF_STORAGE_USERS
	}
	
	func createUserOnFirebase(withSTUser user: STUser) {
		guard let uid = user.uid else { return }
		let userData = user.toDictionary()
		refUser.child(uid).updateChildValues(userData)
	}
	
	func updateUserOnFirebase(withUID uid: String, data: [String: Any]) {
		refUser.child(uid).updateChildValues(data)
	}
	
	func uploadImageToFirebase(withUID uid: String, imageId: String, image: UIImage, metaData: STItem?, completion: ((FIRStorageMetadata?, Error?) -> Void)?) {
		
		// Img to data
		guard let imgData = UIImageJPEGRepresentation(image, 0.5) else {
			print("Failed to convert image to Data")
			return
		}
		
		// Metadata
		let metadata = FIRStorageMetadata()
		metadata.contentType = "image/jpeg"
		if let imgInfo = metaData?.toDictionary() as? [String : String] {
			metadata.customMetadata = imgInfo
		}
		
		// Upload
		refStorageUsers.child(uid).child(imageId).put(imgData, metadata: metadata, completion: completion)
		
		// Sync with fb database
	}
	
}
