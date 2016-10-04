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

class STUser: STBaseModel{
	
	dynamic var uid: String!
	dynamic var displayName: String? = nil
	dynamic var email: String? = nil
	dynamic var photoURL: String? = nil
	
	var institutions: Results<STInstitution> {
		if let realm = self.realm {
			return realm.objects(STInstitution.self).filter("ownerId = '\(uid)'")
		} else {
			return RealmSwift.List<STInstitution>().filter("1 != 1")
		}
	}
	
	convenience init(withFIRUser user: FIRUser) {
		
		self.init()
		
		self.properties.forEach { (property) in
			
			if(property == "photoURL") {
				if let photoURL = user.value(forKey: property) as? URL{
					print("photoURL.absoluteURL \(photoURL.absoluteString)")
					self.setValue(photoURL.absoluteString, forKey: property)
				}
			}else {
				self.setValue(user.value(forKey: property), forKey: property)
			}
		}
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
	
	var properties: [String] {
		return ["uid", "displayName",
		        "email", "photoURL"]
	}

	func toDictionary() -> [String : Any] {
		var userData = [String: Any]()
		self.properties.forEach { (property) in
			userData[property] = self.value(forKey: property)
		}
		userData["institutions"] = Array(institutions.map({ (institution) -> [String : Any] in
			return institution.toDictionary()
		}))
		
		return userData
	}
}
