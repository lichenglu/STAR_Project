//
//  STDefines.swift
//  STAR
//
//  Created by chenglu li on 19/9/2016.
//  Copyright © 2016 Chenglu_Li. All rights reserved.
//

import Foundation
import Firebase

// MARK: - Notifications
let kUserLoginStatusDidChange = "userLoginStatusDidChange"
let kSavingItemStatusDidChange = "savingItemStatusDidChange"

// MARK: - Segue Identifiers

// MARK: - UserDefaults Keys
let kCurrentUserUID = "currentUserId"

// MARK: - Constant Keys
let kHierarchyCoverImage = "hierarchyCoverImage"

// MARK: - Enums
enum STUserLoginStatus {
	case loggedIn(user: FIRUser?)
	case failed(error: Error)
	case loggedOff
}

enum STColors: String{
	case bgColor = "#eeeeee"
	case themeBlue = "#1388CB"
	case shadowColor = "#000000"
	
	func toUIColor() -> UIColor {
		return UIColor(hexString: self.rawValue) ?? UIColor.red
	}
}

enum STStoryboardIds: String {
	case signInVC
	case archiveListVC
	case archiveDetailVC
	case toDoListVC
	case itemDetailVC
}

enum STImageNames: String {
	case emptyData = "placeholder_emptyData"
	
	func toUIImage() -> UIImage? {
		return UIImage(named: self.rawValue)
	}
}

enum STSegueIds: String {
	case authToRootView
}

struct STCache {
	static var imageCache = NSCache<NSString, UIImage>()
}
