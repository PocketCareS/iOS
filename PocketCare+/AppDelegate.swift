import UIKit
import CoreData
import CoreBluetooth
import Alamofire
import AlamofireMapper
import CoreLocation
import MapKit
import Firebase
import FirebaseMessaging
import CoreMotion
import UTMConversion
import FirebaseInstanceID
import CryptoSwift
import BackgroundTasks
import SwiftLocation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, CLLocationManagerDelegate, MKMapViewDelegate {
    
    let gcmMessageIDKey = "gcm.message_id"
    
    var currentZipCode = "99999"
    
    // User defaults
    let defaults = UserDefaults.standard
    
    // Beacon Initializers
    var localBeacon: CLBeaconRegion!
    var beaconPeripheralData: NSDictionary!
    
    // CoreBluetooth Initializers // Core Bluetooth
    var centralManager: CBCentralManager? = nil
    var peripheralManager: CBPeripheralManager? = nil
    
    let UUIDKey = "a1157b5a-2a58-472d-9bb6-32fce5734808"

    //VBT, Major, Minor Generation
    var minorInt = UInt16()
    var majorInt = UInt16()
    var index_stop = 0
    
    let encounterSessionManager = EncounterSession.sharedInstance
    
    let reports = [Report]()
    
    var isCalibrating = false
    var calibrationIdentifier = ""
    var calibrationRSSI = [Int]()
    
    // Calibration variables
    var androidX = 57.0
    var androidY = 35.0
    var iosX = 46.0
    var iosY = 30.0
        
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
                
        let brightness = UIScreen.main.brightness
        defaults.set(brightness, forKey: "brightness")
                
        UNUserNotificationCenter.current().delegate = self
        
        Messaging.messaging().delegate = self
        
        FirebaseApp.configure()
        let vbtName = defaults.string(forKey: "vbtName")
        if vbtName != nil {
            updateUserToken(shouldPOST: false)
            
            self.startAdvertising()
            self.initializeCoreBluetooth()
            DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                self.extendBackgroundRunningTime()
            }
            self.scheduleNotification()
        } else {
            print("App Launched for the first time")
            self.defaults.set(true, forKey: "socialDistanceNotification")
            self.defaults.set(false, forKey: "onCampus")

        }
        
        setup_OneMin_Timer()
        setupLockStateNotification()
        
        registerDailyKeyBackgroundTask()
        registerVBTNameBackgroundTask()
        registerCheckAllBeacons()
        registerFetchZipCode()
        
        return true
    }
        
    func setup_OneMin_Timer() {
        let timer = Timer(timeInterval: 60, target: self, selector: #selector(timer_Invocation), userInfo: nil, repeats: true)
        RunLoop.main.add(timer, forMode: RunLoop.Mode.common)
    }
        
    @objc func timer_Invocation() {
        print("-------->>>>>>>>>>>> TIME DID RUN ")
        let currentMinute = Calendar.current.component(.minute, from: Date())
        if (currentMinute == 0) {
            generateNewVBTName()
            DispatchQueue.main.asyncAfter(deadline: .now() + 60.0) {
                self.updateUserToken(shouldPOST: true)
            }
        }
        
        // If current minute == 59 -> Break all sessions
        if (currentMinute == 59) {
            processBeacons(shouldBreakSession: true)
        }

    }
    
    func setupLockStateNotification() {
        let lockCompleteString = "com.apple.springboard.lockcomplete"
        let lockString = "com.apple.springboard.lockstate"
        // Listen to CFNotification, post Notification accordingly.
        CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(),
                                        nil,
                                        { (_, _, _, _, _) in
                                            NotificationCenter.default.post(name: Notification.Name("lockComplete"), object: nil)
                                        },
                                        lockCompleteString as CFString,
                                        nil,
                                        CFNotificationSuspensionBehavior.deliverImmediately)

        CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(),
                                        nil,
                                        { (_, _, _, _, _) in
                                            NotificationCenter.default.post(name: Notification.Name("lockState"), object: nil)
                                        },
                                        lockString as CFString,
                                        nil,
                                        CFNotificationSuspensionBehavior.deliverImmediately)

        // Listen to Notification and handle.
        NotificationCenter.default.addObserver(self,
                                                selector: #selector(onLockComplete),
                                                name: Notification.Name("lockComplete"),
                                                object: nil)

        NotificationCenter.default.addObserver(self,
                                                selector: #selector(onLockState),
                                                name: Notification.Name("lockState"),
                                                object: nil)
    }
    
    var isDeviceLocked = false
    var didCallLockComplete = false
    @objc func onLockComplete() {
        print("LOCK COMPLETE")
        self.didCallLockComplete = true
    }
    
    @objc func onLockState() {
        print("LOCK STATE")
        if (didCallLockComplete) {
            self.isDeviceLocked = true
            self.didCallLockComplete = false
        } else {
            self.isDeviceLocked = false
        }
    }
    
    // Updates whether or not user is calibrating
    func startCalibration(identifier: String) {
        self.isCalibrating = true
        self.calibrationIdentifier = identifier
    }
    
    func fetchZipCode() {
        LocationManager.shared.locateFromGPS(.oneShot, accuracy: .city) { result in
            switch result {
            case .failure(let error):
                print("Received error: \(error)")
            case .success(let location):
                
                let options = GeocoderRequest.Options()
                let coordinates = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
                
                LocationManager.shared.locateFromCoordinates(coordinates, service: .apple(options)) { result in
                    switch result {
                    case .failure(let error):
                        print("An error has occurred: \(error)")
                    case .success(let places):
                        for place in places {
                            guard let zipCode = place.postalCode else { return }
                            self.currentZipCode = zipCode
                            print("ZipCode: \(zipCode)")
                        }
                    }
                }
            }
        }
    }

    //----------------CORE BLUETOOTH-----------------//
    let centralQueue = DispatchQueue.global(qos: .userInitiated)
    let peripheralQueue = DispatchQueue.global(qos: .userInitiated)
    
    func requestUNNotification() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                NSLog("error: \(error)")
            }
            if (granted) {
                self.initializeCoreBluetooth()
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
                    self.extendBackgroundRunningTime()
                }
                
                self.scheduleNotification()
            }
        }
        UIApplication.shared.registerForRemoteNotifications()
    }
    
    
    func scheduleNotification() {
        let center = UNUserNotificationCenter.current()
        center.removeDeliveredNotifications(withIdentifiers: ["alarm"])
        center.removePendingNotificationRequests(withIdentifiers: ["alarm"])
        let content = UNMutableNotificationContent()
        content.title = "Report Health Status"
        content.body = "Reminder to complete your Daily Health Status. Click here to report it now."
        content.categoryIdentifier = "alarm"
        content.userInfo = ["customData": "fizzbuzz"]
        content.sound = UNNotificationSound.default

        var dateComponents = DateComponents()
        dateComponents.hour = 20
        dateComponents.minute = 0
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        
        let request = UNNotificationRequest(identifier: "alarm", content: content, trigger: trigger)
        center.add(request)
    }
    
    func sendCloseEncounterNotification(){
        if (self.defaults.bool(forKey: "socialDistanceNotification") != false) {
            let center = UNUserNotificationCenter.current()
            // Think it better to remove it here like before
            center.removeDeliveredNotifications(withIdentifiers: ["closeEncounter"])
            center.removePendingNotificationRequests(withIdentifiers: ["closeEncounter"])
            
            center.delegate = self
            
            let content = UNMutableNotificationContent()
            content.title = "Social Distance Alert"
            content.body = "Your current contact duration has exceeded 10 minutes. Please mind your social distance."
            content.categoryIdentifier = "closeEncounter"
            content.sound = UNNotificationSound.default
            
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)

            let request = UNNotificationRequest(identifier: "closeEncounter", content: content, trigger: trigger)
            center.add(request)
            
            let snoozeAction = UNNotificationAction(identifier: "Snooze for an hour", title: "Snooze for an hour", options: [])
            let deleteAction = UNNotificationAction(identifier: "Snooze for a day", title: "Snooze for a day", options: [])
            let category = UNNotificationCategory(identifier: "closeEncounter", actions: [snoozeAction, deleteAction], intentIdentifiers: [], options: [])
            center.setNotificationCategories([category])
        }
    }
    
    func initializeCoreBluetooth() {
        self.centralManager = CBCentralManager(delegate: self, queue: centralQueue)
        self.peripheralManager = CBPeripheralManager(delegate: self, queue: peripheralQueue, options: [:])
        
        setupAdvertisingSwitchNotifier()
    }
     
    func setupAdvertisingSwitchNotifier() {
        NotificationCenter.default.addObserver(self, selector: #selector(turnOFFCoreBluetoothAdvertising), name: UIApplication.willEnterForegroundNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(turnONCoreBluetoothAdvertising), name: UIApplication.didEnterBackgroundNotification, object: nil)
    }
    
    /*
     Turn off corebluetooth advertising when app is in foreground
     Turn on corebluetooth advertising when app is in background
     
     */
    @objc func turnOFFCoreBluetoothAdvertising() {
        peripheralManager?.stopAdvertising()
        print("STARTED PROCESSING BEACONS")
        self.processBeacons(shouldBreakSession: false)
    }
    
    @objc func turnONCoreBluetoothAdvertising() {
        startAdvertisingOverflow()
    }
    
    var currentOverflowBits = ""
    
    // Not called until the app goes in background
    func startAdvertisingOverflow() {
        let adData = [CBAdvertisementDataServiceUUIDsKey :
            OverflowAreaUtils.binaryStringToOverflowServiceUuids(binaryString: self.currentOverflowBits)]
        peripheralManager?.startAdvertising(adData)
    }
    
    func startScanningAllOverflowUUIDS() {
        centralManager?.scanForPeripherals(withServices: OverflowAreaUtils.allOverflowServiceUuids(), options: [CBCentralManagerScanOptionAllowDuplicatesKey: true])
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 180) { // Local notification gets sent every 3 minutes
            NSLog("Restarting scanning")
            self.restartScanning()
        }
    }
    
    func restartScanning() {
        centralManager?.stopScan()
        DispatchQueue.main.async {
            if (self.isDeviceLocked) {
                self.sendNotification()
            }
        }

        
        NSLog("Stopping scanning briefly to reset")
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+1.0) { //@CHANGE
            NSLog("Resuming scanning ")
            self.startScanningAllOverflowUUIDS()
        }
    }
    
    func sendBluetoothTurnedOffNotification() {
        let center = UNUserNotificationCenter.current()

        center.removeDeliveredNotifications(withIdentifiers: ["BLUETOOTHOFF"])
        center.removePendingNotificationRequests(withIdentifiers: ["BLUETOOTHOFF"])
        let content = UNMutableNotificationContent()
        content.title = ""
        content.body = "PocketCare S needs bluetooth to be turned on."
        content.categoryIdentifier = "low-priority"
        let request = UNNotificationRequest(identifier: "BLUETOOTHOFF", content: content, trigger: nil)
        center.add(request)
    }
    
    func sendNotification() {
        //Check time stamp
        let center = UNUserNotificationCenter.current()
        center.removeAllDeliveredNotifications()
        let content = UNMutableNotificationContent()
        content.title = "PocketCare S is running."
        content.body = "No further action is required."
        content.categoryIdentifier = "low-priority"
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
        center.add(request)
    }
    
    var backgroundTask: UIBackgroundTaskIdentifier = UIBackgroundTaskIdentifier.invalid
    var threadStarted = false
    var threadShouldExit = false
    
    func extendBackgroundRunningTime() {
      if (threadStarted) {
        // if we are in here, that means the background task is already running.
        // don't restart it.
        return
      }
      threadStarted = true
      NSLog("Attempting to extend background running time")
      
      self.backgroundTask = UIApplication.shared.beginBackgroundTask(withName: "DummyTask", expirationHandler: {
        NSLog("Background task expired by iOS.")
        UIApplication.shared.endBackgroundTask(self.backgroundTask)
      })
      var lastLogTime = 0.0
      DispatchQueue.global().async {
        let startedTime = Int(Date().timeIntervalSince1970) % 10000000
        while(!self.threadShouldExit) {
            let now = Date().timeIntervalSince1970
            DispatchQueue.main.async {
                if self.peripheralManager?.state == CBManagerState.poweredOn {
                    let state = UIApplication.shared.applicationState
                    if state == .background {
                        //print("App in Background")
                        //NSLog("Advertising \(self.currentOverflowBits)")
                        self.updateAdvertisement()
                    }
                }

                let backgroundTimeRemaining = UIApplication.shared.backgroundTimeRemaining
                if abs(now - lastLogTime) >= 2.0 {
                    lastLogTime = now
                    if backgroundTimeRemaining < 10.0 {
                      NSLog("About to suspend based on background thread running out.")
                    }
                    if (backgroundTimeRemaining < 200000.0) {
                     NSLog("Thread \(startedTime) background time remaining: \(backgroundTimeRemaining)")
                    }
                    else {
                      //NSLog("Thread \(startedTime) background time remaining: INFINITE")
                    }
                }
            }
            sleep(1)
        }
        self.threadStarted = false
        NSLog("*** EXITING BACKGROUND THREAD")
      }
    }
    
    func updateAdvertisement() {
        peripheralManager?.stopAdvertising()
        
        let adData = [CBAdvertisementDataServiceUUIDsKey :
            OverflowAreaUtils.binaryStringToOverflowServiceUuids(binaryString: self.currentOverflowBits)]
        peripheralManager?.startAdvertising(adData)
    }
    
    //----------------CORE BLUETOOTH-----------------//


    
    //------------------iBeacon---------------------//
 
    func startAdvertising() {
        
        let dailyKey = self.generateDailyKey()
        let vbtName = self.generateVBTName(from: dailyKey)
        defaults.set(vbtName, forKey: "vbtName")
        
        print("Major Int: ", majorInt)
        print("Minor Int: ", minorInt)
        
        //self.fetchZipCode()
        
        setOverFlow()
        
        BeaconSender.sharedInstance.startSending(uuid: self.UUIDKey,
                                                 majorID: majorInt,
                                                 minorID: minorInt,
                                                 identifier: "PocketCareBeaconRegion")
        startListening()
        
    }
    
    // 0 Pads Binary String toSize times
    func pad(string : String, toSize: Int) -> String {
      var padded = string
      for _ in 0..<(toSize - string.count) {
        padded = "0" + padded
      }
        return padded
    }
    
    /*
     - Updates currentOverflowBits
     - Called everytime we generate new VBT
     */
    func setOverFlow() {
        /*
         1. majorInt and minorInt are UInt_16
         2. if either ends up having less than 16 bits then 0 pad to 16 bits
         3. currentVBT_Binary MUST BE 32 Bits
         4. Receiver End:
                * Take the 32 bits
                * Divide them up to 2-16 bit blocks
                * Convert each to Decimal
                * Put them side to side ---> VBT
         */
        let currentVBTMajor = pad(string: String(majorInt, radix: 2), toSize: 16)
        let currentVBTMinor = pad(string: String(minorInt, radix: 2), toSize: 16)
        
        let currentVBT_Binary = currentVBTMajor+currentVBTMinor
        
        let binaryString_To_Advertise = "01111111"+currentVBT_Binary+"00000000"+"00000000"+"00000000"+"00000000"+"00000000000000000000000000000000000000000000000000000000000000000000"
        
        self.currentOverflowBits = binaryString_To_Advertise
    }
    
    private var monitor: BeaconMonitor?
    
    func startListening() {
        monitor = BeaconMonitor(uuid: UUID(uuidString: self.UUIDKey)!)
        monitor = BeaconMonitor(uuids: [UUID(uuidString: "a1157b5a-2a58-472d-9bb6-32fce5734809")!,UUID(uuidString: "a1157b5a-2a58-472d-9bb6-32fce5734808")!])
        monitor!.delegate = self
        monitor!.startListening()
    }
    
    //------------------iBeacon------------------//

    func updateFirebaseToken(){
        var deviceId = ""
        InstanceID.instanceID().instanceID { (result, error) in
            if let error = error {
                print("Error fetching remote instange ID: \(error)")
            } else if let result = result {
                deviceId = result.token
                let params = ["deviceId": deviceId] as [String:Any]
                Alamofire.request("\(Constants.hostURL)/user", method: .post, parameters: params, encoding: JSONEncoding.default)
                    .responseObject
                    { (response: DataResponse<VBTResult>) in
                        switch response.result {
                        case let .success(data):
                            self.defaults.set(data.token, forKey: "token")
                            print("TOKEN", data.token)
                        case let .failure(error):
                            print("Some error has occured "+error.localizedDescription)
                            print(response.error as Any)
                        }
                }
            }
        }
    }
    
    func updateUserToken(shouldPOST: Bool){
        var deviceId = ""
        InstanceID.instanceID().instanceID { (result, error) in
            if let error = error {
                print("Error fetching remote instange ID: \(error)")
            } else if let result = result {
                print("Remote instance ID token: \(result.token)")
                deviceId = result.token
                let params = ["deviceId": deviceId] as [String:Any]
                Alamofire.request("\(Constants.hostURL)/user", method: .post, parameters: params, encoding: JSONEncoding.default)
                    .responseObject
                    { (response: DataResponse<VBTResult>) in
                        switch response.result {
                            
                        case let .success(data):
                            self.defaults.set(data.token, forKey: "token")
                            if (shouldPOST) {
                                self.integrateContactListV2API()
                            }
                        case let .failure(error):
                            print("Some error has occured "+error.localizedDescription)
                        }
                }
            }
        }
    }
    
    // Updates user defaults total duration and increase number of encounters by 1
    func updateEncounters (totalDuration: Int, endTime: UInt64) {
        //getCurrentHourAsString()
        let currentDate = Int(generateDateEpoch())
        var allEncounters = defaults.dictionary(forKey: "allEncounters")
        let currentHour = self.hourStringFromUnixTime(unixTime: Double(endTime))
        if (allEncounters != nil) {
            var currentHourEncounterSummary = allEncounters?[currentHour] as? [String: Int]
            if (currentHourEncounterSummary != nil) {
                let currTotalDuration = currentHourEncounterSummary?["totalDuration"]
                let currNumberOfEncounters = currentHourEncounterSummary?["numberOfEncounters"]
                currentHourEncounterSummary = ["totalDuration": totalDuration+currTotalDuration!, "numberOfEncounters": currNumberOfEncounters!+1, "date": currentDate]
                allEncounters?[currentHour] = currentHourEncounterSummary
            } else {
                allEncounters?[currentHour] = ["totalDuration": totalDuration, "numberOfEncounters": 1, "date": currentDate]
            }
            defaults.set(allEncounters, forKey: "allEncounters")

        } else {
            let allEncountersDict = [currentHour : ["totalDuration": totalDuration, "numberOfEncounters": 1, "date": currentDate]]
            defaults.set(allEncountersDict, forKey: "allEncounters")
        }
        
        print("THIS IS ALL ENCOUNTERS \(defaults.dictionary(forKey: "allEncounters") as AnyObject)")
    }
    
    // MARK: UISceneSession Lifecycle
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
    }
    
    // MARK: - Core Data stack
    
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "PocketCare_")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    func application(_ application: UIApplication,
                     didReceiveRemoteNotification userInfo: [NSObject : AnyObject],
                     fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
        // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.
        // TODO: Handle data of notification
        
        // With swizzling disabled you must let Messaging know about the message, for Analytics
        // Messaging.messaging().appDidReceiveMessage(userInfo)
        
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey as NSObject] {
            print("Message ID: \(messageID)")
        }
        
        // Print full message.
        print(userInfo)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.
        // TODO: Handle data of notification
        
        // With swizzling disabled you must let Messaging know about the message, for Analytics
        // Messaging.messaging().appDidReceiveMessage(userInfo)
        
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        
        // Print full message.
        print(userInfo)
        
        completionHandler(UIBackgroundFetchResult.newData)
    }
    
    func resetCalibration() {
        self.calibrationRSSI.removeAll()
        self.calibrationIdentifier = ""
        self.isCalibrating = false
    }
    
}

