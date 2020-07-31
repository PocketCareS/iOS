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

class DisclaimerController: FormViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Disclaimer"
        
        navigationController?.navigationBar.prefersLargeTitles = true
        
        let textAttributes = [NSAttributedString.Key.foregroundColor:UIColor.black]
        navigationController?.navigationBar.largeTitleTextAttributes = textAttributes
        

        form +++ Section("Terms & Conditions")
            
            <<< TextAreaRow() { row in
                row.value = "1. PocketCare S, in its current form, is primarily intended to measure social distance on UB (and SUNY) campuses and other pre-defined premises. It is not intended for contact tracing purposes. \n2. The daily health report in PocketCare S neither provides diagnostic services nor substitutes medical treatment. If you currently feel seriously ill, please seek medical help. \n3. Due to inherent limitations of the smartphone technology used, PocketCare S does not guarantee the information on the number, duration or distance of the close encounters is accurate. The actual values may be above or below the estimated values."
                
                row.textAreaHeight = TextAreaHeight.dynamic(initialTextViewHeight: 300)
                row.cellUpdate { (cell, row) in
                    cell.textView.textColor = .black
                }
                row.disabled = true
        }
        
        form +++ Section("Agreement (Select to Agree)")
            
            <<< CheckRow("agreementCheckRow") { row in
                row.title = "I have read and understand the data collection, usage and privacy policy as well as the disclaimer, and agree to hold the app developers and their employers harmless for any and all consequences of using PocketCare S."
                row.cellSetup { (cell, row) in
                    cell.height = ({return 160})
                    cell.textLabel?.numberOfLines = 0
                }
            }
            
            <<< ButtonRow("continueButton") { row in
                row.title = "Continue"
                row.hidden = true
                row.onCellSelection { (cell, row) in
                    self.handleSubmit()
                }
                row.cellSetup({ (cell, row) in
                    cell.height = ({return 60})
                    cell.textLabel?.numberOfLines = 0
                    cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 20)
                })
                row.hidden = Condition.function(["agreementCheckRow"], { form in
                    return !((form.rowBy(tag: "agreementCheckRow") as? CheckRow)?.value ?? false)
                })
        }
    }
    
    func handleSubmit() {
        dismiss(animated: true, completion: nil)
        
        let tbc = PermissionsController()
        navigationController?.pushViewController(tbc, animated: true)
    }
}
