//
//  STModelBase.swift
//  STAR
//
//  Created by chenglu li on 29/9/2016.
//  Copyright © 2016 Chenglu_Li. All rights reserved.
//

import Foundation
import RealmSwift
import Firebase

protocol STRealmModel {
	static var properties: [String] { get }
	func toDictionary() -> [String: Any]
}

protocol STContainer: class {
	var children: [AnyObject] { get }
	var hierarchyProperties: [String] { get }
}

enum STHierarchyType: Int {
	case institution = 0, box, collection, volume, folder, unknown
	
	func toUIImage() -> UIImage {
		
		print("toUIImage")
		
		let defaultImage = UIImage(named: "institution")

		switch self {
		case .institution:
			return UIImage(named: "institution") ?? defaultImage!
		case .box:
			return UIImage(named: "box") ?? defaultImage!
		case .collection:
			return UIImage(named: "collection") ?? defaultImage!
		case .volume:
			return UIImage(named: "volume") ?? defaultImage!
		default:
			return defaultImage!
		}
	}
}

class STBaseModel: Object {
	
}

class STHierarchy: STBaseModel {
	
	dynamic var id: String = NSUUID().uuidString
	dynamic var title: String!
	dynamic var owner: STBaseModel? {
		willSet{
			guard let owner = owner else { return }
			if let ownerData = owner as? STUser {
				ownerId = ownerData.uid
			}else if let ownerData = owner as? STHierarchy {
				ownerId = ownerData.id
			}
		}
	}
	
	dynamic var ownerId: String!
	
	var type: STHierarchyType {
		guard let type = STHierarchyType(rawValue: _type.rawValue) else {
			return STHierarchyType.unknown
		}
		return type
	}
	
	dynamic var _type: ReamlEnum {
		return ReamlEnum()
	}
	
	func imageForHierarchy() -> UIImage{
		return type.toUIImage()
	}
	
	override static func primaryKey() -> String? {
		return "id"
	}
	
	convenience init(id: String, ownerId: String, title: String) {
		self.init(value: ["id": id, "ownerId": ownerId, "title": title])
	}
}


class RealmString: Object {
	dynamic var stringValue = ""
}

class ReamlEnum: Object {
	dynamic var rawValue = 0
}
