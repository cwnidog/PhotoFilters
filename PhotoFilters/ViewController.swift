//
//  ViewController.swift
//  PhotoFilters
//
//  Created by John Leonard on 1/12/15.
//  Copyright (c) 2015 John Leonard. All rights reserved.
//

import UIKit

class ViewController: UIViewController, ImageSelectedProtocol, UICollectionViewDataSource {
  
  let alertController = UIAlertController(title: "Photos", message: "Pick one  to filter", preferredStyle: UIAlertControllerStyle.ActionSheet)
  
  // image and collection view properties
  let mainImageView = UIImageView()
  var collectionView: UICollectionView!
  var collectionViewYConstaraint: NSLayoutConstraint!
  var originalThumbnail: UIImage!
  var filterNames = [String]()
  let imageQueue = NSOperationQueue()
  var gpuContext: CIContext!
  var thumbnails = [Thumbnail]()
  
  override func loadView() {
    
    let rootView = UIView(frame: UIScreen.mainScreen().bounds)
    rootView.backgroundColor = UIColor.whiteColor()
    rootView.addSubview(self.mainImageView)
    
    self.mainImageView.setTranslatesAutoresizingMaskIntoConstraints(false)
    self.mainImageView.backgroundColor = UIColor.lightGrayColor()
    
    // set up the Photo button
    let photoButton = UIButton()
    photoButton.setTranslatesAutoresizingMaskIntoConstraints(false)
    photoButton.setTitle("Photos", forState: .Normal)
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
    
    // view the image gallery
    let galleryOption = UIAlertAction(title: "Gallery", style: UIAlertActionStyle.Default) { (action) -> Void in
      println("Gallery pressed")
      let galleryVC = GalleryViewController()
      galleryVC.delegate = self
      self.navigationController?.pushViewController(galleryVC, animated: true)
    } // galleryOption closure
    self.alertController.addAction(galleryOption)
    
    // apply the filters to the selected image
    let filterOption = UIAlertAction(title: "Filter", style: UIAlertActionStyle.Default) { (action) -> Void in
      self.collectionViewYConstaraint.constant = 20
      UIView.animateWithDuration(0.4, animations: { () -> Void in
        self.view.layoutIfNeeded()
      })
    } // filterOption closure
    self.alertController.addAction(filterOption)
    
    // set up needed items to use the device's GPU
    let options = [kCIContextWorkingColorSpace: NSNull()] // keep things quick by limiting image resolution and size
    let eaglContext = EAGLContext(API: EAGLRenderingAPI.OpenGLES2)
    self.gpuContext = CIContext(EAGLContext: eaglContext, options: options)
    self.setupThumbnails()
  } // viewDidLoad()
  
  func setupThumbnails() {
    self.filterNames = ["CISepiaTone", "CIPhotoEffectChrome", "CIPhotoEffectNoir", "CIColorInvert", "CIPhotoEffectFade", "CIPhotoEffectMono"]
    for name in self.filterNames {
      let thumbnail = Thumbnail(filterName: name, operationQueue: self.imageQueue, context: self.gpuContext)
      self.thumbnails.append(thumbnail)
    } // for name
  } // setupThumbnails()
  
  //MARK: ImageSelectedDelegate
  
  //Handles things when the user selects an image from the gallery
  func controllerDidSelectImage(image: UIImage) {
    println("Image selected")
    self.mainImageView.image = image // display the image on the main screen
    self.generateThumbnail(image) // generate the filtered thumbnails
    
    for thumbnail in self.thumbnails {
      thumbnail.originalImage = self.originalThumbnail
    } // for thumbnail
    self.collectionView.reloadData()
  } // controllerDidSelectImage()

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
    
    // collectionView
    let collectionViewConstraintsHorizontal = NSLayoutConstraint.constraintsWithVisualFormat("H:|[collectionView]|", options: nil, metrics: nil, views: views)
    rootView.addConstraints(collectionViewConstraintsHorizontal)
    
    let collectionViewConstraintHeight = NSLayoutConstraint.constraintsWithVisualFormat("V:[collectionView(100)]", options: nil, metrics: nil, views: views)
    self.collectionView.addConstraints(collectionViewConstraintHeight)
    
    let collectionViewConstraintsVertical = NSLayoutConstraint.constraintsWithVisualFormat("V:[collectionView]-(-120)-|", options: nil, metrics: nil, views: views)
    rootView.addConstraints(collectionViewConstraintsVertical)
    
    self.collectionViewYConstaraint = collectionViewConstraintsVertical.first as NSLayoutConstraint
    
  } // setupConstraintsOnRootView()

} // ViewController

