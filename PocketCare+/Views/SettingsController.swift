import UIKit
import Eureka
import SafariServices
import MessageUI

class SettingsController: FormViewController {
    
    let defaults = UserDefaults.standard
    
    let privacyPolicyURL = "https://www.buffalo.edu/administrative-services/policy1/ub-policy-lib/privacy.html"
    let featuresURL = "https://engineering.buffalo.edu/computer-science-engineering/pocketcares.html#title_1231067861"
    let faqURL = "https://engineering.buffalo.edu/computer-science-engineering/pocketcares.html#title_1964739023"
    let websiteURL = "https://engineering.buffalo.edu/computer-science-engineering/pocketcares.html"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Settings"
        
        self.tableView.backgroundColor = UIColor(red: 0/255, green: 91/255, blue: 187/255, alpha: 1.0)
        navigationController?.navigationBar.prefersLargeTitles = true
        
        let textAttributes = [NSAttributedString.Key.foregroundColor:UIColor.white]
        navigationController?.navigationBar.largeTitleTextAttributes = textAttributes
        
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.barTintColor = UIColor(red: 0/255, green: 91/255, blue: 187/255, alpha: 1.0)
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.white]
        
        if defaults.bool(forKey: "developerMode") == true {
            navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "chevron.left.slash.chevron.right"), style: .plain, target: self, action: #selector(handleDeveloperMode))
        }
        else {
            
        }
        
        form +++ Section("Information")
            
            <<< ButtonRow(){ row in
                row.title = "User Profile"
            }.cellUpdate { cell, row in
                cell.textLabel?.textColor = UIColor.black
                cell.backgroundColor = UIColor.white
                cell.accessoryType = .disclosureIndicator
                cell.textLabel?.textAlignment = .left
            }.onCellSelection({ (_, _) in
                let upc = UINavigationController(rootViewController:
                    UserProfileController())
                self.present(upc, animated: true, completion: nil)
            })
            
            <<< ButtonRow(){ row in
                row.title = "About PocketCare S"
            }.cellUpdate { cell, row in
                cell.textLabel?.textColor = UIColor.black
                cell.backgroundColor = UIColor.white
                cell.accessoryType = .disclosureIndicator
                cell.textLabel?.textAlignment = .left
            }.onCellSelection({ (_, _) in
                let ac = UINavigationController(rootViewController:
                    AboutController())
                self.present(ac, animated: true, completion: nil)
            })
        
        <<< ButtonRow(){ row in
                        row.title = "What is Power Saving Mode?"
                    }.cellUpdate { cell, row in
                        cell.textLabel?.textColor = UIColor.black
                        cell.backgroundColor = UIColor.white
                        cell.textLabel?.textAlignment = .left
                        cell.accessoryType = .disclosureIndicator
                    }.onCellSelection({ (_, _) in
                        let psic = UINavigationController(rootViewController:
                            PowerSaveInfoController())
                        self.present(psic, animated: true, completion: nil)
                    })
        
        <<< ButtonRow(){ row in
            guard let appVersion = UIApplication.appVersion else { return }
            row.title = "Current Version: \(appVersion)"
            
        }.cellUpdate { cell, row in
            cell.textLabel?.textColor = UIColor.black
            cell.backgroundColor = UIColor.white
            cell.textLabel?.textAlignment = .left
            
            let tap = UITapGestureRecognizer(target: self, action: #selector(self.doubleTapped))
            tap.numberOfTapsRequired = 10
            cell.addGestureRecognizer(tap)
            
        }.onCellSelection({ (_, _) in
        })
        
        
        form +++ Section("Preferences") { section in
            section.header?.height = {(30)}
        }
        
            <<< ButtonRow() { row in
                row.title = "Advanced Settings"
            }.cellUpdate({ (cell, row) in
                cell.textLabel?.textColor = UIColor.black
                cell.backgroundColor = UIColor.white
                cell.textLabel?.textAlignment = .left
                cell.accessoryType = .disclosureIndicator
            }).onCellSelection({ (cell, row) in
                let asc = AdvancedSettingsController()
                self.navigationController?.pushViewController(asc, animated: true)
            })

        
        
        
        form +++ Section("Links") { section in
            section.header?.height = {(30)}
        }
        
        <<< ButtonRow(){ row in
                            row.title = "Privacy Policy"
                        }.cellUpdate { cell, row in
                            cell.textLabel?.textColor = UIColor.black
                            cell.backgroundColor = UIColor.white
                            cell.textLabel?.textAlignment = .left
                            cell.accessoryType = .disclosureIndicator
                    }.onCellSelection({ (_, _) in
                        guard let url = URL(string: self.privacyPolicyURL) else {
                            return
                        }
                        let safariVC = SFSafariViewController(url: url)
                        self.present(safariVC, animated: true, completion: nil)
                    })
            
                    
                    <<< ButtonRow(){ row in
                        row.title = "Features"
                    }.cellUpdate { cell, row in
                        cell.textLabel?.textColor = UIColor.black
                        cell.backgroundColor = UIColor.white
                        cell.textLabel?.textAlignment = .left
                        cell.accessoryType = .disclosureIndicator
                        
                    }.onCellSelection({ (_, _) in
                        guard let url = URL(string: self.featuresURL) else {
                            return
                        }
                        let safariVC = SFSafariViewController(url: url)
                        self.present(safariVC, animated: true, completion: nil)
                    })
            
            
                    <<< ButtonRow(){ row in
                        row.title = "FAQ"
                    }.cellUpdate { cell, row in
                        cell.textLabel?.textColor = UIColor.black
                        cell.backgroundColor = UIColor.white
                        cell.textLabel?.textAlignment = .left
                        cell.accessoryType = .disclosureIndicator
                    }.onCellSelection({ (_, _) in
                        guard let url = URL(string: self.faqURL) else {
                            return
                        }
                        let safariVC = SFSafariViewController(url: url)
                        self.present(safariVC, animated: true, completion: nil)
                    })
        
        
        form +++ Section("Feedback") { section in
            section.header?.height = {(30)}
        }
            
            <<< ButtonRow(){ row in
                row.title = "Contact Us"
            }.cellUpdate { cell, row in
                cell.textLabel?.textColor = UIColor.black
                cell.backgroundColor = UIColor.white
                cell.textLabel?.textAlignment = .left
                cell.accessoryType = .disclosureIndicator
                
            }.onCellSelection({ (_, _) in
                self.presentMailComposer()
            })
            
            
            <<< ButtonRow(){ row in
                row.title = "Refer Friends"
            }.cellUpdate { cell, row in
                cell.textLabel?.textColor = UIColor.black
                cell.backgroundColor = UIColor.white
                cell.accessoryType = .disclosureIndicator
                cell.textLabel?.textAlignment = .left
            }.onCellSelection({ (_, _) in

                if let url = URL(string: self.websiteURL), !url.absoluteString.isEmpty {
                    let objectsToShare = [url] as [Any]
                    let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
                    activityVC.excludedActivityTypes = [
                        UIActivity.ActivityType.postToWeibo,
                        UIActivity.ActivityType.print,
                        UIActivity.ActivityType.assignToContact,
                        UIActivity.ActivityType.saveToCameraRoll,
                        UIActivity.ActivityType.addToReadingList,
                        UIActivity.ActivityType.postToFlickr,
                        UIActivity.ActivityType.postToVimeo,
                        UIActivity.ActivityType.postToTencentWeibo
                    ]
                    self.present(activityVC, animated: true, completion: nil)
                }
            })
        
//        <<< ButtonRow(){ row in
//            row.title = "Rate Us"
//        }.cellUpdate { cell, row in
//            cell.textLabel?.textColor = UIColor.black
//            cell.backgroundColor = UIColor.white
//            cell.textLabel?.textAlignment = .left
//            cell.accessoryType = .disclosureIndicator
//
//        }.onCellSelection({ (_, _) in
//            guard let url = URL(string: self.featuresUrl) else {
//                return
//            }
//            let safariVC = SFSafariViewController(url: url)
//            self.present(safariVC, animated: true, completion: nil)
//        })
        
    }
    
    func presentMailComposer() {
        
        guard MFMailComposeViewController.canSendMail() else {
            return
        }
        
        let composer = MFMailComposeViewController()
        composer.mailComposeDelegate = self
        composer.setToRecipients(["cse-pocketcares@buffalo.edu"])
        
        present(composer, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let header = view as? UITableViewHeaderFooterView {
            header.backgroundView?.backgroundColor = UIColor.clear
            header.textLabel?.textColor = UIColor.white
        }
    }
    
    @objc func doubleTapped() {
        print("Tapped ten times")
        defaults.set(true, forKey: "developerMode")
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "chevron.left.slash.chevron.right"), style: .plain, target: self, action: #selector(handleDeveloperMode))
    }
    
    @objc func handleDeveloperMode() {
        
        let optionMenu = UIAlertController(title: nil, message: "Developer Mode", preferredStyle: .actionSheet)
        
        let openAction = UIAlertAction(title: "Open Developer Mode", style: .default) { (action) in
            let dmc = UINavigationController(rootViewController: DeveloperModeController())
            dmc.modalPresentationStyle = .fullScreen
            self.present(dmc, animated: true, completion: nil)
        }
        
        let turnOffAction = UIAlertAction(title: "Turn Off Developer Mode", style: .destructive) { (action) in
            self.navigationItem.rightBarButtonItem = nil
            self.defaults.set(false, forKey: "developerMode")
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        optionMenu.addAction(openAction)
        optionMenu.addAction(turnOffAction)
        optionMenu.addAction(cancelAction)
        
        self.present(optionMenu, animated: true, completion: nil)
    }
}

extension SettingsController: MFMailComposeViewControllerDelegate {
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        
        if let _ = error {
            //show error alert
            
            controller.dismiss(animated: true, completion: nil)
            
            return
        }
        
        switch result {
        case .cancelled:
            print("Cancelled")
        case .failed:
            print("Failed")
        case .saved:
            print("Saved")
        case .sent:
            print("Sent")
        }
        
        controller.dismiss(animated: true, completion: nil)
    }
}

extension UIApplication {
    static var appVersion: String? {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
    }
}

