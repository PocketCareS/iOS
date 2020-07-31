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
import SafariServices

class WelcomeController: UIViewController, UITextViewDelegate {
    
    let defaults = UserDefaults.standard
    
    let welcomeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Welcome to PocketCare S"
        label.textAlignment = .center
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 34.0, weight: .bold)
        label.textColor = .black
        return label
    }()
    
    let welcomeView: UIView = {
        let view = UIView()
        view.isHidden = true
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        view.layer.cornerRadius = 20
        view.layer.masksToBounds = true
        return view
    }()
    
    let nextButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor(red: 0/255, green: 91/255, blue: 187/255, alpha: 1.0)
        //systemBlue
        button.setTitle("Next", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 17)
        button.layer.cornerRadius = 15
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(handleNext), for: .touchUpInside)
        return button
    }()
    
    @objc func handleNext(){
        
        //One time generation throughout the app
        //@CHECK - MASTER KEY GENERATES TWICE
        var masterKey = Array<UInt8>()
        masterKey = generateMasterKey()
        print("Master Key: \(masterKey)")
        defaults.set(masterKey, forKey: "masterKey")
        
        dismiss(animated: true, completion: nil)
        
        let dc = DisclaimerController()
        navigationController?.pushViewController(dc, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        view.backgroundColor = .white
        
        navigationController?.navigationBar.prefersLargeTitles = true
        
        view.addSubview(welcomeLabel)
        welcomeLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: -60).isActive = true //-50
        welcomeLabel.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20).isActive = true
        welcomeLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20).isActive = true
        welcomeLabel.heightAnchor.constraint(equalToConstant: 100).isActive = true
        
        view.addSubview(welcomeView)
        welcomeView.backgroundColor = .green
        //        welcomeView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 30).isActive = true
        welcomeView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20).isActive = true
        welcomeView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20).isActive = true
        welcomeView.heightAnchor.constraint(equalToConstant: 380).isActive = true //400
        welcomeView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 15).isActive = true //no constant
        
        let welcomeStackView = UIStackView()
        
        welcomeStackView.translatesAutoresizingMaskIntoConstraints = false
        welcomeStackView.axis = .vertical
        welcomeStackView.distribution = .fillEqually
        
        view.addSubview(welcomeStackView)
        welcomeStackView.topAnchor.constraint(equalTo: welcomeView.topAnchor).isActive = true
        welcomeStackView.leftAnchor.constraint(equalTo: welcomeView.leftAnchor).isActive = true
        welcomeStackView.rightAnchor.constraint(equalTo: welcomeView.rightAnchor).isActive = true
        welcomeStackView.bottomAnchor.constraint(equalTo: welcomeView.bottomAnchor).isActive = true
        
        let point1View = UIView()
        point1View.translatesAutoresizingMaskIntoConstraints = false
        point1View.backgroundColor = .clear
        
        let point1ImageView = UIImageView(image: UIImage(systemName: "doc.plaintext"))
        point1ImageView.tintColor = .systemPink
        point1ImageView.contentMode = .scaleAspectFit
        point1ImageView.translatesAutoresizingMaskIntoConstraints = false
        
        point1View.addSubview(point1ImageView)
        point1ImageView.leftAnchor.constraint(equalTo: point1View.leftAnchor, constant: 12).isActive = true
        point1ImageView.widthAnchor.constraint(equalToConstant: 40).isActive = true
        point1ImageView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        point1ImageView.centerYAnchor.constraint(equalTo: point1View.centerYAnchor).isActive = true
        
        let point1Label = UILabel()
        point1Label.numberOfLines = 0
        point1Label.translatesAutoresizingMaskIntoConstraints = false
        point1Label.text = "Take a few seconds to record your health status everyday."
        //"Use the Health Status Monitor to help keep you stay healthy."
        point1Label.textColor = .systemGray
        
        point1View.addSubview(point1Label)
        point1Label.leftAnchor.constraint(equalTo: point1ImageView.rightAnchor, constant: 20).isActive = true
        point1Label.rightAnchor.constraint(equalTo: point1View.rightAnchor, constant: -12).isActive = true
        point1Label.topAnchor.constraint(equalTo: point1View.topAnchor).isActive = true
        point1Label.bottomAnchor.constraint(equalTo: point1View.bottomAnchor).isActive = true
        
        
        
        let point2View = UIView()
        point2View.translatesAutoresizingMaskIntoConstraints = false
        point2View.backgroundColor = .clear
        
        let point2ImageView = UIImageView(image: #imageLiteral(resourceName: "idea"))
        point2ImageView.contentMode = .scaleAspectFit
        point2ImageView.translatesAutoresizingMaskIntoConstraints = false
        
        point2View.addSubview(point2ImageView)
        point2ImageView.leftAnchor.constraint(equalTo: point2View.leftAnchor, constant: 12).isActive = true
        point2ImageView.widthAnchor.constraint(equalToConstant: 40).isActive = true
        point2ImageView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        point2ImageView.centerYAnchor.constraint(equalTo: point2View.centerYAnchor).isActive = true
        
        let point2Label = UILabel()
        point2Label.numberOfLines = 0
        point2Label.translatesAutoresizingMaskIntoConstraints = false
        point2Label.text = "Learn tips and guidelines from health professionals."
        //"Learn tips and guidelines from CDC and other health professionals."
        point2Label.textColor = .systemGray
        
        point2View.addSubview(point2Label)
        point2Label.leftAnchor.constraint(equalTo: point2ImageView.rightAnchor, constant: 20).isActive = true
        point2Label.rightAnchor.constraint(equalTo: point2View.rightAnchor, constant: -12).isActive = true
        point2Label.topAnchor.constraint(equalTo: point2View.topAnchor).isActive = true
        point2Label.bottomAnchor.constraint(equalTo: point2View.bottomAnchor).isActive = true
        
        let point3View = UIView()
        point3View.translatesAutoresizingMaskIntoConstraints = false
        point3View.backgroundColor = .clear
        
        let point3ImageView = UIImageView(image: #imageLiteral(resourceName: "socialDistance"))
        point3ImageView.contentMode = .scaleAspectFit
        
        point3ImageView.translatesAutoresizingMaskIntoConstraints = false
        
        point3View.addSubview(point3ImageView)
        point3ImageView.leftAnchor.constraint(equalTo: point3View.leftAnchor, constant: 12).isActive = true
        point3ImageView.widthAnchor.constraint(equalToConstant: 40).isActive = true
        point3ImageView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        point3ImageView.centerYAnchor.constraint(equalTo: point3View.centerYAnchor).isActive = true
        
        let point3Label = UILabel()
        point3Label.numberOfLines = 0
        point3Label.translatesAutoresizingMaskIntoConstraints = false
        point3Label.text = "Keep track of social distance with other users."
        //"Keep track of places visited and social distance with other users."
        point3Label.textColor = .systemGray
        
        point3View.addSubview(point3Label)
        point3Label.leftAnchor.constraint(equalTo: point3ImageView.rightAnchor, constant: 20).isActive = true
        point3Label.rightAnchor.constraint(equalTo: point3View.rightAnchor, constant: -12).isActive = true
        point3Label.topAnchor.constraint(equalTo: point3View.topAnchor).isActive = true
        point3Label.bottomAnchor.constraint(equalTo: point3View.bottomAnchor).isActive = true
        
        
        let point4View = UIView()
        point4View.translatesAutoresizingMaskIntoConstraints = false
        point4View.backgroundColor = .clear
        
        let point4ImageView = UIImageView(image: UIImage(systemName: "battery.100"))
        point4ImageView.tintColor = .systemGreen
        point4ImageView.contentMode = .scaleAspectFit
        point4ImageView.clipsToBounds = true
        
        point4ImageView.translatesAutoresizingMaskIntoConstraints = false
        
        point4View.addSubview(point4ImageView)
        point4ImageView.leftAnchor.constraint(equalTo: point4View.leftAnchor, constant: 12).isActive = true
        point4ImageView.widthAnchor.constraint(equalToConstant: 40).isActive = true
        point4ImageView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        point4ImageView.centerYAnchor.constraint(equalTo: point4View.centerYAnchor).isActive = true
        
        let point4Label = UILabel()
        point4Label.numberOfLines = 0
        point4Label.translatesAutoresizingMaskIntoConstraints = false
        point4Label.text = "Use Power Saving Mode instead of turning off the screen."
        //"Keep track of places visited and social distance with other users."
        point4Label.textColor = .systemGray
        
        point4View.addSubview(point4Label)
        point4Label.leftAnchor.constraint(equalTo: point4ImageView.rightAnchor, constant: 20).isActive = true
        point4Label.rightAnchor.constraint(equalTo: point4View.rightAnchor, constant: -12).isActive = true
        point4Label.topAnchor.constraint(equalTo: point4View.topAnchor).isActive = true
        point4Label.bottomAnchor.constraint(equalTo: point4View.bottomAnchor).isActive = true
        
        
        let point5View = UIView()
        point5View.translatesAutoresizingMaskIntoConstraints = false
        point5View.backgroundColor = .clear
        
        let point5ImageView = UIImageView(image: UIImage(systemName: "info.circle"))
        point5ImageView.contentMode = .scaleAspectFit
        
        point5ImageView.translatesAutoresizingMaskIntoConstraints = false
        
        point5View.addSubview(point5ImageView)
        point5ImageView.leftAnchor.constraint(equalTo: point5View.leftAnchor, constant: 12).isActive = true
        point5ImageView.widthAnchor.constraint(equalToConstant: 40).isActive = true
        point5ImageView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        point5ImageView.centerYAnchor.constraint(equalTo: point5View.centerYAnchor).isActive = true
        
        let point5Label = UITextView()
        point5Label.delegate = self
        point5Label.showsVerticalScrollIndicator = false
        point5Label.isScrollEnabled = false
        point5Label.textContainer.lineFragmentPadding = 0
        point5Label.isEditable = false
        point5Label.translatesAutoresizingMaskIntoConstraints = false
        let attributedString = NSMutableAttributedString(string: "To learn more about PocketCare S, visit here.", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 17)])
        attributedString.addAttribute(.link, value: "https://engineering.buffalo.edu/computer-science-engineering/pocketcares.html", range: NSRange(location: 40, length: 4))
        
        point5Label.attributedText = attributedString
        point5Label.textColor = .systemGray
        
        point5View.addSubview(point5Label)
        point5Label.leftAnchor.constraint(equalTo: point5ImageView.rightAnchor, constant: 20).isActive = true
        point5Label.rightAnchor.constraint(equalTo: point5View.rightAnchor, constant: -12).isActive = true
        point5Label.centerYAnchor.constraint(equalTo: point5View.centerYAnchor).isActive = true
        
        welcomeStackView.addArrangedSubview(point1View)
        welcomeStackView.addArrangedSubview(point2View)
        welcomeStackView.addArrangedSubview(point3View)
        welcomeStackView.addArrangedSubview(point4View)
        welcomeStackView.addArrangedSubview(point5View)
        
        view.addSubview(nextButton)
        nextButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 50).isActive = true
        nextButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -50).isActive = true
        nextButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50).isActive = true
        nextButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
    }
    
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        
        //        UIApplication.shared.open(URL)
        
        let config = SFSafariViewController.Configuration()
        
        let vc = SFSafariViewController(url: URL, configuration: config)
        present(vc, animated: true)
        
        return false
    }
    
    func generateMasterKey() -> Array<UInt8> {
        var array = Array<UInt8>()
        
        for _ in 0...31 {
            
            let number = Int.random(in: 0 ..< 256)
            
            array.append(UInt8(number))
        }
        
        return array
    }
}
