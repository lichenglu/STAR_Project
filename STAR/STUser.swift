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
	
	static func isLoggedIn() -> Bool {
		return FIRAuth.auth()?.currentUser != nil
	}
	
	static func me() -> STUser? {
		
		guard let currentUID = UserDefaults.standard.object(forKey: kCurrentUserUID) as? String
		else {
			return nil
		}
		
		let currentUser = STHelpers.queryFromRealm(ofType: STUser.self, query: "uid = '\(currentUID)'").first
		return currentUser
	}
}
