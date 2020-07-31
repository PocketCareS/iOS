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
import Eureka
import Alamofire
import FirebaseInstanceID
import JGProgressHUD
import Firebase
import FirebaseMessaging

class UserProfileController: FormViewController {
    
    //welcome, disclaimer, permissions, user information,
    
    var affiliation = ""
    var visaStatus = ""
    
    var gender = ""
    var healthCondition:[String] = []
    var zipCode = ""
    var ageGroup = ""
    var ethnicGroup = ""
    var otherCondition = ""
    let defaults = UserDefaults.standard
    //    var userInformation: UserInformation = UserInformation(gender:"", zipcode: "", ageGroup:"", ethnicGroup:"")
    var otherUC = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "User Profile"
        
        navigationItem.hidesBackButton = true
        
//        healthCondition = defaults.stringArray(forKey: "underlyingConditions") ?? []
        
        navigationController?.navigationBar.prefersLargeTitles = true
        
        //"The anonymous data collected here will help with research."
        
        form +++ Section("") { section in
            section.header?.height = ({return 0})
            }
            <<< LabelRow() { row in
                row.title = "Sharing the information below is optional but highly encouraged."
                row.cellSetup { (cell, row) in
                    cell.height = ({return 100})
                    cell.textLabel?.textAlignment = .center
                    cell.textLabel?.numberOfLines = 0
                }
        }
        
        form +++ Section("University Information")
            
            <<< PickerInputRow<String>() { row in
                if defaults.string(forKey: "affiliation") == nil {
                    
                }
                else {
                    row.value = defaults.string(forKey: "affiliation")
                }
                row.title = "I'm a..."
                row.options = ["Select Affiliation", "Faculty", "Staff", "Graduate Student", "Undergraduate Student", "Other"]
                row.noValueDisplayText = "Select Affiliation"
            }.onChange({ (row) in
                guard let status = row.value else { return }
                self.affiliation = status
                
                self.defaults.set(status, forKey: "affiliation")
            })
            
            <<< PickerInputRow<String>() { row in
                if defaults.string(forKey: "visa") == nil {
                    
                }
                else {
                    row.value = defaults.string(forKey: "visa")
                }
                row.title = "I hold a Student Visa"
                row.options = ["Select", "Yes", "No"]
                row.noValueDisplayText = "Yes or No"
            }.onChange({ (row) in
                guard let visa = row.value else { return }
                self.visaStatus = visa
                
                self.defaults.set(visa, forKey: "visa")
            })
        
        form +++ Section("Other Information")
            
            <<< PickerInputRow<String>() { row in
                if defaults.string(forKey: "ageGroup") == nil {
                    row.value = "Select Age Group"
                }
                else {
                    row.value = defaults.string(forKey: "ageGroup")
                }
                row.title = "Age Group"
                row.options = ["Select Age Group", "Under 20", "20-35", "36-50", "51-65", "Over 65"]
            }.onChange({ (row) in
                guard let value = row.value else { return }
                self.ageGroup = value
                
                self.defaults.set(self.ageGroup, forKey: "ageGroup")
            })
            
            
            <<< ZipCodeRow() { row in
                if defaults.string(forKey: "zipCode") == nil {
                }
                else {
                    row.value = defaults.string(forKey: "zipCode")
                }
                row.title = "Zip Code"
                row.placeholder = "Enter (5 digits)"
                
            }.onChange({ (row) in
                guard let zip = row.value else { return }
                self.zipCode = zip
                
                self.defaults.set(self.zipCode, forKey: "zipCode")
            })
            
            
            <<< PickerInputRow<String>() { row in
                if defaults.string(forKey: "ethnicGroup") == nil {
                    row.value = "Select Ethnic Group"
                }
                else {
                    row.value = defaults.string(forKey: "ethnicGroup")
                }
                row.title = "Ethnic Group"
                row.options = ["Select Ethnic Group", "American Indian or Alaskan Native", "Asian", "Black or African American", "Hispanic or Latino", "Native Hawaiian or Other Pacific Islander", "White", "Two or more races", "Prefer not to say"]
            }.onChange({ (row) in
                guard let value = row.value else { return }
                self.ethnicGroup = value
                
                self.defaults.set(self.ethnicGroup, forKey: "ethnicGroup")
            })
            
            
            <<< PickerInputRow<String>() { row in
                
                if defaults.string(forKey: "gender") == nil {
                    row.value = "Select Gender"
                }
                else {
                    row.value = defaults.string(forKey: "gender")
                }
                
                row.title = "Gender"
                row.options = ["Select Gender", "Male", "Female", "Other", "Prefer not to say"]
            }.onChange({ (row) in
                guard let value = row.value else { return }
                self.gender = value
                
                self.defaults.set(self.gender, forKey: "gender")
            })
        
        form +++ Section("")
            
