import UIKit
import CoreBluetooth
import UTMConversion
import CoreLocation
import SafariServices

class ViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UITextViewDelegate {
    
    let defaults = UserDefaults.standard
    
    let tipsImages = [#imageLiteral(resourceName: "hand-wash"), #imageLiteral(resourceName: "socialDistance"), #imageLiteral(resourceName: "personWithMask"), #imageLiteral(resourceName: "cough"), #imageLiteral(resourceName: "wash"), #imageLiteral(resourceName: "stay-home"), UIImage(systemName: "doc.plaintext")]
    let tipsBoldText = ["Clean your hands often", "Practice Social Distancing", "Cover your Nose and Mouth", "Cover coughs and sneezes", "Clean and Disinfect", "Stay at Home", "Monitor your Health"]
    let tipsPlainText = ["Wash your hands regularly with soap and water for at least 20 seconds. Avoid touching your eyes, nose, and mouth with unwashed hands.", "Avoid close contact with others, and stay home as much as possible.", "When going out in public, make sure to wear a face cover, and keep about 6 feet between yourself and others.", "Always cover your mouth and nose with a tissue when you cough or sneeze, and throw used tissues directly in the trash.", "Clean and disinfect frequently touched objects daily. This includes tables, doorknobs, light switches, etc.", "Stay in your apartment or residence hall room when you are sick. Avoid any unnecessary travel, and limit shopping trips to those needed for essential supplies.", "Be alert for symptoms. Watch for symptoms including fever, cough, shortness of breath. Monitor your symptoms daily using the health monitor in the app."]
    
    var tipsCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let cv = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.backgroundColor = UIColor(red: 0/255, green: 91/255, blue: 187/255, alpha: 1.0)
        return cv
    }()
    
