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
import SceneKit
import ARKit
import CoreLocation

final class CaliberController: UIViewController {
    var sceneView = ARSCNView()
    var resetImageView = UIImageView()
    var resetButton = UIButton()
    var pairID = ""
    let pairIDLabel: UILabel = {
        let pairIDLabel = UILabel()
        
        pairIDLabel.text = "Pair ID: "
        pairIDLabel.translatesAutoresizingMaskIntoConstraints = false
        pairIDLabel.backgroundColor = UIColor.white
        pairIDLabel.textColor = UIColor.black
        pairIDLabel.textAlignment = .center
        pairIDLabel.numberOfLines = 1
        pairIDLabel.layer.cornerRadius = 16.0
        pairIDLabel.font = UIFont.boldSystemFont(ofSize: 14.0)
        pairIDLabel.clipsToBounds = true
        return pairIDLabel
    }()
    let messageLabel: UILabel = {
        let messageLabel = UILabel()
        messageLabel.text = "Detecting the world…"
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.backgroundColor = UIColor(red: 0/255, green: 91/255, blue: 187/255, alpha: 1.0)
        messageLabel.textColor = UIColor.white
        messageLabel.textAlignment = .center
        messageLabel.numberOfLines = 5
        return messageLabel
    }()
    let meterImageView: UIImageView = {
        let meterImageView = UIImageView()
        meterImageView.translatesAutoresizingMaskIntoConstraints = false
        meterImageView.image = UIImage(named: "meter")
        meterImageView.contentMode = .scaleAspectFit
        meterImageView.clipsToBounds = true
        meterImageView.alpha = 1.0
        return meterImageView
    }()
    
    let loadingView: UIActivityIndicatorView = {
        let loadingView = UIActivityIndicatorView()
        loadingView.translatesAutoresizingMaskIntoConstraints = false
        loadingView.contentMode = .scaleAspectFit
        loadingView.clipsToBounds = true
        loadingView.alpha = 1.0
        return loadingView
    }()
    
    let targetImageView: UIImageView = {
        let targetImageView = UIImageView()
        targetImageView.translatesAutoresizingMaskIntoConstraints = false
        targetImageView.image = UIImage(named: "targetWhite")
        targetImageView.contentMode = .scaleAspectFit
        targetImageView.clipsToBounds = true
        targetImageView.alpha = 1.0
        return targetImageView
    }()
    
    let caliberButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 75
        button.clipsToBounds = true
        button.setTitle("Calibrate", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 23.0)
        button.backgroundColor = UIColor(red: 0/255, green: 91/255, blue: 187/255, alpha: 1.0)
        button.addTarget(self, action: #selector(caliberPressed), for: .touchUpInside)
        return button
    }()
    
    fileprivate lazy var session = ARSession()
    fileprivate lazy var sessionConfiguration = ARWorldTrackingConfiguration()
    fileprivate lazy var isMeasuring = false;
    fileprivate lazy var vectorZero = SCNVector3()
    fileprivate lazy var startValue = SCNVector3()
    fileprivate lazy var endValue = SCNVector3()
    fileprivate lazy var lines: [Line] = []
    fileprivate var currentLine: Line?
    fileprivate lazy var unit: DistanceUnit = .meter
    
    var didMeasure2m = false
    var idToPair = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        let vbt = UserDefaults.standard.string(forKey: "vbtName") ?? ""
        let index = vbt.index(vbt.startIndex, offsetBy: 5)
        pairID = String(vbt.prefix(upTo: index))
        sceneView.frame = view.frame
        view.addSubview(sceneView)
        
        let alertController = UIAlertController(title: "Your Pair ID: \(pairID) \n Enter your friends Pair ID (5 digits) and select one of the options: ", message: "", preferredStyle: .alert)
        alertController.addTextField { (textField : UITextField!) -> Void in
            textField.placeholder = "Pair ID"
            textField.keyboardType = .numberPad
        }

        let measuringAction = UIAlertAction(title: "I'm measuring", style: .default, handler: { alert -> Void in
            let pairId = alertController.textFields![0] as UITextField
            self.idToPair = pairId.text ?? ""
        })
        //@CHECK DO NOT DISMISS ALERTCONTROLLER UNTIL USER ENTERS 5 DIGIT
        let notMeasuringAction = UIAlertAction(title: "I'm not measuring", style: .default, handler: { alert -> Void in
            let pairId = alertController.textFields![0] as UITextField
            self.idToPair = pairId.text ?? ""
            self.session.pause()
            self.messageLabel.text = "Press calibrate when both of you are standing 2m apart (based on your friend's measurement)"
            self.view.addSubview(self.caliberButton)
            self.caliberButton.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
            self.caliberButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
            self.caliberButton.heightAnchor.constraint(equalToConstant: 150.0).isActive = true
            self.caliberButton.widthAnchor.constraint(equalToConstant: 150.0).isActive = true
            
        })
        
        alertController.addAction(measuringAction)
        alertController.addAction(notMeasuringAction)

        self.present(alertController, animated: true, completion: nil)
        
