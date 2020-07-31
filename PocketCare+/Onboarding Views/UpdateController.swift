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

class UpdateController: UIViewController {
    
    let welcomeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Update Required"
        label.textAlignment = .left
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 34.0, weight: .bold)
        label.textColor = .black
        return label
    }()
    
    let nextButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor(red: 0/255, green: 91/255, blue: 187/255, alpha: 1.0)
        button.setTitle("Install Update", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 17)
        button.layer.cornerRadius = 15
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(handleNext), for: .touchUpInside)
        return button
    }()
    
    let optionalLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "A new update to PocketCare S is now available. Please click below to install the update."
        label.textAlignment = .center
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 20.0)
        label.textColor = .lightGray
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Update Required"
        
        navigationController?.navigationBar.prefersLargeTitles = true
                                
        view.backgroundColor = .white
        
//        view.addSubview(welcomeLabel)
//        welcomeLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: -30).isActive = true
//        welcomeLabel.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20).isActive = true
//        welcomeLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20).isActive = true
//        welcomeLabel.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.image = #imageLiteral(resourceName: "iOS Launch Screen")
        iv.contentMode = .scaleAspectFit
        
        view.addSubview(iv)
        iv.heightAnchor.constraint(equalToConstant: view.frame.height / 2).isActive = true
        iv.widthAnchor.constraint(equalToConstant: view.frame.width - 100).isActive = true
        iv.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -50).isActive = true
        iv.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        view.addSubview(nextButton)
        nextButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 50).isActive = true
        nextButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -50).isActive = true
        nextButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50).isActive = true
        nextButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        view.addSubview(optionalLabel)
        optionalLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20).isActive = true
        optionalLabel.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20).isActive = true
        optionalLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        optionalLabel.bottomAnchor.constraint(equalTo: nextButton.topAnchor, constant: -40).isActive = true
    }
    
    @objc func handleNext() {
        let link = "https://www.buffalo.edu/content/dam/apps/pocketcare-s"
        
        if let url = URL(string: link) {
            UIApplication.shared.open(url)
        }
    }
}
