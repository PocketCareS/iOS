import UIKit
import CoreLocation

class PermissionsController: UIViewController, BeaconMonitorDelegate, CLLocationManagerDelegate {
    
    let defaults = UserDefaults.standard
    
    let locationManager = CLLocationManager()
    
    let welcomeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Permissions"
        label.textAlignment = .left
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 34.0, weight: .bold)
        label.textColor = .black
        return label
    }()
    
    let welcomeView: UIView = {
        let view = UIView()
        view.isHidden = true
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        view.layer.cornerRadius = 20
        view.layer.masksToBounds = true
        return view
    }()
    
    let continueButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor(red: 0/255, green: 91/255, blue: 187/255, alpha: 1.0)
        //systemBlue
        button.setTitle("Grant Permissions", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 17)
        button.layer.cornerRadius = 15
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(handleContinue), for: .touchUpInside)
        return button
    }()
    
    var clickCount = 0
    
    @objc func handleContinue(){
        
        clickCount = clickCount + 1
        
        if clickCount == 1 {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.startAdvertising()
            appDelegate.requestUNNotification()
            
            defaults.set(true, forKey: "grantPermissions")
            
            continueButton.setTitle("Continue", for: .normal)
        }
        else {
            let vnc = VBTNameController()
            navigationController?.pushViewController(vnc, animated: true)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        title = "Permissions"
        
        navigationController?.navigationBar.prefersLargeTitles = true
        
        let textAttributes = [NSAttributedString.Key.foregroundColor:UIColor.black]
        navigationController?.navigationBar.largeTitleTextAttributes = textAttributes
        
//        view.addSubview(welcomeLabel)
//        welcomeLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: -40).isActive = true
//        welcomeLabel.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20).isActive = true
//        welcomeLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20).isActive = true
//        welcomeLabel.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        let textLabel = UITextView()
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        textLabel.showsVerticalScrollIndicator = false
        textLabel.isScrollEnabled = false
        textLabel.textContainer.lineFragmentPadding = 0
        textLabel.isEditable = false
        textLabel.text = "The app will use anonymous data to collect information on close encounters and social distance. It does not collect any personal information (see FAQ). The app will need the following permissions:"
        
        textLabel.textColor = .black
        textLabel.font = UIFont.systemFont(ofSize: 17)
        
        view.addSubview(textLabel)
        
        textLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10).isActive = true //20
        textLabel.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20).isActive = true
        textLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20).isActive = true
        textLabel.heightAnchor.constraint(equalToConstant: 120).isActive = true//-------------------------------------
        
        view.addSubview(welcomeView)
        welcomeView.topAnchor.constraint(equalTo: textLabel.bottomAnchor, constant: -10).isActive = true //no constant
        welcomeView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20).isActive = true
        welcomeView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20).isActive = true
        welcomeView.heightAnchor.constraint(equalToConstant: 320).isActive = true //350
        
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
        
        let point1ImageView = UIImageView(image: #imageLiteral(resourceName: "bluetooth"))
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
        point1Label.text = "Use Bluetooth (to measure social distance)"
        point1Label.textColor = .black
        
        point1View.addSubview(point1Label)
        point1Label.leftAnchor.constraint(equalTo: point1ImageView.rightAnchor, constant: 20).isActive = true
        point1Label.rightAnchor.constraint(equalTo: point1View.rightAnchor, constant: -12).isActive = true
        point1Label.topAnchor.constraint(equalTo: point1View.topAnchor).isActive = true
        point1Label.bottomAnchor.constraint(equalTo: point1View.bottomAnchor).isActive = true
        
        let point2View = UIView()
        point2View.translatesAutoresizingMaskIntoConstraints = false
        point2View.backgroundColor = .clear
        
        let point2ImageView = UIImageView(image: #imageLiteral(resourceName: "map"))
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
        point2Label.text = "Use GPS to enable Bluetooth scanning (PocketCare S requires GPS to be always enabled, but your location information is not stored anywhere)"
        point2Label.textColor = .black
        
        point2View.addSubview(point2Label)
        point2Label.leftAnchor.constraint(equalTo: point2ImageView.rightAnchor, constant: 20).isActive = true
        point2Label.rightAnchor.constraint(equalTo: point2View.rightAnchor, constant: -12).isActive = true
        point2Label.topAnchor.constraint(equalTo: point2View.topAnchor).isActive = true
        point2Label.bottomAnchor.constraint(equalTo: point2View.bottomAnchor).isActive = true
        
        let point3View = UIView()
        point3View.translatesAutoresizingMaskIntoConstraints = false
        point3View.backgroundColor = .clear
        
        let point3ImageView = UIImageView(image: #imageLiteral(resourceName: "bell-2"))
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
        // @CHECK - Notification Text
        point3Label.text = "Send notifications to improve background scanning capability"
        point3Label.textColor = .black
        
        point3View.addSubview(point3Label)
        point3Label.leftAnchor.constraint(equalTo: point3ImageView.rightAnchor, constant: 20).isActive = true
        point3Label.rightAnchor.constraint(equalTo: point3View.rightAnchor, constant: -12).isActive = true
        point3Label.topAnchor.constraint(equalTo: point3View.topAnchor).isActive = true
        point3Label.bottomAnchor.constraint(equalTo: point3View.bottomAnchor).isActive = true
        
        welcomeStackView.addArrangedSubview(point1View)
        welcomeStackView.addArrangedSubview(point2View)
        welcomeStackView.addArrangedSubview(point3View)
        
        view.addSubview(continueButton)
        continueButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 50).isActive = true
        continueButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -50).isActive = true
        continueButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50).isActive = true
        continueButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        locationManager.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)

        if defaults.bool(forKey: "grantPermissions") == true {
            checkLocationAuthorization()
        }
    }
    
     func checkLocationAuthorization(){
            //@CHECK title and message
            switch CLLocationManager.authorizationStatus() {
                
            case .authorizedWhenInUse:
                showAlwaysLocationPermissionAlert()
                break
                
            case .denied:
                showAlwaysLocationPermissionAlert()
                break
                
            case .notDetermined:
                break
                
            case .restricted:
                showAlwaysLocationPermissionAlert()
                break
                
            case .authorizedAlways:
                print("Authorized Always")
//                dismiss(animated: true, completion: nil)
                break
            }
        }
        
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedAlways {
            print("Authorized Always")
            
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
                return
            }

            appDelegate.fetchZipCode()
//            showAlwaysLocationPermissionAlert()
        }
        if status == .authorizedWhenInUse {
            print("Authorized When In Use")
            showAlwaysLocationPermissionAlert()
        }
        if status == .denied {
            print("Denied")
            showAlwaysLocationPermissionAlert()
        }
        if status == .notDetermined {
            print("Not Determined")
        }
        if status == .restricted {
            print("Restricted")
            showAlwaysLocationPermissionAlert()
        }
    }
    
    func showAlwaysLocationPermissionAlert() {
        let title = "Please allow \"Always\" access to Location"
        let message = "The app requires location access to be always allowed. Please go to Settings > PocketCare S > Change location permission to Always."
        showDoubleActionAlertToUser(with: title, and: message)
    }
    
    func showSingleActionAlertToUser(with title: String, and message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Okay", style: .cancel, handler: nil))
        
        self.present(alert, animated: true)
    }
    
    func showDoubleActionAlertToUser(with title: String, and message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
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
