//
//  STVolume.swift
//  STAR
//
//  Created by chenglu li on 30/9/2016.
//  Copyright © 2016 Chenglu_Li. All rights reserved.
//

import Foundation
import RealmSwift
import Firebase

class STVolume: STHierarchy, STContainer {
	let items = List<STItem>()
	
	override dynamic var _type: ReamlEnum {
		return ReamlEnum(value: ["rawValue": STHierarchyType.volume.rawValue])
	}
	
	var children: [AnyObject]  {
		
		return [items]
	}
	
	var hierarchyProperties: [String] {
		return ["items"]
	}
	
	var firebaseRef: FIRDatabaseReference? {
		let realm = try! Realm()
		if let owner = STRealmDB.query(fromRealm: realm, ofType: STInstitution.self, query: "id = '\(ownerId!)'").first {
			return owner.firebaseRef.child("volumes").child(id)
		}else if let owner = STRealmDB.query(fromRealm: realm, ofType: STCollection.self, query: "id = '\(ownerId!)'").first {
			return owner.firebaseRef?.child("volumes").child(id)
		}
		return nil
	}
}

