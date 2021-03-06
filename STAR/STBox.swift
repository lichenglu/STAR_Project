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
	
	var folders: Results<STFolder> {
		if let realm = self.realm {
			return realm.objects(STFolder.self).filter("ownerId = '\(id)'")
		} else {
			return RealmSwift.List<STFolder>().filter("1 != 1")
		}
	}
	
	override dynamic var _type: ReamlEnum {
		return ReamlEnum(value: ["rawValue": STHierarchyType.box.rawValue])
	}
	
	var children: [AnyObject] {
		
		return [folders]
	}
	
	var hierarchyProperties: [String] {
		return ["folders"]
	}
	
	override var firebaseRef: FIRDatabaseReference? {
		let realm = try! Realm()
		if let owner = STRealmDB.query(fromRealm: realm, ofType: STInstitution.self, query: "id = '\(ownerId!)'").first {
			return owner.firebaseRef?.child("boxes").child(id)
		}else if let owner = STRealmDB.query(fromRealm: realm, ofType: STCollection.self, query: "id = '\(ownerId!)'").first {
			return owner.firebaseRef?.child("boxes").child(id)
		}
		return nil
	}
}

extension STBox {
	
	override var properties: [String] {
		return ["id", "title", "ownerId"]
	}
	
	override func toDictionary() -> [String : Any] {
		var userData = [String: Any]()
		self.properties.forEach { (property) in
			userData[property] = self.value(forKey: property)
		}
		userData["folders"] = Array(self.folders.map({ (folder) -> [String : Any] in
			return folder.toDictionary()
		}))
		
		return userData
	}
}
