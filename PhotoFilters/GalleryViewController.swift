//
//  GalleryViewController.swift
//  PhotoFilters
//
//  Created by John Leonard on 1/12/15.
//  Copyright (c) 2015 John Leonard. All rights reserved.
//

import UIKit

class GalleryViewController: UIViewController, UICollectionViewDataSource {
  
  var collectionView : UICollectionView!
  var images = [UIImage]()
  
  override func loadView() {
    
    //set up the view to use the full screen and FlowLayout
    let rootView = UIView(frame: UIScreen.mainScreen().bounds)
    let collectionViewFlowLayout = UICollectionViewFlowLayout()
    self.collectionView = UICollectionView(frame: rootView.frame, collectionViewLayout: collectionViewFlowLayout)
    collectionView.setTranslatesAutoresizingMaskIntoConstraints(false)
    
    // add the collectionView as a subview, we're our own data source
    rootView.addSubview(self.collectionView)
    self.collectionView.dataSource = self
    
    // set the collection view minimum cell size
    collectionViewFlowLayout.itemSize = CGSize(width: 200, height: 200)
    
    // add Jon Vogel's code to let us set up constraints based on the GalleryViewController's  Navigation Bar
    let navigationBar = self.navigationController!.navigationBar
    rootView.addSubview(navigationBar)
    
    // set up a dictionary of views so we can set constraints with VFL
    let galleryViews = ["collectionView" : collectionView, "navigationBar" : navigationBar]
    
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
  
  // MARK: Gallery Autolayout Constraints
  func setupConstraintsOnRootView(rootView: UIView, forViews galleryViews: [String : AnyObject]) {
    let collectionViewConstraintVertical = NSLayoutConstraint.constraintsWithVisualFormat("V:[navigationBar]-30-[collectionView]-30-|", options: nil, metrics: nil, views: galleryViews)
    rootView.addConstraints(collectionViewConstraintVertical)
    
    let collectionViewConstraintHorizontal = NSLayoutConstraint.constraintsWithVisualFormat("H:|-[collectionView]-|", options: nil, metrics: nil, views: galleryViews)
    rootView.addConstraints(collectionViewConstraintHorizontal)
  } // setupConstraintsOnRootView()
  

    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
