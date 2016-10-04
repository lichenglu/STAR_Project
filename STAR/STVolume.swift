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
	
	var items: Results<STItem> {
		if let realm = self.realm {
			return realm.objects(STItem.self).filter("ownerId = '\(id)'")
		} else {
			return RealmSwift.List<STItem>().filter("1 != 1")
		}
	}

	override dynamic var _type: ReamlEnum {
		return ReamlEnum(value: ["rawValue": STHierarchyType.volume.rawValue])
	}
	
	var children: [AnyObject]  {
		
		return [items]
	}
	
	var hierarchyProperties: [String] {
		return ["items"]
	}
	
	override var firebaseRef: FIRDatabaseReference? {
		let realm = try! Realm()
		if let owner = STRealmDB.query(fromRealm: realm, ofType: STInstitution.self, query: "id = '\(ownerId!)'").first {
			return owner.firebaseRef?.child("volumes").child(id)
		}else if let owner = STRealmDB.query(fromRealm: realm, ofType: STCollection.self, query: "id = '\(ownerId!)'").first {
			return owner.firebaseRef?.child("volumes").child(id)
		}
		return nil
	}
}

extension STVolume {
	
	override var properties: [String] {
		return ["id", "title", "ownerId"]
	}
	
	override func toDictionary() -> [String : Any] {
		var userData = [String: Any]()
		self.properties.forEach { (property) in
			userData[property] = self.value(forKey: property)
		}
		
		userData["items"] = Array(self.items.map({ (item) -> [String : Any] in
			return item.toDictionary()
		}))
		
		return userData
	}
}