        view.addSubview(targetImageView)
        targetImageView.heightAnchor.constraint(equalToConstant: 25.0).isActive = true
        targetImageView.widthAnchor.constraint(equalToConstant: 25.0).isActive = true
        targetImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        targetImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        view.addSubview(messageLabel)
        messageLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0).isActive = true
        messageLabel.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: 0).isActive = true
        messageLabel.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 0).isActive = true
        messageLabel.heightAnchor.constraint(equalToConstant: 80.0).isActive = true
        
        view.addSubview(pairIDLabel)
        pairIDLabel.text = "Pair ID: \(pairID)"
        pairIDLabel.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: 8).isActive = true
        pairIDLabel.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -10).isActive = true
        pairIDLabel.heightAnchor.constraint(equalToConstant: 30.0).isActive = true
        pairIDLabel.widthAnchor.constraint(equalToConstant: 150.0).isActive = true

        setupScene()
    }
    
    @objc func caliberPressed() {
        print("Caliber was pressed")
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.startCalibration(identifier: idToPair)
        self.caliberButton.setTitle("Calibrating...", for: .normal)
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) { // Change `2.0` to the desired number of seconds.
            print(appDelegate.calibrationRSSI)
            self.messageLabel.text = "RSSI Values read at 2m: \(appDelegate.calibrationRSSI)"
            appDelegate.resetCalibration()
            self.caliberButton.setTitle("Thank You", for: .normal)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.isIdleTimerDisabled = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        //session.pause()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        resetValues()
        isMeasuring = true
        targetImageView.image = UIImage(named: "targetGreen")
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        isMeasuring = false
        targetImageView.image = UIImage(named: "targetWhite")
        if let line = currentLine {
            lines.append(line)
            currentLine = nil
            resetButton.isHidden = false
            resetImageView.isHidden = false
        }
        
        if !didMeasure2m {
            reset()
        } else {
            messageLabel.text = " Nice job!, now stand at one end of the line and ask your friend to stand on the other end (2m apart!)"
            self.view.addSubview(self.caliberButton)
            self.caliberButton.setTitle("Calibrate", for: .normal)
            self.caliberButton.centerYAnchor.constraint(equalTo: self.view.centerYAnchor).isActive = true
            self.caliberButton.centerXAnchor.constraint(equalTo: self.view.centerXAnchor).isActive = true
            self.caliberButton.heightAnchor.constraint(equalToConstant: 150.0).isActive = true
            self.caliberButton.widthAnchor.constraint(equalToConstant: 150.0).isActive = true
        }

        print("TOUCHES ENDED")
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        isMeasuring = false
        targetImageView.image = UIImage(named: "targetWhite")
        if let line = currentLine {
            lines.append(line)
            currentLine = nil
            resetButton.isHidden = false
            resetImageView.isHidden = false
        }
        
        if !didMeasure2m {
            reset()
        } else {
            messageLabel.text = " Nice job!, now stand at one end of the line and ask your friend to stand on the other end (2m apart!)"
        }
        
        print("TOUCHES CANCELLED")
    }
    
    func reset() {
        for line in lines {
            line.removeFromParentNode()
        }
        lines.removeAll()
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
}

// MARK: - ARSCNViewDelegate

extension CaliberController: ARSCNViewDelegate {
    func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        DispatchQueue.main.async { [weak self] in
            self?.detectObjects()
        }
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        messageLabel.text = "Error occurred"
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        messageLabel.text = "Interrupted"
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        messageLabel.text = "Interruption ended"
    }
}

// MARK: - Privates

extension CaliberController {
    fileprivate func setupScene() {
        targetImageView.isHidden = true
        sceneView.delegate = self
        sceneView.session = session
        loadingView.startAnimating()
        meterImageView.isHidden = true
        
        resetButton.isHidden = true
        resetImageView.isHidden = true
        session.run(sessionConfiguration, options: [.resetTracking, .removeExistingAnchors])
        resetValues()
    }
    
    fileprivate func resetValues() {
        isMeasuring = false
        startValue = SCNVector3()
        endValue =  SCNVector3()
    }
    
    fileprivate func detectObjects() {
        guard let worldPosition = sceneView.realWorldVector(screenPosition: view.center) else { return }
        targetImageView.isHidden = false
        meterImageView.isHidden = false
        if lines.isEmpty {
            messageLabel.text = "Hold screen & move your phone to measure out a distance of 2m"
            messageLabel.backgroundColor = UIColor(red: 0/255, green: 91/255, blue: 187/255, alpha: 1.0)
        }
        loadingView.stopAnimating()
        if isMeasuring {
            if startValue == vectorZero {
                startValue = worldPosition
                currentLine = Line(sceneView: sceneView, startVector: startValue, unit: unit)
            }
            endValue = worldPosition
            currentLine?.update(to: endValue)
            messageLabel.text = currentLine?.distance(to: endValue) ?? "Calculating…"
            let distanceNumeric = currentLine?.distanceNumeric(to: endValue) ?? 0.0
            messageLabel.backgroundColor = (distanceNumeric >= 2.0 && distanceNumeric < 2.10) ? UIColor.systemGreen : UIColor.red
            didMeasure2m = (distanceNumeric >= 2.0 && distanceNumeric < 2.10) ? true : false
        }
    }
}
