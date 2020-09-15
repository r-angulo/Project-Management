//
//  FinishedProjectViewController.swift
//  AnguloRicardoFinalProject
//
//  Created by Ricardo Angulo on 5/3/20.
//  Copyright © 2020 uscitp342. All rights reserved.
//email:angulor@usc.edu 

import UIKit
import Firebase
import FirebaseUI

class FinishedProjectViewController: UIViewController, UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout{
    //TODO: add real plahceholder image 2x 3x
    @IBOutlet weak var taskTitle: UINavigationItem!
    @IBOutlet weak var projectSummaryTVOutlet: UITextView!
    @IBOutlet weak var completedImagesCollectionOutlet: UICollectionView!
    @IBOutlet weak var estimatedDurationLabel: UILabel!
    @IBOutlet weak var actualDurationLabel: UILabel!
    
    var currentTask:Task!
    let storage = Storage.storage() //storage location from firebase
    var defaultImageWidth:CGFloat = 200
    var defaultImageHeight:CGFloat = 200
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let photo = UIImage(named: "imagePlaceholder.jpg")
        defaultImageWidth = photo?.size.width ?? 200
        defaultImageHeight = photo?.size.height ?? 200
        //set the delegate and datasource of collection view
        completedImagesCollectionOutlet.delegate = self
        completedImagesCollectionOutlet.dataSource = self
        
        taskTitle.title = currentTask.projectName //set the title to the name of the project
        projectSummaryTVOutlet.text = currentTask.summary //set the sumary to that of the task
        setupTimeAnalysis()//call this func
        
    }
    
    func setupTimeAnalysis(){
        //rounding the dates to the nearest 0 because the datepicker sometimes adds seconds
        //this will ensure we are basing difference off minutes and hours only
        let roundedStartDate = Date(timeIntervalSinceReferenceDate: floor(currentTask.startDate.timeIntervalSinceReferenceDate / 60) * 60)
        let roundedEstimatedEndDate = Date(timeIntervalSinceReferenceDate: floor(currentTask.estimatedEndDate.timeIntervalSinceReferenceDate / 60) * 60)
        let roundedActualEndDate = Date(timeIntervalSinceReferenceDate: floor(currentTask.actualEndDate.timeIntervalSinceReferenceDate / 60) * 60)

        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .full
        formatter.allowedUnits = [.hour, .minute]
        formatter.maximumUnitCount = 2
        
        //calcualte and display how long the task was planned to last and set label text
        if let estimatedDuration = formatter.string(from: roundedStartDate , to: roundedEstimatedEndDate){
            estimatedDurationLabel.text = estimatedDuration
        }
        
        //calcualte and display how long the task actually tookand set label text
        if let actualDuration = formatter.string(from: roundedStartDate, to: roundedActualEndDate){
            actualDurationLabel.text = actualDuration
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //if the tasks has images uploaded to firebase, return how many were uploaded,
        //else return 0
        if let imageURLs = currentTask.firIDs,!imageURLs.isEmpty{
            return imageURLs.count
        }else{
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let currIndex = indexPath.row //get the current index from path
        //create instance of collection view cell
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageCell", for: indexPath) as! FireBaseImageCollectionViewCell
        
        //get a reference to the image stored in firebase
        let storageRef = storage.reference()

        //get the image reference
        let reference = storageRef.child(currentTask.firIDs?[currIndex] ?? "")
        
        // UIImageView in cell
        let imageView: UIImageView = cell.imageOutlet

        // set its image to placeholder image while real image comes back
        let placeholderImage = UIImage(named: "imagePlaceholder.jpg")

        // Load the image using SDWebImage on its returned from internet and downloads
        imageView.sd_setImage(with: reference, placeholderImage: placeholderImage)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        //return a dynamic size for the image
        let height = CGFloat(defaultImageHeight) * collectionView.frame.width / CGFloat(defaultImageWidth)
        return CGSize(width: collectionView.frame.width , height: height)
    }
}
