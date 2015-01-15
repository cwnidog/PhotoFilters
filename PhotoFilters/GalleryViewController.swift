//
//  GalleryViewController.swift
//  PhotoFilters
//
//  Created by John Leonard on 1/12/15.
//  Copyright (c) 2015 John Leonard. All rights reserved.
//

import UIKit

protocol ImageSelectedProtocol {
  func controllerDidSelectImage(selectedImage: UIImage) -> Void
} // ImageSelectedProtocol

class GalleryViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
  
  var collectionView : UICollectionView!
  var images = [UIImage]()
  var delegate: ImageSelectedProtocol? // will accept anything that conforms to this protocol
  
  override func loadView() {
    var delegate: ImageSelectedProtocol? // will accept anything that conforms to this protocol
    //set up the view to use the full screen and FlowLayout
    let rootView = UIView(frame: UIScreen.mainScreen().bounds)
    let collectionViewFlowLayout = UICollectionViewFlowLayout()
    
    // create the collection view to display the photos
    self.collectionView = UICollectionView(frame: rootView.frame, collectionViewLayout: collectionViewFlowLayout)
    
    // turn off the collection views setTranslatesAutoresizingMaskIntoConstraints
    self.collectionView.setTranslatesAutoresizingMaskIntoConstraints(false)
    
    // add the collectionView as a subview, we're our own data source and delegate
    rootView.addSubview(self.collectionView)
    self.collectionView.dataSource = self
    self.collectionView.delegate = self
    
    // set the collection view minimum cell size
    collectionViewFlowLayout.itemSize = CGSize(width: 200, height: 200)
    // set up a dictionary of views so we can set constraints with VFL
    let galleryViews = ["collectionView" : collectionView]
    
    // define the constraints
    self.setupConstraintsOnRootView(rootView, forViews: galleryViews )
        
    self.view = rootView
    
  } // loadView()

    override func viewDidLoad() {
        super.viewDidLoad()
      
      self.view.backgroundColor = UIColor.whiteColor()
      
       // register the gallery cell
      self.collectionView.registerClass(GalleryCell.self, forCellWithReuseIdentifier: "GALLERY_CELL")
      
      // load images - for now directly 
      let brooklynBridge = UIImage(named: "brooklynBridge.jpg")
      let desk = UIImage(named: "desk.jpg")
      let dune = UIImage(named: "dune.jpg")
      let fog = UIImage(named: "fog.jpg")
      let oldCab = UIImage(named: "oldCab.jpg")
      let parkBench = UIImage(named: "parkBench.jpg")
      
      // append the images to the images array
      self.images.append(brooklynBridge!)
      self.images.append(desk!)
      self.images.append(dune!)
      self.images.append(fog!)
      self.images.append(oldCab!)
      self.images.append(parkBench!)
    } // viewDidLoad()
  
  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    self.navigationController?.setNavigationBarHidden(false, animated: false)
  }
  
  // MARK: UICollectionViewDataSource
  
  // find out how many images there are in the collection
  func collectionView(collectionView: UICollectionView, numberOfItemsInSection: Int) -> Int {
    return self.images.count
  } // collectionView(numberOfItemsInSection)
  
  // put an image in the collection view cell
  func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCellWithReuseIdentifier("GALLERY_CELL", forIndexPath: indexPath) as GalleryCell
    let image = self.images[indexPath.row]
    cell.imageView.image = image
    return cell
  }
  
  // MARK: Gallery Autolayout Constraints
  func setupConstraintsOnRootView(rootView: UIView, forViews galleryViews: [String : AnyObject]) {
    
    let collectionViewConstraintVertical = NSLayoutConstraint.constraintsWithVisualFormat("V:|-70-[collectionView]-30-|", options: nil, metrics: nil, views: galleryViews)
    rootView.addConstraints(collectionViewConstraintVertical)
    
    //want the collection view to use the full-width of the screen between the margins
    let collectionViewConstraintHorizontal = NSLayoutConstraint.constraintsWithVisualFormat("H:|-[collectionView]-|", options: nil, metrics: nil, views: galleryViews)
    rootView.addConstraints(collectionViewConstraintHorizontal)
  } // setupConstraintsOnRootView()
  
  //MARK: UICollectionViewDelegate
  func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    
    // pass the selected image to the delegate to be filtered
    self.delegate?.controllerDidSelectImage(self.images[indexPath.row])
    
    // pop ourselves off the nav queue
    self.navigationController?.popViewControllerAnimated(true)
  } // collectionView delegate
} // GalleryViewController
