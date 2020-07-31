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
import CoreLocation

class TabBarController: UITabBarController, CLLocationManagerDelegate {
    
//    let locationManager = CLLocationManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        
//        locationManager.delegate = self
        
        let fontConfiguration = UIFont.systemFont(ofSize: 20)
        
        tabBar.barTintColor = UIColor(red: 0/255, green: 91/255, blue: 187/255, alpha: 1.0)
        
        tabBar.unselectedItemTintColor = .white
        UITabBar.appearance().tintColor = .black
        
        let homeTabBarItem = UITabBarItem(title: "Home", image: UIImage(systemName: "house.fill", withConfiguration: UIImage.SymbolConfiguration(font: fontConfiguration, scale: .large))?.withRenderingMode(.alwaysTemplate), selectedImage: UIImage(systemName: "house.fill", withConfiguration: UIImage.SymbolConfiguration(font: fontConfiguration, scale: .large))?.withRenderingMode(.alwaysTemplate))
        
        let healthReportsTabBarItem = UITabBarItem(title: "Reports", image: UIImage(systemName: "doc.plaintext", withConfiguration: UIImage.SymbolConfiguration(font: fontConfiguration, scale: .large)), selectedImage: UIImage(systemName: "doc.plaintext", withConfiguration: UIImage.SymbolConfiguration(font: fontConfiguration, scale: .large)))
        
        let powerSavingTabBarItem = UITabBarItem(title: "", image: UIImage(named: "powerSavingButton")?.withRenderingMode(.alwaysOriginal), selectedImage: UIImage(named: "powerSavingButton"))
        
        let closeEncountersTabBarItem = UITabBarItem(title: "Encounters", image: UIImage(systemName: "antenna.radiowaves.left.and.right", withConfiguration: UIImage.SymbolConfiguration(font: fontConfiguration, scale: .large)), selectedImage: UIImage(systemName: "antenna.radiowaves.left.and.right", withConfiguration: UIImage.SymbolConfiguration(font: fontConfiguration, scale: .large)))
                        
        let settingsTabBarItem = UITabBarItem(title: "Settings", image: UIImage(systemName: "gear", withConfiguration: UIImage.SymbolConfiguration(font: fontConfiguration, scale: .large)), selectedImage: UIImage(systemName: "gear", withConfiguration: UIImage.SymbolConfiguration(font: fontConfiguration, scale: .large)))

        
        let viewController1 = UINavigationController(rootViewController: ViewController())
        viewController1.tabBarItem = homeTabBarItem
        
        let viewController2 = UINavigationController(rootViewController: HealthReportsController())
        viewController2.tabBarItem = healthReportsTabBarItem
        
        let viewController3 = PowerSaveModeController()
        viewController3.tabBarController?.tabBar.isHidden = true
        viewController3.tabBarItem = powerSavingTabBarItem
        
        let viewController4 = UINavigationController(rootViewController: BeaconController())
        viewController4.tabBarItem = closeEncountersTabBarItem
        
        let viewController5 = UINavigationController(rootViewController: SettingsController())
        viewController5.tabBarItem = settingsTabBarItem
                
        viewControllers = [viewController1, viewController2, viewController3, viewController4, viewController5]
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        //checkLocationServices()
        
        print("Tab Bar Controller")
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    private var bounceAnimation: CAKeyframeAnimation = {
        let bounceAnimation = CAKeyframeAnimation(keyPath: "transform.scale")
        bounceAnimation.values = [1.0, 1.4, 0.9, 1.02, 1.0]
        bounceAnimation.duration = TimeInterval(0.3)
        bounceAnimation.calculationMode = CAAnimationCalculationMode.cubic
        return bounceAnimation
    }()

    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        guard let idx = tabBar.items?.firstIndex(of: item), tabBar.subviews.count > idx + 1, let imageView = tabBar.subviews[idx + 1].subviews.compactMap({ $0 as? UIImageView }).first else {
            return
        }
        imageView.layer.add(bounceAnimation, forKey: nil)
    }
}

extension TabBarController {
    
    func checkLocationServices(){
        if CLLocationManager.locationServicesEnabled() {
            checkLocationAuthorization()
        }
        else {
            let title = "Location Services Turned Off"
            let message = "We could not access your location because Location Services are turned off. To turn Location Services on, go to Settings > Privacy > Turn Location Services On"
            showSingleActionAlertToUser(with: title, and: message)
        }
    }
    
    func checkLocationAuthorization(){
        //@CHECK title and message
        switch CLLocationManager.authorizationStatus() {
            
        case .authorizedWhenInUse:
            let title = "Please allow Always access to Location"
            let message = "The app requires location access to be always allowed. To allow access, go to Settings > PocketCare S > Change location permissions to Always."
//            "The app works best when location access has been always allowed. To allow access, go to Settings > PocketCare S > Change location permissions to Always."
            showDoubleActionAlertToUser(with: title, and: message)
            
        case .denied:
            let title = "Location access not granted"
            let message = "We did not receive permission to access your location. We need location permissions in order to enable close encounter scanning. To allow access, go to Settings > PocketCare S > Change location permissions to Always."
            showDoubleActionAlertToUser(with: title, and: message)
            
        case .notDetermined:
            break
            
        case .restricted:
            break
            
        case .authorizedAlways:
            print("Authorized Always")
            break
        }
    }
    
    func showSingleActionAlertToUser(with title: String, and message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Okay", style: .cancel, handler: nil))
        
        self.present(alert, animated: true)
    }
    
    func showDoubleActionAlertToUser(with title: String, and message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Later", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Go to Settings", style: .default, handler: { (action) in
            
            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                return
            }
            
            if UIApplication.shared.canOpenURL(settingsUrl) {
                UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                    print("Settings opened: \(success)") // Prints true
                })
            }
        }))
        
        self.present(alert, animated: true)
    }
}

