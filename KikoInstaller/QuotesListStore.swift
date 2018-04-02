//
//  QuotesListStore.swift
//  KikoInstaller
//
//  Created by Prabhakar Annavi on 2/9/17.
//  Copyright © 2017 Eoxys Systems. All rights reserved.
//

import Foundation

class QuotesListStore:NSData {
    
    var quotesListArr = [QuotesListModel]()
    
    func add(list:QuotesListModel) {
        quotesListArr.append(list)
    }
    
    func add(planName: String){
        let quotesList = QuotesListModel()
        
        quotesList.planName = planName
        
        quotesListArr.append(quotesList)
    }
    
    func getAll() -> [QuotesListModel]{
        return quotesListArr
    }
    
}
