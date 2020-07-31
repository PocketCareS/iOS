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

import Foundation
import UIKit
import MessageUI
import CoreData

class DeveloperModeController: UIViewController {
    public static let sharedInstance = DeveloperModeController()

    let defaults = UserDefaults.standard
    var timer = Timer()
    let textView: UITextView = {
        let tv = UITextView()
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.text = ""
        tv.textColor = .white
        tv.backgroundColor = .clear
        tv.isEditable = false
        return tv
    }()
    
    let calibrationLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Calibration:"
        label.textColor = .white
        return label
    }()
    
    let calibrationSwitch: UISwitch = {
        let cs = UISwitch()
        cs.backgroundColor = .white
        cs.layer.cornerRadius = 16.0
        cs.translatesAutoresizingMaskIntoConstraints = false
        return cs
    }()
    
    let sliderAndroidX: UISlider = {
        let slider = UISlider()
        slider.translatesAutoresizingMaskIntoConstraints = false
        slider.minimumValue = 10
        slider.maximumValue = 70
        slider.tintColor = .white
        slider.setValue(57, animated: true)
        return slider
    }()
    
    let sliderAndroidY: UISlider = {
        let slider = UISlider()
        slider.translatesAutoresizingMaskIntoConstraints = false
        slider.minimumValue = 10
        slider.maximumValue = 70
        slider.tintColor = .white
        slider.setValue(35, animated: true)
        return slider
    }()
    
    let slideriOSX: UISlider = {
        let slider = UISlider()
        slider.translatesAutoresizingMaskIntoConstraints = false
        slider.minimumValue = 10
        slider.maximumValue = 70
        slider.tintColor = .white
        slider.setValue(46, animated: true)
        return slider
    }()
    
    let slideriOSY: UISlider = {
        let slider = UISlider()
        slider.translatesAutoresizingMaskIntoConstraints = false
        slider.minimumValue = 10
        slider.maximumValue = 70
        slider.tintColor = .white
        slider.setValue(30, animated: true)
        return slider
    }()
    
    let sliderStackView: UIStackView = {
        let sv = UIStackView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.axis = .vertical
        sv.distribution = .fillProportionally
        return sv
    }()
    
    let labelStackView: UIStackView = {
        let sv = UIStackView()
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.axis = .vertical
        sv.distribution = .fillProportionally
        return sv
    }()
    
    let androidXLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Android X:"
        return label
    }()
    
    let androidYLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Android Y:"
        return label
    }()
    
    let iOSXLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "iOS X:"
        return label
    }()
    
    let iOSYLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .white
        label.text = "iOS Y:"
        return label
    }()
    
    var allBeaconsSeen = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViewController()
        setupViews()
        
        androidXLabel.text = "Android X: \(Int(sliderAndroidX.value))"
        androidYLabel.text = "Android Y: \(Int(sliderAndroidY.value))"
        iOSXLabel.text = "iOS X: \(Int(slideriOSX.value))"
        iOSYLabel.text = "iOS Y: \(Int(slideriOSY.value))"
        
        calibrationSwitch.addTarget(self, action: #selector(handleSwitch), for: .valueChanged)
        sliderAndroidX.addTarget(self, action: #selector(handleAndroidX), for: .valueChanged)
        sliderAndroidY.addTarget(self, action: #selector(handleAndroidY), for: .valueChanged)
        slideriOSX.addTarget(self, action: #selector(handleiOSX), for: .valueChanged)
        slideriOSY.addTarget(self, action: #selector(handleiOSY), for: .valueChanged)
    }
    
    @objc func handleAndroidX() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        androidXLabel.text = "Android X: \(Int(sliderAndroidX.value))"
        print("IM BEING CALLED ????")
        appDelegate.androidX = Double(Int(sliderAndroidX.value))
    }
    
    @objc func handleAndroidY() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        androidYLabel.text = "Android Y: \(Int(sliderAndroidY.value))"

        appDelegate.androidY = Double(Int(sliderAndroidY.value))
    }
    
    @objc func handleiOSX() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        iOSXLabel.text = "iOS X: \(Int(slideriOSX.value))"

        appDelegate.iosX = Double(Int(slideriOSX.value))
    }
    
    @objc func handleiOSY() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        iOSYLabel.text = "iOS Y: \(Int(slideriOSY.value))"

        appDelegate.iosY = Double(Int(slideriOSY.value))
    }
    
    func setupTextView() {
        view.addSubview(textView)
        textView.topAnchor.constraint(equalTo: calibrationSwitch.bottomAnchor, constant: 20).isActive = true
        textView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 15).isActive = true
        textView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -15).isActive = true
        textView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
    }
    
    func setupSliderStackView() {
        
        textView.removeFromSuperview()
        
        sliderStackView.addArrangedSubview(sliderAndroidX)
        sliderStackView.addArrangedSubview(sliderAndroidY)
        sliderStackView.addArrangedSubview(slideriOSX)
        sliderStackView.addArrangedSubview(slideriOSY)
        
        labelStackView.addArrangedSubview(androidXLabel)
        labelStackView.addArrangedSubview(androidYLabel)
        labelStackView.addArrangedSubview(iOSXLabel)
        labelStackView.addArrangedSubview(iOSYLabel)
        
        view.addSubview(labelStackView)
        labelStackView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 15).isActive = true
        labelStackView.widthAnchor.constraint(equalToConstant: 150).isActive = true
        labelStackView.topAnchor.constraint(equalTo: calibrationLabel.bottomAnchor, constant: 20).isActive = true
        labelStackView.heightAnchor.constraint(equalToConstant: 200).isActive = true

        view.addSubview(sliderStackView)
        sliderStackView.leftAnchor.constraint(equalTo: labelStackView.rightAnchor, constant: 15).isActive = true
        sliderStackView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -15).isActive = true
        sliderStackView.topAnchor.constraint(equalTo: calibrationLabel.bottomAnchor, constant: 20).isActive = true
        sliderStackView.heightAnchor.constraint(equalToConstant: 200).isActive = true
        
        view.addSubview(textView)
        textView.topAnchor.constraint(equalTo: sliderStackView.bottomAnchor, constant: 20).isActive = true
        textView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 15).isActive = true
        textView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -15).isActive = true
        textView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
    }
    
    func removeSliderStackView() {
        
        sliderStackView.removeFromSuperview()
        labelStackView.removeFromSuperview()
        
        setupTextView()
    }
    
    @objc func handleSwitch() {
        
        if calibrationSwitch.isOn {
            setupSliderStackView()
        }
        else {
            removeSliderStackView()
        }
    }
        
    override func viewDidAppear(_ animated: Bool) {
        update()
        self.timer = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(self.update), userInfo: nil, repeats: true)
    }
    
    var VBTS: [NSManagedObject] = []

    func fetchVBTS() {
        //1
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        //2
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "VBT")
        
        //3
        do {
          VBTS = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
          print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    var ServerDumps: [NSManagedObject] = []

    func fetchServerDump() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "ServerDump")
        
        do {
          ServerDumps = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
          print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    var allBeacons: [NSManagedObject] = []

    func fetchAllBeacons() {
        //1
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        //2
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "BeaconArray")
        
        //3
        do {
          allBeacons = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
          print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    @objc func update() {
        let allHoursArr = defaults.array(forKey: "allHoursArr") // Contains all hours
        print("allHoursArr", allHoursArr)
        fetchVBTS()
        fetchServerDump()
        fetchAllBeacons()
        let hourlyContactInfoDict = defaults.dictionary(forKey: "hourlyContactInfo")
        let token = defaults.string(forKey: "token")
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let isLocked = appDelegate.isDeviceLocked
        let currentlyDevice = isLocked ? "Currently the device is locked/Screen DARK" : "Currently the device is unlocked/Screen LIT"
        let currentlyOnCampus = self.defaults.bool(forKey: "onCampus") ? "Location: On Campus" : "Location: Off Campus"
        let isAdvertisingBeacon = BeaconSender.sharedInstance.isAdvertising() ? "Advertising Beacon" : "Not Advertising Beacon"
        
        var dumpStatement = "Device Token: \(token ?? "None") \n\(currentlyDevice) \nThis Device VBT: \(defaults.value(forKey: "vbtName") ?? "")" + "\n" + isAdvertisingBeacon + "\n" + currentlyOnCampus + "\n" + "************************************************************" + "\n\n"
        if (hourlyContactInfoDict != nil) {
            let allBeaconsArray = getAllBeaconsArray()
            
            for beacon in allBeaconsArray.reversed() {
                let VBT = beacon
                guard let vbtDict = hourlyContactInfoDict?[VBT] as? [String: Any] else {
                    return
                }
                let startTime = (vbtDict["startTime"] as? UInt64)!
                let endTime = (vbtDict["endTime"] as? UInt64)!
                let deviceType = (vbtDict["deviceType"] as? String)!
                            
                let notify = (vbtDict["notify"] as? String)!
                let allSessions = (vbtDict["allSessions"] as? [[String:Any]])!
                
                let smDistance = (vbtDict["smDistance"] as? Double)!
                let isValid = (vbtDict["isValid"] as? String)!
                let maxRSSI = (vbtDict["maxRSSI"] as? [String:Double])!
                let distancesDict = (vbtDict["Distances"] as? [String:Double])!

                let currentMinute = Calendar.current.component(.minute, from: Date())
                
                
                let currentSession = "\nONGOING \nStart: \(timeStringFromUnixTime(unixTime: Double(startTime))) \nEnd: \(timeStringFromUnixTime(unixTime: Double(endTime))) \nisValid: \(isValid) \nsmDistance: \(smDistance) \nnotify: \(notify) \n"
                
                var previousSessions = ""
                for session in allSessions {
                    let notify = (session["notify"] as? String)!
                    let startTime = (session["startTime"] as? UInt64)!
                    let endTime = (session["endTime"] as? UInt64)!
                    let avgDist = (session["avgDist"] as? Double)!
                    let countTen = (session["countTen"] as? Int)!
                    let countTwo = (session["countTwo"] as? Int)!
                    let isValid = (session["isValid"] as? String)!
                    
                    let reason = session["reason"] as? String ?? "None"
                    
                    previousSessions += "Reason: \(reason)\nStart: \(timeStringFromUnixTime(unixTime: Double(startTime))), End: \(timeStringFromUnixTime(unixTime: Double(endTime))), avgDist: \(avgDist), countTen: \(countTen), countTwo: \(countTwo), notify: \(notify), isValid: \(isValid) \n\n"

                }
                
                let beaconInfo = "BeaconID: \(VBT) \nDevice Type: \(deviceType) \n\(currentSession)\nMAXRSSI \(maxRSSI["\(currentMinute)"] ?? 0.0) \nDistance \(distancesDict["\(currentMinute)"] ?? 0.0) \n\nPrev Sessions \n\n\(previousSessions) \n----------------------------------\n---------------------------------- \n\n"
                
                dumpStatement += beaconInfo
            }
            
            
            
            var vbts = ""
            for vbt in VBTS {
                let date = vbt.value(forKey: "date") as? Date
                let time = timeStringFromUnixTime(unixTime: date?.timeIntervalSince1970 ?? 0)
                
                vbts += "\(time)" + " - \(vbt.value(forKey: "vbt")!)" + "\n"
            }
            
            var serverDumps = ""

            for serverDump in ServerDumps {
                let date = serverDump.value(forKey: "date") as? Date
                let time = timeStringFromUnixTime(unixTime: date?.timeIntervalSince1970 ?? 0)
                
                let param = serverDump.value(forKey: "param") as? String
                let response = serverDump.value(forKey: "response") as? String
                serverDumps += "\(time)" + "\n" + "\(param!)" + "\n" + "Response \(response!)" + "\n\n"
            }
            
            dumpStatement += "VBT Change History:\n\(vbts)" + "\n" + "Server Dumps" + "\n" + serverDumps
        }
        
        self.textView.text = dumpStatement
    }
    
    func getAllBeaconsArray() -> [String] {
        var allBeaconsArray = [String]()

        for beacon in allBeacons {
            let beaconString = beacon.value(forKey: "vbt") as? String
            allBeaconsArray.append(beaconString!)
        }
        return allBeaconsArray
    }
    
    func timeStringFromUnixTime(unixTime: Double) -> String {
        if (unixTime == 0.0) {
            return "0"
        }
        let date = NSDate(timeIntervalSince1970: unixTime)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd, HH:mm a"
        return dateFormatter.string(from: date as Date)
    }

    
    override func viewDidDisappear(_ animated: Bool) {
        self.timer.invalidate()
    }
    
    func setupViewController() {
        title = "Developer"
        navigationController?.navigationBar.prefersLargeTitles = true
        view.backgroundColor = UIColor(red: 0/255, green: 91/255, blue: 187/255, alpha: 1.0)
        let textAttributes = [NSAttributedString.Key.foregroundColor:UIColor.white]
        navigationController?.navigationBar.largeTitleTextAttributes = textAttributes
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleCancel))
        navigationController?.navigationBar.tintColor = .white
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "envelope"), style: .done, target: self, action: #selector(handleEmail))
        
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.barTintColor = UIColor(red: 0/255, green: 91/255, blue: 187/255, alpha: 1.0)
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.white]
    }
    
    func setupViews() {
        view.addSubview(calibrationLabel)
        calibrationLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10).isActive = true
        calibrationLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20).isActive = true
        calibrationLabel.widthAnchor.constraint(equalToConstant: 100).isActive = true
        calibrationLabel.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        view.addSubview(calibrationSwitch)
        calibrationSwitch.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10).isActive = true
        calibrationSwitch.leftAnchor.constraint(equalTo: calibrationLabel.rightAnchor, constant: 5).isActive = true
        calibrationSwitch.widthAnchor.constraint(equalToConstant: 48).isActive = true
        
        setupTextView()

        textView.font = UIFont(name: "HelveticaNeue", size: 15.0)
    }
    
    @objc func handleCancel() {
        dismiss(animated: true, completion: nil)
    }
    
    func presentMailComposer() {
        
        guard MFMailComposeViewController.canSendMail() else {
            return
        }
        
        let composer = MFMailComposeViewController()
        composer.mailComposeDelegate = self
        composer.setToRecipients(["mdrafsan@buffalo.edu", "anantpat@buffalo.edu"])
        composer.setSubject("Developer Log")
        let hourlyContactInfoDict = defaults.dictionary(forKey: "hourlyContactInfo")
        let dataToSend = "\n\n" + "\(hourlyContactInfoDict)" + "\n" + textView.text
        composer.setMessageBody(dataToSend, isHTML: false)
        
        present(composer, animated: true, completion: nil)
    }
    
    @objc func handleEmail() {
        presentMailComposer()
    }
    
    
}
extension DeveloperModeController: MFMailComposeViewControllerDelegate {

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

