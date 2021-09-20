//
//  GitHubService.swift
//  GitSearchDemo
//
//  Created by Sergei Morozov on 19.09.21.
//

import Foundation

typealias DictionaryResponseBlock = ([String : Any]?, Int, Error?) -> Void // dict, statusCode, error

enum GHSection: String {
    case search
    case other
    
    private static let baseURLTemplate = "https://api.github.com/{section}"
    
    func baseURLString() -> String {
        return
            GHSection.baseURLTemplate
            .replacingOccurrences(of: "{section}", with: "search")
    }
}

enum HTTPMethod: String {
    case GET
    case POST
    case PUT
    case DELETE
}

enum Constants {
    static let retryCount = 1
    
    static let timeout = 10.0
    
    enum ErrorStatusCodes {
        static let noHTTPResponse = -1
        static let createRequestFailed = -1000
    }
}


final class GitHubService {
    
    
    let baseURLString = ""
    static let shared: GitHubService = GitHubService()
    enum Constants {
        static let retryCount = 1 // 3
        
        static let timeout = 10.0
        
        enum ErrorStatusCodes {
            static let noHTTPResponse = -1
            static let createRequestFailed = -1000
        }
    }
    
    //MARK:- Base methods
    
    private var session: URLSession {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = Constants.timeout
        
        return URLSession(configuration: configuration)
    }
    
    private func sendRequestWithDictionaryResponse(request: URLRequest, retryCount: Int, completion: @escaping DictionaryResponseBlock) {
        print("GitHubService: sendRequest: \(request), retryCount: \(retryCount)")
        
        if let httpBody = request.httpBody {
            if let jsonObject = try? JSONSerialization.jsonObject(with: httpBody, options: []) {
                print("\(jsonObject)")
            }
        }
        
        let dataTask = session.dataTask(with: request) { [weak self] (data, response, error) in
            self?.processDictionaryResponse(with: data, request: request, response: response, retryCount: retryCount, error: error, completion: completion)
        }
        
        dataTask.resume()
    }
    
    private func processDictionaryResponse(with data: Data?, request: URLRequest, response: URLResponse?, retryCount: Int, error: Error?, completion: @escaping DictionaryResponseBlock) {
        
        let statusCode: Int = (response as? HTTPURLResponse)?.statusCode ?? Constants.ErrorStatusCodes.noHTTPResponse
        
        var resultDict: [String : Any]?
        
        if let responseData = data {
            if let dict = try? JSONSerialization.jsonObject(with: responseData, options: []) {
                resultDict = dict as? [String : Any]
            }
        }
        
        if error == nil && statusCode == 200 {
            completion(resultDict, statusCode, nil);
        } else if retryCount > 0 {
            sendRequestWithDictionaryResponse(request: request, retryCount: retryCount - 1, completion: completion)
        } else {
            completion(resultDict, statusCode, error);
        }
    }
    
    private func createRequest(withPath path: String, section: GHSection = .search, method: HTTPMethod = .GET) -> URLRequest? {
        
        let urlPath = path
        
        let urlStr = section.baseURLString() + "/" + urlPath
        guard let requestURL = URL(string: urlStr) else {
            return nil
        }
        
        var request = URLRequest(url: requestURL)
        
        request.httpMethod = method.rawValue
        
        return request
    }
    
    //MARK: - getFunctions
    
    func getSearchRepositories(searchString : String, searchCount : Int, pageNum: Int, completion: @escaping DictionaryResponseBlock) {
        guard let request = createRequest(withPath: "repositories?q=\(searchString)&sort=stars&order=desc&per_page=\(searchCount)&page=\(pageNum)") else {
            completion (nil, Constants.ErrorStatusCodes.createRequestFailed, nil)
            return
        }
        sendRequestWithDictionaryResponse(request: request, retryCount: Constants.retryCount - 1, completion: completion)
    }
}
