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

protocol STRealmModel: class {
	var properties: [String] { get }
	func toDictionary() -> [String: Any]
}

protocol STContainer: class {
	var children: [AnyObject] { get }
	var hierarchyProperties: [String] { get }
}

enum STHierarchyType: Int {
	case institution = 0, box, collection, volume, folder, item, unknown
	
	func toUIImage() -> UIImage {
		
		let key = kHierarchyCoverImage + "\(self.rawValue)" as NSString
		
		if let image = STCache.imageCache.object(forKey: key) {
			return image
		}else{
			print("toUIImage")
			let defaultImage = UIImage(named: "institution")
			let image = UIImage(named: "\(self)") ?? defaultImage!
			STCache.imageCache.setObject(image, forKey: key)
			return image
		}
	}
	
	func toBgColor() -> UIColor {
		
		let color: UIColor
		let defaultColor = STColors.bgColor.toUIColor()
		
		switch self {
		case .institution:
			color = UIColor(hexString: "#df6f1d") ?? defaultColor
		case .collection:
			color = UIColor(hexString: "#35aadc") ?? defaultColor
		case .box:
			color = UIColor(hexString: "#382e2c") ?? defaultColor
		case .volume:
			color = UIColor(hexString: "#40bdb9") ?? defaultColor
		case .folder:
			color = UIColor(hexString: "#455A64") ?? defaultColor
		case .item:
			color = UIColor(hexString: "#455A64") ?? defaultColor
		default:
			color = defaultColor
		}
		
		return color
	}
	
	func plural() -> String{
		if self == .box {
			return "boxes"
		}
		
		return "\(self)s"
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
	
	func getHierarchyImg() -> UIImage{
		return type.toUIImage()
	}
	
	func getBgColor() -> UIColor {
		return type.toBgColor()
	}
	
	var firebaseRef: FIRDatabaseReference? {
		guard (self.ownerId) != nil else { return nil }
		return STFirebaseDB.db.refUser
	}
	
	override static func primaryKey() -> String? {
		return "id"
	}
	
	convenience init(id: String, ownerId: String, title: String) {
		self.init(value: ["id": id, "ownerId": ownerId, "title": title])
	}
}

extension STHierarchy: STRealmModel {
	
	var properties: [String] {
		return [""]
	}
	
	func toDictionary() -> [String : Any] {
		var userData = [String: Any]()
		self.properties.forEach { (property) in
			userData[property] = self.value(forKey: property)
		}
		
		return userData
	}
}

class RealmString: Object {
	dynamic var stringValue = ""
}

class ReamlEnum: Object {
	dynamic var rawValue = 0
}