extension AppDelegate: MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        
        let dataDict:[String: String] = ["token": fcmToken]
        NotificationCenter.default.post(name: Notification.Name("FCMToken"), object: nil, userInfo: dataDict)
        print("MESSAGE RECEIVED FROM FIREBASE")
        updateFirebaseToken()
        // TODO: If necessary send token to application server.
        // Note: This callback is fired at each app startup and whenever a new token is generated.
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    
    // Receive displayed notifications for iOS 10 devices.
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        
        // With swizzling disabled you must let Messaging know about the message, for Analytics
        // Messaging.messaging().appDidReceiveMessage(userInfo)
        
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        
        // Print full message.
        print(userInfo)
        
        // Change this to your preferred presentation option
        completionHandler([.alert, .sound, .badge])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }
        
        // Print full message.
        print(userInfo)
        
        
        if response.actionIdentifier == "Snooze for an hour" {
            //@CHECK
            print("Snooze for an hour")
        }
        else if response.actionIdentifier == "Snooze for a day" {
            //@CHECK
            print("Snooze for a day")
        }

        
        completionHandler()
    }
}

// Storage Functions
extension AppDelegate {
    
    // Distance to RSSI Return 10^[(Rssi-59-x)/y] where y = 40 and x = 4
    // RSSI[dbm] = −(10n log10(d) − A)
    
