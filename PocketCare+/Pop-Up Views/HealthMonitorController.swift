import UIKit
import Eureka
import Alamofire

class HealthMonitorController: FormViewController {
    let defaults = UserDefaults.standard
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.backgroundColor = UIColor(red: 0/255, green: 91/255, blue: 187/255, alpha: 1.0)
        
        title = "Health Monitor"
        navigationController?.navigationBar.prefersLargeTitles = true
        let textAttributes = [NSAttributedString.Key.foregroundColor:UIColor.white]
        navigationController?.navigationBar.largeTitleTextAttributes = textAttributes
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleCancel))
        navigationController?.navigationBar.tintColor = .white
        
        print("presenting view")
        
        let today = Date()
        let formatter3 = DateFormatter()
        formatter3.dateFormat = "EEEE, d MMM y"
        let date = formatter3.string(from: today)
        
        form +++ Section("Do you have the following symptoms or observations today (\(date))?")
            
            <<< CheckRow("checkRow0") { row in
                row.title = "I have the following symptoms: (click to choose & check all that apply)"
                row.value = false
                row.cellSetup({ (cell, row) in
                    cell.height = ({return 80})
                    cell.textLabel?.numberOfLines = 0
                })
                row.onChange { (row) in
                    if row.value! == true {
                        print("Row Added")
                        if row.value! == true {
                            (self.form.rowBy(tag: "checkRow6") as? CheckRow)?.value = false
                            self.tableView.reloadData()
                        }
                    }
                    else {
                        print("Row Removed")
                    }
                }
                
            }
            
            <<< CheckRow("checkRow1") { row in
                row.title = "Fever"
                row.value = false
                row.cellSetup({ (cell, row) in
                    cell.height = ({return 60})
                    cell.textLabel?.numberOfLines = 0
                })
                row.hidden = Condition.function(["checkRow0"], { form in
                    return !((form.rowBy(tag: "checkRow0") as? CheckRow)?.value ?? false)
                })
            }
            <<< CheckRow("checkRow2") { row in
                row.title = "Cough"
                row.value = false
                row.cellSetup({ (cell, row) in
                    cell.height = ({return 60})
                    cell.textLabel?.numberOfLines = 0
                })
                row.hidden = Condition.function(["checkRow0"], { form in
                    return !((form.rowBy(tag: "checkRow0") as? CheckRow)?.value ?? false)
                })
            }
            <<< CheckRow("checkRow3") { row in
                row.title = "Shortness of Breath or difficulty breathing"
                row.value = false
                row.cellSetup({ (cell, row) in
                    cell.height = ({return 60})
                    cell.textLabel?.numberOfLines = 0
                })
                row.hidden = Condition.function(["checkRow0"], { form in
                    return !((form.rowBy(tag: "checkRow0") as? CheckRow)?.value ?? false)
                })
            }
            <<< CheckRow("checkRow4") { row in
                row.title = "Chills"
                row.value = false
                row.cellSetup({ (cell, row) in
                    cell.height = ({return 60})
                    cell.textLabel?.numberOfLines = 0
                })
                row.hidden = Condition.function(["checkRow0"], { form in
                    return !((form.rowBy(tag: "checkRow0") as? CheckRow)?.value ?? false)
                })
            }
            <<< CheckRow("checkRow5") { row in
                row.title = "Other (Muscle Pain, Sore Throat, New loss of taste or smell)"
                row.value = false
                row.cellSetup({ (cell, row) in
                    cell.height = ({return 60})
                    cell.textLabel?.numberOfLines = 0
                })
                row.hidden = Condition.function(["checkRow0"], { form in
                    return !((form.rowBy(tag: "checkRow0") as? CheckRow)?.value ?? false)
                })
            }
            
            <<< CheckRow("checkRow6") { row in
                row.title = "I am feeling fine"
                row.value = false
                row.cellSetup({ (cell, row) in
                    cell.height = ({return 60})
                    cell.textLabel?.numberOfLines = 0
                })
                row.onChange { (row) in
                    if row.value! == true {
                        (self.form.rowBy(tag: "checkRow0") as? CheckRow)?.value = false
                        self.tableView.reloadData()
                    }
                }
            }
            
            <<< CheckRow("checkRow7") { row in
                row.title = "My roommate is sick"
                row.value = false
                row.cellSetup({ (cell, row) in
                    cell.height = ({return 60})
                    cell.textLabel?.numberOfLines = 0
                })
            }
            
            <<< CheckRow("checkRow8") { row in
                row.title = "Someone I met today was sick"
                row.value = false
                row.cellSetup({ (cell, row) in
                    cell.height = ({return 60})
                    cell.textLabel?.numberOfLines = 0
                })
            }
            
            <<< ButtonRow() { row in
                row.title = "Submit"
                row.onCellSelection { (cell, row) in
                    self.handleSubmit()
                    //                    row.deselect(animated: true)
                }
                row.cellSetup({ (cell, row) in
                    cell.height = ({return 60})
                    cell.textLabel?.numberOfLines = 0
                    cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 20)
                })
        }
    }
    
    var symptoms = [String]()
    var healthRecommendation = ""
    
    
    func handleSubmit() {
        guard let checkRow0 = form.rowBy(tag: "checkRow0") as? CheckRow else { return }
        guard let checkRow1 = form.rowBy(tag: "checkRow1") as? CheckRow else { return }
        guard let checkRow2 = form.rowBy(tag: "checkRow2") as? CheckRow else { return }
        guard let checkRow3 = form.rowBy(tag: "checkRow3") as? CheckRow else { return }
        guard let checkRow4 = form.rowBy(tag: "checkRow4") as? CheckRow else { return }
        guard let checkRow5 = form.rowBy(tag: "checkRow5") as? CheckRow else { return }
        guard let checkRow6 = form.rowBy(tag: "checkRow6") as? CheckRow else { return }
        guard let checkRow7 = form.rowBy(tag: "checkRow7") as? CheckRow else { return }
        guard let checkRow8 = form.rowBy(tag: "checkRow8") as? CheckRow else { return }
        
        if checkRow0.value == false && checkRow1.value == false && checkRow2.value == false && checkRow3.value == false && checkRow4.value == false && checkRow5.value == false && checkRow6.value == false && checkRow7.value == false && checkRow8.value == false {
            
            let alert = UIAlertController(title: "No Selection", message: "You haven't selected any options. Please select the appropriate options in the health monitor and try again.", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Okay", style: .cancel, handler: nil))
            
            self.present(alert, animated: true)
            
        }
            
        else if checkRow0.value == false && checkRow6.value == false {
            
            let alert = UIAlertController(title: "Status Not Reported", message: "You haven't reported your status. If you're experiencing any symptoms, please select those symptoms. Otherwise, select I am feeling fine.", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Okay", style: .cancel, handler: nil))
            
            self.present(alert, animated: true)
            
        }
            
        else if checkRow0.value == true && checkRow1.value == false && checkRow2.value == false && checkRow3.value == false && checkRow4.value == false && checkRow5.value == false {
            
            let alert = UIAlertController(title: "Symptoms Not Selected", message: "Please select the specific symptoms that you are experiencing.", preferredStyle: .alert)
            
            alert.addAction(UIAlertAction(title: "Okay", style: .cancel, handler: nil))
            
            self.present(alert, animated: true)
        }
        
        else {
        
        if checkRow0.value! == true {
            if checkRow1.value! == true {
                symptoms.append("Fever")
            }
            if checkRow2.value! == true {
                symptoms.append("Cough")
            }
            if checkRow3.value! == true {
                symptoms.append("Shortness of Breath or difficulty breathing")
            }
            if checkRow4.value! == true {
                symptoms.append("Chills")
            }
            if checkRow5.value! == true {
                symptoms.append("Other (Muscle Pain, Sore Throat, New loss of taste or smell)")
            }
        }
        
        
        if checkRow6.value! == true {
            symptoms.append("I am feeling fine")
        }
        if checkRow7.value! == true {
            symptoms.append("My roommate is sick")
        }
        if checkRow8.value! == true {
            symptoms.append("Someone I met today was sick")
        }
        
        if (symptoms.contains("Fever") && symptoms.contains("Cough")) || (symptoms.contains("Fever") && symptoms.contains("Shortness of Breath or difficulty breathing")) {
            healthRecommendation = "Based on the symptoms you selected, please contact medical professionals immediately!"
        }
        else if symptoms.contains("Fever") || symptoms.contains("Cough") || symptoms.contains("Shortness of Breath or difficulty breathing") ||  symptoms.contains("Chills") ||  symptoms.contains("Other (Muscle Pain, Sore Throat, New loss of taste or smell)") {
            healthRecommendation = "Please stay home and continue to watch your symptoms daily."
        }
        else if symptoms.contains("I am feeling fine") {
            healthRecommendation = "You reported no symptoms, let's stay healthy and fit."
        }
        if symptoms.contains("My roommate is sick") {
            if healthRecommendation == "" {
                healthRecommendation.append("Tell your roommate to take precautions and maintain appropriate distance from your roommate.")
            }
            else {
             healthRecommendation.append(" Tell your roommate to take precautions and maintain appropriate distance from your roommate.")
            }
        }
        
        saveData()
        uploadHealthReport()
        let alert = UIAlertController(title: "Health Report", message: healthRecommendation, preferredStyle: .alert)
        
        //                    alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: { (action) in
        //                        self.dismiss(animated: true, completion: nil)
        //                    }))
        
        alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: { (action) in
            
            self.dismiss(animated: true, completion: nil)
            self.symptoms.removeAll()
            self.tableView.reloadData()
            self.healthRecommendation = ""
        }))
        
        //                    alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
        
        self.present(alert, animated: true)
            
        }
        
    }
    
    func getDate(_ date: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        dateFormatter.timeZone = TimeZone.current
        dateFormatter.locale = Locale.current
        return dateFormatter.date(from: date) // replace Date String
    }
    
    func generateDateEpoch() -> UInt64 {
        let today = Date()
        let date = Calendar.current.date(bySettingHour: 12, minute: 0, second: 0, of: today)!
        let currentHour = Calendar.current.date(byAdding: .hour, value: -4, to: date)!
        print("Date:", currentHour)
        return UInt64(currentHour.toMillis())
    }
    
    func uploadHealthReport(){
        var parameters = [String: Any]()
        var headers = [String: String]()
        let token = defaults.string(forKey: "token")
        let usersSymptoms:[String] = symptoms.filter{ $0 != "My roommate is sick" && $0 != "Someone I met today was sick" }
        parameters["usersSymptoms"] = usersSymptoms
        
        let date = generateDateEpoch()
        parameters["date"] = date
        
        if symptoms.contains("My roommate is sick"){
            parameters["roommatesSymptoms"] = ["True"]
        } else {
            parameters["roommatesSymptoms"] = ["False"]
        }
        if symptoms.contains("Someone I met today was sick"){
            parameters["othersSymptoms"] = ["True"]
        } else {
            parameters["othersSymptoms"] = ["False"]
        }
        
        if token != nil {
            headers["token"] = token
            print("Parameters: \(parameters)")
            print("Headers: \(headers)")
            Alamofire.request("\(Constants.hostURL)/user/symptoms", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON
                { (response:DataResponse) in
                    switch(response.result)
                    {
                    case .success(_):
                        print("SUCCESS UPLOADING USER HEALTH REPORT")
                        print(response)
                        break
                    case .failure(_):
                        
//                        let appDelegate = UIApplication.shared.delegate as! AppDelegate
//                        appDelegate.updateUserToken()
//                        self.uploadHealthReport()
//
                        print("FAILURE UPLOADING USER HEALTH REPORT")
                        print(response)
                        break
                    }
            }
        }
    }
    
    @objc func handleCancel(){
        print("Cancelling")
        dismiss(animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let header = view as? UITableViewHeaderFooterView {
            header.backgroundView?.backgroundColor = UIColor.clear
            header.textLabel?.textColor = UIColor.white
        }
    }
    
    var healthStatus = ""
        
    func saveData(){
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        if symptoms.contains("Fever") || symptoms.contains("Cough") ||  symptoms.contains("Shortness of Breath or difficulty breathing") ||
            symptoms.contains("Chills") ||
            symptoms.contains("Other (Muscle Pain, Sore Throat, New loss of taste or smell)") {
            
            healthStatus = "I have the following symptoms: \n"
            
            let symptomArray = ["Fever", "Cough", "Shortness of Breath or difficulty breathing", "Chills", "Other (Muscle Pain, Sore Throat, New loss of taste or smell)"]
            
            for element in symptomArray {
                if symptoms.contains(element) {
                    healthStatus.append("• \(element)\n")
                }
            }
        }
        
        if symptoms.contains("I am feeling fine") && symptoms.contains("My roommate is sick") && symptoms.contains("Someone I met today was sick"){
            healthStatus.append("I am feeling fine. My roommate is sick. Someone I met today was sick.")
        }
        else if symptoms.contains("I am feeling fine") && symptoms.contains("My roommate is sick") {
            healthStatus.append("I am feeling fine. My roommate is sick.")
        }
        else if symptoms.contains("I am feeling fine") && symptoms.contains("Someone I met today was sick") {
            healthStatus.append("I am feeling fine. Someone I met today was sick.")
        }
        else if symptoms.contains("My roommate is sick") && symptoms.contains("Someone I met today was sick") {
            healthStatus.append("My roommate is sick. Someone I met today was sick.")
        }
        else if symptoms.contains("I am feeling fine") {
            healthStatus.append("I am feeling fine.")
        }
        else if symptoms.contains("My roommate is sick") {
            healthStatus.append("My roommate is sick.")
        }
        else if symptoms.contains("Someone I met today was sick") {
            healthStatus.append("Someone I met today was sick.")
        }
        
//        if symptoms.contains("My roommate is sick") && symptoms.contains("Someone I met today was sick") && !healthStatus.contains("My roommate is sick") && !healthStatus.contains("Someone I met today was sick") {
//            healthStatus.append("My roommate is sick. Someone I met today was sick.")
//        }
//        else if symptoms.contains("My roommate is sick") && !healthStatus.contains("My roommate is sick"){
//            healthStatus.append("My roommate is sick.")
//        }
//        else if symptoms.contains("Someone I met today was sick")  && !healthStatus.contains("Someone I met today was sick") {
//            healthStatus.append("Someone I met today was sick.")
//        }
        
        let report = Report(context: context)
        
        let currentDateTime = Date()
        let formatter = DateFormatter()
        formatter.timeStyle = .medium
        formatter.dateStyle = .medium
        let dateTimeString = formatter.string(from: currentDateTime)

        report.date = dateTimeString
        print(report.date)
        
        
        let formatter1 = DateFormatter()
        formatter1.dateFormat = "MMM d, y"
        let dts = formatter1.string(from: currentDateTime)
        print("DTS:", dts)
        
        let currentDate = Date()
        let df = DateFormatter()
        df.dateFormat = "MMM d, y"
        let cd = df.string(from: currentDate)
        print("CD:", cd)
        
        
        report.status = healthStatus
        report.recommendation = healthRecommendation
        
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
    }
    
    
}
