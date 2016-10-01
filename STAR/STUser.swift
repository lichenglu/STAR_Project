//
//  STUser.swift
//  STAR
//
//  Created by chenglu li on 25/9/2016.
//  Copyright © 2016 Chenglu_Li. All rights reserved.
//
import Foundation
import RealmSwift
import Firebase

class STUser: Object{
	
	dynamic var uid: String!
	dynamic var displayName: String? = nil
	dynamic var email: String? = nil
	dynamic var photoURL: String? = nil
	
	convenience init(withFIRUser user: FIRUser) {
		var userData = [String: Any]()
		STUser.properties.forEach { (property) in
			
			if(property == "photoURL") {
				if let photoURL = user.value(forKey: property) as? URL{
					print("photoURL.absoluteURL \(photoURL.absoluteString)")
					userData[property] = photoURL.absoluteString
				}
			}else {
				userData[property] = user.value(forKey: property)
			}
		}
		
		self.init(value: userData)
	}
	
	override static func primaryKey() -> String? {
		return "uid"
	}
	
	static func isLoggedIn() -> Bool {
		return FIRAuth.auth()?.currentUser != nil
	}
	
	static var currentUserId: String {
		guard let uid = STUser.me()?.uid else { return "" }
		return uid
	}
	
	static func me() -> STUser? {
		
		guard let currentUID = UserDefaults.standard.object(forKey: kCurrentUserUID) as? String
		else {
			return nil
		}
		
		let realm = try! Realm()
		
		let currentUser = STRealmDB.query(fromRealm: realm, ofType: STUser.self, query: "uid = '\(currentUID)'").first

		return currentUser
	}
}

extension STUser: STRealmModel {
	
	static var properties: [String] {
		return ["uid", "displayName",
		        "email", "photoURL"]
	}

	func toDictionary() -> [String : Any] {
		var userData = [String: Any]()
		STUser.properties.forEach { (property) in
			userData[property] = self.value(forKey: property)
		}
		
		return userData
	}
}
