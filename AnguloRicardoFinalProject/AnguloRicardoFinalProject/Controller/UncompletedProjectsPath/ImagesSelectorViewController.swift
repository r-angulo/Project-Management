//
//  ImagesSelectorViewController.swift
//  AnguloRicardoFinalProject
//
//  Created by Ricardo Angulo on 4/21/20.
//  Copyright © 2020 uscitp342. All rights reserved.
//email:angulor@usc.edu 

import UIKit
import Firebase

class ImagesSelectorViewController: UIViewController,UINavigationControllerDelegate,UIImagePickerControllerDelegate,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    @IBOutlet weak var numberOfImagesOutlet: UILabel!
    @IBOutlet weak var imagesCV: UICollectionView!
    @IBOutlet weak var addImage: UIButton!
    
    var currentTask:Task! //current task
    var selectedImages:[String] = [String]() //stores the images the user selected
    let MAXIMAGESALLOWED = 5 //constant for max allowed images
    var imagesSizes:[(width: CGFloat, height: CGFloat)] = []//to be used for dynamic cell
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //setup delegate and datasource as self for image collection view
        imagesCV.delegate = self
        imagesCV.dataSource = self
        
        //display how many images the user can upload
        numberOfImagesOutlet.text = "0 of \(MAXIMAGESALLOWED) \(NSLocalizedString("images", comment: ""))"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //if there are image urls in the user defaults, load them into current selected images
        if (UserDefaults.standard.array(forKey: "imagesArray")) != nil{
            selectedImages = UserDefaults.standard.array(forKey: "imagesArray") as? [String] ?? [""]
        }
        //display how many images the user can upload
        numberOfImagesOutlet.text =  "\(self.selectedImages.count) of \(self.MAXIMAGESALLOWED) \(NSLocalizedString("images", comment: ""))"
        imagesCV.reloadData()
    }
    
    func enableDisableAddButton(){
        //if there are more than max images allowd, disable add button else dont and show it
        if selectedImages.count >= MAXIMAGESALLOWED {
            addImage.isEnabled = false
            addImage.alpha = 0.5
        }else{
            addImage.isEnabled = true
            addImage.alpha = 1.0
        }
    }
    
    @IBAction func addImageClicked(_ sender: UIButton) {
        let imagePicker = UIImagePickerController()// create instance of UIImagePickerController
        
        // set properties of image picker
        imagePicker.delegate = self
        imagePicker.allowsEditing = false
        imagePicker.mediaTypes = ["public.image"]
        imagePicker.sourceType = .photoLibrary
        
        // present imagePicker
        present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        //if the user dismissed the image picker
        picker.dismiss(animated: true) //animate the dismissal
        
        //then get the image url
        guard let imageURL = info[.imageURL] as? URL else{
            return
        }
        
        //then get the image url
        guard let image = info[.originalImage] as? UIImage else{
            return
        }
        
        //add this image's size to the image array
        imagesSizes.append((image.size.width,image.size.height))
        
        //add the image urls path to the global array
        selectedImages.append(imageURL.lastPathComponent)
        
        //update the images array with the new images url in the user defaults
        UserDefaults.standard.set(selectedImages, forKey: "imagesArray")
        enableDisableAddButton()//enable or disable the add button
        
        //update the display telling the user how many images they have uploaded
        self.numberOfImagesOutlet.text = "\(self.selectedImages.count) of \(self.MAXIMAGESALLOWED) \(NSLocalizedString("images", comment: ""))"
        
        imagesCV.reloadData()
    }
    
    func imagePickerControllerDidCancel(_ picker:
        UIImagePickerController) {
        picker.dismiss(animated: true)//dismiss the picker view
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return selectedImages.count //return as many cells as there are images urls
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        //create a cell
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "imageContainerCell", for: indexPath) as! ImageContainerCollectionViewCell
        cell.deleteImageBtnOutlet.tag = indexPath.row //create a tag for this image
        
        //create action for when deleted
        cell.deleteImageBtnOutlet.addTarget(self, action: #selector(deleteImage(sender:)), for: UIControl.Event.touchUpInside)
        
        //get the full image url from the temporary directory
        let imageURL = URL(fileURLWithPath: selectedImages[indexPath.row], relativeTo: FileManager.default.temporaryDirectory)
        
        //get the image date from the url
        do {
            let imageData: Data = try Data(contentsOf: imageURL)//image has to exists since it was just uploaded
            cell.imageViewOutlet.image = UIImage(data: imageData) //set the image cell with the data from url

            return cell
        } catch {
            print("ERROR: could not delete data from temporary directory")
            cell.imageViewOutlet.image = UIImage(named: "imagePlaceholder.jpg") //set the image cell with the data from url
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        //return a dynamic size cell for image
        let photoHeight = imagesSizes[indexPath.row].height
        let photoWidth = imagesSizes[indexPath.row].width

        let width = collectionView.frame.width
        let height = CGFloat(photoHeight) * width / CGFloat(photoWidth)
        return CGSize(width: width, height: height)
    }
    
    @objc func deleteImage(sender:UIButton) {
        //create alert when user delete images
        //add actions cancel and delete
        let alertController = UIAlertController(title: NSLocalizedString("Delete_Image", comment: ""), message: NSLocalizedString("Check_delete_image", comment: ""), preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: NSLocalizedString("Cancel", comment: ""), style: .cancel, handler: nil)
        
        let deleteAction = UIAlertAction(title: NSLocalizedString("Delete", comment: ""), style: .destructive) { (UIAlertAction) in
            //if delete is selected ,remove the image that was clicked
            //remove from the images array and the view cell and update counter label
            let i = sender.tag
            self.selectedImages.remove(at: i)
            UserDefaults.standard.set(self.selectedImages, forKey: "imagesArray")
            self.numberOfImagesOutlet.text = "\(self.selectedImages.count) of \(self.MAXIMAGESALLOWED) \(NSLocalizedString("images", comment: ""))"
            self.enableDisableAddButton()
            self.imagesCV.reloadData()
            
        }
        //add this action to the alert controller
        alertController.addAction(cancelAction)
        alertController.addAction(deleteAction)
        self.present(alertController,animated: true,completion: nil) //present this view controller
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //if next is clicked, pass the current task and the images uploaded from user
        if segue.identifier == "completeSegue" {
            let nextVC = segue.destination as? CompleteProjectViewController
            nextVC?.currentTask = self.currentTask
            nextVC?.taskImagesURLs = self.selectedImages
        }
    }
}
