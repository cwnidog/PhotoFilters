//
//  ViewController.swift
//  PhotoFilters
//
//  Created by John Leonard on 1/12/15.
//  Copyright (c) 2015 John Leonard. All rights reserved.
//

import UIKit
import Social

class ViewController: UIViewController, ImageSelectedProtocol, UICollectionViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UICollectionViewDelegate {
  
  let alertController = UIAlertController(title: NSLocalizedString("Photo Filtering", comment: "This is the title for our Alert Controller"), message: NSLocalizedString("Funkify Your Photos", comment: "This is the message for our alert controller"), preferredStyle: UIAlertControllerStyle.ActionSheet)
  
  // image and collection view properties
  let mainImageView = UIImageView()
  var baseMainImage : UIImage! // holds image selected from Gallery before filters applied. This avoids filter build-up

  var mainImageViewButtonConstraint : NSLayoutConstraint!
  
  var collectionView: UICollectionView!
  var collectionViewYConstraint: NSLayoutConstraint!
  
  var originalThumbnail: UIImage!
  var filterNames = [String]()
  
  let imageQueue = NSOperationQueue()
  var gpuContext: CIContext!
  var thumbnails = [Thumbnail]()
  var filterOption : UIAlertAction!
  var filteredMainImage : UIImage! // holds a filtered version of the main image
  
  var doneButton : UIBarButtonItem!
  var shareButton : UIBarButtonItem!
  
  var delegate: ImageSelectedProtocol? // will accept anything that conforms to this protocol
  
  override func loadView() {
    
    let rootView = UIView(frame: UIScreen.mainScreen().bounds)
    rootView.backgroundColor = UIColor.whiteColor()
    rootView.addSubview(self.mainImageView)
    
    self.mainImageView.setTranslatesAutoresizingMaskIntoConstraints(false)
    self.mainImageView.backgroundColor = UIColor.lightGrayColor()
    
    // set up the Photo button
    let photoButton = UIButton()
    photoButton.setTranslatesAutoresizingMaskIntoConstraints(false)
    photoButton.setTitle(
      NSLocalizedString("PhotosButton", comment: "This is the title for our photos button"), forState: .Normal)
    photoButton.setTitleColor(UIColor.blackColor(), forState: .Normal)
    rootView.addSubview(photoButton)
    photoButton.addTarget(self, action: "photoButtonPressed:", forControlEvents: UIControlEvents.TouchUpInside)
    
    // set up the collection view to hold the filtered images
    let collectionViewFlowLayout = UICollectionViewFlowLayout()
    self.collectionView = UICollectionView(frame: CGRectZero, collectionViewLayout: collectionViewFlowLayout)
    collectionViewFlowLayout.itemSize = CGSize(width: 100, height: 100)
    collectionViewFlowLayout.scrollDirection = .Horizontal
    collectionView.setTranslatesAutoresizingMaskIntoConstraints(false)
    collectionView.dataSource = self
    collectionView.delegate = self
    collectionView.registerClass(GalleryCell.self, forCellWithReuseIdentifier: "FILTER_CELL")
    rootView.addSubview(collectionView)
    
    // set up the views dictionary for VFL
    let views = ["photoButton" : photoButton, "mainImageView" : self.mainImageView, "collectionView" : collectionView]
    
    // setup constraints
    self.setupConstraintsOnRootView(rootView, forViews: views)
    
    self.view = rootView
  } // loadView()

  override func viewDidLoad() {
    super.viewDidLoad()
    
    // want to use an action sheet to allow the user to select images from the gallery or to apply filters to the
    // selected image
    
    // define the done and share buttons. Add the share button to the nav bar
    self.doneButton =  UIBarButtonItem(title: NSLocalizedString("DoneBarButton",  comment: "The name of our done bar button"), style: UIBarButtonItemStyle.Done, target: self, action: "donePressed")
    self.shareButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Action, target: self, action: "sharePressed")
    self.navigationItem.rightBarButtonItem = self.shareButton
    
    // view the image gallery
    let galleryOption = UIAlertAction( title: NSLocalizedString("GalleryOption", comment: "This is the name of our Gallery action"), style: UIAlertActionStyle.Default) { (action) -> Void in
      println("Gallery pressed")
      let galleryVC = GalleryViewController()
      galleryVC.delegate = self // this sets us up as the galleryVC delegate
      self.navigationController?.pushViewController(galleryVC, animated: true)
    } // galleryOption closure
    self.alertController.addAction(galleryOption)
    
