import UIKit

class PowerSaveModeController: UIViewController {
        
    let powerSaveModeButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Exit Power Saving Mode", for: .normal)
        button.tintColor = .lightGray
        button.setTitleColor(.lightGray, for: .normal)
        button.titleLabel?.textAlignment = .right
        button.addTarget(self, action: #selector(handlePowerSaveMode), for: .touchUpInside)
        return button
    }()
    
    let imageView: UIImageView = {
        let iv = UIImageView()
        iv.translatesAutoresizingMaskIntoConstraints = false
        iv.image = #imageLiteral(resourceName: "powerSaveExit")
        iv.contentMode = .scaleAspectFit
        iv.clipsToBounds = true
        iv.alpha = 0.5
        return iv
    }()
    
    let infoLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "You've entered Power Saving Mode. Tap anywhere to Exit."
        label.textAlignment = .center
        label.textColor = #colorLiteral(red: 0.4198469818, green: 0.4199114442, blue: 0.4198329449, alpha: 1)
        label.numberOfLines = 0
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        view.backgroundColor = .black
        
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handlePowerSaveMode)))
        
//        powerSaveModeButton.setLeftIcon(image: UIImage(systemName: "battery.100")!)
        
//        view.addSubview(powerSaveModeButton)
//        powerSaveModeButton.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -5).isActive = true
//        powerSaveModeButton.widthAnchor.constraint(equalToConstant: 250).isActive = true
//        powerSaveModeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10).isActive = true
//        powerSaveModeButton.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        view.addSubview(imageView)
        imageView.widthAnchor.constraint(equalToConstant: 200).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: 200).isActive = true
        imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        imageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        view.addSubview(infoLabel)
        infoLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 60).isActive = true
        infoLabel.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -60).isActive = true
        infoLabel.heightAnchor.constraint(equalToConstant: 50).isActive = true
        infoLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        infoLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 20).isActive = true
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        UIScreen.main.brightness = 0.1
        
        tabBarController?.tabBar.isHidden = true

    }
    
//    override func viewDidDisappear(_ animated: Bool) {
//        super.viewDidDisappear(true)
//
//        UIScreen.main.brightness = self.brightness
//        print(self.brightness)
//    }
//
    
    @objc func handlePowerSaveMode() {
        tabBarController?.selectedIndex = 0
        tabBarController?.tabBar.isHidden = false
    }
}

extension UIButton {
    
    func setLeftIcon(image: UIImage) {
        self.setImage(image, for: .normal)
        self.imageEdgeInsets =
            UIEdgeInsets(top: 0, left: -4, bottom: 0, right: image.size.width-8)
    }
}