    func convertRSSI_to_Distance_iOS(RSSI: Int) -> Double {
        return max(Double(1.0),pow(Double(10),Double(Double(Double(RSSI)-iosX)/iosY)).truncate(places: 2))
    }
    
    func convertRSSI_to_Distance_android(RSSI: Int) -> Double {
        return max(Double(1.0),pow(Double(10),Double(Double(Double(RSSI)-androidX)/androidY)).truncate(places: 2))
    }
    
    func generateDateEpoch() -> UInt64 {
        let today = Date()
        let date = Calendar.current.date(bySettingHour: 12, minute: 0, second: 0, of: today)!
        let currentHour = Calendar.current.date(byAdding: .hour, value: -4, to: date)!
        print("Date:", currentHour)
        return UInt64(currentHour.toMillis())
    }

    func generateHourEpoch() -> UInt64 {
        let today = Date()
        let hour = Calendar.current.component(.hour, from: today)
        let hourDate = Calendar.current.date(bySettingHour: hour, minute: 0, second: 0, of: today)!
        let modifiedDate = Calendar.current.date(byAdding: .hour, value: -4, to: hourDate)!
        return UInt64(modifiedDate.toMillis())
    }
    
    //Returns time and date from UNIX
    func timeStringFromUnixTime(unixTime: Double) -> String {
        let date = NSDate(timeIntervalSince1970: unixTime)
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(secondsFromGMT: -14400)
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .short
        return dateFormatter.string(from: date as Date)
    }
    
