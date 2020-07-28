import UIKit
import CoreData
import UserNotifications

class HealthReportsController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var tableView = UITableView()
    let cellId = "cellId"
    var reports: [Report] = []
    
    
    let noReportsLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "You don't have any health reports yet. Please enter your daily health report, it only takes a few seconds."
        label.textAlignment = .center
        label.numberOfLines = 0
        label.textColor = .white
        return label
    }()
    
    let addReportButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Add New Report", for: .normal)
        button.addTarget(self, action: #selector(handleAddReport), for: .touchUpInside)
        button.backgroundColor = .white
        button.setTitleColor(.systemBlue, for: .normal)
        button.layer.cornerRadius = 10
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        button.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.25).cgColor
        button.layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
        button.layer.shadowOpacity = 1.0
        button.layer.shadowRadius = 0.0
        button.layer.masksToBounds = false
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 0/255, green: 91/255, blue: 187/255, alpha: 1.0)
        
        let textAttributes = [NSAttributedString.Key.foregroundColor:UIColor.white]
        navigationController?.navigationBar.largeTitleTextAttributes = textAttributes
        
        navigationController?.navigationBar.prefersLargeTitles = true
        
        let fontConfiguration = UIImage.SymbolConfiguration(font: UIFont.systemFont(ofSize: 22), scale: .large)
        let plusBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "plus.circle.fill", withConfiguration: fontConfiguration), style: .plain, target: self, action: #selector(handleAddReport))
        navigationItem.rightBarButtonItem = plusBarButtonItem
        
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.barTintColor = UIColor(red: 0/255, green: 91/255, blue: 187/255, alpha: 1.0)
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor : UIColor.white]
                
        title = "Reports" //Health Reports
        
        addTableView()
        
        tableView.separatorColor = .white
    }
    
    @objc func handleAddReport() {
        let hmc = UINavigationController(rootViewController: HealthMonitorController())
        hmc.modalPresentationStyle = .fullScreen
        present(hmc, animated: true, completion: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        getData()
        
        if reports.count == 0 {
            self.tableView.separatorStyle = .none
            
            addNoReportView()
            
        } else {
            self.tableView.separatorStyle = .singleLine
            
            noReportsLabel.removeFromSuperview()
            addReportButton.removeFromSuperview()
        }
        print("Reports count = \(reports.count)")
        tableView.reloadData()
        self.tableView.tableFooterView = UIView()
    }
    
    func addNoReportView() {
        view.addSubview(noReportsLabel)
        noReportsLabel.widthAnchor.constraint(equalToConstant: view.frame.width / 2).isActive = true
        noReportsLabel.heightAnchor.constraint(equalToConstant: 100).isActive = true
        noReportsLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 30).isActive = true
        noReportsLabel.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -30).isActive = true
        noReportsLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -50).isActive = true
        
        view.addSubview(addReportButton)
        addReportButton.widthAnchor.constraint(equalToConstant: 200).isActive = true
        addReportButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        addReportButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        addReportButton.topAnchor.constraint(equalTo: noReportsLabel.bottomAnchor, constant: 20).isActive = true
    }
    
    func addTableView(){
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.backgroundColor = UIColor(red: 0/255, green: 91/255, blue: 187/255, alpha: 1.0)
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellId)
        
        view.addSubview(tableView)
        tableView.pin(to: view)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reports.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
        
        let report = reports[indexPath.row]
        
        for subview in cell.contentView.subviews {
            subview.removeFromSuperview()
        }
        
        print(reports)
        
        cell.backgroundColor = UIColor(red: 0/255, green: 91/255, blue: 187/255, alpha: 1.0)
        cell.selectionStyle = .none
        
        let dateLabel = UILabel(frame: CGRect(x: 20, y: 20, width: cell.frame.width - (40), height: 60))
        let mutableAttributedString1 = NSMutableAttributedString()
        let boldText1 = NSAttributedString(string: "Date: \n", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 20)])
        let plainText1 = NSAttributedString(string: report.date!, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14)])
        mutableAttributedString1.append(boldText1)
        mutableAttributedString1.append(plainText1)
        dateLabel.attributedText = mutableAttributedString1
        dateLabel.numberOfLines = 0
        dateLabel.textColor = .white
        cell.contentView.addSubview(dateLabel)
        
        let statusLabel = UILabel(frame: CGRect(x: 20, y: 90, width: cell.frame.width - (40), height: 100))
        let mutableAttributedString2 = NSMutableAttributedString()
        let boldText2 = NSAttributedString(string: "Health Status: \n", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 20)])
        let plainText2 = NSAttributedString(string: report.status!, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14)])
        mutableAttributedString2.append(boldText2)
        mutableAttributedString2.append(plainText2)
        statusLabel.attributedText = mutableAttributedString2
        statusLabel.numberOfLines = 0
        statusLabel.textColor = .white
        statusLabel.adjustsFontSizeToFitWidth = true
        cell.contentView.addSubview(statusLabel)
        
        let recommendationLabel = UILabel(frame: CGRect(x: 20, y: 200, width: cell.frame.width - (40), height: 100))
        let mutableAttributedString3 = NSMutableAttributedString()
        let boldText3 = NSAttributedString(string: "Health Recommendation: \n", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 20)])
        let plainText3 = NSAttributedString(string: report.recommendation!, attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14)])
        mutableAttributedString3.append(boldText3)
        mutableAttributedString3.append(plainText3)
        recommendationLabel.attributedText = mutableAttributedString3
        recommendationLabel.numberOfLines = 0
        recommendationLabel.adjustsFontSizeToFitWidth = true
        recommendationLabel.textColor = .white
        cell.contentView.addSubview(recommendationLabel)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 310
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        if editingStyle == .delete {
            let report = reports[indexPath.row]
            context.delete(report)
            (UIApplication.shared.delegate as! AppDelegate).saveContext()
            
            do {
                reports = try context.fetch(Report.fetchRequest())
                reports = reports.reversed()
            }
            catch {
                print("Fetching failed")
            }
        }
        print("Reports count = \(reports.count)")
        if reports.count == 0 {
            self.tableView.separatorStyle = .none
            
            addNoReportView()
        } else {
            self.tableView.separatorStyle = .singleLine
            
            
        }
        tableView.reloadData()
    }
    
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
        
    func getData(){
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
//        print("Report Count:", reports.count)
        
//        print("Reports:", reports)
        
        let currentDateTime = Date()
        let formatter1 = DateFormatter()
        formatter1.dateFormat = "MMM d, y"
        let dts = formatter1.string(from: currentDateTime)
//        print("DTS:", dts)
        
//        for report in reports {
//            guard let reportDate = report.date else { return }
//            print(reportDate)
//
//            if reportDate.contains(dts) && reports.count == 0 {
//
//            }
//            if reportDate.contains(dts) && reports.count == 1 {
//                print("Same 2 Dates")
//                context.delete(report)
//                (UIApplication.shared.delegate as! AppDelegate).saveContext()
//            }
//            else if reportDate.contains(dts) && reports.count + 1 > 2 {
//                print("Same Many Dates")
//                context.delete(report)
//                (UIApplication.shared.delegate as! AppDelegate).saveContext()
//            }
//            else {
//                print("Different Date")
//            }
//        }
        
        var request = NSFetchRequest<NSFetchRequestResult>()
        request = Report.fetchRequest()
        request.returnsObjectsAsFaults = false
        
        var sameDateArray = [Report]()
        
        do {
            reports = try context.fetch(request) as! [Report]
            
            for report in reports {
                guard let reportDate = report.date else { return }
                
                if reportDate.contains(dts) {
                    sameDateArray.append(report)
                }
                }
                print("Same Date Array:", sameDateArray)
            
            if sameDateArray.count >= 2 {
            for i in 0...sameDateArray.count - 2 {
                context.delete(sameDateArray[i])
                (UIApplication.shared.delegate as! AppDelegate).saveContext()
                sameDateArray.remove(at: i)
                reports.remove(at: i)
            }
            }
            reports = try context.fetch(request) as! [Report]
            reports = reports.reversed()
        }
        catch {
            print("Fetching failed")
        }
    }
    
    func setupNotificationPermissions() {
        let center = UNUserNotificationCenter.current()

        center.requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in
            if granted {
                print("Yay!")
            } else {
                print("D'oh")
            }
        }
    }
    
