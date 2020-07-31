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

class PowerSaveInfoController: UIViewController {
    
    let imageView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.image = UIImage(systemName: "battery.100")
        iv.tintColor = .systemGreen
        iv.contentMode = .scaleAspectFit
        iv.clipsToBounds = true
        return iv
    }()
    
    let textView: UITextView = {
        let tv = UITextView()
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.text = "The Power Saving Mode is not necessary to keep scanning for close encounters, but could be useful when you don’t plan to use the phone often. If you are not in the Power Saving Mode, you will receive the \"PocketCare S is running\" notification periodically, which will light up your screen for 10 seconds. If you don't plan to use the phone at all for a long time, and don't want to receive this notification during this period, we suggest that you enter the Power Saving Mode. If you don’t mind the occasional notifications, then you don’t need to use the Power Saving Mode. \n\nNote: Power Saving Mode is not required for the app to work when it is in the background."
        
//        "Power Saving Mode allows users to keep PocketCare S in the foreground by dimming the screen of the app for low power consumption, and the ability to communicate with other devices efficiently. Power Saving Mode saves battery life of your iPhone, and can be accessed from anywhere by clicking on the Power Saving Mode button on the bottom tab. \n\nNote: Power Saving Mode is not required for the app to work when it is in the background."
        
        tv.font = UIFont.systemFont(ofSize: 20)
        tv.isEditable = false
        return tv
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViewController()
        setupViews()
        setupAnimation()
    }
    
    func setupViewController() {
        
        title = "Power Saving Mode"
        
        view.backgroundColor = .white
        
        navigationController?.navigationBar.prefersLargeTitles = true
        
        let textAttributes = [NSAttributedString.Key.foregroundColor:UIColor.black]
        navigationController?.navigationBar.largeTitleTextAttributes = textAttributes
    }
    
    func setupViews() {
        view.addSubview(imageView)
        imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 30).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 120).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 120).isActive = true
        imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        view.addSubview(textView)
        textView.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 20).isActive = true
        textView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20).isActive = true
        textView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20).isActive = true
        textView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 20).isActive = true
    }
    
    func setupAnimation() {
        
        UIView.animate(withDuration: 1.0, animations: {() -> Void in
            self.imageView.transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
        }, completion: {(_ finished: Bool) -> Void in
            UIView.animate(withDuration: 1.0, animations: {() -> Void in
                self.imageView.transform = CGAffineTransform(scaleX: 1, y: 1)
            })
        })
    }
}
