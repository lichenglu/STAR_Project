//
//  AppDelegate.swift
//  STAR
//
//  Created by chenglu li on 19/9/2016.
//  Copyright © 2016 Chenglu_Li. All rights reserved.
//

import UIKit
import Firebase

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

	var window: UIWindow?
	
	lazy var archiveListVC: STArchiveListViewController? = {
		
		let appDelegate = UIApplication.shared.delegate
		
		if let tabBarVC = appDelegate?.window??.rootViewController as? UITabBarController,
			let navs = tabBarVC.viewControllers,
			let nav = navs[0] as? UINavigationController {
			
			let vcs = nav.viewControllers
			
			if let archiveListVC = vcs[0] as? STArchiveListViewController{
				return archiveListVC
			}
		}
		
		return nil
	}()
	
//	+ (SCSwiftNewDiscoverVC*)discoverViewController {
//	AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
//	UINavigationController *nav = [(UITabBarController *)appDelegate.window.rootViewController viewControllers][0];
//	SCSwiftNewDiscoverVC *discoverVC = nav.viewControllers[0];
//	return discoverVC;
//	}
	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
		
		// Configuration for firebase
		FIRApp.configure()
		
		// Google Login
		GIDSignIn.sharedInstance().clientID = FIRApp.defaultApp()?.options.clientID
		GIDSignIn.sharedInstance().delegate = self
		
		return true
	}

	func applicationWillResignActive(_ application: UIApplication) {
		// Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
		// Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
	}

	func applicationDidEnterBackground(_ application: UIApplication) {
		// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
		// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
	}

	func applicationWillEnterForeground(_ application: UIApplication) {
		// Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
	}

	func applicationDidBecomeActive(_ application: UIApplication) {
		// Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
	}

	func applicationWillTerminate(_ application: UIApplication) {
		// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
	}
	
	func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
		
		let appKeyOption = UIApplicationOpenURLOptionsKey.sourceApplication
		
		guard let sourceApplication = options[appKeyOption] as? String else {
			return false
		}
		
		return GIDSignIn.sharedInstance().handle(url as URL, sourceApplication: sourceApplication, annotation: nil)
	}
	
	func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
		return GIDSignIn.sharedInstance().handle(url, sourceApplication: sourceApplication,  annotation: annotation)
	}
}

extension AppDelegate: GIDSignInDelegate{
	
	func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
		
		if let error = error {
			print(error.localizedDescription)
			didFailToSignIn(error: error)
			return
		}
		
		guard let authentication = user.authentication else { return }
		let credential = FIRGoogleAuthProvider.credential(withIDToken: authentication.idToken, accessToken: authentication.accessToken)
		
		FIRAuth.auth()?.signIn(with: credential) { (user, error) in
			if error != nil {
				print(error?.localizedDescription)
				self.didFailToSignIn(error: error!)
			}
			
			STHelpers.postNotification(withName: kUserLoginStatusDidChange, userInfo: ["loginStatus": STUserLoginStatus.loggedIn(user: user)])
		}
	}
	
	func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
		// Perform any operations when the user disconnects from app here.
		STHelpers.postNotification(withName: kUserLoginStatusDidChange, userInfo: ["loginStatus": STUserLoginStatus.loggedOff])
	}
	
	// Helpers
	func didFailToSignIn(error: Error) {
		STHelpers.postNotification(withName: kUserLoginStatusDidChange, userInfo: ["loginStatus": STUserLoginStatus.failed(error: error)])
	}
}