    func hourStringFromUnixTime(unixTime: Double) -> String {
        let date = NSDate(timeIntervalSince1970: unixTime)
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(secondsFromGMT: -14400)
        dateFormatter.dateFormat = "h a"
        return dateFormatter.string(from: date as Date)
    }
}

extension Dictionary {
    mutating func merge(dict: [Key: Value]){
        for (k, v) in dict {
            updateValue(v, forKey: k)
        }
    }
}

extension AppDelegate: BeaconMonitorDelegate {
    
    func calculateSmoothDistance(distances: [Double]) -> Double {
        var distancesArr = distances
        distancesArr.sort(by: <)
        let n = distancesArr.count
        var ni = Double(n+1)
        var denominator = Double(0)
        var smoothedDistance = Double(0)
        
        for dist in distancesArr {
            smoothedDistance = smoothedDistance + (ni*dist)
            denominator = denominator + ni
            ni = ni - 1
        }
        
        return smoothedDistance/denominator
        
    }
    
    
    
    func saveBeacon(vbt: String) {
        DispatchQueue.main.async {
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                return
            }
            
            let managedContext = appDelegate.persistentContainer.viewContext
            let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "BeaconArray")
            let entity = NSEntityDescription.entity(forEntityName: "BeaconArray", in: managedContext)!

            fetchRequest.predicate = NSPredicate(format: "vbt == %@", vbt)
            do {
                let beacon = try managedContext.fetch(fetchRequest)
                if (beacon.count == 0) {
                    let beacon = NSManagedObject(entity: entity, insertInto: managedContext)
                    let hourlyTimeStamp = self.generateHourEpoch()
                    beacon.setValue(vbt, forKeyPath: "vbt")
                    beacon.setValue("\(hourlyTimeStamp)", forKeyPath: "hourEpoch")
                    do {
                        try managedContext.save()
                    } catch let error as NSError {
                        print("Could not save. \(error), \(error.userInfo)")
                    }
                }
            } catch let error as NSError {
              print("Could not fetch. \(error), \(error.userInfo)")
            }
        }
    }
    
    /*
     Core Data Keys
     - uniqueEncounters: [minor1, minor2...]
     - proximities: Int
     - accuracy: Int
     - numProximities
     - numAccuracies
     - totalLengthOfExposure: in seconds (increase if any beacon prox < 2.5)
     */

    @objc func receivedAllBeacons(_ monitor: BeaconMonitor, beacons: [CLBeacon], deviceType: String) {
        if (!didGenerateCurrentHourVBT()) {
            self.generateNewVBTName()
        }
        
        let currentMinute = Calendar.current.component(.minute, from: Date())

        if (currentMinute == 59){
            return
        }
        
        if (beacons.count > 0) {
            //CHECK BEACON
            
            for beacon in beacons {
                let VBT = "\(beacon.major)"+"\(beacon.minor)"
                saveBeacon(vbt: VBT)
                let rssi = abs(beacon.rssi)
                if (isCalibrating) {
                    if (VBT.contains(calibrationIdentifier)) {
                        calibrationRSSI.append(rssi)
                    }
                    if (calibrationRSSI.count >= 5) {
                        isCalibrating = false
                    }
                }
                let approxDistance = deviceType == "iOS" ? convertRSSI_to_Distance_iOS(RSSI: rssi) : convertRSSI_to_Distance_android(RSSI: rssi)
                
                let currentTime = UInt64(Date().timeIntervalSince1970)
                let currentMinute = Calendar.current.component(.minute, from: Date()) // Of this hour
                
                let shouldNotify = encounterSessionManager.processEncounter(VBT: VBT, rssi: rssi, approxDistance: approxDistance, currentZipCode: self.currentZipCode, currentTime: currentTime, currentMinute: currentMinute, deviceType: deviceType)
                if (shouldNotify) {
                    sendCloseEncounterNotification()
                }
            }
        }
        
    }
}

extension AppDelegate: CBPeripheralManagerDelegate, CBCentralManagerDelegate, CBPeripheralDelegate {
    
