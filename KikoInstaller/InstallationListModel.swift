//
//  InstallationListModel.swift
//  KikoInstaller
//
//  Created by Prabhakar Annavi on 1/28/17.
//  Copyright © 2017 Eoxys Systems. All rights reserved.
//

import Foundation
import SwiftyJSON

class InstallationListModel {
    
    internal var userId : String!
    internal var userName : String!
    internal var planName : String!
    internal var date : String!
    internal var type : String!
    internal var confirmPlan : String!
    
    internal var areas : [JSON]!
    internal var areaName : String!
    internal var areaDate : String!
    
}
