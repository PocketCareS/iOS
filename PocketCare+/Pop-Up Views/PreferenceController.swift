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
import Eureka

class PreferenceController: FormViewController{
    
    let defaults:UserDefaults = UserDefaults.standard
    var initialLocationChange = true
    var initialBluetoothChange = true
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Preferences"
        
        self.tableView.backgroundColor = UIColor(red: 0/255, green: 91/255, blue: 187/255, alpha: 1.0)
        navigationController?.navigationBar.prefersLargeTitles = true
        
        let textAttributes = [NSAttributedString.Key.foregroundColor:UIColor.white]
        navigationController?.navigationBar.largeTitleTextAttributes = textAttributes
        
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.barTintColor = UIColor(red: 0/255, green: 91/255, blue: 187/255, alpha: 1.0)
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.white]
        
        
        form +++ Section("Location")
            <<< SwitchRow("Location") { row in
                row.title = "Location"
            }.onChange { row in
                if self.initialLocationChange {
                    self.initialLocationChange = false
                    if row.value! {
                        self.defaults.set("ON", forKey: "isLocationEnabled")
                    } else {
                        self.defaults.set("OFF", forKey: "isLocationEnabled")
                    }
                } else {
                    let isLocationEnabled = self.defaults.string(forKey: "isLocationEnabled")
                    switch(isLocationEnabled){
                    case "ON":
                        //Alert User
                        let alert = UIAlertController(title: "Warning", message: "Pocketcare+ will not work accurately if you disable location.", preferredStyle: .alert)
                        
                        alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: { _ in
                            self.defaults.set("OFF", forKey: "isLocationEnabled")
                            print("Location CHANGE = OFF")
                        }))
                        
                        self.present(alert, animated: true)
                        break
                    case "OFF":
                        self.defaults.set("ON", forKey: "isLocationEnabled")
                        print("Location CHANGE = ON")
                        break
                    default:
                        if row.value ?? true {
                            self.defaults.set("ON", forKey: "isLocationEnabled")
                        } else {
                            self.defaults.set("OFF", forKey: "isLocationEnabled")
                        }
                        print("DEFAULT CHANGE")
                        break
                    }
                }
            }.cellSetup { cell, row in
                cell.backgroundColor = .white
                let isLocationEnabled = self.defaults.string(forKey: "isLocationEnabled")
                switch(isLocationEnabled){
                case "ON":
                    print("Location EXIST = ON")
                    row.value = true
                    break
                case "OFF":
                    print("Location EXIST =  OFF")
                    row.value = false
                    break
                default:
                    print("DEFAULT SETUP")
                    row.value = true
                    break
                }
            }.cellUpdate { cell, row in
                cell.textLabel?.font = .systemFont(ofSize: 18.0)
        }
        form +++ Section("Bluetooth")
            <<< SwitchRow("Bluetooth") { row in
                row.title = "Bluetooth"
            }.onChange { row in
                if self.initialBluetoothChange {
                    self.initialBluetoothChange = false
                    if row.value! {
                        self.defaults.set("ON", forKey: "isBluetoothEnabled")
                    } else {
                        self.defaults.set("OFF", forKey: "isBluetoothEnabled")
                    }
                } else {
                    let isBluetoothEnabled = self.defaults.string(forKey: "isBluetoothEnabled")
                    switch(isBluetoothEnabled){
                    case "ON":
                        //Alert User
                        let alert = UIAlertController(title: "Warning", message: "Pocketcare+ will not work accurately if you disable bluetooth.", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: { _ in
                            self.defaults.set("OFF", forKey: "isBluetoothEnabled")
                            print("Bluetooth CHANGE = OFF")
                        }))
                        self.present(alert, animated: true)
                        break
                    case "OFF":
                        self.defaults.set("ON", forKey: "isBluetoothEnabled")
                        print("Bluetooth CHANGE = ON")
                        break
                    default:
                        if row.value ?? true {
                            self.defaults.set("ON", forKey: "isBluetoothEnabled")
                        } else {
                            self.defaults.set("OFF", forKey: "isBluetoothEnabled")
                        }
                        print("DEFAULT CHANGE")
                        break
                    }
                }
            }.cellSetup { cell, row in
                cell.backgroundColor = .white
                let isBluetoothEnabled = self.defaults.string(forKey: "isBluetoothEnabled")
                switch(isBluetoothEnabled){
                case "ON":
                    print("Bluetooth EXIST = ON")
                    row.value = true
                    break
                case "OFF":
                    print("Bluetooth EXIST =  OFF")
                    row.value = false
                    break
                default:
                    print("DEFAULT SETUP")
                    row.value = true
                    break
                }
            }.cellUpdate { cell, row in
                cell.textLabel?.font = .systemFont(ofSize: 18.0)
            }
