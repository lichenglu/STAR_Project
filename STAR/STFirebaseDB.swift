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

class STFirebaseDB {
	
	static let db = STFirebaseDB()
	
	private let _REF_BASE = DB_BASE
	private let _REF_USERS = DB_BASE.child("users")
	
	var refBase: FIRDatabaseReference {
		return _REF_BASE
	}
	
	var refBUser: FIRDatabaseReference {
		return _REF_USERS
	}
	
	func createUserOnFirebase(withSTUser user: STUser) {
		guard let uid = user.uid else { return }
		let userData = user.toDictionary()
		refBUser.child(uid).updateChildValues(userData)
	}
}
