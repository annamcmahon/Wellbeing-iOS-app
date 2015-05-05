//
//  AppDelegate.swift
//  WellnessApp
//
//  Created by Anna Jo McMahon on 4/11/15.
//  Copyright (c) 2015 anna. All rights reserved.
//

import UIKit
import Parse
import Bolts

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
	var currentUser: PFUser?
	//var homeTableViewController: homeTableViewController?
	
	var window: UIWindow?
	var sendTime: NSDate = NSDate().dateByAddingTimeInterval(10)
	var allNotificationsForApp: [UILocalNotification]?
	var dataShouldBeReset: Bool?
	
	
	func reset() ->Bool{
		return dataShouldBeReset!
	}
	
	func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
		dataShouldBeReset = true 
		initializeParse()
		setRootViewController();
		//updateParseLocalDataStore()
		//homeTableViewController().maketheobjectswithLocalDataStore()

	//	UIApplication.sharedApplication().cancelAllLocalNotifications()
		
		application.setMinimumBackgroundFetchInterval(UIApplicationBackgroundFetchIntervalMinimum)
		var minfetch = UIApplicationBackgroundFetchIntervalMinimum
		
		//if application.respondsToSelector("registerUserNotificationSettings:") {
			let types:UIUserNotificationType = (.Alert | .Badge | .Sound)
			let settings:UIUserNotificationSettings = UIUserNotificationSettings(forTypes: types, categories: nil)
			application.registerUserNotificationSettings(settings)
			application.registerForRemoteNotifications()
		//}
		

		return true
	}
	
	func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
		
		println("didRegisterForRemoteNotificationsWithDeviceToken")
		let currentInstallation = PFInstallation.currentInstallation()
		currentInstallation.setDeviceTokenFromData(deviceToken)
		currentInstallation.saveInBackgroundWithBlock { (succeeded, e) -> Void in
			//code
		}
	}
	
	func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
		println("failed to register for remote notifications:  (error)")
	}
	
	func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
		println("didReceiveRemoteNotification")
		PFPush.handlePush(userInfo)
	}
	
	func application(application: UIApplication,didRegisterUserNotificationSettings
		notificationSettings: UIUserNotificationSettings){
			
			if notificationSettings.types == nil{
				/* The user did not allow us to send notifications */
				return
			}
			//updateParseLocalDataStore()
	}


	
	func applicationDidEnterBackground(application: UIApplication) {
		// Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
		// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
		print("entering background")
	}

	func applicationWillTerminate(application: UIApplication) {
		// Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
		print("terminating")

	}
	func applicationWillEnterForeground(application: UIApplication) {
		println("Hello again world")
		homeTableViewController().maketheobjectswithLocalDataStore()
	}
	
	func initializeParse(){
		Parse.enableLocalDatastore()
		// Initialize Parse.
		Parse.setApplicationId("wFcqaTXYYCeNqKJ8wswlwtXChEzJyFyBV7N5JOZX",
			clientKey: "MomzqWhPQSVPNZ6hNjXtSSs6Lah5OMQCE8p4amsW")
	}
	
	func clearCurrentLocalData(){
		PFObject.unpinAllObjects()
		//UIApplication.sharedApplication().cancelAllLocalNotifications()
	}

	
	func updateParseLocalDataStore(){
		var querysurveyStrings: [String] = [String]()
		var query: PFQuery = PFQuery(className:"SurveySummary")
		query.findObjectsInBackgroundWithBlock {
			(objects: [AnyObject]?, error: NSError?) -> Void in
			if error == nil {
				if let objects = objects as? [PFObject] {
					PFObject.pinAllInBackground(objects)
					for ob in objects{
						querysurveyStrings.append(ob["Survey"] as! String)
					}
				for surveyString in querysurveyStrings{
					var querysurvey = PFQuery(className: surveyString)
					querysurvey.findObjectsInBackgroundWithBlock {
						(objects: [AnyObject]?, error: NSError?) -> Void in
						if error == nil {
							if let objects = objects as? [PFObject] {
								PFObject.pinAllInBackground(objects)
								
								NSThread.exit()
							}
						}
					}
				}
					
					//homeTableViewController().maketheobjectswithLocalDataStore()
					//homeTableViewController().tableView.setNeedsDisplay()
					homeTableViewController().setReset()
				}
			}else {
				println("FAILED HERE")
				println("Error: \(error) \(error!.userInfo!)")
			}
		}
	}
	
	func updateTheData(){
		var persistentInt:Int {
			get {
				return NSUserDefaults.standardUserDefaults().objectForKey("persistent Int") as! Int
			}
			set {
				NSUserDefaults.standardUserDefaults().setInteger(newValue, forKey: "persistent Int")
			}
		}
		
		
		
	
	}
	func application(application: UIApplication, performFetchWithCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
		
		//clearCurrentLocalData()
		let currentDate = NSDate()
		let calendar = NSCalendar.currentCalendar()
		let components = calendar.components(.CalendarUnitHour | .CalendarUnitMinute, fromDate:  NSDate())
		let currentHour = components.hour
		
		if(currentHour<13){
			//PFObject.unpinAllObjects()
			//clearCurrentLocalData()
			//updateParseLocalDataStore()
		
			var unPinSuccess = false
					var querysurveyStrings: [String] = [String]()
					var query: PFQuery = PFQuery(className:"SurveySummary")
					query.findObjectsInBackground().continueWithSuccessBlock({
						(task: BFTask!) -> AnyObject! in
						return PFObject.unpinAllObjectsInBackground().continueWithSuccessBlock({
							(ignored: BFTask!) -> AnyObject! in
							let AllSurveys = task.result as? NSArray
								for ob in AllSurveys! {
									var surveyString = ob["Survey"] as! String
									query = PFQuery(className: surveyString)
									query.findObjectsInBackground().continueWithSuccessBlock({
										(task: BFTask!) -> AnyObject! in
										return PFObject.unpinAllObjectsInBackground().continueWithSuccessBlock({
											(ignored: BFTask!) -> AnyObject! in
											let allQuestions = task.result as? NSArray
											return PFObject.pinAllInBackground(allQuestions as? [AnyObject])
										})
									})
							}
							homeTableViewController().maketheobjectswithLocalDataStore()
							unPinSuccess = true
							return PFObject.pinAllInBackground(AllSurveys as? [AnyObject])
							})
					})
			completionHandler(UIBackgroundFetchResult.NewData)

			if unPinSuccess {
					NSThread.exit()
			}
			
				}
		}
	
	func setRootViewController(){
				self.currentUser = PFUser.currentUser()
				var storyboard = UIStoryboard(name: "Main", bundle: nil)
		
				if let cUser = PFUser.currentUser() {
					var appdelegate = UIApplication.sharedApplication().delegate as! AppDelegate
					appdelegate.window?.rootViewController = (storyboard.instantiateInitialViewController() as! UINavigationController)
				}
				else{
					var loginviewController = storyboard.instantiateViewControllerWithIdentifier("loginView") as! UIViewController;
					self.window!.rootViewController = loginviewController
				}
	}

	
}
