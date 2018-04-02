//
//  UserStore.swift
//  KikoInstaller
//
//  Created by Prabhakar Annavi on 1/9/17.
//  Copyright © 2017 Eoxys Systems. All rights reserved.
//

import Foundation

class UserStore: NSData {
    var userArr = [UserModel]()
    
    func add(user:UserModel) {
        userArr.append(user)
    }
    
    func add(userUid:String,userId:String,userName:String){
        let user = UserModel()
        
        user.userUid = userUid
        user.userId = userId
        user.userName = userName
        userArr.append(user)
    }
    
    func getAt(index:Int) -> UserModel{
        if userArr.count > index {
            print("iffffffffffffffffffffffff")
            return userArr[index]
           
        }else{
            print("elseeeeeeeeeeeeeeeeeeeee")
            return UserModel()
        }
    }
    
    func clearAll(){
        userArr.removeAll()
    }
    
    func getSize() -> Int{
        return userArr.count
    }
    
}
