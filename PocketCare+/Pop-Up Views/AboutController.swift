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

class AboutController: UIViewController {
    
    let mutableString = NSMutableAttributedString()
    let websiteURL = "https://engineering.buffalo.edu/computer-science-engineering/pocketcares.html"
    
    let imageView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.image = #imageLiteral(resourceName: "iOS Launch Screen")
        iv.contentMode = .scaleAspectFit
        iv.clipsToBounds = true
        return iv
    }()
    
    let textView: UITextView = {
        let tv = UITextView()
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.showsVerticalScrollIndicator = false
        tv.isEditable = false
        return tv
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViewController()
        setupViews()
        setupText()
    }
    
    func setupViewController() {
        
        title = "PocketCare S"
        
        view.backgroundColor = .white
        
        navigationController?.navigationBar.prefersLargeTitles = true
        
        let textAttributes = [NSAttributedString.Key.foregroundColor:UIColor.black]
        navigationController?.navigationBar.largeTitleTextAttributes = textAttributes
    }
    
    func setupViews() {
        view.addSubview(imageView)
        imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 30).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 150).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 150).isActive = true
        imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        view.addSubview(textView)
        textView.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 20).isActive = true
        textView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20).isActive = true
        textView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20).isActive = true
        textView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 20).isActive = true
    }
    
    func setupText() {
        let about = "About App"
        let font = UIFont.boldSystemFont(ofSize: 20)
        let attributes = [NSAttributedString.Key.font: font]
        let attributedAbout = NSAttributedString(string: about, attributes: attributes)
        
        let aboutText = "\n\nPocketCare S uses Bluetooth to enable smartphones to send and receive beacon signals. It checks the distance between a smartphone and another beacon (or smartphone running the same app) to see if they are within 2 meters from each other, and if so, the smartphone records the duration of such a close encounter with another beacon. \n\nIt provides each user with social distance information such as the number of other users who have been in close proximity with the user on a hourly and daily basis. It also reports to the user the duration of the close encounter sessions the user was involved, and alerts the user if the duration of the current session exceeds a certain threshold. \n\nFor administrators of an organization (whose members adopt PocketCare S), social distance information aggregated over all of its member users such as the total number and duration of close encounters in the workplace will be made available through an analytics dashboard, which responds to queries such as \"what is the number (or the percentage) of the users who have had more (or less) than \"x\" number (or minutes) of close encounters?\". Such information will empower both users and employers to practice and encourage good social distancing in the workplace. \n\nPocketCare S is built upon a previous application, called PocketCare, developed five years ago by University at Buffalo (UB) faculty and students track the flu/virus propagation, and used by many volunteers. The new PocketCare S is the second generation of PocketCare, where \"S\" also stands for \"Social distance\". \n\nFor more information, visit PocketCare S "
        
        let font1 = UIFont.systemFont(ofSize: 15)
        let attributes1 = [NSAttributedString.Key.font: font1]
        let attributedAboutText = NSAttributedString(string: aboutText, attributes: attributes1)
        
        let link0 = NSMutableAttributedString(string: "website.")
        link0.addAttribute(.link, value: websiteURL, range: NSRange(location: 0, length: link0.length - 1))
        link0.addAttributes(attributes1, range: NSRange(location: 0, length: link0.length))
        
        let dataCollection = "\n\nData Collection, Usage, and Privacy Policy"
        let attributedDataCollection = NSAttributedString(string: dataCollection, attributes: attributes)
        
        let dataCollectionText1 = "\n\nThe app does not collect any private information about an individual person. All the data collected is anonymous and will not reveal any personally identifiable information. \n\nThe app collects anonymous ids of the beacons encountered, and estimates the duration of each close encounter session. Each smartphone randomly generates and frequently changes its anonymous id to be advertised to other smartphones to further protect privacy. Although the app requires the GPS to be turned on in order to determine if a close encounter with another beacon occurs on a campus or not, no GPS information is collected. Users are encouraged, "
        let attributedDataCollectionText1 = NSAttributedString(string: dataCollectionText1, attributes: attributes1)

        let dataCollectionText2 = "but are not required"
        let font2 = UIFont.boldSystemFont(ofSize: 15)
        let attributes2 = [NSAttributedString.Key.font: font2]
        let attributedDataCollectionText2 = NSAttributedString(string: dataCollectionText2, attributes: attributes2)

        let dataCollectionText3 = ", to provide a daily, anonymous health monitoring report, and other anonymous profile information such as age groups, zip code, gender and ethnicity. \n\nSome anonymized data collected will be stored in a secure server. Based on the anonymous data, the server will aggregate the information on the number and duration of close encounters on campus from all users, and make such aggregated information (instead of information about any particular individual) available to the public. \n\nPocketCare S strictly adheres to the privacy policies reviewed and approved by "
        let attributedDataCollectionText3 = NSAttributedString(string: dataCollectionText3, attributes: attributes1)
        
        let link1 = NSMutableAttributedString(string: "University at Buffalo Human Research Protection Program (IRB)")
        link1.addAttribute(.link, value: "https://www.research.buffalo.edu/rsp/irb/behavioral_sciences/", range: NSRange(location: 0, length: link1.length))
        link1.addAttributes(attributes1, range: NSRange(location: 0, length: link1.length))

        let dataCollectionText4 = ". More information about the data collection, usage and privacy policy can be found on our "
        let attributedDataCollectionText4 = NSAttributedString(string: dataCollectionText4, attributes: attributes1)
        
        let link2 = NSMutableAttributedString(string: "website.")
        link2.addAttribute(.link, value: websiteURL, range: NSRange(location: 0, length: link2.length - 1))
        link2.addAttributes(attributes1, range: NSRange(location: 0, length: link2.length))
        
        mutableString.append(attributedAbout)
        mutableString.append(attributedAboutText)
        mutableString.append(link0)
        mutableString.append(attributedDataCollection)
        mutableString.append(attributedDataCollectionText1)
        mutableString.append(attributedDataCollectionText2)
        mutableString.append(attributedDataCollectionText3)
        mutableString.append(link1)
        mutableString.append(attributedDataCollectionText4)
        mutableString.append(link2)
        
        textView.attributedText = mutableString
    }
}
