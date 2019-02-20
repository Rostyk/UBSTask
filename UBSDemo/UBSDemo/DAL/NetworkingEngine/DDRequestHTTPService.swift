//
//  DDRequestHTTPTransport.swift
//  EquifyCRM
//
//  Created by Rostyslav Stepanyak on 25/06/18.
//  Copyright © 2017 DDragons LLC. All rights reserved.
//

import Foundation

class DDRequestHTTPService: NSObject, DDRequestService {
    let baseUrl: URL
    var session: URLSession?
    
    init(baseUrl: URL) {
        self.baseUrl = baseUrl
        super.init()
        session = URLSession(configuration: URLSessionConfiguration.default, delegate: self, delegateQueue: nil)
    }
    
    func logNetworkResponse(response: HTTPURLResponse?, error: Error?, body: Data?) {
        if let response = response {
            if error == nil && (200..<300).contains(response.statusCode) {
                /*DDLogs.success("""
                    \n----- [NETWORK RESPONSE] -----
                    URL: \(String(describing: response.url))
                    STATUS CODE: \(String(describing: response.statusCode))
                    BODY\n \(bodyStr ?? "<empty>")
                    -----------------------------
                    """)*/
        } else {
            /*DDLogs.error("""
                \n----- [NETWORK RESPONSE] -----
                URL: \(String(describing: response.url))
                ERROR: \(String(describing: error))
                STATUS CODE: \(String(describing: response.statusCode))
                BODY\n \(bodyStr ?? "<empty>")
                -----------------------------
                """)*/
            }
        }
    }
    
    internal func send<T>(request: DDRequest, completion: @escaping (T?, TransportError?) -> Void) where T: DDResponse, T: Deserializable {
        
        guard let request = prepareHttpRequestFor(ddRequest: request) else {
            completion(nil, TransportError.SerializationFailed)
            return
        }
        
        session?.dataTask(with: request) {
            (responseData, urlResponse, requestError) in
            
            var error: TransportError? = nil
            var response: T? = nil
            let httpUrlResponse = urlResponse as? HTTPURLResponse
            
            // Request completed successfully if responseData is not nil and requestError is nil
            // It is also expected that urlResponse will always contain a proper HTTPURLResponse object
            if let responseData = responseData,
                requestError == nil,
                httpUrlResponse != nil {
                
                if (200..<300).contains(httpUrlResponse!.statusCode) {
                    response = T(data: responseData)
                    if response == nil {
                        error = TransportError.DeserializationFailed
                    }
                } else {
                    error = TransportError.ServerError(code: httpUrlResponse!.statusCode)
                }    
            } else {
                error = TransportError.RequestFailed(error: requestError)
                print("Request Error: " + error!.localizedDescription)
            }
            
            self.logNetworkResponse(response: httpUrlResponse, error: error, body: responseData)
            
            DispatchQueue.main.async {
                completion(response, error)
            }
        }.resume()
    }
    
    func prepareHttpRequestFor(ddRequest: DDRequest) -> URLRequest? {

        guard let httpRequest = ddRequest as? HTTPRequest else { return nil }

        let url = baseUrl.appendingPathComponent(httpRequest.relativePath)
        var request: URLRequest!
        
        switch httpRequest {
        case let getRequst as HTTPGetRequest:
            var components = URLComponents(string: url.absoluteString)!
            
            components.queryItems = getRequst.urlQueryItems
            
            request = URLRequest(url: components.url!)
            if let additionalHeaders = getRequst.additionalHeaders {
                for (headerField, value) in additionalHeaders {
                    request.addValue(value, forHTTPHeaderField: headerField)
                }
            }
            
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            
        case let postRequest as HTTPPostRequest:
            request = URLRequest(url: url)
            let postData = postRequest.dataForHttpBody
            
            if let additionalHeaders = postRequest.additionalHeaders {
                for (headerField, value) in additionalHeaders {
                    request.addValue(value, forHTTPHeaderField: headerField)
                }
            }
            
            request.httpBody = postData
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue(String(describing: postData?.count), forHTTPHeaderField: "Content-Length")
        default:
            return nil
        }
        
        request.httpMethod = httpRequest.httpMethod
        return request
    }
}

extension DDRequestHTTPService: URLSessionDelegate {
    
}

protocol HTTPRequest {
    var relativePath: String { get }
    var httpMethod: String { get }
}

protocol HTTPGetRequest: HTTPRequest {
    var urlQueryItems: [URLQueryItem]? { get }
    var additionalHeaders: [String: String]? { get }
}

protocol HTTPPostRequest: HTTPRequest {
    var dataForHttpBody: Data? { get }
    var additionalHeaders: [String: String]? { get }
}

extension HTTPRequest {
    var relativePath: String {
        return relativePath
    }
}

extension HTTPPostRequest {
    var httpMethod: String {
        return "POST"
    }
}

extension HTTPGetRequest {
    var httpMethod: String {
        return "GET"
    }
}
