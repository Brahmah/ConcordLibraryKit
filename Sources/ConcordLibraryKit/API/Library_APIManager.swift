//
//  Library_APIManager.swift
//  ConcordLibrary
//
//  Created by Bashir Rahmah on 4/7/2022.
//

import Foundation
import URLImage
import URLImageStore

enum CONCORD_HTTP_METHODS: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case patch = "PATCH"
    case delete = "DELETE"
}

struct RuntimeError: Error {
    let message: String
    
    init(_ message: String) {
        self.message = message
    }
    
    public var localizedDescription: String {
        return message
    }
    public var description: String {
        return message
    }
}

public struct Library_APIManager {
    static let mainURL = "https://ilimcollege.concordinfiniti.com"
    static let urlImageService = URLImageService(fileStore: nil, inMemoryStore: URLImageInMemoryStore())
    static func makeCall(path: String, method: CONCORD_HTTP_METHODS, body: String?, headers: [String: String], completion: @escaping (Result<String, Error>) -> Void) {
        if let url = URL(string: "\(Library_APIManager.mainURL)/\(path)") {
            var req = URLRequest(url: url)
            req.allHTTPHeaderFields = headers
            req.httpMethod = method.rawValue
            req.httpShouldHandleCookies = true
            if let body = body {
                req.httpBody = body.data(using: .utf8)
            }
            URLSession.shared.dataTask(with: req) { resData, res, resError in
                guard resError == nil else {
                    completion(.failure(resError!))
                    return
                }
                if let resData = resData {
                    let resStr = String(decoding: resData, as: UTF8.self)
                    completion(.success(resStr))
                } else {
                    completion(.failure(RuntimeError("Response Data Was Optional.")))
                }
            }
            .resume()
        } else {
            completion(.failure(RuntimeError("Unable To Construct URL For Request.")))
        }
    }
}
