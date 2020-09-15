//
//  CompleteProjectViewController.swift
//  AnguloRicardoFinalProject
//
//  Created by Ricardo Angulo on 4/24/20.
//  Copyright © 2020 uscitp342. All rights reserved.
//email:angulor@usc.edu 

import UIKit
import Firebase

class CompleteProjectViewController: UIViewController {
    @IBOutlet weak var statusLabelOutlet: UILabel!
    @IBOutlet weak var segueButton: UIButton!
    @IBOutlet weak var progressBar: UIProgressView!
    
    var currentTask:Task!
    private var tasksModel = TasksService.shared
    
    var taskImagesURLs:[String]? = nil
    let storage = Storage.storage()
    var itemsToSave = 1 //keeps track of how many items need to be saved, default is 1(summary and date count as one )
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        progressBar.progress = 0.0 //start the progress bars progress at 0
        if let imagesURLs = taskImagesURLs, !imagesURLs.isEmpty{
            //if there are images uploaded, increase items to save counter and call upload images
            itemsToSave += imagesURLs.count
            uploadImages()
        }else{
            //if there are no images to save simply complete project without images
            completeProject(firebaseURLs: nil)
        }
    }
    
    func completeProject(firebaseURLs:[String]?){
        //get summary from defaults
        guard let projectSummary = UserDefaults.standard.string(forKey: "ProjectSummary") else {
            return
        }
        
        //get end date from defaults
        let actualEndDate = UserDefaults.standard.object(forKey: "actualEndDate") as? Date ?? Date()
        
        //call the tasks model to complete project with summary and end date
        tasksModel.completeProject(&currentTask, summary: projectSummary, completeDate: actualEndDate,imageURLs: firebaseURLs)
        deleteDefaultsAndTemp() //delete defaults and temp
        progressBar.progress = 1.0//put progress at complete
        enableButton(withText: NSLocalizedString("saved", comment: ""))//enable button and change label text to saved
    }
    
    func deleteDefaultsAndTemp(){
        //delete the defaults contents
        UserDefaults.standard.dictionaryRepresentation().keys.forEach { key in
            UserDefaults.standard.removeObject(forKey: key)
        }
        //delete all data in the temporary directory
        do {
            let tmpDirURL = FileManager.default.temporaryDirectory
            let tmpDirectory = try FileManager.default.contentsOfDirectory(atPath: tmpDirURL.path)
            try tmpDirectory.forEach { file in
                let fileUrl = tmpDirURL.appendingPathComponent(file)
                try FileManager.default.removeItem(atPath: fileUrl.path)
            }
        } catch {
            print("ERROR: could not delete data from temporary directory")
        }
    }
    
    func uploadImages(){
        var firebaseURLs = [String]() //stores the urls from fire base
        var imagesUploaded = 0 // the images that have been uploaded
        
        // unwrap the urls
        guard let taskImagesURLs =  taskImagesURLs else{
            return
        }
        let totalImages = taskImagesURLs.count //the total images to upload

        
        let storageRef = storage.reference() //create refernce to firebase storage

        for imageName in taskImagesURLs{ //for every image that user uploaed
            //get the full url stored in temporary directory
            let localFile =  URL(fileURLWithPath: imageName, relativeTo: FileManager.default.temporaryDirectory)

            //get the devices unique id
            let uniqueID = UIDevice.current.identifierForVendor?.uuidString
            
            //get the images's unique ud
            let imageID = UUID().uuidString
            
            //create unique id from device and image and store it as name
            let imageName = "\(uniqueID ?? "")_\(imageID)"
            
            //create reference to the image that will be uploaded
            let imgRef = storageRef.child(imageName)
            
            //create and upload task with the local file that user uploaed
            let uploadTask = imgRef.putFile(from: localFile, metadata: nil) { metadata, error in
                if let error = error{//if there is an error uploading display it
                    print("Firebase Error:\(error)")
                }
            }
            
            uploadTask.observe(.success) { snapshot in
                // if Upload completed successfully
                firebaseURLs.append(imageName) //add the image name to firebase url's array
                imagesUploaded += 1
                //update progress bar reflecting the total images uploaeded
                self.progressBar.progress = Float(imagesUploaded)/Float(self.itemsToSave)
                if imagesUploaded == totalImages {//if all images have been uploaded
                    //call the complete project with the firebase urls to pass to the tasks
                    self.completeProject(firebaseURLs: firebaseURLs)
                }
            }
            
            
            uploadTask.observe(.failure) { snapshot in
                //if uploading failts
                //try to display why it failed in console
                if let error = snapshot.error as NSError? {
                    switch (StorageErrorCode(rawValue: error.code)) {
                    case .objectNotFound:
                        print("FIREBASE ERROR: image does nnot exist")
                        break
                    case .unauthorized:
                        print("FIREBASE ERROR: permission denied")
                        break
                    case .cancelled:
                        print("FIREBASE ERROR: upload was cancelled")
                        break
                    case .unknown:
                        print("FIREBASE ERROR: unknown error")
                        break
                    default:
                        print("FIREBASE ERROR: unknown error")
                        break
                    }
                }
                DispatchQueue.main.async {
                    //tell the user the uploading image failed and let them try again
                    self.enableButton(withText: NSLocalizedString("not_saved", comment: ""))
                }
            }
        }
    }
    
    func enableButton(withText text:String) {
        //enables the button and updates the label's with the text passed in
        statusLabelOutlet.text = text
        segueButton.isEnabled = true
        segueButton.backgroundColor = UIColor.black
        segueButton.setTitleColor(.white, for: .normal)
    }
}
