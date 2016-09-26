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

// MARK: - Segue Identifiers

// MARK: - UserDefaults Keys
let kCurrentUserUID = "currentUserId"

// MARK: - Enums
enum STUserLoginStatus {
	case loggedIn(user: FIRUser?)
	case failed(error: Error)
	case loggedOff
}

enum STColors{
	case shadowGray
}
