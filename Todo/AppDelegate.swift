//
//  AppDelegate.swift
//  PactTodo
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        if ProcessInfo.processInfo.arguments.contains(TestEnvironmentStubInfo.kUseHttpStubs) {
            setupStubs(ProcessInfo.processInfo.environment)
        }
        
        return true
    }
    
    func setupStubs(_ environment: [String: String]) {
        print("================================")
        print("🚚 REGISTER STUBS")
        print("--------------------------------")
        for (key, value) in environment {
            guard TestEnvironmentStubInfo.isStubInfo(key),
                let stubInfo = TestEnvironmentStubInfo(environmentKey: key, value: value)
                else {
                    continue
            }
            
            stub(withTestEnvironmentInfo:stubInfo)
            print("STUB: \(stubInfo.description)")
        }
        print("================================")
    }
}
