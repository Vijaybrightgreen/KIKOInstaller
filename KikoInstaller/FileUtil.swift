//
//  FileUtil.swift
//  KikoInstaller
//
//  Created by Prabhakar Annavi on 3/7/17.
//  Copyright © 2017 Eoxys Systems. All rights reserved.
//

import Foundation
import SwiftyJSON

class FileUtil {
    
    let dirPaths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
    let fileManager = FileManager.default
    
    let OriginalfolderName = "/OriginalPlan"
    let TempFolderName = "/TempPlan"
    
    func isFileExist(path:String) -> Bool{
        return fileManager.fileExists(atPath: path)
    }
    
    func readFile(path:String) -> AnyObject {
        let docsDir = dirPaths[0]
        var unarchiveAlbums:AnyObject = NSData()
        
        print(docsDir+path)
        
        if fileManager.fileExists(atPath: docsDir+path) {
            
            let data = fileManager.contents(atPath: docsDir+path)
            unarchiveAlbums = NSKeyedUnarchiver.unarchiveObject(with: data!) as AnyObject
        }
        
        return unarchiveAlbums
    }
    
//    func createTempDirectory(dataForJson:AnyObject,path:String) -> String? {
//        
//        guard let tempDirURL = NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("myTempFile.xxx") else {
//            return nil
//        }
//        
////        do {
////            try FileManager.default.createDirectory(at: tempDirURL, withIntermediateDirectories: true, attributes: nil)
////        } catch {
////            return nil
////        }
//        
//        return tempDirURL.absoluteString
//    }
    
    func copyFile(atPath:String,toPath:String) {
        let docsDir = dirPaths[0]
                do {
                    try fileManager.copyItem(atPath: docsDir+atPath, toPath: docsDir+toPath)
                    print("Copy successful")
                } catch let error {
                    print("Error COPYING: \(error.localizedDescription)")
                }
        
        //        do {
        //            try fileManager.removeItem(atPath: docsDir+OriginalfolderName+"plan1.json")
        //            print("Removal successful")
        //        } catch let error {
        //            print("Error: \(error.localizedDescription)")
        //        }

    }
    
    func writeFileToTempFolder(dataForJson:AnyObject,path:String) throws {
        let docsDir = dirPaths[0]
        print("writeFile path to TEMP FOLDER ",docsDir+path)
        
        let filename = "/"+(path as NSString).lastPathComponent
        print("FILE NAME \(filename)")
        print("FILEEEE---->",fileManager.fileExists(atPath: docsDir+TempFolderName))
        
        // CHECK if TempPlan Folder Exists or create it
        if !fileManager.fileExists(atPath: docsDir+TempFolderName) {
            do{
                try fileManager.createDirectory(atPath: docsDir+TempFolderName, withIntermediateDirectories: false, attributes: nil)
                print("TEMPFOLDER DIR CREATED")
            }catch{
                print("dir create error ",error)
            }
        }else{
            print("TEMP PLAN DIRECTORY ALREADY EXIST")
        }
        
        //Create file in TempPlan folder
        if !fileManager.fileExists(atPath: docsDir+TempFolderName+filename) {
            let data = NSKeyedArchiver.archivedData(withRootObject: dataForJson)
            if (fileManager.createFile(atPath: docsDir+TempFolderName+filename, contents: data, attributes: nil) == true) {
                print("File Saved successfully in TEMP PLAN FOLDER")
            }else{
                print("ERROR WRITING FILE")
            }
        }else{
            print("FILE ALREADY EXISTS iN TEMP FOLDER")
            
        }
    }
    
