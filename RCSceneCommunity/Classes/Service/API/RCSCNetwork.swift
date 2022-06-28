//
//  RCSCService.swift
//  RCSceneCommunity
//
//  Created by xuefeng on 2022/3/28.
//

import Foundation
import Alamofire

public typealias RCSCSuccessClosure<T> = (_ object: T?) -> Void
public typealias RCSCFailedClosure = (_ error: RCSCError) -> Void
public typealias RCSCProgressHandler = (Progress) -> Void
public typealias RCSCSession = Alamofire.Session
public typealias RCSCNetworkReachabilityManager = NetworkReachabilityManager
public typealias RCSCRequest = Alamofire.Request
public typealias RCSCDataResponse = AFDataResponse
public typealias RCSCHTTPHeaders = HTTPHeaders
public typealias RCSCHTTPMethod = HTTPMethod
public typealias RCSCParameterEncoding = ParameterEncoding
public typealias RCSCJSONEncoding = JSONEncoding

public enum RCSCNetworkReachabilityStatus {
    case unknown
    case notReachable
    case ethernetOrWiFi
    case cellular
}

public struct RCSCMultipartFormData {
    let data: Data
    let name: String
    let fileName: String
    let mimeType: String
    
    init(data: Data, name: String, fileName: String, mimeType: String) {
        self.data = data
        self.name = name
        self.fileName = fileName
        self.mimeType = mimeType
    }
}

public class RCSCHTTPTask<T: Codable>: Equatable {

    var request: RCSCRequest?

    private var successHandler: RCSCSuccessClosure<T>?

    private var failedHandler: RCSCFailedClosure?

    private var progressHandler: RCSCProgressHandler?
    
    func handleResponse(response: RCSCDataResponse<RCSCSuccess<T>>) {
        switch response.result {
        case .failure(let error):
            if let closure = failedHandler {
                let err = RCSCError(error.responseCode ?? -1,error.localizedDescription)
                closure(err)
            } else {
                SVProgressHUD.showError(withStatus: "网络异常")
                debugPrint("\(error.localizedDescription)： \(error.responseCode ?? -1)")
            }
        case .success(let obj):
            if let closure = successHandler, obj.isSuccess() {
                closure(obj.data)
            }
            else if let closure = failedHandler, !obj.isSuccess() {
                let err = RCSCError(obj.code ?? -1, obj.msg ?? "网络错误")
                closure(err)
            }
            else if let closure = failedHandler {
                let err = RCSCError(-1,"网络错误")
                closure(err)
            }
            else {
                SVProgressHUD.showError(withStatus: "\(obj.msg ?? "网络错误")")
                debugPrint("Network error path:\(response.request?.url) code:\(obj.code ?? -1)")
            }
        }
        clearReference()
    }

    func handleProgress(progress: Foundation.Progress) {
        if let closure = progressHandler {
            closure(progress)
        }
    }

    @discardableResult
    public func success(_ closure: @escaping RCSCSuccessClosure<T>) -> Self {
        successHandler = closure
        return self
    }

    @discardableResult
    public func failed(_ closure: @escaping RCSCFailedClosure) -> Self {
        failedHandler = closure
        return self
    }

    @discardableResult
    public func progress(closure: @escaping RCSCProgressHandler) -> Self {
        progressHandler = closure
        return self
    }

    func cancel() {
        request?.cancel()
    }

    func clearReference() {
        successHandler = nil
        failedHandler = nil
        progressHandler = nil
    }
    
    public static func == (lhs: RCSCHTTPTask, rhs: RCSCHTTPTask) -> Bool {
        return lhs.request?.id == rhs.request?.id
    }
}

class RCSCNetwork {
    
    public static let network = RCSCNetwork()
    
    var sessionManager: RCSCSession!
    
    var reachability: RCSCNetworkReachabilityManager?
    
    var networkStatus: RCSCNetworkReachabilityStatus = .unknown
    
    private init() {
        let config = URLSessionConfiguration.af.default
        config.timeoutIntervalForRequest = 20
        config.timeoutIntervalForResource = 20
        config.httpAdditionalHeaders?.updateValue("application/json",forKey: "Accept")
        config.httpAdditionalHeaders?.updateValue("application/json",forKey: "Content-Type")
        sessionManager = RCSCSession(configuration: config)
    }
    
    @discardableResult
    private func request<T: Codable>(url: String,
                                     method: RCSCHTTPMethod,
                                     parameters: [String: Any]?,
                                     headers: [String: String]? = nil,
                                     encoding: RCSCParameterEncoding = RCSCJSONEncoding.default,
                                     type: T.Type) -> RCSCHTTPTask<T> {
        let task = RCSCHTTPTask<T>()
        var h: RCSCHTTPHeaders?
        if let tempHeaders = headers {
            h = RCSCHTTPHeaders(tempHeaders)
            h?["Content-Type"] = "application/json"
        }
        task.request = sessionManager.request(url, method: method, parameters: parameters, encoding: encoding, headers: h, interceptor: nil, requestModifier: nil).responseDecodable(of: RCSCSuccess<T>.self) {response in
            if let data = response.data, let jsonString = String(data: data, encoding: .utf8) {
                print(jsonString)
            }
            task.handleResponse(response: response)
        }
        return task
    }
    
    @discardableResult
    public func upload<T: Codable>(url: String,
                                   method: RCSCHTTPMethod = .post,
                                   parameters: [String: String]?,
                                   datas: [RCSCMultipartFormData],
                                   headers: [String: String]? = nil,
                                   type: T.Type) -> RCSCHTTPTask<T> {
        let task = RCSCHTTPTask<T>()
        var h: RCSCHTTPHeaders?
        if let tempHeaders = headers {
            h = RCSCHTTPHeaders(tempHeaders)
        }

        task.request = sessionManager.upload(multipartFormData: { (multipartData) in
            if let parameters = parameters {
                for p in parameters {
                    multipartData.append(p.value.data(using: .utf8)!, withName: p.key)
                }
            }
            for d in datas {
                multipartData.append(d.data, withName: d.name, fileName: d.fileName, mimeType: d.mimeType)
            }
        }, to: url, method: method, headers: h).uploadProgress(queue: .main, closure: { (progress) in
            task.handleProgress(progress: progress)
        }).validate().responseDecodable(of: RCSCSuccess<T>.self) { response in
            if let data = response.data, let jsonString = String(data: data, encoding: .utf8) {
                print(jsonString)
            }
            task.handleResponse(response: response)
        }
        return task
    }
}

extension RCSCNetwork {
    @discardableResult
    public func post<T: Codable>(
                           url: String,
                           parameters: [String: Any]?,
                           headers: [String: String]? = nil,
                           encoding: RCSCParameterEncoding = RCSCJSONEncoding.default,
                           type: T.Type) -> RCSCHTTPTask<T> {
       return request(url: url, method: .post, parameters: parameters, headers: headers, encoding: encoding, type: type)
   }
    @discardableResult
    public func get<T: Codable>(
                           url: String,
                           parameters: [String: Any]?,
                           headers: [String: String]? = nil,
                           encoding: RCSCParameterEncoding = RCSCJSONEncoding.default,
                           type: T.Type) -> RCSCHTTPTask<T> {
       return request(url: url, method: .get, parameters: parameters, headers: headers, encoding: encoding, type: type)
   }
}