            <<< ButtonRow("continueButton") { row in
                row.title = "Save"
                row.onCellSelection { (cell, row) in
                    self.dismiss(animated: true, completion: nil)
                    self.uploadUserDetails()
//                    self.defaults.set(true, forKey: "hasEntered")
                }
                row.cellSetup({ (cell, row) in
                    cell.height = ({ return 60 })
                    cell.textLabel?.numberOfLines = 0
                    cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 20)
                })
        }
    }
    
    //        func handleSubmit() {
    //            dismiss(animated: true, completion: nil)
    //            validateValues()
    //            let vnc = VBTNameController()
    //            vnc.userInformation = userInformation
    //            navigationController?.pushViewController(vnc, animated: true)
    //        }
    
    func validateValues(){
        
        if affiliation == "Select Affiliation" || defaults.string(forKey: "affiliation") == nil {
            affiliation = ""
        }
        else {
            guard let affiliationDefaults = defaults.string(forKey: "affiliation") else { return }
            affiliation = affiliationDefaults
        }
        
        if visaStatus == "Select" || defaults.string(forKey: "visa") == nil {
            visaStatus = ""
        }
        else {
            guard let visaDefaults = defaults.string(forKey: "visa") else { return }
            visaStatus = visaDefaults
        }
        
        if gender == "Select Gender" || defaults.string(forKey: "gender") == nil {
            gender = ""
        }
        else {
            guard let genderDefaults = defaults.string(forKey: "gender") else { return }
            gender = genderDefaults
        }
        
        if defaults.string(forKey: "zipCode") == nil {
            zipCode = ""
        }
        else {
            guard let zipCodeDefaults = defaults.string(forKey: "zipCode") else { return }
            zipCode = zipCodeDefaults
        }
        
        if ageGroup == "Select Age Group" || defaults.string(forKey: "ageGroup") == nil {
            ageGroup = ""
        }
        else {
            guard let ageGroupDefaults = defaults.string(forKey: "ageGroup") else { return }
            ageGroup = ageGroupDefaults
        }
        
        if ethnicGroup == "Ethnic Group" || defaults.string(forKey: "ethnicGroup") == nil {
            ethnicGroup = ""
        }
        else {
            guard let ethnicGroupDefaults = defaults.string(forKey: "ethnicGroup") else { return }
            ethnicGroup = ethnicGroupDefaults
        }
    }
    
     
    func uploadUserDetails(){
        var parameters = [String: Any]()
        var headers = [String: String]()
        let token = defaults.string(forKey: "token")
        validateValues()
        parameters["affiliation"] = affiliation
        parameters["visaStatus"] = visaStatus
//        parameters["healthCondition"] = healthCondition
        parameters["gender"] = gender
        parameters["zipCode"] = zipCode
        parameters["ethnicGroup"] = ethnicGroup
        parameters["ageGroup"] = ageGroup
        print("\(String(describing: token))")
        print("Parameters : \(String(describing: parameters))")
        if token != nil {
            headers["token"] = token
            print("Parameters: \(parameters)")
            print("Headers: \(headers)")
            Alamofire.request("\(Constants.hostURL)/user/info", method: .post, parameters: parameters, encoding: JSONEncoding.default, headers: headers).responseJSON
                { (response:DataResponse) in
                    switch(response.result)
                    {
                        
                    case .success(_):
                        print("SUCCESS UPLOADING USER DETAILS")
                        
                        let psin = PowerSavingImportantNote()
                        self.navigationController?.pushViewController(psin, animated: true)
                        
                        break
                        
                    case .failure(_):
                        
//                        if response.response?.statusCode == 401 {
//                            self.updateUserToken()
//                            self.uploadUserDetails()
//                        }
                        
                        print("FAILURE UPLOADING USER DETAILS")
                        print(response)
                        
                        let psin = PowerSavingImportantNote()
                        self.navigationController?.pushViewController(psin, animated: true)
                        
                        break
                    }
            }
        }
        
        else {
            let psin = PowerSavingImportantNote()
            self.navigationController?.pushViewController(psin, animated: true)
        }
    }
    
    func updateUserToken(){
        var deviceId = ""
        print("UPDATE FIREBASE TOKEN")
        InstanceID.instanceID().instanceID { (result, error) in
            if let error = error {
                print("Error fetching remote instange ID: \(error)")
            } else if let result = result {
                print("Remote instance ID token: \(result.token)")
                deviceId = result.token
                let params = ["deviceId": deviceId] as [String:Any]
                Alamofire.request("\(Constants.hostURL)/user", method: .post, parameters: params, encoding: JSONEncoding.default)
                    .responseObject
                    { (response: DataResponse<VBTResult>) in
                        switch response.result {
                            
                        case let .success(data):
                            self.defaults.set(data.token, forKey: "token")
                            
                        case let .failure(error):
                            print("Some error has occured "+error.localizedDescription)
                            print(response.error as Any)
                        }
                }
            }
        }
    }
}
struct UserInformation {
    var gender,zipcode,ageGroup,ethnicGroup: String
}