    let welcomeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Welcome to PocketCare+"
        label.textAlignment = .left
        label.font = UIFont.boldSystemFont(ofSize: 25)
        label.textColor = .white
        return label
    }()
    
    let welcomeView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .white
        view.layer.cornerRadius = 20
        view.layer.masksToBounds = true
        return view
    }()
    
    let tipsLabel: UITextView = {
        let label = UITextView()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .left
        label.isScrollEnabled = false
        label.isEditable = false
        
        let range = NSRange(location: 14, length: 3)
        
        let attributes = [NSAttributedString.Key.foregroundColor : UIColor.white, NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 25)]
        let attributedString = NSMutableAttributedString(string: "Tips (Source: CDC)", attributes: attributes)
        attributedString.addAttribute(.link, value: "https://www.cdc.gov/coronavirus/2019-ncov/prevent-getting-sick/prevention.html", range: range)
        attributedString.addAttribute(NSAttributedString.Key.underlineStyle, value: NSNumber(value: 1), range: range)
        
        label.linkTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.cyan]
        
        label.attributedText = attributedString
        label.backgroundColor = .clear
        return label
    }()
    
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
                
        let config = SFSafariViewController.Configuration()
        
        let vc = SFSafariViewController(url: URL, configuration: config)
        present(vc, animated: true)
        
        return false
    }
    
    @objc func handlePowerSaveMode() {
        let psm = PowerSaveModeController()
        psm.modalPresentationStyle = .fullScreen
        present(psm, animated: true, completion: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(true)
        
        let brightness = UIScreen.main.brightness
        defaults.set(brightness, forKey: "brightness")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        let brightness = defaults.float(forKey: "brightness")
        UIScreen.main.brightness = CGFloat(brightness)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
                        
//        let blScanItem = UIBarButtonItem.button(image: UIImage(systemName: "person.2.fill")!, title: " \(peripheralDeviceNames.count) Devices Nearby", target: self, action: #selector(handleScanData))
        
        let fontConfiguration = UIImage.SymbolConfiguration(font: UIFont.systemFont(ofSize: 22), scale: .large)
        let plusBarButtonItem = UIBarButtonItem.button(image: UIImage(systemName: "doc.plaintext")!, title: " Health Monitor", target: self, action: #selector(handleHealthMonitor))
        let calibarBarButtonItem = UIBarButtonItem.button(image: UIImage(systemName: "camera")!, title: " Calibrate Bluetooth", target: self, action: #selector(handleCaliber))
        navigationItem.rightBarButtonItem = plusBarButtonItem
        //navigationItem.leftBarButtonItem = calibarBarButtonItem
        navigationController?.navigationBar.tintColor = .white

        
        
        //         Image needs to be added to project.
        //        guard let buttonIcon = UIImage(systemName: "heart.fill") else { return }
        //
        //        let rightBarButton = UIBarButtonItem.button(image: buttonIcon, title: " Health Monitor", target: self, action: #selector(handleHealthMonitor))
        //        rightBarButton.image = buttonIcon
        
        //        self.navigationItem.rightBarButtonItem = rightBarButton
        
        if let layout = tipsCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .horizontal
        }
        
        tipsCollectionView.delegate = self
        tipsCollectionView.dataSource = self
        tipsCollectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cellId")
        
        tipsCollectionView.showsHorizontalScrollIndicator = false
        
        title = "Home"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        let textAttributes = [NSAttributedString.Key.foregroundColor:UIColor.white]
        navigationController?.navigationBar.largeTitleTextAttributes = textAttributes
        
        view.backgroundColor = UIColor(red: 0/255, green: 91/255, blue: 187/255, alpha: 1.0)
        
//        view.addSubview(welcomeLabel)
//        welcomeLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 15).isActive = true //30
//        welcomeLabel.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 20).isActive = true
//        welcomeLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20).isActive = true
//        welcomeLabel.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        
        view.addSubview(welcomeView)
        welcomeView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 30).isActive = true //30
        welcomeView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20).isActive = true
        welcomeView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20).isActive = true
        
        welcomeView.bottomAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        
        view.addSubview(tipsLabel)
        tipsLabel.topAnchor.constraint(equalTo: welcomeView.bottomAnchor, constant: 30).isActive = true
        tipsLabel.rightAnchor.constraint(equalTo: view.rightAnchor, constant: 20).isActive = true
        tipsLabel.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20).isActive = true
        tipsLabel.heightAnchor.constraint(equalToConstant: 40).isActive = true //30
        
        view.addSubview(tipsCollectionView)
        tipsCollectionView.topAnchor.constraint(equalTo: tipsLabel.bottomAnchor, constant: 30).isActive = true
        tipsCollectionView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -20).isActive = true
        tipsCollectionView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 20).isActive = true
        tipsCollectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -30).isActive = true
        
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
        point1ImageView.widthAnchor.constraint(equalToConstant: 30).isActive = true
        point1ImageView.heightAnchor.constraint(equalToConstant: 30).isActive = true
        point1ImageView.centerYAnchor.constraint(equalTo: point1View.centerYAnchor).isActive = true
        
        let point1Label = UILabel()
        point1Label.numberOfLines = 0
        point1Label.translatesAutoresizingMaskIntoConstraints = false
        point1Label.text = "Take 5 seconds to record your health status everyday."
        point1Label.textColor = .black
        
        point1View.addSubview(point1Label)
        point1Label.leftAnchor.constraint(equalTo: point1ImageView.rightAnchor, constant: 12).isActive = true
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
        point2ImageView.widthAnchor.constraint(equalToConstant: 30).isActive = true
        point2ImageView.heightAnchor.constraint(equalToConstant: 30).isActive = true
        point2ImageView.centerYAnchor.constraint(equalTo: point2View.centerYAnchor).isActive = true
        
        let point2Label = UILabel()
        point2Label.numberOfLines = 0
        point2Label.translatesAutoresizingMaskIntoConstraints = false
        point2Label.text = "Learn tips and guidelines from health professionals."
        point2Label.textColor = .black
        
        point2View.addSubview(point2Label)
        point2Label.leftAnchor.constraint(equalTo: point2ImageView.rightAnchor, constant: 12).isActive = true
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
        point3ImageView.widthAnchor.constraint(equalToConstant: 30).isActive = true
        point3ImageView.heightAnchor.constraint(equalToConstant: 30).isActive = true
        point3ImageView.centerYAnchor.constraint(equalTo: point3View.centerYAnchor).isActive = true
        
        let point3Label = UILabel()
        point3Label.numberOfLines = 0
        point3Label.translatesAutoresizingMaskIntoConstraints = false
        point3Label.text = "Keep track of social distance with other users."
        point3Label.textColor = .black
        
        point3View.addSubview(point3Label)
        point3Label.leftAnchor.constraint(equalTo: point3ImageView.rightAnchor, constant: 12).isActive = true
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
        point4ImageView.widthAnchor.constraint(equalToConstant: 30).isActive = true
        point4ImageView.heightAnchor.constraint(equalToConstant: 30).isActive = true
        point4ImageView.centerYAnchor.constraint(equalTo: point4View.centerYAnchor).isActive = true
        
        let point4Label = UILabel()
        point4Label.numberOfLines = 0
        point4Label.translatesAutoresizingMaskIntoConstraints = false
        point4Label.text = "Use Power Saving Mode instead of turning off the screen."
        point4Label.textColor = .black
        
        point4View.addSubview(point4Label)
        point4Label.leftAnchor.constraint(equalTo: point4ImageView.rightAnchor, constant: 12).isActive = true
        point4Label.rightAnchor.constraint(equalTo: point4View.rightAnchor, constant: -12).isActive = true
        point4Label.topAnchor.constraint(equalTo: point4View.topAnchor).isActive = true
        point4Label.bottomAnchor.constraint(equalTo: point4View.bottomAnchor).isActive = true
        
        welcomeStackView.addArrangedSubview(point1View)
        welcomeStackView.addArrangedSubview(point2View)
        welcomeStackView.addArrangedSubview(point3View)
        welcomeStackView.addArrangedSubview(point4View)
        
        tipsLabel.delegate = self
    }
    
    @objc func handleHealthMonitor() {
        print("Handling Health Monitor")
        
        let hmc = UINavigationController(rootViewController: HealthMonitorController())
        present(hmc, animated: true, completion: nil)
    }
    
    @objc func handleCaliber() {
        print("Handling Caliber Controller")
        
        let hmc = UINavigationController(rootViewController: CaliberController())
        present(hmc, animated: true, completion: nil)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return tipsPlainText.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cellId", for: indexPath)
        
        for subview in cell.contentView.subviews {
            subview.removeFromSuperview()
        }
        
        let imageView = UIImageView(image: tipsImages[indexPath.row])
        if indexPath.row == tipsImages.count - 1 {
            imageView.tintColor = .red
        }
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        cell.contentView.addSubview(imageView)
        imageView.topAnchor.constraint(equalTo: cell.topAnchor, constant: 20).isActive = true
        imageView.heightAnchor.constraint(equalToConstant: cell.frame.width / 3).isActive = true
        imageView.widthAnchor.constraint(equalToConstant: cell.frame.width / 3).isActive = true
        imageView.centerXAnchor.constraint(equalTo: cell.centerXAnchor).isActive = true
        
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.adjustsFontSizeToFitWidth = true
        label.numberOfLines = 0
        label.textAlignment = .center
        
        let mutableAttributedString = NSMutableAttributedString()
        
        let boldText = NSAttributedString(string: tipsBoldText[indexPath.row] + "\n", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 17)])
        let plainText = NSAttributedString(string: tipsPlainText[indexPath.row], attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 14)])
        
        mutableAttributedString.append(boldText)
        mutableAttributedString.append(plainText)
        
        label.attributedText = mutableAttributedString
        cell.contentView.addSubview(label)
        label.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 5).isActive = true
        label.bottomAnchor.constraint(equalTo: cell.bottomAnchor, constant: -12).isActive = true
        label.leftAnchor.constraint(equalTo: cell.leftAnchor, constant: 12).isActive = true
        label.rightAnchor.constraint(equalTo: cell.rightAnchor, constant: -12).isActive = true
        
        cell.layer.cornerRadius = 20
        cell.layer.masksToBounds = true
        cell.backgroundColor = .white
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let size = CGSize(width: 250, height: tipsCollectionView.frame.height)
        return size
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.row == 1 {
            tabBarController?.selectedIndex = 3
        }
        else if indexPath.row == 6 {
            tabBarController?.selectedIndex = 1
        }
    }
    
    @objc func handleScanData() {
        print("Handling Scan")
    }
}

extension UIBarButtonItem {
    static func button(image: UIImage, title: String, target: Any, action: Selector) -> UIBarButtonItem {
        let button = UIButton()
        button.setImage(image, for: .normal)
        button.imageView?.tintColor = .white
        button.addTarget(target, action: action, for: .touchUpInside)
        button.setTitle(title, for: .normal)
        button.sizeToFit()
        return UIBarButtonItem(customView: button)
    }
}