    func isCorrectIdentifier(bitString: String) -> Bool {
        //@CHECK whats the logic behind it ?
        let correctIdentifierDict = ["1111111" : true,
                                     "0111111" : true,
                                     "1011111" : true,
                                     "1101111" : true,
                                     "1110111" : true,
                                     "1111011" : true,
                                     "1111101" : true,
                                     "1111110" : true
                                    ]
        return correctIdentifierDict[bitString] == nil ? false : true
    }
    
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        //
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral,advertisementData: [String : Any], rssi RSSI: NSNumber) {
        let currentMinute = Calendar.current.component(.minute, from: Date())
        if (!didGenerateCurrentHourVBT()) {
            self.generateNewVBTName()
        }
        
        if (currentMinute == 59){
            return
        }
        
        if let overflowIds = advertisementData[CBAdvertisementDataOverflowServiceUUIDsKey] {
            if let overflowIds = overflowIds as? [CBUUID] {
                
                let discoveredBinaryString = OverflowAreaUtils.overflowServiceUuidsToBinaryString(overflowUuids: overflowIds)
                let appIdentifier = discoveredBinaryString[1..<8] // Last 7 bits of the first byte
                
                let VBT_BytesArr = discoveredBinaryString[8..<40]
                                
                if (isCorrectIdentifier(bitString: appIdentifier)) {
                                        
                    let VBT = "\(UInt16(strtoul(VBT_BytesArr, nil, 2)))" //--> Convert bits to decimal
                    saveBeacon(vbt: VBT)

                    let rssi = abs(RSSI as! Int)
                    
                    if (rssi >= 85) {
                        return
                    }
                    
                    if (isCalibrating) {
                        if (VBT.contains(calibrationIdentifier)) {
                            calibrationRSSI.append(rssi)
                        }
                        if (calibrationRSSI.count >= 5) {
                            isCalibrating = false
                        }
                    }
                    
                    let approxDistance = convertRSSI_to_Distance_iOS(RSSI: rssi)
                   
                    let currentTime = UInt64(Date().timeIntervalSince1970)
                    let currentMinute = Calendar.current.component(.minute, from: Date()) // Of this hour
                    if (advertisementData["kCBAdvDataTxPowerLevel"] as? Int != nil) {
                        
                        // Advertisement coming from background, no need to stop
                        let shouldNotify = encounterSessionManager.processEncounter(VBT: VBT, rssi: rssi, approxDistance: approxDistance, currentZipCode: self.currentZipCode, currentTime: currentTime, currentMinute: currentMinute, deviceType: "iOS")
                        if (shouldNotify) {
                            sendCloseEncounterNotification()
                        }
                    } else {
                        
                        // Advertisement coming from foreground, start and stop scanning periodically
                        self.centralManager?.stopScan()
                        let shouldNotify = encounterSessionManager.processEncounter(VBT: VBT, rssi: rssi, approxDistance: approxDistance, currentZipCode: self.currentZipCode, currentTime: currentTime, currentMinute: currentMinute, deviceType: "iOS")
                        if (shouldNotify) {
                            sendCloseEncounterNotification()
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { // Change `2.0` to the desired number of seconds.
                            self.centralManager?.scanForPeripherals(withServices: OverflowAreaUtils.allOverflowServiceUuids(), options: [CBCentralManagerScanOptionAllowDuplicatesKey: true])
                        }

                    }
                }
            }
        }
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state == CBManagerState.poweredOn {
            startScanningAllOverflowUUIDS()
        } else {
            self.centralManager?.stopScan()
            sendBluetoothTurnedOffNotification()
        }
    }
    
    
    

}
    
extension AppDelegate {
    
    func generateMasterKey() -> Array<UInt8> {
        var array = Array<UInt8>()
        
        for _ in 0...31 {
            
            let number = Int.random(in: 0 ..< 256)
            
            array.append(UInt8(number))
        }
        return array
    }
    
    func generateDailyKey() -> Array<UInt8> {
           let masterKey = defaults.array(forKey: "masterKey") as? [UInt8]
           let dailyKeyFull = HDKFsha256(masterKey: masterKey ?? [])
           let dailyKey = dailyKeyFull.chunked(into: 16)[0]
           let dailyKeyHex = convertDailyKeyToHex(dailyKey: dailyKey)
           defaults.set(dailyKeyHex, forKey: "dailyKeyHex")
           return dailyKey
    }
    
    func convertDailyKeyToHex(dailyKey: [UInt8]) -> String {
        return dailyKey.toHexString()
    }
    
    func generateVBTName(from dailyKey: Array<UInt8>) -> String {
        let vbt = calHmacSha256(secretKey: dailyKey, message: generateTimestampTimeInHours())
        print("VBT: \(vbt)")
        
        let vbtArray = vbt.chunked(into: 2)
        print(vbtArray)
        
        for index in stride(from: 0, to: vbtArray.count - 1, by: 1) {
            print(vbtArray[index])
            if vbtArray[index][0] == 0 && vbtArray[index][1] == 0 {
            }
            else {
                minorInt = convertToInt(from: vbtArray[index])
                index_stop = index + 1
                break
            }
        }
        for index in stride(from: index_stop, to: vbtArray.count - 1, by: 1) {
            print(vbtArray[index])
            if vbtArray[index][0] == 0 && vbtArray[index][1] == 0 {
            }
            else {
                majorInt = convertToInt(from: vbtArray[index])
                break
            }
        }
        print("FIRST MINOR: ", self.minorInt)
        print("FIRST MAJOR: ", self.majorInt)
        let vbtName = String(majorInt) + String(minorInt)

        return vbtName
    }
  
    func calHmacSha256(secretKey: Array<UInt8>, message: Array<UInt8>) -> Array<UInt8> {
        var result = Array<UInt8>()
        
        do {
            result = try HMAC(key: secretKey, variant: .sha256).authenticate(message)
        }
        catch {
            print("Failed to calculate HMAC-SHA256")
        }
        return result
    }
    
    func generateTimestamp() -> Array<UInt8> {
        let currentTimeStamp = generateDateEpoch()
        
        let timeInDays = (currentTimeStamp / (1000 * 3600 * 24))
        
        var bigEndian = timeInDays.bigEndian
        let count = MemoryLayout<UInt64>.size
        let bytePtr = withUnsafePointer(to: &bigEndian) {
            $0.withMemoryRebound(to: UInt8.self, capacity: count) {
                UnsafeBufferPointer(start: $0, count: count)
            }
        }
        let byteArray = Array(bytePtr)
        return byteArray
    }
    
    func generateTimestampTimeInHours() -> Array<UInt8> {
        
      let currentTimeStamp = generateHourEpoch()
        
      let timeInHours = currentTimeStamp / (1000 * 3600)
        
      var bigEndian = timeInHours.bigEndian
      let count = MemoryLayout<UInt64>.size
      let bytePtr = withUnsafePointer(to: &bigEndian) {
        $0.withMemoryRebound(to: UInt8.self, capacity: count) {
          UnsafeBufferPointer(start: $0, count: count)
        }
      }
      let byteArray = Array(bytePtr)
      return byteArray
        
    }
    
    func HDKFsha256(masterKey: Array<UInt8>) -> Array<UInt8> {
        
        if masterKey == nil || masterKey.count <= 0 {
            print("Provided master key must not be nil")
        }
        
        let salt = Array<UInt8>(repeating: 0, count: 16)
        
        let extract = calHmacSha256(secretKey: salt, message: masterKey)
        
        var message = generateTimestamp()
        message.append(1)
        
        let blockN = calHmacSha256(secretKey: extract, message: message)
        return blockN
    }
    
    func byteArray<T>(from value: T) -> [UInt8] where T: FixedWidthInteger {
        withUnsafeBytes(of: value.bigEndian, Array.init)
    }
    
    func convertToInt(from array: Array<UInt8>) -> UInt16 {
        var value : UInt16 = 0
        let data = NSData(bytes: array, length: 2)
        data.getBytes(&value, length: 2)
        value = UInt16(bigEndian: value)
        
        return value
    }
    
