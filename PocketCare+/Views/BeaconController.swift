import UIKit
import Foundation
import CoreLocation
import FSCalendar
import ScrollableGraphView
import Alamofire
import Charts
import SwiftyJSON
import CoreData

class BeaconController: UIViewController, UITableViewDelegate, FSCalendarDelegate, FSCalendarDataSource {
    
    var encounterPoints = [-1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0]
//        [5, 7, 10, 2, 5, 6, 10, 2.0, 5.0, 4.0, 3.0, 5.0, 4.0, 7.0, 8.0, 6.0, 1.0, 0.0, 5.0, 3.0, 5.0, 4.0, 7.0, 8.0]
    var durationPoints = [-1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0]

    var hours = ["0","0","0","0","0","0","0","0","0","0","0","0","0","0","0","0","0","0","0","0","0", "0", "0", "0"]
    
//    var hours = ["12AM","1AM","2AM","3AM","4AM","5AM","6AM","7AM","8AM","9AM","10AM","11AM","12PM","1PM","2PM","3PM","4PM","5PM","6PM","7PM","8PM", "9PM", "10PM", "11PM"]

    let defaults = UserDefaults.standard
    
    var calendar: FSCalendar = {
        let calendar = FSCalendar()
        calendar.translatesAutoresizingMaskIntoConstraints = false
        calendar.scope = .week
        calendar.appearance.borderRadius = 0.4
        calendar.appearance.headerDateFormat = "MMM yyyy"
        calendar.appearance.weekdayTextColor = .white
        calendar.appearance.headerTitleColor = .white
        calendar.appearance.titleDefaultColor = .white
        calendar.appearance.selectionColor = .white
        calendar.appearance.titleSelectionColor = .black
        calendar.appearance.todayColor = .systemBlue
        
        return calendar
    }()
    
