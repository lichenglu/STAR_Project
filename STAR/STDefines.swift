//
//  STDefines.swift
//  STAR
//
//  Created by chenglu li on 19/9/2016.
//  Copyright © 2016 Chenglu_Li. All rights reserved.
//

import Foundation

// Notifications
let kUserDidSuccessfullySignedIn = "userDidSuccessfullySignedIn"
let kUserDidFailToSignIn = "userDidFailToSignIn"
let kUserLoginStatusDidChange = "userLoginStatusDidChange"


enum STColors{
	case shadowGray
}

enum STUserLoginStatus {
	case loggedIn
	case failed(error: Error)
	case loggedOff
}
