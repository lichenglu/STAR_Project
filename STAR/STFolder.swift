//
//  STFolder.swift
//  STAR
//
//  Created by chenglu li on 30/9/2016.
//  Copyright © 2016 Chenglu_Li. All rights reserved.
//

import Foundation
import RealmSwift
import Firebase

class STFolder: STHierarchy, STContainer {
	
	var items: Results<STItem> {
		if let realm = self.realm {
			return realm.objects(STItem.self).filter("ownerId = '\(id)'")
		} else {
			return RealmSwift.List<STItem>().filter("1 != 1")
		}
	}
	
	override dynamic var _type: ReamlEnum {
		return ReamlEnum(value: ["rawValue": STHierarchyType.folder.rawValue])
	}
	
	var children: [AnyObject]  {
		
		return [items]
	}
	
	var hierarchyProperties: [String] {
		return ["items"]
	}
	
	override var firebaseRef: FIRDatabaseReference? {
		let realm = try! Realm()
		let owner = STRealmDB.query(fromRealm: realm, ofType: STBox.self, query: "id = '\(ownerId!)'").first
		return owner?.firebaseRef?.child("folders").child(id)
	}
}

extension STFolder {
	
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