    func convertToHourEpoch(today: Date) -> UInt64 {
        let hour = Calendar.current.component(.hour, from: today)
        let hourDate = Calendar.current.date(bySettingHour: hour, minute: 0, second: 0, of: today)!
        let modifiedDate = Calendar.current.date(byAdding: .hour, value: -4, to: hourDate)!
        print("modifiedDate", modifiedDate, "UInt64(modifiedDate.toMillis()", UInt64(modifiedDate.toMillis()))
        return UInt64(modifiedDate.toMillis())
        //1594933200000
    }
    
    func getIntFromByte(VBT: Array<UInt8>, index: Int) -> UInt8 {
        return ((VBT[index] & 0xff) << 8) | (VBT[index + 1] & 0xff)
    }
}

extension Date {
    func toMillis() -> Int64! {
        return Int64(self.timeIntervalSince1970 * 1000)
    }
}

extension Array {
    func chunked(into size: Int) -> [[Element]] {
        return stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
}

extension String {
    subscript(_ range: CountableRange<Int>) -> String {
        let start = index(startIndex, offsetBy: max(0, range.lowerBound))
        let end = index(start, offsetBy: min(self.count - range.lowerBound,
                                             range.upperBound - range.lowerBound))
        return String(self[start..<end])
    }

    subscript(_ range: CountablePartialRangeFrom<Int>) -> String {
        let start = index(startIndex, offsetBy: max(0, range.lowerBound))
         return String(self[start...])
    }
}

extension Double {
    func round(to places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}

extension Double
{
    func truncate(places : Int)-> Double
    {
        return Double(floor(pow(10.0, Double(places)) * self)/pow(10.0, Double(places)))
    }
}

extension AppDelegate {
        
    //MARK: Register BackGround Tasks
    private func registerDailyKeyBackgroundTask() {
        BGTaskScheduler.shared.register(forTaskWithIdentifier: "com.bgTask.generateDailyKey", using: nil) { task in
            self.generateDailyKeyBackgroundTask(task: task as! BGAppRefreshTask)
        }
    }
    
    private func registerVBTNameBackgroundTask() {
        BGTaskScheduler.shared.register(forTaskWithIdentifier: "com.bgTask.generate.NewVBTName", using: nil) { task in
            self.generateVBTNameBackgroundTask(task: task as! BGProcessingTask)
        }
    }
    
    private func registerCheckAllBeacons() {
        print("DID registerCheckAllBeacons")
        BGTaskScheduler.shared.register(forTaskWithIdentifier: "com.bgTask.check.allBeacons", using: nil) { task in
            self.checkAllBeacons(task: task as! BGProcessingTask)
        }
    }
    
    private func registerFetchZipCode() {
        print("DID registerFetchZipCode")
        BGTaskScheduler.shared.register(forTaskWithIdentifier: "com.bgTask.fetch.zipCode", using: nil) { task in
            self.fetchNewZipcode(task: task as! BGProcessingTask)
        }
    }
    
    func fetchNewZipcode(task: BGProcessingTask) {
        
        let queue = OperationQueue()
        
        queue.addOperation {
            print("FetchZipCode was called")
            self.fetchZipCode()
        }
        
        task.expirationHandler = {
            queue.cancelAllOperations()
        }
        
        let lastOperation = queue.operations.last
        lastOperation?.completionBlock = {
            task.setTaskCompleted(success: !(lastOperation?.isCancelled ?? false))
        }
        scheduleFetchZipcode()
    }
    
    func checkAllBeacons(task: BGProcessingTask) {
        print("CHECK ALL BEACONS WAS CALLED")
        let queue = OperationQueue()
        //queue.maxConcurrentOperationCount = 1
        
        queue.addOperation {
            print("checkAllBeacons was called")
            self.processBeacons(shouldBreakSession: false)
        }
        
        task.expirationHandler = {
            queue.cancelAllOperations()
        }
        
        let lastOperation = queue.operations.last
        lastOperation?.completionBlock = {
            task.setTaskCompleted(success: !(lastOperation?.isCancelled ?? false))
        }
        scheduleCheckAllBeacons()
    }
    
