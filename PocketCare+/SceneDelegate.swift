/*
Copyright 2020 University at Buffalo

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/

import UIKit
import Firebase

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
//    Version Naming based on Major.Minor.Patch
    let currentVersion = "1.1.4"
    var latestVersion = ""
    
    var isActive = false
    
    var window: UIWindow?
    var defaults = UserDefaults.standard
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(frame: windowScene.coordinateSpace.bounds)
        window?.windowScene = windowScene
        window?.backgroundColor = UIColor(red: 0/255, green: 91/255, blue: 187/255, alpha: 1.0)
        fetchVersionFromFirebase {
            if self.isActive == false {
                print("Is Active False")
                self.setupLatestUpdatedViews()
            }
        }
        
        window?.makeKeyAndVisible()
    }
    
    
    func fetchVersionFromFirebase(finished: @escaping () -> Void) {
            let db = Firestore.firestore()
            db.collection("Info").getDocuments { (querySnapshot, err) in

                if let err = err {
                    self.isActive = true
                    print("Is Active True 1")
                    print("Error getting documents", err)
                    self.setupLatestUpdatedViews()
                }
                else {
                        for document in querySnapshot!.documents {
                            let latest = document.data()["version"] as! String
                            print("Version Number: \(latest)")
                            self.latestVersion = latest
                    
                        if self.currentVersion != self.latestVersion {
                            print("different version")
                            self.isActive = true
                            print("Is Active True 2")
                            self.window?.rootViewController = UINavigationController(rootViewController:
                                UpdateController())
                        }
                        else {
                            self.isActive = true
                            print("Is Active True 3")
                            print("same version")
                            self.setupLatestUpdatedViews()
                        }
                    }
                }
                finished()
            }
    }
    
    func setupLatestUpdatedViews() {
        if self.defaults.bool(forKey: "hasEntered") == false {
            
            if defaults.bool(forKey: "grantPermissions") == true {
                
                 self.window?.rootViewController = UINavigationController(rootViewController: PermissionsController())
            }
            else {
                 self.window?.rootViewController = UINavigationController(rootViewController: WelcomeController())
            }
        } else {
            self.window?.rootViewController = TabBarController()
        }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not neccessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
        fetchVersionFromFirebase {
            if self.isActive == false {
                print("Is Active False")
                self.setupLatestUpdatedViews()
            }
        }
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        
        (UIApplication.shared.delegate as! AppDelegate).scheduleDailyKeyGeneration()
        //Added a 3 second delay once it goes into background mode
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            (UIApplication.shared.delegate as! AppDelegate).scheduleVBTNameGeneration()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            (UIApplication.shared.delegate as! AppDelegate).scheduleCheckAllBeacons()
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
            (UIApplication.shared.delegate as! AppDelegate).scheduleFetchZipcode()
        }
        
        (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
    }
}


