//
//  ViewController.swift
//  Alloy Example
//
//  Created by Marc Hervera on 8/5/22.
//

import UIKit
import Alloy
import SwiftUI

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        AlloySettings.configure.apiKey = "028d85e0-aa24-4ca1-99f2-90e3ee3f4e6b"
        AlloySettings.configure.production = true
        AlloySettings.configure.realProduction = false
        AlloySettings.configure.evaluateOnUpload = false
        
        AlloySettings.configure.steps = [
            .init(orDocumentTypes: [.license, .passport]),
            .init(orDocumentTypes: [.paystub, .bankStatement, .docW2])
        ]
        
    }

    @IBAction func openAlloyNormal(_ sender: UIButton) {
        
        let data = EvaluationData(nameFirst: "John", nameLast: "Doe")
        let alloy = AlloyController(evaluationData: data)
        
        present(alloy, animated: true)
        
    }
    
    @IBAction func openAlloyApproved(_ sender: UIButton) {
        
        let data = EvaluationData(nameFirst: "John", nameLast: "Approved")
        let alloy = AlloyController(evaluationData: data)
        
        present(alloy, animated: true)
        
    }
    
    @IBAction func openAlloyDenied(_ sender: UIButton) {
        
        let data = EvaluationData(nameFirst: "John", nameLast: "Denied")
        let alloy = AlloyController(evaluationData: data)
        
        present(alloy, animated: true)
        
    }
    
    @IBAction func openAlloyManual(_ sender: UIButton) {
        
        let data = EvaluationData(nameFirst: "John", nameLast: "Manual Review")
        let alloy = AlloyController(evaluationData: data)
        
        present(alloy, animated: true)
        
    }
    
}
