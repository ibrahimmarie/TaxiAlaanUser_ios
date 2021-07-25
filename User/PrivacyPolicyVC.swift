//
//  PrivacyPolicyVC.swift
//  User
//
//  Created by infos on 10/24/18.
//  Copyright © 2018 iCOMPUTERS. All rights reserved.
//

import UIKit

class PrivacyPolicyVC: UIViewController {

    
    @IBOutlet weak var webView: UIWebView!
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let url = URL (string: "file:///Users/infos/Downloads/html/TermsandconditionsEtaxiEnglish.html")
        let requestObj = URLRequest(url: url!)
        webView.loadRequest(requestObj)
    }
    

    @IBAction func backBtnTapped(_ sender: Any) {
       self.dismiss(animated: true, completion: nil)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
