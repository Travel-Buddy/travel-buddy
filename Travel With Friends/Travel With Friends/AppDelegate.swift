//
//  AppDelegate.swift
//  Travel With Friends
//
//  Created by Kevin Thrailkill on 4/23/17.
//  Copyright © 2017 kevinthrailkill. All rights reserved.
//

import UIKit
import FacebookCore
import GooglePlaces
import Parse
import ParseFacebookUtilsV4

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        
        Parse.initialize(with: ParseClientConfiguration(block: { (configuration: ParseMutableClientConfiguration) in
            configuration.applicationId = "travel-buddy"
            configuration.server = "https://morning-dusk-12610.herokuapp.com/parse"
        }))
        
        
        PFFacebookUtils.initializeFacebook(applicationLaunchOptions: launchOptions)

        
        //google places setup
        GMSPlacesClient.provideAPIKey("AIzaSyD-suG8UH-JaQ6ZEsXWbpnfe0gTZq1u380")
        
        
        if let _ = PFUser.current() {
            // Do stuff with the user
            
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            
            let tripViewController = storyboard.instantiateViewController(withIdentifier: "TripsNavigationController") as! UINavigationController
            
            window?.rootViewController = tripViewController
 
        }
        
        setAppearance()
        
        
        //Observer for if the user logs out
        NotificationCenter.default.addObserver(forName: NSNotification.Name("UserDidLogout"), object: nil, queue: OperationQueue.main) { (NSNotification) ->
            Void in
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let loginVC = storyboard.instantiateInitialViewController()
            self.window?.rootViewController = loginVC
        }
        
        
        
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        return SDKApplicationDelegate.shared.application(app, open: url, options: options)
        
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
        
        //lets fb analytics know that app is being used
         AppEventsLogger.activate(application)
        
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func setAppearance() {
        let attributes: [String: AnyObject] = [
            NSFontAttributeName: UIFont.Headings.NavHeading,
            NSForegroundColorAttributeName: UIColor.FlatColor.White.Background
        ]
        
        UINavigationBar.appearance().titleTextAttributes = attributes
        UINavigationBar.appearance().barTintColor = UIColor.FlatColor.Blue.BarTint
        UINavigationBar.appearance().tintColor = UIColor.FlatColor.White.NavBarTextTint
    }
    


}

