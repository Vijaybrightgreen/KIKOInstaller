//
//  SearchViewController.swift
//  KikoInstaller
//
//  Created by Prabhakar Annavi on 1/25/17.
//  Copyright © 2017 Eoxys Systems. All rights reserved.
//

import UIKit
import Material

class SearchViewController: SearchBarController {
   

    var themeColor = ThemeColor()
    var customUtil = CustomUtil()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
     
        print("SEARCH viewDid Load")
    }
    
    fileprivate var menuButton: IconButton!
    //fileprivate var moreButton: IconButton!
    
    open override func prepare() {
        super.prepare()
        prepareMenuButton()
       // prepareMoreButton()
        prepareStatusBar()
        prepareSearchBar()
        
        statusBar.backgroundColor = customUtil.hexStringToUIColor(hex: themeColor.navigationBarBgColor)
        searchBar.backgroundColor = customUtil.hexStringToUIColor(hex: themeColor.navigationBarBgColor)
        searchBar.textField.dividerColor = themeColor.dividerNormalColor
    }
    
  
}

extension SearchViewController {
    fileprivate func prepareMenuButton() {
        menuButton = IconButton(image: Icon.cm.menu)
        
        menuButton.addTarget(self, action: #selector(self.backBtnAction), for: .touchUpInside)
    }
    
    
    func backBtnAction() {
        dismiss(animated: true, completion: nil)
    }
    
//    fileprivate func prepareMoreButton() {
//        moreButton = IconButton(image: Icon.cm.moreVertical)
//    }
    
    fileprivate func prepareStatusBar() {
        statusBarStyle = .default
        
        // Access the statusBar.
        //        statusBar.backgroundColor = Color.green.base
    }
    
    fileprivate func prepareSearchBar() {
        searchBar.leftViews = [menuButton]
        //searchBar.rightViews = [moreButton]
    }

    

}


