//
//  MarkerView.swift
//  User
//
//  Created by AlaanCo on 8/17/19.
//  Copyright © 2019 iCOMPUTERS. All rights reserved.
//

import UIKit
import LBTATools


@objc protocol DelegateTapMarker {
    func tapMarker()
}

@objc class MarkerView: UIView {
    
    let imageShadow : UIImageView = {
        let i = UIImageView()
        i.image = #imageLiteral(resourceName: "ic_shadow")
        i.translatesAutoresizingMaskIntoConstraints = false
        return i
    }()
    
    let imageDot : UIImageView = {
        let i = UIImageView()
        i.image = #imageLiteral(resourceName: "ic_dot")
        i.contentMode = .scaleAspectFit
        i.translatesAutoresizingMaskIntoConstraints = false
        return i
    }()
    
    let viewLine = UIView()
    
    lazy var btnMarker:UIButton = {
        let btn = UIButton()
        btn.translatesAutoresizingMaskIntoConstraints = false
        btn.setImage(#imageLiteral(resourceName: "ic_origin_unselected_marker"), for: .normal)
        btn.contentMode = .scaleAspectFit
        btn.addTarget(self, action: #selector(tapMarker), for: .touchUpInside)
        return btn
    }()
    
    var delegate:DelegateTapMarker?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        [imageShadow,imageDot,btnMarker,viewLine].forEach{addSubview($0)}
        
        btnMarker.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        btnMarker.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        
        btnMarker.anchor(top: nil, leading: nil, bottom: nil, trailing: nil,padding: .init(top: 0, left: 0, bottom: -10, right: 0))
        
        
        
        imageShadow.anchor(top: self.btnMarker.bottomAnchor, leading: nil, bottom: nil, trailing:nil,size:.init(width: 10, height: 10))
        imageShadow.centerXAnchor.constraint(equalTo: btnMarker.centerXAnchor).isActive = true
        
        imageDot.centerXAnchor.constraint(equalTo: imageShadow.centerXAnchor).isActive = true
        imageDot.centerYAnchor.constraint(equalTo: imageShadow.centerYAnchor).isActive = true
        
        
        
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc
    public  func initDelegate(delegate:DelegateTapMarker)  {
        self.delegate = delegate
    }
    
    @objc
    func tapMarker()  {
        
        delegate?.tapMarker()
        
    }
    
 @objc
 public   func changeIcon(status:Int)  {
        
        if status == 1 {
            
          btnMarker.setImage(#imageLiteral(resourceName: "ic_origin_unselected_marker"), for: .normal)
        } else {
            
            btnMarker.setImage(#imageLiteral(resourceName: "ic_dest_unselected_marker"), for: .normal)
        }
        
    }
    
   @objc public func open(status:Int)  {
        
        if status == 1  {
             btnMarker.setImage(#imageLiteral(resourceName: "ic_origin_unselected_marker"), for: .normal)
            
            UIView.animate(withDuration: 0.75, delay: 0, options: [], animations: {
                
                self.imageShadow.alpha = 0.60
                self.imageShadow.transform = CGAffineTransform(scaleX: 2.5, y: 2.5)
                
            }, completion: nil)
            
        }else if status == 2 {
            
            btnMarker.setImage(#imageLiteral(resourceName: "ic_dest_unselected_marker"), for: .normal)
            
            UIView.animate(withDuration: 0.75, delay: 0, options: [], animations: {
                
                self.imageShadow.alpha = 0.60
                self.imageShadow.transform = CGAffineTransform(scaleX: 2.5, y: 2.5)
                
            }, completion: nil)
            
        }
        
       
        
    }
    
    @objc public func close(){
        
        UIView.animate(withDuration: 0.75, delay: 0, options: [], animations: {
            
            self.imageShadow.alpha = 1
            self.imageShadow.transform = CGAffineTransform(scaleX: 1.25, y:1.25)
            
        }, completion: nil)
        
    }
    
}