    func processBeacons(shouldBreakSession: Bool) {
        if (self.defaults.dictionary(forKey: "hourlyContactInfo") != nil) {
            var hourlyContactInfoDict = self.defaults.dictionary(forKey: "hourlyContactInfo")
            
            for (VBT, VBTDict) in hourlyContactInfoDict! {
                //Get the VBT dict
                let vbtDict = VBTDict as? [String: Any]
                //bug fix 1234
                let startTime = (vbtDict?["startTime"] as? UInt64) ?? 0
                var endTime = (vbtDict?["endTime"] as? UInt64) ?? 0
                
                let distancesDict = (vbtDict?["Distances"] as? [String:Double])!
                
                let allDistancesArr = Array(distancesDict.values)
                
                let notify = (vbtDict?["notify"] as? String)!
                var allSessions = (vbtDict?["allSessions"] as? [[String:Any]])!
                
                let smDistance = (vbtDict?["smDistance"] as? Double)!
                
                let deviceType = (vbtDict?["deviceType"] as? String)!

                let newCurrentTime = UInt64(Date().timeIntervalSince1970)
                let minutesPassedSinceLastSeen = (newCurrentTime-endTime)/60
                // Check if the currentime - the endTime of current ongoing session > 5 minutes
                if (shouldBreakSession) {
                    let dateEnded = Date(timeIntervalSince1970: TimeInterval(endTime))
                    let minute = Calendar.current.component(.minute, from: dateEnded)
                    endTime = minute == 58 ? endTime+60 : endTime
                    // We are in 59th minute, so break all sessions
                    let lastSessionSmoothDistance = calculateSmoothDistance(distances: allDistancesArr)
                    let totalDurationOfOngoingSession = ((endTime-startTime)/60)+1

                    // If blackout period of more than 5
                    let countTen = lastSessionSmoothDistance > 2 ? totalDurationOfOngoingSession : 0
                    let countTwo = lastSessionSmoothDistance <= 2 ? totalDurationOfOngoingSession : 0
                    print("countTwo", countTwo)
                    print("endTime", endTime)
                    print("startTime", startTime)
                    
                    if (lastSessionSmoothDistance <= 2.0 && totalDurationOfOngoingSession >= 5) {
                        // It was a good session put it in allSessions Valid
                        allSessions.append(["startTime": startTime,"endTime": endTime, "isValid":"true", "avgDist": smDistance, "notify":notify, "countTwo": countTwo, "countTen":countTen,"reason" : "The blackout time > 5 min"])
                        self.updateEncounters(totalDuration: Int(countTwo), endTime: endTime)
                    } else {
                        if (countTwo != 0 && countTen != 0) {
                            // It was a bad session put it in allSessions as inValid
                            allSessions.append(["startTime": startTime,"endTime": endTime, "isValid":"false", "avgDist": smDistance, "notify":notify, "countTwo": countTwo, "countTen":countTen, "reason" : "The blackout time > 5 min"])
                        }
                    }
                    
                    // -- TO DO
                    // -- Database cleared every 14-days 
                    let vbtDict = ["zipCode" : self.currentZipCode,
                                  "smDistance" : 0.0,
                                  "Distances" : [String:Int](),
                                  "maxRSSI" : [String: Int](),
                                  "sumRSSI" : 0,
                                  "numRSSI" : 0,
                                  "startTime": 0,
                                  "endTime": 0,
                                  "isValid": "false",
                                  "notify": "false",
                                  "deviceType": deviceType,
                                  "allSessions" : allSessions
                                ] as [String : Any]
                                   
                    hourlyContactInfoDict?[VBT] = vbtDict
                    self.defaults.set(hourlyContactInfoDict, forKey: "hourlyContactInfo")
                }
                else if (minutesPassedSinceLastSeen >= 5) {
                    let lastSessionSmoothDistance = calculateSmoothDistance(distances: allDistancesArr)
                    let totalDurationOfOngoingSession = ((endTime-startTime)/60)+1

                    // If blackout period of more than 5
                    let countTen = lastSessionSmoothDistance > 2 ? totalDurationOfOngoingSession : 0
                    let countTwo = lastSessionSmoothDistance <= 2 ? totalDurationOfOngoingSession : 0
                    print("countTwo", countTwo)
                    print("endTime", endTime)
                    print("startTime", startTime)
                    
                    if (lastSessionSmoothDistance <= 2.0 && totalDurationOfOngoingSession >= 5) {
                        // It was a good session put it in allSessions Valid
                        allSessions.append(["startTime": startTime,"endTime": endTime, "isValid":"true", "avgDist": smDistance, "notify":notify, "countTwo": countTwo, "countTen":countTen, "reason" : "The blackout time >5"])
                        self.updateEncounters(totalDuration: Int(countTwo), endTime: endTime)
                    } else {
                        if (countTwo != 0 && countTen != 0) {
                            // It was a bad session put it in allSessions as inValid
                            allSessions.append(["startTime": startTime,"endTime": endTime, "isValid":"false", "avgDist": smDistance, "notify":notify, "countTwo": countTwo, "countTen":countTen, "reason" : "The blackout time > 5 min"])
                        }
                    }
                    
                    // If we haven't heard from this in the last 3 hours, no need to
                    // keep it in dictionary
                    let vbtDict = ["zipCode" : self.currentZipCode,
                                  "smDistance" : 0.0,
                                  "Distances" : [String:Int](),
                                  "maxRSSI" : [String: Int](),
                                  "sumRSSI" : 0,
                                  "numRSSI" : 0,
                                  "startTime": 0,
                                  "endTime": 0,
                                  "isValid": "false",
                                  "notify": "false",
                                  "deviceType": deviceType,
                                  "allSessions" : allSessions
                                ] as [String : Any]
                                   
                    hourlyContactInfoDict?[VBT] = vbtDict
                    self.defaults.set(hourlyContactInfoDict, forKey: "hourlyContactInfo")

                }
            }
        }
    }
    
    func scheduleFetchZipcode() {
        print("DID scheduleFetchZipcode")
        let fetchZipCodeRequest = BGProcessingTaskRequest(identifier: "com.bgTask.fetch.zipCode")
        fetchZipCodeRequest.earliestBeginDate = Date(timeIntervalSinceNow: 900) //@3600 Seconds / 60 mins
        do {
            try BGTaskScheduler.shared.submit(fetchZipCodeRequest)
        } catch {
            print("Could not schedule app refresh: \(error)")
        }
    }
    
    func scheduleCheckAllBeacons() {
        print("DID scheduleCheckAllBeacons")
        let checkAllBeaconsRequest = BGProcessingTaskRequest(identifier: "com.bgTask.check.allBeacons")
        checkAllBeaconsRequest.earliestBeginDate = Date(timeIntervalSinceNow: 480) //@480 Seconds // 8 mins
        do {
            try BGTaskScheduler.shared.submit(checkAllBeaconsRequest)
        } catch {
            print("Could not schedule app refresh: \(error)")
        }
    }
    
    func generateDailyKeyBackgroundTask(task: BGAppRefreshTask) {
        
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        
        queue.addOperation {
            //Check if Master Key is nil, if it is, then generate one.
            //MARK: Master Key
            if self.defaults.array(forKey: "masterKey") == nil {
                let masterKey = self.generateMasterKey()
                self.defaults.set(masterKey, forKey: "masterKey")
            }
            
            //MARK: Daily Key
            let dailyKey = self.generateDailyKey()
            self.defaults.set(dailyKey, forKey: "dailyKey")
        }
        
        task.expirationHandler = {
            queue.cancelAllOperations()
        }
        
        let lastOperation = queue.operations.last
        lastOperation?.completionBlock = {
            task.setTaskCompleted(success: !(lastOperation?.isCancelled ?? false))
        }
        
        scheduleDailyKeyGeneration()
    }
    
    func generateVBTNameBackgroundTask(task: BGProcessingTask) {
        
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        
        queue.addOperation {
            self.generateNewVBTName()
        }
        
        task.expirationHandler = {
            queue.cancelAllOperations()
        }
        
        let lastOperation = queue.operations.last
        lastOperation?.completionBlock = {
            task.setTaskCompleted(success: !(lastOperation?.isCancelled ?? false))
        }
        
        scheduleVBTNameGeneration()
    }
    
    func saveVBT_DB() {
        DispatchQueue.main.async {
            let managedContext = self.persistentContainer.viewContext
            
            let entity = NSEntityDescription.entity(forEntityName: "VBT", in: managedContext)!
            
            let VBT = NSManagedObject(entity: entity, insertInto: managedContext)
            let vbtName = self.defaults.string(forKey: "vbtName")

            VBT.setValue(vbtName, forKeyPath: "vbt")
            VBT.setValue(Date(), forKeyPath: "date")

            do {
                try managedContext.save()
            } catch let error as NSError {
                print("Could not save. \(error), \(error.userInfo)")
            }
        }
    }
    
    func didGenerateCurrentHourVBT() -> Bool {
        let lastTimeVBTGeneration = self.defaults.string(forKey: "lastVBTGenerationTime")
        if (lastTimeVBTGeneration == "\(self.generateHourEpoch())") {
            return true
        }
        return false
    }
    
    func didPostToServer() -> Bool {
        let lastTimeVBTGeneration = self.defaults.string(forKey: "lastServerPostTime")
        if (lastTimeVBTGeneration == "\(self.generateHourEpoch())") {
            return true
        }
        return false
    }
    
