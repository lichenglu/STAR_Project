//
//  STBox.swift
//  STAR
//
//  Created by chenglu li on 30/9/2016.
//  Copyright © 2016 Chenglu_Li. All rights reserved.
//

import Foundation
import RealmSwift
import Firebase

class STBox: STHierarchy, STContainer {
	
	let folders = List<STFolder>()
	
	override dynamic var _type: ReamlEnum {
		return ReamlEnum(value: ["rawValue": STHierarchyType.box.rawValue])
	}
	
	var children: [[AnyObject]] {
		
		var result = [[AnyObject]]()
		var tempArr = [AnyObject]()
		
		folders.forEach{ tempArr.append($0) }
		result.append(tempArr)
		
		return result
	}
	
	var hierarchyProperties: [String] {
		return ["folders"]
	}
	
	var firebaseRef: FIRDatabaseReference? {
		let realm = try! Realm()
		if let owner = STRealmDB.query(fromRealm: realm, ofType: STInstitution.self, query: "id = '\(ownerId!)'").first {
			return owner.firebaseRef.child("boxes").child(id)
		}else if let owner = STRealmDB.query(fromRealm: realm, ofType: STCollection.self, query: "id = '\(ownerId!)'").first {
			return owner.firebaseRef?.child("boxes").child(id)
		}
		return nil
	}
}
