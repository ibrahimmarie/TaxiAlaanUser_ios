//
//  TransactionController.swift
//  User
//
//  Created by AlaanCo on 4/15/19.
//  Copyright © 2019 iCOMPUTERS. All rights reserved.
//

import UIKit
import GoogleMobileAds
class TransactionController: UIViewController {
    
    @IBOutlet weak var bannerView: GADBannerView!
    @IBOutlet weak var titelLabel: UILabel!
    @IBOutlet weak var textFieldWallet: UITextField!
    @IBOutlet weak var textFielAmount: UITextField!
    
    @IBOutlet weak var labelFirstName: UILabel!
 
    @IBOutlet weak var lastType: UILabel!
    @IBOutlet weak var btnAction: UIButton!
    @IBOutlet weak var imagBack: UIImageView!
    @IBOutlet weak var btnSend: UIButton!
    
    var firstInput = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initView()
        adsGoogle()
        
    }
    
    func initView(){
      
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        imagBack.isUserInteractionEnabled = true
        imagBack.addGestureRecognizer(tapGestureRecognizer)
        
        labelFirstName.isHidden = true
        lastType.isHidden = true
        
        titelLabel.text = "Send Money".localized()
        btnSend.setTitle("Validate".localized(), for: UIControl.State.normal)
        btnSend.layer.cornerRadius = 5
        btnSend.clipsToBounds = false
        
        textFieldWallet.placeholder =  "Please enter  wallet id".localized()
        textFielAmount.placeholder = "Please enter amount".localized()
        
    }
    
    func adsGoogle(){
        
        bannerView.adUnitID = "ca-app-pub-6606021354718512/7694872321"
        bannerView.rootViewController = self
        bannerView.load(GADRequest())
        bannerView.backgroundColor = UIColor.white
    }
    
    @objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer){
        
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnSubmit(_ sender: Any) {
        
        if firstInput {
            
            let param:[String:Any] = ["wallet_id":self.textFieldWallet.text ?? ""]
            
            
            if textFieldWallet.text?.count ?? 0 < 1 {
                CommenMethods.alertviewController_title("", messageAlert: "VALIDATE".localized(), viewController: self, okPop: false)
                return
                
            }
            
            let loading =  LoadingViewClass()
            loading.startLoading()
            
            ServiceAPI.shared.fetchGenericData(urlString: MD_DETAILS_WALLET, parameters: param, methodInput:.post,isHeaders: true) { (model:ModelTransaction?, error:Error?,status:Int?) in
               
                loading.stopLoading()
                
                if status == 200 {
                    
                    self.labelFirstName.isHidden = false
                    self.lastType.isHidden = false
                    
                    self.labelFirstName.text = "\(model?.first_name ?? "") \(model?.last_name ?? "")"
                    self.lastType.text = model?.type
                    self.btnAction.setTitle("Submit".localized(), for: UIControl.State.normal)
                    self.firstInput = false
                    
                    
                }else if status == 404 {
                    
                    CommenMethods.alertviewController_title("", messageAlert: "Wallet Not Found!".localized(), viewController: self, okPop: false)
                    
                }else if status == 500{
                    CommenMethods.alertviewController_title("", messageAlert:"ERRORMSG".localized(), viewController: self, okPop: false)
                    
                }else if status == 402 {
                    
                    CommenMethods.alertviewController_title("", messageAlert:"Balance Is Not Enough.".localized(), viewController: self, okPop: false)
                    
                }
  
            }

        } else {
            
        
            let param:[String:Any] = ["wallet_id":self.textFieldWallet.text ?? "",
                                      "amount":textFielAmount.text ?? ""]

            if textFieldWallet.text?.count ?? 0 < 1 {
                CommenMethods.alertviewController_title("", messageAlert: "VALIDATE".localized(), viewController: self, okPop: false)
                return
                
            }
            
            let loading =  LoadingViewClass()
            loading.startLoading()
            
            ServiceAPI.shared.fetchGenericData(urlString: MD_TRANSFER, parameters: param, methodInput:.post,isHeaders: true) { (model:ModelTransaction?,error:Error?,status:Int?) in
                
                loading.stopLoading()
                
                if status == 200 {
                    
                  self.navigationController?.popViewController(animated: true)
                    
                }else if status == 404 {
                    
                    CommenMethods.alertviewController_title("", messageAlert: "Wallet Not Found!".localized(), viewController: self, okPop: false)
                    
                }else if status == 500{
                    CommenMethods.alertviewController_title("", messageAlert: "ERRORMSG".localized(), viewController: self, okPop: false)
                    
                }else if status == 402 {
                    
                    CommenMethods.alertviewController_title("", messageAlert:"Balance Is Not Enough.".localized(), viewController: self, okPop: false)
                    
                }
                
                
            }
            
            
        }
        
    }
    
}
