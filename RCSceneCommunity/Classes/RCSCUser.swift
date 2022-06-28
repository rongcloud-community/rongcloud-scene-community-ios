//
//  RCSCUser.swift
//  RCSceneCommunity
//
//  Created by xuefeng on 2022/3/31.
//

import Foundation

public class RCSCUser {
    
    static var user: RCSCUser?

    public let userId: String
    public var userName: String
    public var portrait: String?
    public var imToken: String
    public let authorization: String
    public let type: Int
    public var sex: Int
    public convenience init(model: RCSCUserModel) {
        self.init(userId: model.userId, userName: model.userName, portrait: model.portrait, imToken: model.imToken, authorization: model.authorization, type: model.type,sex: model.sex)
    }
    
    public init(userId: String, userName: String, portrait: String?, imToken: String, authorization: String, type: Int, sex: Int) {
        self.userId = userId
        self.userName = userName
        self.portrait = portrait
        self.imToken = imToken
        self.authorization = authorization
        self.type = type
        self.sex = sex
    }
    
    public static func loadUser(user: RCSCUser?) {
        Self.user = user
    }
    
    public static func isLogin() -> Bool{
        guard let user = Self.user else {
            return false
        }
        return user.authorization.count > 0
    }
}

let userIdKey = "userIdKey"
let userNameKey = "userNameKey"
let portraitKey = "portraitKey"
let imTokenKey = "imTokenKey"
let authorizationKey = "authorizationKey"
let typeKey = "typeKey"
let sexKey = "sexKey"

public extension RCSCUser {
    
    func rCSCstorageUser() {
        UserDefaults.standard.set(self.userId, forKey: userIdKey)
        UserDefaults.standard.set(self.userName, forKey: userNameKey)
        UserDefaults.standard.set(self.portrait, forKey: portraitKey)
        UserDefaults.standard.set(self.imToken, forKey: imTokenKey)
        UserDefaults.standard.set(self.authorization, forKey: authorizationKey)
        UserDefaults.standard.set(self.type, forKey: typeKey)
        UserDefaults.standard.set(self.sex, forKey: sexKey)
    }
    
    static func RCSCGetUser() -> RCSCUser? {
        guard let userId = UserDefaults.standard.value(forKey: userIdKey) as? String,
              let userName = UserDefaults.standard.value(forKey: userNameKey) as? String,
              let imToken = UserDefaults.standard.value(forKey: imTokenKey) as? String,
              let authorization = UserDefaults.standard.value(forKey: authorizationKey) as? String,
              let type = UserDefaults.standard.value(forKey: typeKey) as? Int ,
              let sex = UserDefaults.standard.value(forKey: sexKey) as? Int else {
                  return nil
              }

        let portrait = UserDefaults.standard.value(forKey: portraitKey) as? String
        Self.user = RCSCUser(userId: userId, userName: userName, portrait: portrait, imToken: imToken, authorization: authorization, type: type,sex: sex)
        return Self.user
    }
    static func  clearRCSCUserData(){
        UserDefaults.standard.removeObject(forKey: userIdKey)
        UserDefaults.standard.removeObject(forKey: userNameKey)
        UserDefaults.standard.removeObject(forKey: portraitKey)
        UserDefaults.standard.removeObject(forKey: imTokenKey)
        UserDefaults.standard.removeObject(forKey: authorizationKey)
        UserDefaults.standard.removeObject(forKey: typeKey)
        UserDefaults.standard.removeObject(forKey: sexKey)
        UserDefaults.standard.synchronize()
        RCSCUser.user = nil
    }
}
