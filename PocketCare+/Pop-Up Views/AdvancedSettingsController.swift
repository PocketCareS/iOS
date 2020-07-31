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
import Foundation
import Eureka

class AdvancedSettingsController: FormViewController {
    let defaults = UserDefaults.standard

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViewController()
        
        self.tableView.backgroundColor = UIColor(red: 0/255, green: 91/255, blue: 187/255, alpha: 1.0)
        
        form +++ Section("Notifications")
        
            <<< SwitchRow() { row in
                row.title = "Social Distance Alert"
                row.cellStyle = UITableViewCell.CellStyle.subtitle
                row.value = self.defaults.bool(forKey: "socialDistanceNotification")
        }.cellUpdate { cell, _ in
            cell.detailTextLabel?.text = "Notifies when a close encounter session exceeds 10 minutes"
            cell.detailTextLabel?.numberOfLines = 0
            cell.height = {(100)}
            }.onChange({ (row) in
                if row.value == true {
                    self.defaults.set(true, forKey: "socialDistanceNotification")
                } else {
                    self.defaults.set(false, forKey: "socialDistanceNotification")
                }
            })
            
        
        <<< PickerInputRow<String>() { row in
            row.title = "Options to Snooze Notifications"
            row.cellStyle = UITableViewCell.CellStyle.subtitle
            row.options = ["None","Snooze for an hour","Snooze for a day"]
        }.cellUpdate { cell, row in
            
            cell.detailTextLabel?.numberOfLines = 0
            cell.height = {(100)}
            
            if row.value == nil {
                cell.detailTextLabel?.text = "Choose if/how to snooze the Social Distance Notification"
            }
        }.onChange({ (row) in
            row.cell.detailTextLabel?.text = row.value
            self.defaults.set(row.value, forKey: "snoozeNotificationsOptions")
        })
        
        
            <<< TimeRow() { row in
                row.title = "Health Report Reminder"
                row.cellStyle = UITableViewCell.CellStyle.subtitle
            }.cellUpdate({ (cell, row) in
                
                cell.height = {(100)}
                cell.detailTextLabel?.numberOfLines = 0
                
                if row.value == nil {
                    cell.detailTextLabel?.text = "Schedule a time for daily submissions"
                }
            }).onChange({ (row) in
                row.cell.detailTextLabel?.text = row.value?.description
                
                // What to do
                // First get the time convert it to military time
                // Then call scheduleNotification() in app delegate to reschedule
                // When you call scheduleNotification() it will automatically remove all
                // pending notifications (SO USER WON'T GET THE ONE AT 8 P.M.)
                // And pass in the time
                
            })
        
        
        form +++ Section("Close Encounter Scanning")
        
        <<< SwitchRow() { row in
                row.title = "Off-Campus Scanning"
                row.cellStyle = UITableViewCell.CellStyle.subtitle
        }.cellUpdate { cell, _ in
            cell.detailTextLabel?.text = "You can pause off-campus scanning by turning on this option"
            cell.detailTextLabel?.numberOfLines = 0
            cell.height = {(100)}
        }
        
        <<< TimeRow() { row in
            row.title = "Night-Time Start"
            row.cellStyle = UITableViewCell.CellStyle.subtitle

        }.cellUpdate({ (cell, row) in
            
            cell.height = {(100)}
            cell.detailTextLabel?.numberOfLines = 0
            
            if row.value == nil {
                cell.detailTextLabel?.text = "Schedule a time to turn off scanning after 8 PM"
            }
        }).onChange({ (row) in
            row.cell.detailTextLabel?.text = row.value?.description
        })
        
        <<< TimeRow() { row in
            row.title = "Night-Time End"
            row.cellStyle = UITableViewCell.CellStyle.subtitle
        }.cellUpdate({ (cell, row) in
            
            cell.height = {(100)}
            cell.detailTextLabel?.numberOfLines = 0
            
            if row.value == nil {
                cell.detailTextLabel?.text = "Schedule a time to resume scanning before 8 AM"
            }
        }).onChange({ (row) in
            row.cell.detailTextLabel?.text = row.value?.description
        })
        
    }
    
    func setupViewController() {
        title = "Advanced Settings"
        navigationController?.navigationBar.prefersLargeTitles = true
        view.backgroundColor = UIColor(red: 0/255, green: 91/255, blue: 187/255, alpha: 1.0)
        let textAttributes = [NSAttributedString.Key.foregroundColor:UIColor.white]
        navigationController?.navigationBar.largeTitleTextAttributes = textAttributes
        
        navigationController?.navigationBar.tintColor = .white
                
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.barTintColor = UIColor(red: 0/255, green: 91/255, blue: 187/255, alpha: 1.0)
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.white]
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let header = view as? UITableViewHeaderFooterView {
            header.backgroundView?.backgroundColor = UIColor.clear
            header.textLabel?.textColor = UIColor.white
        }
    }
}
