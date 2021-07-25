//
//  Service.swift
//  User
//
//  Created by AlaanCo on 4/16/19.
//  Copyright © 2019 iCOMPUTERS. All rights reserved.
//

import Foundation
import UIKit
import Alamofire

struct ServiceAPI {
    
    static let shared = ServiceAPI()
    
    func fetchGenericData<T: Decodable>(urlString: String,parameters:Parameters,methodInput:HTTPMethod,isHeaders:Bool = false , completion: @escaping (T? , Error?,Int?) -> ()) {
        
        var headers:HTTPHeaders? = nil
        if isHeaders {
            headers = [
                "Authorization": "Bearer \(UserDefaults.standard.string(forKey: "access_token") ?? "")",
                "X-Requested-With": "XMLHttpRequest"
            ]
        }
        
        Alamofire.request(SERVICE_URL+urlString, method: methodInput, parameters: parameters, encoding:URLEncoding.default, headers: headers).responseData { response in
            switch response.result {
                
            case .success:
                
                let  jsonDecoder = JSONDecoder()
                guard let data = response.result.value else { completion(nil,nil,response.response?.statusCode); return }
                
                do {
                    let json = try jsonDecoder.decode(T.self, from: data)
                    completion(json, nil,response.response?.statusCode)
                    
                }catch let error{
                    completion(nil,error,response.response?.statusCode)
                }
                
            case .failure(let error):
                
                completion(nil,error,response.response?.statusCode)
                
            }
            
        }
        
        
    }
    
   /* func fetchGenericData<T: Decodable>(urlString: String,parameter:[String:Any],completion: @escaping (T? ,Int?,Error?) -> ()) {
        
        print(UserDefaults.standard.string(forKey: "access_token") ?? "")
    
        do {
            let data = try JSONSerialization.data(withJSONObject: parameter, options: [])
            
            var url = URLRequest(url: URL(string:SERVICE_URL+urlString)!)
            url.setValue("XMLHttpRequest", forHTTPHeaderField: "X-Requested-With")
            url.setValue("Authorization", forHTTPHeaderField: UserDefaults.standard.string(forKey: "access_token") ?? "")
            url.httpBody = data
            url.httpMethod = "POST"
            
            
            let session = URLSession.shared
            let task = session.dataTask(with: url) {(data, response, error) in
                
                 let status = (response as! HTTPURLResponse).statusCode
                if let err = error {
                    completion(nil,status,err)
                    return
                }
                
                do {
                    
                    let response = try JSONDecoder().decode(T.self, from: data!)
                    completion(response,status,nil)
                    
                }catch let jsonErr {
                    completion(nil,status,jsonErr)
                    
                }
            }
            task.resume()
            
        } catch let error {
            completion(nil,500,error)
        }
        
        
    }*/
    
}
