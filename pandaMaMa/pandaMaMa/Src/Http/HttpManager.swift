//
//  HttpManager.swift
//  AnAnOrderCarDriver
//
//  Created by Mac on 17/3/22.
//  Copyright © 2017年 treee. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

typealias SuccessBlock = (_ success:AnyObject) -> Void
typealias RequestFailBlock = (_ message:AnyObject) -> Void
typealias ConnectFailBlock = (_ error:AnyObject) -> Void

/// 网络请求信息
class HttpManager: NSObject {
    //MARK:-
    //MARK:properties
    
    //MARK:-
    //MARK:method
    private override init() {
        super.init()
    }

    /// 根据后缀地址拼接成完整的url访问地址
    ///
    /// - Parameter url: 后缀的地址
    /// - Returns: 返回一个完整的url地址
    class func getUrl(url:String) -> String {
        return kPort_script_URL + url
    }
    
    /// 根据用户的请求字典，添加用户的辨识信息
    ///
    /// - Parameter sourceDic: 源字典
    class func getParams(sourceDic : [String:Any], cmdCode:E_CMDCODE) -> [String : Any] {
        guard CC_NEED_LOGIN_QUEUE().contains(cmdCode) else {
            return sourceDic
        }
        var temsourceDic: [String:Any] = sourceDic
        let currentConfig = Config.current
        temsourceDic["token"] = currentConfig.getUserDictionary().object(forKey: "token")
        return temsourceDic
    }
    
    /// 请求地址，包含了请求所有状态的回调
    ///
    /// - Parameters:
    ///   - url: 请求的地址
    ///   - params: 请求的参数
    ///   - SuccessBlock: 请求成功的回调
    ///   - requestFailBlock: 请求失败
    ///   - connectFailBlock: 无法连接到服务器
    class func postForResult(_ url:String, params:[String:Any], successBlock:SuccessBlock?, requestFailBlock:RequestFailBlock?, connectFailBlock:ConnectFailBlock?) -> Void {
        request(url, method: .post, params: params, headers: nil, successBlock: successBlock, requestFailBlock: requestFailBlock, connectFailBlock: connectFailBlock)
    }
    
    
    /// 请求地址，包含了请求成功的回调
    ///
    /// - Parameters:
    ///   - url: 请求的地址
    ///   - params: 请求的参数
    ///   - successBlock: 请求成功的回调
    class func postForResult(_ url:String, params:[String:Any], successBlock:@escaping SuccessBlock) -> Void {
        postForResult(url, params: params, successBlock: successBlock, requestFailBlock: nil, connectFailBlock: nil)
    }
    
    
    /// 请求地址，包含了所有状态的回调
    ///
    /// - Parameters:
    ///   - url: 请求的地址
    ///   - params: 请求的参数
    ///   - successBlock: 请求成功的回调
    ///   - requestFailBlock: 请求失败的回调
    ///   - connectFailBlock: 无法连接到服务器
    class func getForResult(_ url:String, params:[String:Any], successBlock:SuccessBlock?, requestFailBlock:RequestFailBlock?, connectFailBlock:ConnectFailBlock?) -> Void {
        request(url, method: .get, params: params, headers: nil, successBlock: successBlock, requestFailBlock: requestFailBlock, connectFailBlock: connectFailBlock)
    }
    
    /// 请求地址，包含了所有状态的回调
    ///
    /// - Parameters:
    ///   - url: 请求的地址
    ///   - params: 请求的参数
    ///   - successBlock: 请求成功的回调
    class func getForResult(_ url:String, params:[String:Any], successBlock:@escaping SuccessBlock) -> Void {
        getForResult(url, params: params, successBlock: successBlock, requestFailBlock: nil, connectFailBlock: nil)
    }
    
    
    
    /// 请求的方法，调用Alamofire的请求方法
    ///
    /// - Parameters:
    ///   - url: 请求的地址
    ///   - method: 请求的方法
    ///   - params: 请求的参数
    ///   - successBlock: 成功的回调
    ///   - requestFailBlock: 失败的回调
    ///   - connectFailBlock: 无法连接到服务器
    class func request(_ url:String, method:HTTPMethod, params:[String:Any], headers: [String: String]?, successBlock:SuccessBlock?, requestFailBlock:RequestFailBlock?, connectFailBlock:ConnectFailBlock?) -> Void {
        Alamofire.request(url, method: method, parameters: params, headers: headers).responseJSON { (response) in
            print("\(url)->\(params)")
            if response.result.isFailure {
                if (connectFailBlock != nil) {
                    connectFailBlock!(kHttp_Notice_ReqesutFailed as AnyObject)
                    return
                }
            }else {
                let jsonData = JSON.init(data: response.data!)
                if self.stateSuccess(jsonData["state"].string!) {
                    if (successBlock != nil) {
                        successBlock!(jsonData as AnyObject)
                        return
                    }
                }else {
                    if (requestFailBlock != nil) {
                        requestFailBlock!(jsonData as AnyObject)
                        return
                    }
                }
            }
        }
    }
    
    
   class func stateSuccess(_ stateCode:String) -> Bool {
        let errorCode:[String] = ["error","unSuccess","fail"]
        if (errorCode.contains(stateCode)) {
            return false
        }
        return true
    }
    
}
