//
//  NetworkManager.swift
//  GithubRepos
//
//  Created by Michael Abadi on 11/4/17.
//  Copyright © 2017 Michael Abadi Santoso. All rights reserved.
//

import Foundation
import Alamofire

/**
 * @discussion Enum for the NetworkError
 */
public enum NetworkError: Error {
    case dataIsNotEncodable(_: Any)
    case badRequest(_: String)
    case unauthorized(_: String)
    case forbidden(_: String)
    case serverError
    case httpMethodNotAllow
    case stringFailedToDecode(_: Data, encoding: String.Encoding)
    case invalidURL(_: String)
    case missingEndpoint
    case noInternet
}

// Define the parameter's dictionary
public typealias ParametersDict = [String : Any?]

// Define the header's dictionary
public typealias HeadersDict = [String: String]

/**
 * @discussion Define what kind of HTTP method must be used to carry out the `Request`
 * @case get
 * @case post
 * @case put
 * @case delete
 * @case patch
 */
public enum RequestMethod: String {
    case options = "OPTIONS"
    case get     = "GET"
    case head    = "HEAD"
    case post    = "POST"
    case put     = "PUT"
    case patch   = "PATCH"
    case delete  = "DELETE"
    case trace   = "TRACE"
    case connect = "CONNECT"
}

/**
 * @discussion Define what kind of HTTP Request Path
 * @case getUsers
 * @case getImage
 */
public enum RequestPath {
    case getUsers
    case getImage
}

/**
 * @discussion Define what kind of Type Object to be saved later after request
 * @case users
 * @case image
 */
public enum TypeObject {
    case users
    case image
}

/**
 * @discussion Class for Network Manager services
 */
class NetworkManager: NSObject {
    static let sharedInstance = NetworkManager()
    
    /**
     * @discussion Function for fetching URL Request
     * @param request - the path for requesting
     * @param customUrl - custom url string to request
     * @param completion - void
     */
    func fetchUrl(request: RequestPath, customUrl: String?, _ completion: @escaping (AnyObject?) -> Void){
        switch request {
        case .getUsers:
            requestEndpoint(Config.Endpoint.getUsers+String(Config.Parameters.getUserPaginationNumber), type: .users, method: .get, body: nil, headers: nil, completion: completion)
        case .getImage:
            requestEndpoint(customUrl!, type: .users, method: .get, body: nil, headers: nil, completion: completion)
        }
    }
    
    /**
     * @discussion Function for fetching URL Request using Alamofire
     * @param urlString - the url
     * @param type - the type of the object or model
     * @param method - http method
     * @param body - http body
     * @param headers - http header
     */
    func requestEndpoint(_ urlString: String, type: TypeObject, method: HTTPMethod, body: ParametersDict?, headers: HeadersDict?, completion: @escaping (AnyObject?) -> ()) {
        
        //let parameters: Parameters = body
        let utilityQueue = DispatchQueue.global(qos: .utility)
        
        if let body = body {
            let parameters: Parameters = body as Any as! Parameters
            Alamofire.request(urlString, method: method,  parameters: parameters)
                .responseJSON(queue: utilityQueue) { response in
                    
            }
        }else{
            Alamofire.request(urlString, method: method)
                .validate()
                .responseJSON(queue: utilityQueue) { [unowned self] response in
                    print("Finish Fetching page api", urlString)
                    guard case let .failure(error) = response.result else {
                        switch type {
                        case .users :
                            let objectResponse = response.map { json -> GithubUsers in
                                //self.saveResponseToDatabase(key:                                    Config.DatabaseKey.githubResponses, object: json as AnyObject)
                                return GithubUsers(array: json as! [[String: AnyObject]])
                            }
                            if let object = objectResponse.value {
                                DispatchQueue.main.async(execute: {
                                    completion(object as AnyObject)
                                })
                            }
                        case .image:
                            break
                        }
                        return
                    }
                    
                    self.checkError(error: error as AnyObject, completion: completion)
            }
        }
        
    }
    
    /**
     * @discussion Function for Save Response to Database
     * @param key - the key to be mark in db
     * @param object - the data to be saved in db
     */
    func saveResponseToDatabase(key: String, object: AnyObject?){
        DatabaseManager.sharedInstance.saveToDatabase(key: key, object: object, objectType: .githubUsers) { (response) in
            print("Github Response Saved")
        }
    }
    
    
    /**
     * @discussion Function for Check Error and trigger network activity
     * @param error - the error object
     */
    func checkError(error: AnyObject?, completion: @escaping (AnyObject?) -> Void) {
        if let error = error as? AFError {
            switch error {
            case .invalidURL(let url):
                print("Invalid URL: \(url) - \(error.localizedDescription)")
            case .parameterEncodingFailed(let reason):
                print("Parameter encoding failed: \(error.localizedDescription)")
                print("Failure Reason: \(reason)")
            case .multipartEncodingFailed(let reason):
                print("Multipart encoding failed: \(error.localizedDescription)")
                print("Failure Reason: \(reason)")
            case .responseValidationFailed(let reason):
                print("Response validation failed: \(error.localizedDescription)")
                print("Failure Reason: \(reason)")
                
                switch reason {
                case .dataFileNil, .dataFileReadFailed:
                    print("Downloaded file could not be read")
                case .missingContentType(let acceptableContentTypes):
                    print("Content Type Missing: \(acceptableContentTypes)")
                case .unacceptableContentType(let acceptableContentTypes, let responseContentType):
                    print("Response content type: \(responseContentType) was unacceptable: \(acceptableContentTypes)")
                case .unacceptableStatusCode(let code):
                    print("Response status code was unacceptable: \(code)")
                }
            case .responseSerializationFailed(let reason):
                print("Response serialization failed: \(error.localizedDescription)")
                print("Failure Reason: \(reason)")
            }
            print("Underlying error: \(error.underlyingError)")
        } else if let error = error as? URLError {
            print("URLError occurred: \(error.code.rawValue)")
            completion(error as AnyObject)
        } else {
            print("Unknown error: \(error)")
        }
        completion(nil)
    }
    
    /**
     * @discussion Function for Check Error Type to trigger notif bar
     * @param errorCode - the error code
     */
    func checkErrorType(errorCode: Int) -> NetworkError{
        if errorCode == -1009 {
            return .noInternet
        }
        return .noInternet
    }
    
}
