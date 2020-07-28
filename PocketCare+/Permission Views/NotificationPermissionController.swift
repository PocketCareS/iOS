import UIKit
import UserNotifications

class NotificationPermissionController: UIViewController {
    
    let center = UNUserNotificationCenter.current()
    
    let welcomeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Notifications"
        label.textAlignment = .left
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 34.0, weight: .bold)
        label.adjustsFontSizeToFitWidth = true
        label.textColor = .black
        return label
    }()
    
    let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = #imageLiteral(resourceName: "bell-2")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    let statusLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Please allow notifications to enable health check reminders."
        label.textAlignment = .center
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 20.0)
        label.adjustsFontSizeToFitWidth = true
        label.textColor = .black
        return label
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
        dismiss(animated: true, completion: nil)
        
        let upc = UserProfileController()
        navigationController?.pushViewController(upc, animated: true)
    }
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        view.addSubview(welcomeLabel)
        welcomeLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: -30).isActive = true
        welcomeLabel.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20).isActive = true
        welcomeLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20).isActive = true
        welcomeLabel.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        view.addSubview(imageView)
        imageView.topAnchor.constraint(equalTo: welcomeLabel.bottomAnchor, constant: 30).isActive = true
        imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 100).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: 100).isActive = true
        
        view.addSubview(nextButton)
        nextButton.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 50).isActive = true
        nextButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -50).isActive = true
        nextButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50).isActive = true
        nextButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        view.addSubview(statusLabel)
        statusLabel.bottomAnchor.constraint(equalTo: nextButton.topAnchor, constant: -50).isActive = true
        statusLabel.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20).isActive = true
        statusLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20).isActive = true
        statusLabel.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        center.requestAuthorization(options: [.alert, .badge, .sound]) { (granted, error) in
            if granted {
                
                DispatchQueue.main.async {
                self.imageView.centerYAnchor.constraint(equalTo: self.view.centerYAnchor, constant: -50).isActive = true
                self.imageView.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
                self.imageView.heightAnchor.constraint(equalToConstant: 100).isActive = true
                self.imageView.widthAnchor.constraint(equalToConstant: 100).isActive = true
                
                self.statusLabel.text = "Thank you for allowing PocketCare+ to send notifications. Click Next to continue."
                    
                }
            } else {
                
                DispatchQueue.main.async {

                let alert = UIAlertController(title: "Notifications not enabled", message: "We did not receive permission to send notifications. To allow permission, go to Settings > PocketCare+ > Turn Notifications On", preferredStyle: .alert)

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
                    
                    
                alert.addAction(UIAlertAction(title: "Okay", style: .cancel, handler: nil))

                self.present(alert, animated: true)
                    
                }
            }
        }
        
//        let center = UNUserNotificationCenter.current()
//        center.getNotificationSettings { (settings) in
//            if(settings.authorizationStatus == .authorized)
//            {
//                print("Push authorized")
//            }
//            else
//            {
//                print("Push not authorized")
//            }
//        }
    }
}