    let summaryView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        view.layer.cornerRadius = 20
        return view
    }()
    
    let dailySummaryView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        view.layer.cornerRadius = 20
        return view
    }()
    
    let hourlySummaryView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(red: 0/255, green: 91/255, blue: 187/255, alpha: 1.0)
        view.layer.borderColor = UIColor.white.cgColor
        return view
    }()
    
    let dailySummaryStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.distribution = .fillEqually
        stackView.axis = .vertical
        return stackView
    }()
    
    let dsTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.text = "Daily Summary"
        label.numberOfLines = 0
        return label
    }()
    
    let dsNumberOfEncountersImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(systemName: "person.3.fill")
        imageView.tintColor = .systemPink
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        return imageView
    }()
    
    let dsNumberOfEncountersLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 15)
        label.text = "Number of Close Encounters: 0"
        label.numberOfLines = 0
        return label
    }()
    
    let dsTotalLengthOfExposureImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(systemName: "alarm.fill")
        imageView.tintColor = .systemOrange
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        return imageView
    }()
    
    let dsTotalLengthOfExposureLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 15)
        label.text = "Total Duration: 0 hours 0 minutes"
        label.numberOfLines = 0
        return label
    }()
    
    let dsStatusImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(systemName: "checkmark.circle.fill")
        imageView.tintColor = .systemGreen
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        return imageView
    }()
    
    let dsStatusLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 15)
        label.text = "Good job maintaining appropriate social distance!"
        label.numberOfLines = 0
        return label
    }()
    
    let hourlySummaryStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.distribution = .fillEqually
        return stackView
    }()
    
    let hsTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.text = "Hourly Summary"
        label.numberOfLines = 0
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()
    
    let hsNumberOfEncountersImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(systemName: "person.3.fill")
        imageView.tintColor = .systemPink
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        return imageView
    }()
    
    let hsNumberOfEncountersLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 15)
        label.text = "Number of close encounters: 191"
        label.numberOfLines = 0
        return label
    }()
    
    let hsTotalLengthOfExposureImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(systemName: "alarm.fill")
        imageView.tintColor = .systemOrange
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        return imageView
    }()
    
    let hsTotalLengthOfExposureLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 15)
        label.text = "Total Length of Exposure: 5 hrs 36 minutes"
        label.numberOfLines = 0
        return label
    }()
    
    let hsStatusImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(systemName: "checkmark.circle.fill")
        imageView.tintColor = .systemGreen
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        return imageView
    }()
    
    let hsStatusLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 15)
        label.text = "You're doing pretty well so far, keep going!"
        label.numberOfLines = 0
        return label
    }()
    
    var beacons = [Any]() as! [CLBeacon]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(defaults.value(forKey: "allEncounters") as! AnyObject)
        
        setupViewController()
        setupCalendarView()
        setupSummaryViews()
        setupDailySummaryStackView()
        setupOneTimeInfoView()
        updateView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        calendar.select(calendar.maximumDate)
        fetchServerDump()
        //Check if location permissions is granted. If the permission is not granted, present an alert to inform the user that location permissions are required for the app to work properly.
        //@CHECK - when checkLocationServices() is called.
        checkLocationServices()
    }
    
    func maximumDate(for calendar: FSCalendar) -> Date {
        print("MAXIMUM DATE CALLED")
        return Date()
    }
    
    func minimumDate(for calendar: FSCalendar) -> Date {
        return Calendar.current.date(byAdding: .day, value: -30, to: Date())!
    }
    
    func convertDate(from date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        return dateFormatter.string(from: date)
    }
        
    func fetchAllCurrentHourBeaconsArray() {
        DispatchQueue.main.async {
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                return
            }
            
            let managedContext = appDelegate.persistentContainer.viewContext
            let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "BeaconArray")
            let hourlyTimeStamp = self.generateHourEpoch()
            fetchRequest.predicate = NSPredicate(format: "hourEpoch == %@", "\(hourlyTimeStamp)")

            do {
                let currentHourBeacons = try managedContext.fetch(fetchRequest)
                var currentHourBeaconsArr = [String]()

                for beacon in currentHourBeacons {
                    let beaconString = beacon.value(forKey: "vbt") as? String
                    currentHourBeaconsArr.append(beaconString!)
                }
                
                self.configureCurrentHourData(currentHourBeacons: currentHourBeaconsArr)
            } catch let error as NSError {
              print("Could not fetch. \(error), \(error.userInfo)")
            }
        }
    }
    
    func generateHourEpoch() -> UInt64 {
        let today = Date()
        let hour = Calendar.current.component(.hour, from: today)
        let hourDate = Calendar.current.date(bySettingHour: hour, minute: 0, second: 0, of: today)!
        let modifiedDate = Calendar.current.date(byAdding: .hour, value: -4, to: hourDate)!
        return UInt64(modifiedDate.toMillis())
    }
        
    var ServerDumps: [NSManagedObject] = []
    
    // Fetch Server Dump to Check to make sure we have sent data to the server
    func fetchServerDump() {
        DispatchQueue.main.async {
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                return
            }
            
            let managedContext = appDelegate.persistentContainer.viewContext
            
            let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "ServerDump")
            
            do {
                self.ServerDumps = try managedContext.fetch(fetchRequest)
                self.configureCurrentDateData()
            } catch let error as NSError {
              print("Could not fetch. \(error), \(error.userInfo)")
            }
        }
    }
    
    var dsCloseEncounterCount_CurrentHour = 0
    var dsTotalDuration_CurrentHour = 0
    //Have to implement
    func getCurrentHoursData() {
        if (defaults.contains("hourlyContactInfo")) {
            self.fetchAllCurrentHourBeaconsArray()
        }
    }
    
    func configureCurrentHourData(currentHourBeacons: [String]) {
        let hourlyContactInfoDict = defaults.dictionary(forKey: "hourlyContactInfo")
        
        let date = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(secondsFromGMT: -14400)
        dateFormatter.dateFormat = "h a"
        let currentHourStr = dateFormatter.string(from: date as Date)
        print("currentHourBeacons", currentHourBeacons)
        if (currentHourBeacons.count == 0) {
            return
        }
        for beacon in currentHourBeacons {
            let VBT = beacon
            guard let vbtDict = hourlyContactInfoDict?[VBT] as? [String: Any] else {
                return
            }
            
            let allSessions = (vbtDict["allSessions"] as? [[String:Any]])!

            let isValid = (vbtDict["isValid"] as? String)!
            
            for session in allSessions {
                let countTwo = (session["countTwo"] as? Int)!
                let isValid = (session["isValid"] as? String)!
                
                if (isValid == "true") {
                    let index = self.hours.firstIndex(of: currentHourStr)

                    if (index != nil) {
                        self.encounterPoints[index ?? 0] += 1.0
                        self.durationPoints[index ?? 0] += Double(countTwo)
                        
                        self.dsCloseEncounterCount_CurrentHour += 1
                        self.dsTotalDuration_CurrentHour += Int(countTwo)
                    } else {
                        self.hours.append(currentHourStr)
                        self.encounterPoints.append(1.0)
                        self.durationPoints.append(Double(countTwo))
                        self.dsCloseEncounterCount_CurrentHour = 1
                        self.dsTotalDuration_CurrentHour = Int(countTwo)
                    }
                }
            }
            
            if (isValid == "true") {
                let startTime = (vbtDict["startTime"] as? UInt64)!
                let endTime = (vbtDict["endTime"] as? UInt64)!
                let totalDurationOfOngoingSession = ((endTime-startTime)/60)+1
                
                let index = self.hours.firstIndex(of: currentHourStr)
                
                if (index != nil) {
                    self.encounterPoints[index ?? 0] += 1.0
                    self.durationPoints[index ?? 0] += Double(totalDurationOfOngoingSession)
                    
                    self.dsCloseEncounterCount_CurrentHour += 1
                    self.dsTotalDuration_CurrentHour += Int(totalDurationOfOngoingSession)
                } else {
                    self.hours.append(currentHourStr)
                    self.encounterPoints.append(1.0)
                    self.durationPoints.append(Double(totalDurationOfOngoingSession))
                    self.dsCloseEncounterCount_CurrentHour = 1
                    self.dsTotalDuration_CurrentHour = Int(totalDurationOfOngoingSession)
                }
                
            }
        }
    }
    
    func configureCurrentDateData() {
        if (ServerDumps.count == 0) {
            // Haven't sent anything to server yet. Use local data
            configureCurrentDateDataLocal()
        } else {
            let dateEpoch = generateDateEpoch(from: Date())
            getEncounterInformationFromServer(for: dateEpoch)
        }
    }
    
    func configureCurrentDateDataLocal() {
        encounterPoints = [-1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0]
        //        [5, 7, 10, 2, 5, 6, 10, 2.0, 5.0, 4.0, 3.0, 5.0, 4.0, 7.0, 8.0, 6.0, 1.0, 0.0, 5.0, 3.0, 5.0, 4.0, 7.0, 8.0]
        durationPoints = [-1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0]
        hours = ["0","0","0","0","0","0","0","0","0","0","0","0","0","0","0","0","0","0","0","0","0", "0", "0", "0"]
        
        
        var index = 0
        var dsCloseEncounterCount = 0
        var dsTotalDuration = 0
        
        // Check to see if there is anything in all encounters.
        // If not we just use what we have for this hour in ongoing
        
        guard let storedDictionary = defaults.dictionary(forKey: "allEncounters") else {
            getCurrentHoursData()
            DispatchQueue.main.async {
                self.dsNumberOfEncountersLabel.text = "Number of Close Encounters: \(self.dsCloseEncounterCount_CurrentHour)"
            }
            
            DispatchQueue.main.async {
                self.dsTotalLengthOfExposureLabel.text = "Total Duration: \(self.minutesToHoursMinutes(minutes:self.dsTotalDuration_CurrentHour))"
            }
            removeUnchangedValuesFromGraphData()

            DispatchQueue.main.async {
                self.barChartView.notifyDataSetChanged()
                self.setupGraphView()
            }
            
            self.dsCloseEncounterCount_CurrentHour = 0
            self.dsTotalDuration_CurrentHour = 0
            return
            
        }

        for key in storedDictionary.keys {
            
            index = validateHourIndex(for: key)
            print("Index:", index)

            print("hours", hours)
            
            let storedDictionaryKey = storedDictionary[key] as! [String: Any]
            let currentDateEpochWhenUpdated = storedDictionaryKey["date"] as? Int ?? 0
            let numberOfEncountersDouble = storedDictionaryKey["numberOfEncounters"] as! Double
            let totalDurationDouble = storedDictionaryKey["totalDuration"] as! Double
            
            let currentDateEpoch = Int(generateDateEpoch(from: Date()))
            
            if currentDateEpoch == currentDateEpochWhenUpdated
        && currentDateEpochWhenUpdated != 0 {
                
                hours[index] = key
                
                encounterPoints[index] = numberOfEncountersDouble
                durationPoints[index] = totalDurationDouble
                //            encounterPoints.append(numberOfEncountersDouble)
                //            durationPoints.append(totalDurationDouble)

                            dsCloseEncounterCount += Int(numberOfEncountersDouble)
                            dsTotalDuration += Int(totalDurationDouble)
                            getCurrentHoursData()
                            DispatchQueue.main.async {
                                self.dsNumberOfEncountersLabel.text = "Number of Close Encounters: \(dsCloseEncounterCount+self.dsCloseEncounterCount_CurrentHour)"
                            }
                            
                            DispatchQueue.main.async {
                                self.dsTotalLengthOfExposureLabel.text = "Total Duration: \(self.minutesToHoursMinutes(minutes: dsTotalDuration+self.dsTotalDuration_CurrentHour))"
                            }
            }
        }
        
        
        removeUnchangedValuesFromGraphData()

        DispatchQueue.main.async {
            self.barChartView.notifyDataSetChanged()
            self.setupGraphView()
        }
    }
    
    func minutesToHoursMinutes (minutes : Int) -> String {
        return "\((minutes / 60)) hours \(minutes % 60) minutes"
    }
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        
        hours = []
        encounterPoints = []
        durationPoints = []
        
        var dsCloseEncounterCount = 0
        var dsTotalDuration = 0
        
        let currentDateString = convertDate(from: Date())
        let selectedDateString = convertDate(from: date)
        
        print("Current Date:",currentDateString)
        print("Selected Date:",selectedDateString)
        
        if currentDateString == selectedDateString {
            configureCurrentDateData()
        }
        else {
            let dateEpoch = generateDateEpoch(from: date)
            getEncounterInformationFromServer(for: dateEpoch)
        }
    }
    
    func getEncounterInformationFromServer(for date: UInt64) {
        let parameters = getParams(startDate: date, endDate: date)
        var headers = [String: String]()
        let token = defaults.string(forKey: "token")
                
        if token != nil {
            headers["token"] = token
            print("Parameters: \(parameters)")
            print("Headers: \(headers)")
            
            // Create URL
            let url = URLComponents(string: "\(Constants.hostURL)/analytics/contactData?startDate=\(String(date))&endDate=\(String(date))&contactType=close")

            guard let requestUrl = url else { fatalError() }
            
            var request = URLRequest(url: requestUrl.url!)
            // Specify HTTP Method to use
            request.httpMethod = "GET"
            
            request.setValue(token, forHTTPHeaderField: "token")

            // Send HTTP Request
            let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                
                // Check if Error took place
                if let error = error {
                    // If there is in error use local data to populate chart
                    let todaysDateEpoch = self.generateDateEpoch(from: Date())

                    if (date == todaysDateEpoch) {
                        self.configureCurrentDateDataLocal()
                    }
                    return
                }
                
                // Read HTTP Response Status code
                if let response = response as? HTTPURLResponse {
                    print("Response HTTP Status code: \(response.statusCode)")
                }
                
                // Convert HTTP Response Data to a simple String
                if let data = data, let dataString = String(data: data, encoding: .utf8) {
                    print("Response data string:\n \(dataString)")

                    self.parseJSON(for: dataString, and: date)
                }
            }
            task.resume()
        }
    }
        
    func parseJSON(for string: String, and date: UInt64) {
        
        encounterPoints = [-1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0]
        //        [5, 7, 10, 2, 5, 6, 10, 2.0, 5.0, 4.0, 3.0, 5.0, 4.0, 7.0, 8.0, 6.0, 1.0, 0.0, 5.0, 3.0, 5.0, 4.0, 7.0, 8.0]
        durationPoints = [-1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0, -1.0]
        hours = ["0","0","0","0","0","0","0","0","0","0","0","0","0","0","0","0","0","0","0","0","0", "0", "0", "0"]
        
        var index = 0
        
        if let data = string.data(using: .utf8) {
            if let json = try? JSON(data: data) {
                
                //MARK: HOURLY SUMMARY
                if let closeEncounterCount = json["contactCount"][String(date)]["closeContactCount"].dictionaryObject {
                    for key in closeEncounterCount.keys {
                        
                        guard let epochInMillis = Double(key) else { return }
                        print(epochInMillis)
                        
                        let epoch = epochInMillis / 1000
                        print(epoch)
                        
                        let dateAndTimeFromEpoch = Date(timeIntervalSince1970: epoch)
                        let hourString = convertString(from: dateAndTimeFromEpoch)
                        
                        print(hourString)
                        

                        print("Hours:", hours)
                        
                        if let numberOfContacts = json["contactCount"][String(date)]["closeContactCount"][key]["numberOfContacts"].int, let totalDuration =  json["contactCount"][String(date)]["closeContactCount"][key]["duration"].int {
                            if (numberOfContacts > 0 && totalDuration > 0) {
                                index = validateHourIndex(for: hourString)
                                hours[index] = hourString
                                encounterPoints[index] = Double(numberOfContacts)
                                durationPoints[index] = Double(totalDuration)
                            }
                            
                        }
                    }
                }
                
                //MARK: Calculate current hours data if date selected = today
                let dateEpoch = generateDateEpoch(from: Date())
                if (date == dateEpoch) {
                    getCurrentHoursData()
                }
                
                //MARK: DAILY SUMMARY
                //Number of close encounters
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    if let totalCount = json["contactCount"][String(date)]["totalCount"].int {
                        
                        DispatchQueue.main.async {
                            self.dsNumberOfEncountersLabel.text = date != dateEpoch ? "Number of Close Encounters: \(totalCount)" : "Number of Close Encounters: \(totalCount+self.dsCloseEncounterCount_CurrentHour)"
                        }
                      print("Total Count",totalCount)
                    }
                    // @@@@CHECK BECAUSE DISPATCH QUEUE DO NOT REFRESH MAKE IT
                    //Total Duration
                    if let totalDuration = json["contactCount"][String(date)]["duration"].int {
                        
                        DispatchQueue.main.async {
                            self.dsTotalLengthOfExposureLabel.text = date != dateEpoch ? "Total Duration: \(self.minutesToHoursMinutes(minutes: totalDuration))" : "Total Duration: \(self.minutesToHoursMinutes(minutes: totalDuration+self.dsTotalDuration_CurrentHour))"
                        }
                        print("Total Duration",totalDuration)
                    }
                }
            }
        }
                
        removeUnchangedValuesFromGraphData()
        
        DispatchQueue.main.async {
            self.setupGraphView()
            self.barChartView.notifyDataSetChanged()
        }
    }
    
    func validateHourIndex(for hourString: String) -> Int {
        var hourKeys = ["12 AM","1 AM","2 AM","3 AM","4 AM","5 AM","6 AM","7 AM","8 AM","9 AM","10 AM","11 AM","12 PM","1 PM","2 PM","3 PM","4 PM","5 PM","6 PM","7 PM","8 PM", "9 PM", "10 PM", "11 PM"]
        return hourKeys.firstIndex(of: hourString) ?? 0
    }
    
    func removeUnchangedValuesFromGraphData() {
        encounterPoints = encounterPoints.filter { $0 != -1.0 }
        durationPoints = durationPoints.filter { $0 != -1.0 }
        hours = hours.filter { $0 != "0" }
    }
    
    func convertString(from date: Date) -> String {
        let formatter3 = DateFormatter()
        formatter3.dateFormat = "h a"
        formatter3.timeZone = TimeZone(abbreviation: "UTC")
        let dateString = formatter3.string(from: date)
        return dateString
    }
    
    func generateDateEpoch(from date: Date) -> UInt64 {
        let date1 = Calendar.current.date(bySettingHour: 12, minute: 0, second: 0, of: date)!
        let currentHour = Calendar.current.date(byAdding: .hour, value: -4, to: date1)!
        print("Date:", currentHour)
        return UInt64(currentHour.toMillis())
    }
    
    func getParams(startDate: UInt64, endDate: UInt64) -> [String: Any] {
        var params = [String: Any]()

        params["startDate"] = startDate
        params["endDate"] = endDate
        
        return params
    }
    
    func setupOneTimeInfoView() {
//        let title = "Close Encounters"
//        let message = "On this screen, you will see information on close encounters with other PocketCare S users."
        if defaults.bool(forKey: "openedEncountersPageBefore") == false {
//            showSingleActionAlertToUser(with: title, and: message)
            handleInfo()
            defaults.set(true, forKey: "openedEncountersPageBefore")
        }
        else {
            
        }
    }
    
    func updateView() {
        updateValues()
        NotificationCenter.default.addObserver(self, selector: #selector(willEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    
    @objc func willEnterForeground() {
        updateValues()
    }
    
    func updateValues() {
        if (UserDefaults.standard.dictionary(forKey: "uniqueEncounters") != nil) {
            dsNumberOfEncountersLabel.text = "Number of Close Encounters: \(UserDefaults.standard.dictionary(forKey: "uniqueEncounters")!.keys.count)"
        }
    }
    
    func setupViewController() {
        
        title = "Encounters"
        navigationController?.navigationBar.prefersLargeTitles = true
        view.backgroundColor = UIColor(red: 0/255, green: 91/255, blue: 187/255, alpha: 1.0)
        let textAttributes = [NSAttributedString.Key.foregroundColor:UIColor.white]
        navigationController?.navigationBar.largeTitleTextAttributes = textAttributes
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "info.circle", withConfiguration: UIImage.SymbolConfiguration(font: UIFont.systemFont(ofSize: 20), scale: .large)), style: .plain, target: self, action: #selector(handleInfo))
        navigationController?.navigationBar.tintColor = .white
        
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.barTintColor = UIColor(red: 0/255, green: 91/255, blue: 187/255, alpha: 1.0)
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.white]
    }
    
    func setupCalendarView() {
        view.addSubview(calendar)
        calendar.widthAnchor.constraint(equalToConstant: view.frame.width).isActive = true
        calendar.heightAnchor.constraint(equalToConstant: 300).isActive = true //200
        calendar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10).isActive = true
        
        calendar.dataSource = self
        calendar.delegate = self
    }
    
    @objc func setupSummaryViews() {
        view.addSubview(summaryView)
        summaryView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 140).isActive = true
        summaryView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20).isActive = true
        summaryView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20).isActive = true
        summaryView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20).isActive = true
        
        summaryView.addSubview(dailySummaryView)
        dailySummaryView.topAnchor.constraint(equalTo: summaryView.topAnchor).isActive = true
        dailySummaryView.leftAnchor.constraint(equalTo: summaryView.leftAnchor).isActive = true
        dailySummaryView.rightAnchor.constraint(equalTo: summaryView.rightAnchor).isActive = true
        dailySummaryView.heightAnchor.constraint(equalToConstant: 170).isActive = true
        //        dailySummaryView.bottomAnchor.constraint(equalTo: summaryView.centerYAnchor, constant: -10).isActive = true
        
        summaryView.addSubview(hourlySummaryView)
        hourlySummaryView.topAnchor.constraint(equalTo: dailySummaryView.bottomAnchor, constant: 20).isActive = true
        hourlySummaryView.leftAnchor.constraint(equalTo: summaryView.leftAnchor).isActive = true
        hourlySummaryView.rightAnchor.constraint(equalTo: summaryView.rightAnchor).isActive = true
        hourlySummaryView.bottomAnchor.constraint(equalTo: summaryView.bottomAnchor).isActive = true
        
        view.addSubview(dsTitleLabel)
        dsTitleLabel.topAnchor.constraint(equalTo: dailySummaryView.topAnchor, constant: 12).isActive = true
        dsTitleLabel.leftAnchor.constraint(equalTo: dailySummaryView.leftAnchor, constant: 15).isActive = true
        dsTitleLabel.heightAnchor.constraint(equalToConstant: 30).isActive = true
        dsTitleLabel.widthAnchor.constraint(equalToConstant: 200).isActive = true
        
        view.addSubview(hsTitleLabel)
        hsTitleLabel.topAnchor.constraint(equalTo: hourlySummaryView.topAnchor).isActive = true
        hsTitleLabel.leftAnchor.constraint(equalTo: hourlySummaryView.leftAnchor, constant: 12).isActive = true
        hsTitleLabel.rightAnchor.constraint(equalTo: hourlySummaryView.rightAnchor, constant: -12).isActive = true
        hsTitleLabel.heightAnchor.constraint(equalToConstant: 30).isActive = true
    }
    
    func setupDailySummaryStackView() {
        view.addSubview(dailySummaryStackView)
        dailySummaryStackView.leftAnchor.constraint(equalTo: dailySummaryView.leftAnchor, constant: 12).isActive = true
        dailySummaryStackView.rightAnchor.constraint(equalTo: dailySummaryView.rightAnchor, constant: -12).isActive = true
        dailySummaryStackView.topAnchor.constraint(equalTo: dsTitleLabel.bottomAnchor, constant: 12).isActive = true
        dailySummaryStackView.bottomAnchor.constraint(equalTo: dailySummaryView.bottomAnchor, constant: -12).isActive = true
        
        setupDailySummarySubStackViews()
    }
    
    func setupDailySummarySubStackViews() {
        let noeStackView = UIStackView()
        noeStackView.axis = .horizontal
        noeStackView.distribution = .fillProportionally
        noeStackView.spacing = 10
        noeStackView.addArrangedSubview(dsNumberOfEncountersImageView)
        noeStackView.addArrangedSubview(dsNumberOfEncountersLabel)
        dsNumberOfEncountersImageView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        dsNumberOfEncountersImageView.widthAnchor.constraint(equalToConstant: 30).isActive = true
        dailySummaryStackView.addArrangedSubview(noeStackView)
        
        let tloeStackView = UIStackView()
        tloeStackView.axis = .horizontal
        tloeStackView.distribution = .fillProportionally
        tloeStackView.spacing = 10
        tloeStackView.addArrangedSubview(dsTotalLengthOfExposureImageView)
        tloeStackView.addArrangedSubview(dsTotalLengthOfExposureLabel)
        dsTotalLengthOfExposureImageView.heightAnchor.constraint(equalToConstant: 10).isActive = true
        dsTotalLengthOfExposureImageView.widthAnchor.constraint(equalToConstant: 30).isActive = true
        dailySummaryStackView.addArrangedSubview(tloeStackView)
        
        //        let sStackView = UIStackView()
        //        sStackView.axis = .horizontal
        //        sStackView.distribution = .fillProportionally
        //        sStackView.spacing = 10
        //        sStackView.addArrangedSubview(dsStatusImageView)
        //        sStackView.addArrangedSubview(dsStatusLabel)
        //        dsStatusImageView.heightAnchor.constraint(equalToConstant: 10).isActive = true
        //        dsStatusImageView.widthAnchor.constraint(equalToConstant: 30).isActive = true
        //        dailySummaryStackView.addArrangedSubview(sStackView)
    }
    
    func setupHourlySummaryStackView() {
        view.addSubview(hourlySummaryStackView)
        hourlySummaryStackView.leftAnchor.constraint(equalTo: hourlySummaryView.leftAnchor, constant: 12).isActive = true
        hourlySummaryStackView.rightAnchor.constraint(equalTo: hourlySummaryView.rightAnchor, constant: -12).isActive = true
        hourlySummaryStackView.topAnchor.constraint(equalTo: hsTitleLabel.bottomAnchor, constant: 12).isActive = true
        hourlySummaryStackView.bottomAnchor.constraint(equalTo: hourlySummaryView.bottomAnchor, constant: -12).isActive = true
        
        setupHourlySummarySubStackViews()
    }
    
    func setupHourlySummarySubStackViews() {
        let noeStackView = UIStackView()
        noeStackView.axis = .horizontal
        noeStackView.distribution = .fillProportionally
        noeStackView.spacing = 10
        noeStackView.addArrangedSubview(hsNumberOfEncountersImageView)
        noeStackView.addArrangedSubview(hsNumberOfEncountersLabel)
        hsNumberOfEncountersImageView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        hsNumberOfEncountersImageView.widthAnchor.constraint(equalToConstant: 30).isActive = true
        hourlySummaryStackView.addArrangedSubview(noeStackView)
        
        let tloeStackView = UIStackView()
        tloeStackView.axis = .horizontal
        tloeStackView.distribution = .fillProportionally
        tloeStackView.spacing = 10
        tloeStackView.addArrangedSubview(hsTotalLengthOfExposureImageView)
        tloeStackView.addArrangedSubview(hsTotalLengthOfExposureLabel)
        hsTotalLengthOfExposureImageView.heightAnchor.constraint(equalToConstant: 10).isActive = true
        hsTotalLengthOfExposureImageView.widthAnchor.constraint(equalToConstant: 30).isActive = true
        hourlySummaryStackView.addArrangedSubview(tloeStackView)
        
        let sStackView = UIStackView()
        sStackView.axis = .horizontal
        sStackView.distribution = .fillProportionally
        sStackView.spacing = 10
        sStackView.addArrangedSubview(hsStatusImageView)
        sStackView.addArrangedSubview(hsStatusLabel)
        hsStatusImageView.heightAnchor.constraint(equalToConstant: 10).isActive = true
        hsStatusImageView.widthAnchor.constraint(equalToConstant: 30).isActive = true
        hourlySummaryStackView.addArrangedSubview(sStackView)
    }
    
    let barChartView = BarChartView()
    
    func setupGraphView(){
        
//        removeUnchangedValuesFromGraphData()
        
        var encounterEntries: [BarChartDataEntry] = []
        var durationEntries: [BarChartDataEntry] = []

            for i in 0..<hours.count {
                let encounterDataEntry = BarChartDataEntry(x: Double(i), y: Double(encounterPoints[i]))
                encounterEntries.append(encounterDataEntry)
                
                let durationDataEntry = BarChartDataEntry(x: Double(i), y: Double(durationPoints[i]))
                durationEntries.append(durationDataEntry)
        }
        
        let encounterDataSet = BarChartDataSet(entries: encounterEntries, label: "Close Encounters")
        encounterDataSet.valueFont = UIFont.systemFont(ofSize: 12)
        
        let durationDataSet = BarChartDataSet(entries: durationEntries, label: "Total Duration (minutes)")
        durationDataSet.valueFont = UIFont.systemFont(ofSize: 12)

        
        let dataSets: [BarChartDataSet] = [encounterDataSet, durationDataSet]
        
        let chartData = BarChartData(dataSets: dataSets)
        
        let groupSpace = 0.3
        let barSpace = 0.05
        let barWidth = 0.3
        // (0.3 + 0.05) * 2 + 0.3 = 1.00 -> interval per "group"

        let groupCount = self.hours.count
        let startYear = 0

        chartData.barWidth = barWidth
        barChartView.xAxis.axisMinimum = Double(startYear)
        let gg = chartData.groupWidth(groupSpace: groupSpace, barSpace: barSpace)
        print("Groupspace: \(gg)")
        barChartView.xAxis.axisMaximum = Double(startYear) + gg * Double(groupCount)

        chartData.groupBars(fromX: Double(startYear), groupSpace: groupSpace, barSpace: barSpace)
        //chartData.groupWidth(groupSpace: groupSpace, barSpace: barSpace)
        

        barChartView.data = chartData
        encounterDataSet.setColor(.white)
        durationDataSet.setColor(UIColor(red: 105/255, green: 237/255, blue: 255/255, alpha: 1.0))

        barChartView.setVisibleXRange(minXRange: 1, maxXRange: 4)
        
        let legend = barChartView.legend
        legend.enabled = true
        legend.textColor = .white
        legend.horizontalAlignment = .right
        legend.verticalAlignment = .top
        legend.orientation = .vertical
        legend.drawInside = true
//        legend.yOffset = 50.0 //10.0
        legend.yOffset = 0.0
        legend.xOffset = 10.0
        legend.yEntrySpace = 0.0

        let yaxis = barChartView.leftAxis
        yaxis.spaceTop = 0.35
        yaxis.axisMinimum = 0
        yaxis.drawGridLinesEnabled = false
        yaxis.labelTextColor = .white
        yaxis.drawGridLinesEnabled = false
        yaxis.drawAxisLineEnabled = true
        yaxis.drawLabelsEnabled = false
        yaxis.axisLineWidth = 1.0
        yaxis.axisLineColor = .white
        yaxis.labelFont = UIFont.systemFont(ofSize: 12.0)
        
        barChartView.rightAxis.drawGridLinesEnabled = false
        barChartView.rightAxis.drawAxisLineEnabled = false
        barChartView.rightAxis.drawLabelsEnabled = false

        let xaxis = barChartView.xAxis
        xaxis.labelPosition = .bottom
        xaxis.centerAxisLabelsEnabled = true
        xaxis.valueFormatter = IndexAxisValueFormatter(values: self.hours)
        xaxis.granularity = 1
        xaxis.drawLabelsEnabled = true
        xaxis.drawGridLinesEnabled = false
        xaxis.valueFormatter = IndexAxisValueFormatter(values: hours)
        xaxis.labelTextColor = .white
        xaxis.labelPosition = .bottom
        xaxis.axisLineWidth = 1.0
        xaxis.axisLineColor = .white
        barChartView.barData?.setValueTextColor(.white)

        barChartView.highlightPerTapEnabled = false
        barChartView.highlightFullBarEnabled = false
        barChartView.doubleTapToZoomEnabled = false
        barChartView.pinchZoomEnabled = false
        barChartView.drawValueAboveBarEnabled = true
        barChartView.dragEnabled = true
        barChartView.setScaleEnabled(false)
        barChartView.animate(yAxisDuration: 0.5, easingOption: .easeInSine)
        
        if(encounterPoints == [] && durationPoints == []){
            barChartView.clear()
        }
        
        barChartView.noDataText = "No Hourly Summary Data"
        barChartView.noDataTextColor = .white
        
        //@CHECK - call this function when updating data and chart
        barChartView.notifyDataSetChanged()
        
        barChartView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(barChartView)
        barChartView.leftAnchor.constraint(equalTo: hourlySummaryView.leftAnchor).isActive = true
        barChartView.rightAnchor.constraint(equalTo: hourlySummaryView.rightAnchor).isActive = true
        barChartView.topAnchor.constraint(equalTo: hourlySummaryView.topAnchor, constant: 50).isActive = true
        barChartView.bottomAnchor.constraint(equalTo: hourlySummaryView.bottomAnchor).isActive = true
        
//        let graphView = ScrollableGraphView()
//        graphView.dataSource = self
//        graphView.translatesAutoresizingMaskIntoConstraints = false
//
//        // Setup the plot
//        let barPlot1 = BarPlot(identifier: "bar1")
//        barPlot1.barWidth = 25
//        //        barPlot.barLineWidth = 1
//        //        barPlot.barLineColor = UIColor.black
//        barPlot1.barColor = UIColor.white
//        barPlot1.adaptAnimationType = ScrollableGraphViewAnimationType.elastic //.easeOut
//        barPlot1.animationDuration = 1.5 //0.5
//        barPlot1.shouldRoundBarCorners = true
//        barPlot1.barWidth = 20
//
//        // Setup the reference lines
//        let referenceLines = ReferenceLines()
//        referenceLines.referenceLineLabelFont = UIFont.boldSystemFont(ofSize: 8)
//        referenceLines.referenceLineColor = .clear
//        referenceLines.referenceLineLabelColor = UIColor.white
//        referenceLines.dataPointLabelColor = UIColor.white.withAlphaComponent(0.5)
//
//        // Setup the graph
//        graphView.backgroundFillColor = UIColor(red: 0/255, green: 91/255, blue: 187/255, alpha: 1.0)
//
//        //        graphView.shouldAnimateOnStartup = true
//        graphView.shouldAdaptRange = true
//        graphView.shouldAnimateOnStartup = true
//        graphView.shouldRangeAlwaysStartAtZero = true
//        graphView.showsHorizontalScrollIndicator = false
//        graphView.dataPointSpacing = 65
//
//
//        //        graphView.layer.borderWidth = 2.0
//        //        graphView.layer.borderColor = UIColor.white.cgColor
//        //        graphView.layer.cornerRadius = 10
//        //        graphView.rangeMax = 100
//        //        graphView.rangeMin = 0
//
//        // Add everything
//        graphView.addPlot(plot: barPlot1)
//
//        graphView.addReferenceLines(referenceLines: referenceLines)
//
//        view.addSubview(graphView)
//        graphView.leftAnchor.constraint(equalTo: hourlySummaryView.leftAnchor).isActive = true
//        graphView.rightAnchor.constraint(equalTo: hourlySummaryView.rightAnchor).isActive = true
//        graphView.topAnchor.constraint(equalTo: hourlySummaryView.topAnchor, constant: 80).isActive = true
//        graphView.bottomAnchor.constraint(equalTo: hourlySummaryView.bottomAnchor).isActive = true
    }
    
    @objc func handleInfo() {
        let alert = UIAlertController(title: "Close Encounters", message: "A period of at least 5 minutes during which you are within 2 meters of another user is called a close encounter. You will be notified if a close encounter session exceeds 10 minutes. Your close encounters are recorded in a log on your device, with a slight lag for privacy protection purposes. Please check back for updates.", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Okay", style: .cancel, handler: nil))
        
        self.present(alert, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 250
    }
    
}

extension BeaconController {
    
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
            let message = "The app works best when location access has been always allowed. To allow access, go to Settings > PocketCare S > Change location permissions to Always."
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