//    func scheduleNotification() {
//        let center = UNUserNotificationCenter.current()
//
//        let content = UNMutableNotificationContent()
//        content.title = "Report Health Status"
//        content.body = "You haven't reported your Health Status for the day. Click here to report it now."
//        content.categoryIdentifier = "alarm"
//        content.userInfo = ["customData": "fizzbuzz"]
//        content.sound = UNNotificationSound.default
//
//        var dateComponents = DateComponents()
//        //@CHECK - Notification Time
//        dateComponents.hour = 15
//        dateComponents.minute = 6
//        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
//
//        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
//        center.add(request)
//    }
    
}

//for report in reports {
//
//               let currentDateTime = Date()
//               let formatter = DateFormatter()
//               formatter.timeStyle = .none
//               formatter.dateStyle = .medium
//               let todaysDate = formatter.string(from: currentDateTime)
//
//               let formatter1 = DateFormatter()
//               formatter1.timeStyle = .medium
//               formatter1.dateStyle = .medium
//               let dateTimeString1 = formatter1.date(from: report.date!)
//
//               print(dateTimeString1)
//
//               let formatter2 = DateFormatter()
//               formatter2.timeStyle = .none
//               formatter2.dateStyle = .medium
//               let dateTimeString2 = formatter2.string(from: dateTimeString1!)
//
//               print(dateTimeString2)
//
//               print("Report.date: \(dateTimeString2)")
//               print("Date Time String: \(todaysDate)")
//
//               if dateTimeString2 == todaysDate {
//