    // apply the filters to the selected image
    self.filterOption = UIAlertAction(title: NSLocalizedString("Filter Option", comment: "The name of our filtering option"), style: UIAlertActionStyle.Default) { (action) -> Void in
      self.collectionViewYConstraint.constant = 20
      self.mainImageViewButtonConstraint.constant = 70
      UIView.animateWithDuration(0.4, animations: { () -> Void in
        self.view.layoutIfNeeded()
      })
      
      //add the done button to the Filter nav bar
      self.navigationItem.rightBarButtonItem = self.doneButton
      
    } // filterOption closure
    self.alertController.addAction(filterOption)
    self.filterOption.enabled = true
    
    // add an option to use the camera - assuming there is one
    if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera){
      let cameraOption = UIAlertAction(title:
       NSLocalizedString("CameraOption", comment: "The name of our option to get the photo from the camera"), style: .Default, handler: { (action) -> Void in
        
        let imagePickerController = UIImagePickerController()
        imagePickerController.sourceType = UIImagePickerControllerSourceType.Camera
        imagePickerController.allowsEditing = true
        imagePickerController.delegate = self
        self.presentViewController(imagePickerController, animated: true, completion: nil)
      })// closure
      self.alertController.addAction(cameraOption)
    } // camera available
    
      // add option to go to stored photos
      let photoOption = UIAlertAction(title: NSLocalizedString("Photos", comment: "The name of our option to use stored photos"), style: .Default) { (action) -> Void in
        let photosVC = PhotosViewController()
        photosVC.destinationImageSize = self.mainImageView.frame.size
        photosVC.delegate = self
        self.navigationController?.pushViewController(photosVC, animated: true)
      } // closure
      self.alertController.addAction(photoOption)
      
    // set up needed items to use the device's GPU
    let options = [kCIContextWorkingColorSpace: NSNull()] // keep things quick by limiting image resolution and size
    let eaglContext = EAGLContext(API: EAGLRenderingAPI.OpenGLES2)
    self.gpuContext = CIContext(EAGLContext: eaglContext, options: options)
    self.setupThumbnails()
  } // viewDidLoad()
  
  func setupThumbnails() {
    // the list of filters to apply
    self.filterNames = ["CISepiaTone", "CIPhotoEffectChrome", "CIPhotoEffectNoir", "CIColorInvert", "CIPhotoEffectFade", "CIPhotoEffectMono"]
    
    // apply each of the filters
    for name in self.filterNames {
      let thumbnail = Thumbnail(filterName: name, operationQueue: self.imageQueue, context: self.gpuContext)
      self.thumbnails.append(thumbnail) // add the filtered image to the set of thumbnails
    } // for name
  } // setupThumbnails()
  
  //MARK: ImageSelectedDelegate
  
  //Instantiates the galleryVC delegate things when the user selects an image from the gallery
  func controllerDidSelectImage(selectedImage: UIImage) {
    println("Image selected")
    self.mainImageView.image = selectedImage // display the image on the main screen
    self.baseMainImage = selectedImage // save it away for re-use
    self.generateThumbnail(selectedImage) // generate the filtered thumbnails
    
    // keep a copy of the original image for each of the filters
    for thumbnail in self.thumbnails {
      thumbnail.originalImage = self.originalThumbnail
      thumbnail.filteredImage = nil // we don't have a filtered image yet
    } // for thumbnail
    self.collectionView.reloadData()
  } // controllerDidSelectImage()
  
  // MARK: UIImagePickerController
  func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
    let image = info[UIImagePickerControllerEditedImage] as? UIImage
    self.controllerDidSelectImage(image!)
    picker.dismissViewControllerAnimated(true, completion: nil)
  } // imagePickerController()
  
  func imagePickerControllerDidCancel(picker: UIImagePickerController) {
    picker.dismissViewControllerAnimated(true, completion: nil)
  } // imagePickerControllerDidCancel()
  
  // MARK: Button Selectors
  
  func photoButtonPressed(sender: UIButton) {
    self.presentViewController(self.alertController, animated: true, completion: nil)
  } // photoButtonPressed()
  
  // generate the filtered thumbnails from the original image and display them in the collection view
  func generateThumbnail(originalImage: UIImage) {
    let size = CGSize(width: 100, height: 100)
    UIGraphicsBeginImageContext(size) // begin our image context
    originalImage.drawInRect(CGRect(x: 0, y: 0, width: 100, height: 100))
    self.originalThumbnail = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext() // end our image context
  } // generateThumbnail()
  
  func donePressed() {
    // put the collectionView back out of sight and let the main image stretch back out to the original size
    self.collectionViewYConstraint.constant = -120
    self.mainImageViewButtonConstraint.constant  = 30
    UIView.animateWithDuration(0.4, animations: { () -> Void in
      self.view.layoutIfNeeded()
    }) // closure
    self.navigationItem.rightBarButtonItem = self.shareButton
  } // donePressed
  
  func sharePressed() {
    if SLComposeViewController.isAvailableForServiceType(SLServiceTypeTwitter){
      let compViewController = SLComposeViewController(forServiceType: SLServiceTypeTwitter)
      compViewController.addImage(self.mainImageView.image)
      self.presentViewController(compViewController, animated: true, completion: nil)
    } // Twitter available
    
    else {
      // tell user to turn on twitter
    } // else
  } // sharePressed()
  
  // MARK: UICollectionViewDataSource
  func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return self.thumbnails.count
  } // collectionView(numberOfItemsInSection)
  
  func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCellWithReuseIdentifier("FILTER_CELL", forIndexPath: indexPath) as GalleryCell
    let thumbnail = self.thumbnails[indexPath.row]
    
    if thumbnail.originalImage != nil { // have an image to process
      if thumbnail.filteredImage == nil { // need to generate the filtered image
        thumbnail.generateFilteredImage()
        cell.imageView.image = thumbnail.filteredImage!
        
      } // filteredImage == nil
    } // originalImage != nil
    
    return cell
  } // collectionView(cellForItemAtIndexPath)
  
  // does just what its name suggests
  func generateFilteredImage(filterIndex: Int) {
    
    let startImage = CIImage(image: baseMainImage)
    let filter = CIFilter(name: self.filterNames[filterIndex])
    
    // use default values for any keys that the filter may need
    filter.setDefaults()
    filter.setValue(startImage, forKey: kCIInputImageKey)
    
    // apply the filters and get the filtered image
    let result = filter.valueForKey(kCIOutputImageKey) as CIImage
    let extent = result.extent()
    let imageRef = self.gpuContext.createCGImage(result, fromRect: extent)
    self.filteredMainImage = UIImage(CGImage: imageRef)
  } // generateFilteredImage()
  
  //MARK: UICollectionViewDelegate
  func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    // generate a filtered version of the mainImage, using the selected filter
    generateFilteredImage(indexPath.row)
    self.mainImageView.image = self.filteredMainImage
  } // collectionView delegate
  
  // MARK: Autolayout Constraints
  func setupConstraintsOnRootView(rootView: UIView, forViews views: [String : AnyObject])
  {
    // photo button constraints
    let photoButtonConstraintVertical = NSLayoutConstraint.constraintsWithVisualFormat("V:[photoButton]-20-|", options: nil, metrics: nil, views: views)
    rootView.addConstraints(photoButtonConstraintVertical)
    let photoButton = views["photoButton"] as UIView!
    
    let photoButtonConstraintHorizontal = NSLayoutConstraint(item: photoButton, attribute: .CenterX, relatedBy: NSLayoutRelation.Equal, toItem: rootView, attribute: NSLayoutAttribute.CenterX, multiplier: 1.0, constant: 0.0)
    rootView.addConstraint(photoButtonConstraintHorizontal)
    
    // mainImageViewConstraints
    let mainImageViewConstraintHorizontal = NSLayoutConstraint.constraintsWithVisualFormat("H:|-[mainImageView]-|", options: nil, metrics: nil, views: views)
    rootView.addConstraints(mainImageViewConstraintHorizontal)
    
    let mainImageViewConstraintVertical = NSLayoutConstraint.constraintsWithVisualFormat("V:|-72-[mainImageView]-30-[photoButton]", options: nil, metrics: nil, views: views)
    rootView.addConstraints(mainImageViewConstraintVertical)
    var testConstraint = NSLayoutConstraint()
    self.mainImageViewButtonConstraint = mainImageViewConstraintVertical[1] as NSLayoutConstraint
    
    
    // collectionView
    let collectionViewConstraintsHorizontal = NSLayoutConstraint.constraintsWithVisualFormat("H:|[collectionView]|", options: nil, metrics: nil, views: views)
    rootView.addConstraints(collectionViewConstraintsHorizontal)
    
    let collectionViewConstraintHeight = NSLayoutConstraint.constraintsWithVisualFormat("V:[collectionView(100)]", options: nil, metrics: nil, views: views)
    self.collectionView.addConstraints(collectionViewConstraintHeight)
    
    let collectionViewConstraintsVertical = NSLayoutConstraint.constraintsWithVisualFormat("V:[collectionView]-(-120)-|", options: nil, metrics: nil, views: views)
    rootView.addConstraints(collectionViewConstraintsVertical)
    
    self.collectionViewYConstraint = collectionViewConstraintsVertical.first as NSLayoutConstraint
    
  } // setupConstraintsOnRootView()

} // ViewController