    func overwriteFileToTempFolder(dataForJson:AnyObject,path:String) throws {
        let docsDir = dirPaths[0]
        print("overwriteFile path to TEMP FOLDER ",docsDir+path)
        
        let filename = "/"+(path as NSString).lastPathComponent
        print("FILE NAME \(filename)")
        print("FILEEEE---->",fileManager.fileExists(atPath: docsDir+TempFolderName))
        
        // CHECK if TempPlan Folder Exists or create it
        if !fileManager.fileExists(atPath: docsDir+TempFolderName) {
            do{
                try fileManager.createDirectory(atPath: docsDir+TempFolderName, withIntermediateDirectories: false, attributes: nil)
                print("TEMPFOLDER DIR CREATED")
            }catch{
                print("dir create error ",error)
            }
        }else{
            print("TEMP PLAN DIRECTORY ALREADY EXIST")
        }
        
        //Create file in TempPlan folder
        if !fileManager.fileExists(atPath: docsDir+TempFolderName+filename) {
            let data = NSKeyedArchiver.archivedData(withRootObject: dataForJson)
            if (fileManager.createFile(atPath: docsDir+TempFolderName+filename, contents: data, attributes: nil) == true) {
                print("overwriteFile Saved successfully in TEMP PLAN FOLDER")
            }else{
                print("ERROR overwriteFile FILE")
            }
        }else{
            let data = NSKeyedArchiver.archivedData(withRootObject: dataForJson)
            print("File ALREADY EXISTS iN TEMP FOLDER")
            //REMOVE EXISTING FILE
            do{
               try fileManager.removeItem(atPath: docsDir+TempFolderName+filename)
                print("EXISTING FILE REMOVED FROM TEMP FOLDER")
            }catch {
                print("overwriteFile ERROR EXISTING FILE REMOVED FROM TEMP FOLDER  \(error)")
            }
            
            //OVERWRITE NEW FILE
            if (fileManager.createFile(atPath: docsDir+TempFolderName+filename, contents: data, attributes: nil) == true) {
                print("OVERWRITE File Saved successfully in TEMP PLAN FOLDER")
            }else{
                print("ERROR OVERWRITE FILE")
            }
        }
        
        //Listing the Contents of a Directory
        do {
            let filelist = try fileManager.contentsOfDirectory(atPath: docsDir+"/TempPlan")
            
            for filename in filelist {
                print("FIIIIIIIILE TEMP FOLDER CONTENT",filename)
            }
        } catch let error {
            print("Error: \(error.localizedDescription)")
        }
        
    }
    
    func writeFileToOriginalFolder(dataForJson:AnyObject,path:String) throws {
        
        let docsDir = dirPaths[0]
        print("writeFile path to ORIGINAL FOLDER ",docsDir+path)
        
        let filename = "/"+(path as NSString).lastPathComponent
        print("FILE NAME \(filename)")
        
        //var isDir : ObjCBool = false
        
        print(docsDir+OriginalfolderName)
        
        
        
        // CHECK if OriginalPlan Folder Exists or create it
        if !fileManager.fileExists(atPath: docsDir+OriginalfolderName) {
            
            do{
                try fileManager.createDirectory(atPath: docsDir+OriginalfolderName, withIntermediateDirectories: false, attributes: nil)
                print("ORIGINALFOLDER DIR CREATED")
            }catch{
                print("dir OriginalPLAN create error ",error)
            }
            
        }else{
            print("ORIGINAL PLAN DIRECTORY ALREADY EXIST")
        }
        
        print("PPPPPATH \(docsDir+OriginalfolderName+filename)")
        
        //Create file in OriginalPlan folder
        if !fileManager.fileExists(atPath: docsDir+OriginalfolderName+filename) {
            let data = NSKeyedArchiver.archivedData(withRootObject: dataForJson)
            if (fileManager.createFile(atPath: docsDir+OriginalfolderName+filename, contents: data, attributes: nil) == true) {
                print("File Saved successfully in ORIGINAL PLAN FOLDER")
            }else{
                print("ERROR WRITING FILE")
            }
        }else{
            print("FILE ALREADY EXISTS IN ORIGINAL FOLDER")
        }
        
        
        //Listing the Contents of a Directory
        do {
            let filelist = try fileManager.contentsOfDirectory(atPath: docsDir+"/OriginalPlan")
            
            for filename in filelist {
                print("FIIIIIIIILE ORIGINAL FOLDER CONTENT",filename)
            }
        } catch let error {
            print("Error: \(error.localizedDescription)")
        }
        
    }
    
    
    
    
    func filesAtDoc(){
        let docsDir = dirPaths[0]
        print("DOC DIR \(docsDir)")
        do{
            print("FILES AT DOC DIR",try fileManager.contentsOfDirectory(atPath: docsDir))
            
        }catch{
            print("Error filesAtDoc")
        }
        
    }
    
    func contFile(path:String){
        let docsDir = dirPaths[0]
        print("FILE CONTENT IN DOCUMENT DIRECTORY",fileManager.contents(atPath: docsDir+path)!)
        
    }
    
    func deleteAtPath(path:String) -> Bool{
        let docsDir = dirPaths[0]
        do{
            try fileManager.removeItem(atPath: docsDir+path)
            return true
        }catch{
            return false
        }
    }
    
}