//            <<< SliderRow("Proximity") { row in
//                if self.defaults.contains("proximityValue"){
//                    let proximityValue = self.defaults.float(forKey: "proximityValue")
//                    let proximitySliderValue = self.defaults.float(forKey: "proximitySliderValue")
//                    row.value = proximitySliderValue
//                    row.displayValueFor = { _ in
//                        return "\(proximityValue) dB"
//                    }
//                } else {
//                    self.defaults.set(-55.0, forKey: "proximityValue")
//                    self.defaults.set(0.0, forKey: "proximitySliderValue")
//                    row.value = 0
//                    row.displayValueFor = { _ in
//                        return "-55 dB"
//                    }
//                }
//                row.title = "Proximity"
//            }.cellUpdate { cell, row in
//                cell.textLabel?.font = .systemFont(ofSize: 18.0)
//            }.onChange { row in
//                let value = row.value
//                let proximityValue = Float(-55 - Int((value!) * 4.5)) // Changed line
//                print("Proximity change : \(proximityValue)")
//                row.displayValueFor = { _ in
//                    return "\(proximityValue) dB"
//                }
//                self.defaults.set(proximityValue, forKey: "proximityValue")
//                self.defaults.set(value, forKey: "proximitySliderValue")
//                row.updateCell()
//        }
        
        form +++ Section("Notifications")
            <<< SwitchRow("Notifications") { row in
                row.title = "Health Check Notifications"
            }.onChange { row in
                if row.value! {
                    UNUserNotificationCenter.current().getNotificationSettings { (settings) in
                        if settings.authorizationStatus == .authorized {
                            self.defaults.set(true, forKey: "isLocalNotificationsEnabled")
                            self.updateNotification()
                        } else {
                            row.value = false
                            self.openAppSettings()
                        }
                    }
                } else {
                    UNUserNotificationCenter.current().getNotificationSettings { (settings) in
                        if settings.authorizationStatus == .authorized {
                            self.defaults.set(false, forKey: "isLocalNotificationsEnabled")
                            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["healthReportNotification"])
                        }
                    }
                }
            }.cellSetup { cell, row in
                UNUserNotificationCenter.current().getNotificationSettings { (settings) in
                    if settings.authorizationStatus == .authorized {
                        if self.defaults.contains("isLocalNotificationsEnabled"){
                            if self.defaults.bool(forKey: "isLocalNotificationsEnabled"){
                                row.value = true
                            } else {
                                row.value = false
                            }
                        } else {
                            row.value = true
                            self.defaults.set(true, forKey: "isLocalNotificationsEnabled")
                        }
                    }
                    else {
                        row.value = false
                    }
                }
                cell.backgroundColor = .white
            }.cellUpdate { cell, row in
                cell.textLabel?.font = .systemFont(ofSize: 18.0)
            }
            
            <<< TimeRow("Health Report Time") { row in
                row.title = "Health Report Time"
                let calendar: Calendar = Calendar(identifier: .gregorian)
                if self.defaults.contains("notificationTime"){
                    let timeInformation = self.defaults.object(forKey: "notificationTime") as? [Int] ?? [Int]()
                    if timeInformation.count == 2 {
                        row.value = calendar.date(bySettingHour: timeInformation[0], minute: timeInformation[1], second: 0, of: Date())!
                    }
                } else {
                    let date: Date = Date()
                    row.noValueDisplayText = "8:00 PM"
                    row.value = calendar.date(bySettingHour: 20, minute: 0, second: 0, of: date)!
                }
                self.updateNotification()
            }.onChange { row in
                if let date = row.value {
                    var timeInformation:[Int] = []
                    let calendar = Calendar.current
                    let hour = calendar.component(.hour, from: date)
                    let minutes = calendar.component(.minute, from: date)
                    timeInformation.append(hour)
                    timeInformation.append(minutes)
                    self.defaults.set(timeInformation, forKey: "notificationTime")
                    self.updateNotification()
                    print("\(hour) and \(minutes)")
                }
                row.updateCell()
            }.cellSetup { cell, row in
                cell.backgroundColor = .white
            }.cellUpdate { cell, row in
                cell.textLabel?.font = .systemFont(ofSize: 18.0)
        }
    }
    
    func openAppSettings(){
        DispatchQueue.main.async {
            if let bundleIdentifier = Bundle.main.bundleIdentifier, let appSettings = URL(string: UIApplication.openSettingsURLString + bundleIdentifier) {
                if UIApplication.shared.canOpenURL(appSettings) {
                    UIApplication.shared.open(appSettings)
                }
            }
        }
    }
    
    func updateNotification(){
        let center =  UNUserNotificationCenter.current()
        let content = UNMutableNotificationContent()
        content.title = "Report Time"
        content.body = "Hey you haven't reported your health status for the day. Click here to report it now"
        content.sound = UNNotificationSound.default
        let calendar: Calendar = Calendar(identifier: .gregorian)
        if defaults.contains("notificationTime"){
            //Setting user specified time
            let timeInformation = self.defaults.object(forKey: "notificationTime") as? [Int] ?? [Int]()
            if timeInformation.count == 2 {
                let alertDate = calendar.date(bySettingHour: timeInformation[0], minute: timeInformation[1], second: 0, of: Date())!
                let triggerDaily = Calendar.current.dateComponents([.hour, .minute, .second], from: alertDate)
                let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDaily, repeats: true)
                let request = UNNotificationRequest(identifier: "healthReportNotification", content: content, trigger: trigger)
                center.add(request) { (error) in
                    if error != nil {
                        print("error \(String(describing: error))")
                    }
                }
            }
        } else {
            //Setting default time as 8:00 pm
            let alertDate = calendar.date(bySettingHour: 20, minute: 0, second: 0, of: Date())!
            let triggerDaily = Calendar.current.dateComponents([.hour, .minute, .second], from: alertDate)
            let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDaily, repeats: true)
            let request = UNNotificationRequest(identifier: "Health Report Notification", content: content, trigger: trigger)
            center.add(request) { (error) in
                if error != nil {
                    print("error \(String(describing: error))")
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let header = view as? UITableViewHeaderFooterView {
            header.backgroundView?.backgroundColor = UIColor.clear
            header.textLabel?.textColor = UIColor.white
        }
    }
}


extension UserDefaults{
    func contains(_ key: String) -> Bool {
        return UserDefaults.standard.object(forKey: key) != nil
    }
}

