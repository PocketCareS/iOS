import Foundation
import UIKit
import FSCalendar
import Charts

class GraphController: UIViewController, FSCalendarDataSource, FSCalendarDelegate {
    let week1 = [ "4/19", "4/20", "4/21", "4/22","4/23","4/24","4/25"]
    let week1A = [0.0, 20.0, 50.0, 30.0, 10.0, 10.0, 80.0]
    let week1B = [0.0, 5.0, 10.0, 6.0, 3.0, 2.0, 10.0]
    
    let week0 = [ "", "", "", "","","4/24","4/25"]
    let week0A = [0.0, 0.0, 0.0, 0.0, 0.0, 20.0, 30.0]
    let week0B = [0.0, 0.0, 0.0, 0.0, 0.0, 7.0, 5.0]
    
    let week2A = [0.0, 20.0, 50.0, 30.0, 10.0, 10.0, 80.0]
    let week2B = [0.0, 5.0, 10.0, 6.0, 3.0, 2.0, 10.0]
    let week2 = ["4/26", "4/27", "4/28", "4/29","4/30","5/1",""]
    
    let weekDays = ["Sun","Mon","Tue","Wed","Thu","Fri","Sat"]
    var window: UIWindow?
    let blueView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(red: 0/255, green: 91/255, blue: 187/255, alpha: 1.0)
        return view
    }()
    let contactsLabel = UILabel()
    let locationLabel = UILabel()
    let placesView = BarChartView()
    let contactsView = BarChartView()
    override func viewDidLoad() {
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.view.backgroundColor = UIColor(red: 214, green: 247, blue: 255)
        view.addSubview(blueView)
        blueView.widthAnchor.constraint(equalToConstant: view.frame.width).isActive = true
        blueView.heightAnchor.constraint(equalToConstant: view.frame.height / 6).isActive = true
        blueView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        let calendar = FSCalendar()
        calendar.translatesAutoresizingMaskIntoConstraints = false
        calendar.dataSource = self
        calendar.delegate = self
        calendar.scope = .week
        calendar.appearance.borderRadius = 0.4
        calendar.appearance.headerDateFormat = "MMM yyyy"
        calendar.appearance.weekdayTextColor = .white
        calendar.appearance.headerTitleColor = .white
        calendar.appearance.titleDefaultColor = .white
        calendar.appearance.selectionColor = .none
        calendar.appearance.titleSelectionColor = .white
        calendar.appearance.todayColor = .systemBlue
        calendar.today = nil
        view.addSubview(calendar)
        calendar.widthAnchor.constraint(equalToConstant: view.frame.width).isActive = true
        calendar.heightAnchor.constraint(equalToConstant: view.frame.height / 3).isActive = true
        calendar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        
        contactsLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(contactsLabel)
        contactsLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        contactsLabel.topAnchor.constraint(equalTo: blueView.bottomAnchor).isActive = true
        contactsLabel.heightAnchor.constraint(equalToConstant: 50).isActive = true
        contactsLabel.text = "Number of Human Contacts Per Day"
        //contacts bar graph
        contactsView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(contactsView)
        contactsView.widthAnchor.constraint(equalToConstant: view.frame.width).isActive = true
        //contactsView.heightAnchor.constraint(equalToConstant: (bottomView-150)/2.0).isActive = true
        contactsView.bottomAnchor.constraint(equalTo: view.centerYAnchor, constant: 45).isActive = true
        contactsView.topAnchor.constraint(equalTo:contactsLabel.bottomAnchor, constant: -30).isActive = true
        //contactsView.bottomAnchor.constraint(equalToConstant:blueView.bottomAnchor, constant:50).isActive = true
        
        locationLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(locationLabel)
        locationLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        locationLabel.topAnchor.constraint(equalTo: contactsView.bottomAnchor).isActive = true
        locationLabel.heightAnchor.constraint(equalToConstant: 50).isActive = true
        locationLabel.text = "Number of Places Visited Per Day"
        
        //places bar graph
        placesView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(placesView)
        placesView.widthAnchor.constraint(equalToConstant: view.frame.width).isActive = true
        placesView.topAnchor.constraint(equalTo: locationLabel.bottomAnchor, constant: -30).isActive = true
        placesView.bottomAnchor.constraint(equalTo:view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        setChart(contactsPoints: week2, contactsValues: week2A, placesPoints:week2, placesValues: week2B)
    }
    func setChart(contactsPoints: [String], contactsValues: [Double],placesPoints: [String], placesValues: [Double]) {
        
        var contactsEntries: [BarChartDataEntry] = []
        var placesEntries: [BarChartDataEntry] = []
        for i in 0..<contactsPoints.count {
            let contactsDataEntry = BarChartDataEntry(x: Double(i), y: Double(contactsValues[i]))
            contactsEntries.append(contactsDataEntry)
        }
        for i in 0..<placesPoints.count {
            let placesDataEntry = BarChartDataEntry(x: Double(i), y: Double(contactsValues[i]))
            placesEntries.append(placesDataEntry)
        }
        //contacts bar graph
        let chartDataSet = BarChartDataSet(entries: contactsEntries, label: "Bar Chart")
        let chartData = BarChartData(dataSet: chartDataSet)
        contactsView.data = chartData
        chartDataSet.setColor(UIColor(red: 81, green: 210, blue: 254))
        //chartDataSet.colors = ChartColorTemplates.vordiplom()
        contactsView.legend.enabled = false
        contactsView.xAxis.drawLabelsEnabled = false
        contactsView.xAxis.drawGridLinesEnabled = false
        contactsView.rightAxis.drawGridLinesEnabled = false
        contactsView.leftAxis.drawGridLinesEnabled = false
        contactsView.xAxis.labelPosition = .bottom
        contactsView.rightAxis.drawAxisLineEnabled = false
        contactsView.rightAxis.drawLabelsEnabled = false
        contactsView.doubleTapToZoomEnabled = false
        contactsView.pinchZoomEnabled = false
        contactsView.leftAxis.labelFont = UIFont.systemFont(ofSize: 12.0)
        contactsView.drawValueAboveBarEnabled = true
        contactsView.dragEnabled = false
        contactsView.animate(yAxisDuration: 0.5, easingOption: .easeInSine)
        let placesDataSet = BarChartDataSet(entries: placesEntries, label: "Bar Chart")
        let placesData = BarChartData(dataSet: placesDataSet)
        placesView.data = placesData
        placesView.dragEnabled = false
        placesDataSet.setColor(#colorLiteral(red: 0.2629416981, green: 0.8235294223, blue: 0.1847054663, alpha: 0.8624518408))
        //placesDataSet.colors = ChartColorTemplates.vordiplom()
        placesView.legend.enabled = false
        placesView.xAxis.drawLabelsEnabled = true
        placesView.xAxis.drawGridLinesEnabled = false
        placesView.rightAxis.drawGridLinesEnabled = false
        placesView.leftAxis.drawGridLinesEnabled = false
        placesView.xAxis.labelPosition = .bottom
        placesView.rightAxis.drawAxisLineEnabled = false
        placesView.doubleTapToZoomEnabled = false
        placesView.pinchZoomEnabled = false
        placesView.rightAxis.drawLabelsEnabled = false
        placesView.drawValueAboveBarEnabled = true
        placesView.leftAxis.labelFont = UIFont.systemFont(ofSize: 12.0)
        placesView.xAxis.valueFormatter = IndexAxisValueFormatter   (values:weekDays)
        placesView.xAxis.granularity = 1.0
        placesView.animate(yAxisDuration: 0.5, easingOption: .easeInSine)
        if(placesPoints==[]){
            placesView.clear()
        }
        if(contactsPoints == []){
            contactsView.clear()
        }
        contactsView.noDataText = "No Contacts Data For this Week"
        placesView.noDataText = "No Location Data For this Week"
    }
    //calendar
    func maximumDate(for calendar: FSCalendar) -> Date {
        return Date()
    }
    func minimumDate(for calendar: FSCalendar) -> Date {
        return Calendar.current.date(byAdding: .day, value: -14, to: Date())!
    }
    func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
        let genCalendar = Calendar.current
        
        print("\(genCalendar.component(.day, from: calendar.currentPage))")
        if(calendar.currentPage<calendar.minimumDate){
            calendar.select(calendar.minimumDate)
        }
        else{
            
        }
        if(genCalendar.component(.day, from: calendar.currentPage)==12){
            setChart(contactsPoints: week0, contactsValues: week0A, placesPoints:week0, placesValues: week0B)
        }
        else if(genCalendar.component(.day, from: calendar.currentPage)==19){
            setChart(contactsPoints: week1, contactsValues: week1A, placesPoints:week1, placesValues: week1B)
        }
        else if(genCalendar.component(.day, from: calendar.currentPage)==26){
            setChart(contactsPoints: week2, contactsValues: week2A, placesPoints:week2, placesValues: week2B)
        }
        
    }
    /*func retrieveUserDefaults(index: Int){
           longittudeArray = defaults.stringArray(forKey: "\(month)"+"/"+"\(day)"+"/"+"longitude") ?? [""]
           latittudeArray = defaults.stringArray(forKey: "\(month)"+"/"+"\(day)"+"/"+"latittude") ?? [""]
           timeArray = defaults.stringArray(forKey: "\(month)"+"/"+"\(day)"+"/"+"time") ?? [""]
       }*/
}
extension UIColor {
   convenience init(red: Int, green: Int, blue: Int) {
       assert(red >= 0 && red <= 255, "Invalid red component")
       assert(green >= 0 && green <= 255, "Invalid green component")
       assert(blue >= 0 && blue <= 255, "Invalid blue component")
       self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
   }
   convenience init(rgb: Int) {
       self.init(
           red: (rgb >> 16) & 0xFF,
           green: (rgb >> 8) & 0xFF,
           blue: rgb & 0xFF
       )
   }
}
