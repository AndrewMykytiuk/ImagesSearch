//
//  NetworkManager.swift
//  ImageSearch
//
//  Created by User on 12/04/2018.
//  Copyright © 2018 MPTechnologies. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import SwiftyJSON

class NetworkManager: NSObject {
    
    class private func parsedObjectFromResponse(_ responseObject: Any?) -> Any? {
        
        if responseObject is NSDictionary {
            
            let item = responseObject as! NSDictionary
            let newDict = NSMutableDictionary()
            
            let keys = item.allKeys;
            
            for key in keys {
                
                let info = item[key]
                
                if info is NSArray || info is NSDictionary {
                    newDict[key] = parsedObjectFromResponse(info)
                }
                else if !(info is NSNull)
                {
                    if info is String
                    {
                        if info as! String == "null"
                        {
                            continue
                        }
                    }
                    
                    newDict[key] = info
                }
            }
            
            return newDict
        }
        else if responseObject is NSArray
        {
            let array = NSMutableArray()
            
            for info in responseObject as! NSArray {
                if !(info is NSNull) {
                    array.add(parsedObjectFromResponse(info)!)
                }
            }
            
            return array;
        }
        else if responseObject is NSNull {
            return nil
        }
        
        return responseObject
    }
    
    class private func parseReponse(_ response: DataResponse<Any>, complete: @escaping ( _ completeInfo: JSON?, _ errorMessage: String?) -> Void) {
        if response.error != nil {
            
            let error = response.error as NSError?
            
            if error?.code != NSURLErrorCancelled {
                
                if response.response?.statusCode == 201 ||
                    response.response?.statusCode == 200 {
                    if let value = parsedObjectFromResponse(response.result.value) {
                        complete(JSON(value), nil)
                    }
                    else {
                        complete(nil, nil)
                    }
                }
                else {
                    complete(nil, response.error?.localizedDescription)
                }
            }
        }
        else {
            
            if let result = parsedObjectFromResponse(response.result.value) {
                let json = JSON(result)
                
                if json["stat"].stringValue != "ok" {
                    complete (nil, json["stat"].stringValue)
                }
                else {
                    complete (json, nil)
                }
            }
            else {
                complete (nil, nil)
            }
        }
    }
    
    class private func baseRequestWithPath(path: String, parameters: Dictionary<String, Any>?, method: HTTPMethod, complete: @escaping ( _ completeInfo: JSON?, _ errorMessage: String?) -> Void) -> DataRequest {
        
        let encoding = JSONEncoding.prettyPrinted
        return Alamofire.request(path, method: method, parameters : parameters, encoding: encoding, headers: nil)
            
            .responseJSON { response in
                parseReponse(response, complete: complete)
        }
    }
    
    @discardableResult class private func getRequestWithPath(path: String, parameters: Dictionary<String, Any>?, complete: @escaping ( _ completeInfo: JSON?, _ errorMessage: String?) -> Void) -> DataRequest {
        return baseRequestWithPath(path: path, parameters: parameters, method: .get, complete: complete)
    }
    
    class func cancelPreviousRequests(completion: @escaping()->Void) {
        let sessionManager = Alamofire.SessionManager.default
        sessionManager.session.getTasksWithCompletionHandler { dataTasks, uploadTasks, downloadTasks in
            let operBlock = BlockOperation()
            operBlock.addExecutionBlock {
                dataTasks.forEach { $0.cancel() }
                uploadTasks.forEach { $0.cancel() }
                downloadTasks.forEach { $0.cancel() }
            }
            operBlock.completionBlock = {
                completion()
            }
            operBlock.start()
        }
    }
    
    class func getImages(_ imagesCount: Int, text:String, page: Int, completion: @escaping(_ dict: [JSON], _ error: String?)->Void) {
        
        let apiKey = "0d48be7d35c252fa3ccaaf7f454754df"
        
        getRequestWithPath(path: "https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=\(apiKey)&text=\(text)&page=\(page)&format=json&nojsoncallback=1&per_page=\(imagesCount)&extras=url_o",
        parameters: nil) { (response, error) in
            if let json = response {
                completion(json["photos"]["photo"].arrayValue, error)
            }
            else {
                completion([], error)
            }

        }
    }
    
}
