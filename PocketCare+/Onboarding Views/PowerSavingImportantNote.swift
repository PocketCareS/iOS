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

class PowerSavingImportantNote: UIViewController {
    
    let defaults = UserDefaults.standard
    
    let imageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "BatteryScreen")
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.tintColor = .systemGreen
        iv.contentMode = .scaleAspectFit
        iv.clipsToBounds = true
        return iv
    }()
    
    let textView: UITextView = {
        let tv = UITextView()
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.showsVerticalScrollIndicator = false
        tv.textColor = .black
        tv.textAlignment = .center
        tv.isEditable = false
        return tv
    }()

    let nextButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor(red: 0/255, green: 91/255, blue: 187/255, alpha: 1.0)
        button.setTitle("Continue", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 17)
        button.layer.cornerRadius = 15
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(handleNext), for: .touchUpInside)
        return button
    }()
    
    @objc func handleNext() {
        defaults.set(true, forKey: "hasEntered")
        
        let tbc = TabBarController()
        tbc.modalPresentationStyle = .fullScreen
        present(tbc, animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.hidesBackButton = true
        
        setupViewController()
        setupViews()
        setupText()
    }
    
    let mutableString = NSMutableAttributedString()

    func setupText() {
        let aboutText = "The Power Saving Mode is not necessary to keep scanning for close encounters, but could be useful when you don’t plan to use the phone often. If you are not in the Power Saving Mode, you will receive the \"PocketCare S is running\" notification periodically, which will light up your screen for 10 seconds. If you don't plan to use the phone at all for a long time, and don't want to receive this notification during this period, we suggest that you enter the Power Saving Mode. If you don’t mind the occasional notifications, then you don’t need to use the Power Saving Mode."
        
//        "Power Saving Mode allows users to keep PocketCare S in the foreground by dimming the screen of the app for low power consumption, and the ability to communicate with other devices efficiently."
        
        
        let font1 = UIFont.systemFont(ofSize: 17)
        let attributes1 = [NSAttributedString.Key.font: font1]
        let attributedAboutText = NSAttributedString(string: aboutText, attributes: attributes1)
        
        let font2 = UIFont.boldSystemFont(ofSize: 17)
        let attributes2 = [NSAttributedString.Key.font: font2]
        let dataCollection = "\n\nNote: Power Saving Mode is not required for the app to work when it is in the background."
        let attributedDataCollection = NSAttributedString(string: dataCollection, attributes: attributes2)
        
        mutableString.append(attributedAboutText)
        mutableString.append(attributedDataCollection)
        textView.attributedText = mutableString
    }
    
    func setupViewController() {
        view.backgroundColor = .white
        
        title = "Power Saving"
        
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    func setupViews() {
        view.addSubview(imageView)
        imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 15).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: view.frame.height / 4).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: view.frame.height / 4).isActive = true
        imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        view.addSubview(nextButton)
        nextButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 50).isActive = true
        nextButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -50).isActive = true
        nextButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20).isActive = true
        nextButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        view.addSubview(textView)
        textView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20).isActive = true
        textView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20).isActive = true
        textView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        textView.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 30).isActive = true
        textView.bottomAnchor.constraint(equalTo: nextButton.topAnchor, constant: -30).isActive = true
    }
    
}