    @objc func generateNewVBTName() {
        
        print("CURRENT", currentOverflowBits)
        //Check if Master Key is nil, if it is, then generate one.
        //MARK: Master Key
        if self.defaults.array(forKey: "masterKey") == nil {
            let masterKey = self.generateMasterKey()
            self.defaults.set(masterKey, forKey: "masterKey")
        }
        
        //Check if Daily Key is nil, if it is, then generate one.
        //MARK: Daily Key
        if self.defaults.array(forKey: "dailyKey") == nil {
            let dailyKey = self.generateDailyKey()
            self.defaults.set(dailyKey, forKey: "dailyKey")
        }
        
        //MARK: VBT Name
        let dailyKey = (self.defaults.array(forKey: "dailyKey") ?? []) as Array<UInt8>
        let vbtName = self.generateVBTName(from: dailyKey)
        self.defaults.set(vbtName, forKey: "vbtName")
        
        //@CHECK: Whenever new VBT name is generated,
        //        Reset overflow, update overflow advertisement
        //        Stop Beacon transmission, and start again with current major and minor
        print("NEW MINOR: ", self.minorInt)
        print("NEW MAJOR: ", self.majorInt)
        
        self.peripheralManager?.stopAdvertising()
        BeaconSender.sharedInstance.stopSending()
        DispatchQueue.main.asyncAfter(deadline: .now() + 10.0) {
            self.setOverFlow()
            self.updateAdvertisement()
            BeaconSender.sharedInstance.startSending(uuid: self.UUIDKey, majorID: self.majorInt, minorID: self.minorInt, identifier: "PocketCareBeaconRegion")
        }
        
        print("CURRENT", currentOverflowBits)
        self.defaults.setValue(self.generateHourEpoch(), forKey: "lastVBTGenerationTime")
        saveVBT_DB()
    }
    
    
    func scheduleDailyKeyGeneration() {
        
        let dailyKeyRequest = BGAppRefreshTaskRequest(identifier: "com.bgTask.generateDailyKey")
        dailyKeyRequest.earliestBeginDate = Date(timeIntervalSinceNow: 86400)
        
        do {
            try BGTaskScheduler.shared.submit(dailyKeyRequest)
        } catch {
            print("Could not schedule app refresh: \(error)")
        }
    }
    

    func scheduleVBTNameGeneration() {
        let vbtNameRequest = BGProcessingTaskRequest(identifier: "com.bgTask.generate.NewVBTName")
        vbtNameRequest.earliestBeginDate = Date(timeIntervalSinceNow: 3600)
        
        do {
            try BGTaskScheduler.shared.submit(vbtNameRequest)
        } catch {
            print("Could not schedule app refresh: \(error)")
        }
    }
    
    // Upload data to server
    func getContactListParams() -> [String:Any]{
        
        var allHoursArr = defaults.array(forKey: "allHoursArr") // Contains all hours
        if (allHoursArr != nil && (allHoursArr?.count ?? 0) > 0) { // Change to 0 to TEST
            // If we have more than one hours saved in all hours
            let dailyKey = defaults.string(forKey: "dailyKeyHex")
            
            let currentDate = self.generateDateEpoch()
            let currentCurrentHourEpoch = allHoursArr?[0]
            print("currentCurrentHourEpoch", currentCurrentHourEpoch)
            // Remove first element from all hours
            allHoursArr?.remove(at: 0)
            defaults.set(allHoursArr, forKey: "allHoursArr") //----> Update all hours arr
            
            var dict =  Dictionary<String, Array<Any>>() // Create zip code dictionary
            
            let hourlyContactInfoDict = self.defaults.dictionary(forKey: "hourlyContactInfo")
            
            for (VBT, VBTDict) in hourlyContactInfoDict! {
                let vbtDict = VBTDict as? [String: Any]
                let allSessions = (vbtDict?["allSessions"] as? [[String:Any]])!
                let zipCode = (vbtDict?["zipCode"] as? String)!
                for i in allSessions.indices {
                    let session = allSessions[i]
                    let endTime = (session["endTime"] as? UInt64)! // <-- VBT's end time not individ sessons

                    let hourTime = convertToHourEpoch(today: Date(timeIntervalSince1970: Double(endTime)))
                    print("hourTime", hourTime)
                    if (hourTime == currentCurrentHourEpoch as? UInt64 ?? 0) {
                        //Happened at the same hour
                        //allSessions.remove(at: i)
                        let countTwo = session["countTwo"] as? Int ?? 0
                        let countTen = session["countTen"] as? Int ?? 0
                        let avgDist = session["avgDist"] as? Double ?? 0.0
                        let totalCount = countTwo+countTen
                        if (dict[zipCode] != nil) { //Checking for nil here
                            var zipCodeArr = dict[zipCode]!
                            zipCodeArr.append(["vbtName":VBT, "countTwo":countTwo, "countTen": countTen, "avgDist": avgDist, "totalCount": totalCount])
                            dict[zipCode] = zipCodeArr
                        } else {
                            dict[zipCode] = [["vbtName":VBT, "countTwo":countTwo, "countTen": countTen, "avgDist": avgDist, "totalCount": totalCount]]
                        }
                    }
                }
            }
            
            // Update hourly contact info dict and remove VBTs with no sessions left
            self.defaults.set(hourlyContactInfoDict, forKey: "hourlyContactInfo")
            
            let allInfo = ["\(currentDate)": ["dailyKey": dailyKey ?? "","hourlyContactInfo" : ["\(currentCurrentHourEpoch ?? "")" : dict]]]
            let dateWiseContactInfo = ["dateWiseContactInfo":allInfo]
            /*
             let jsonData = try! JSONSerialization.data(withJSONObject: dateWiseContactInfo)
             let jsonString = NSString(data: jsonData, encoding: String.Encoding.utf8.rawValue) ?? NSString()
             */
            return dateWiseContactInfo
        }
        //1594962000000
        return [String:Any]()
    }
    
    func saveServerDump_DB(param: String, response: String) {
        // 1
        let managedContext = self.persistentContainer.viewContext
        
        // 2
        let entity = NSEntityDescription.entity(forEntityName: "ServerDump", in: managedContext)!
        
        let ServerDump = NSManagedObject(entity: entity, insertInto: managedContext)

        // 3
        ServerDump.setValue(param, forKeyPath: "param")
        ServerDump.setValue(Date(), forKeyPath: "date")
        ServerDump.setValue(response, forKeyPath: "response")

        // 4
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
        
    func integrateContactListV2API() {
        let params = getContactListParams()
        if (params.count > 0) {
            var headers = [String: String]()
            let token = defaults.string(forKey: "token")
            print("PARAMS : \(params)")
            if token != nil {
                headers["token"] = token
                print("Parameters: \(params)")
                print("Headers: \(headers)")
                Alamofire.request("\(Constants.hostURL)/upload/contactlist", method: .post, parameters: params, encoding: JSONEncoding.default, headers: headers).responseJSON
                    { (response:DataResponse) in
                        switch(response.result)
                        {
                        case .success(_):
                            print("SUCCESS UPLOADING CONTACT LIST")
                            print("Servers response", response)
                            self.saveServerDump_DB(param: params.description, response: "SUCCESS")
                            self.defaults.setValue(self.generateHourEpoch(), forKey: "lastServerPostTime")
                            break
                        case .failure(_):
                            print("FAILURE UPLOADING CONTACT LIST")
                            print(response)
                            self.saveServerDump_DB(param: params.description, response: "FAIL")

                            break
                        }
                }
            }
        }
    }
}





