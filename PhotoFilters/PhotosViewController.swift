//
//  PhotosViewController.swift
//  PhotoFilters
//
//  Created by John Leonard on 1/14/15.
//  Copyright (c) 2015 John Leonard. All rights reserved.
//

import UIKit
import Photos

class PhotosViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate {
  
  var assetsFetchResults : PHFetchResult!
  var assetCollection : PHAssetCollection!
  var imageManager = PHCachingImageManager()
  
  var collectionView : UICollectionView!
  
  var destinationImageSize : CGSize!
  
  var delegate : ImageSelectedProtocol?
  
  override func loadView() {
    let rootView = UIView(frame: UIScreen.mainScreen().bounds)
    self.collectionView = UICollectionView(frame: rootView.bounds, collectionViewLayout: UICollectionViewFlowLayout())
    
    let flowLayout = collectionView.collectionViewLayout as UICollectionViewFlowLayout
    flowLayout.itemSize = CGSize(width: 100, height: 100)
    
    collectionView.setTranslatesAutoresizingMaskIntoConstraints(false)
    rootView.addSubview(collectionView)
    
    self.view = rootView
    
  } // loadView()

    override func viewDidLoad() {
        super.viewDidLoad()
      
      self.assetsFetchResults = PHAsset.fetchAssetsWithOptions(nil)
      
      // we're our own dataSource & delegate
      self.collectionView.dataSource = self
      self.collectionView.delegate = self
      
      // register the Gallery Cell as teh collectionView cell
      self.collectionView.registerClass(GalleryCell.self, forCellWithReuseIdentifier: "PHOTO_CELL")
    } // viewDidLoad
  
  // MARK: UICollectionViewDataSource
  func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return self.assetsFetchResults.count
  } // collectionView(numberOfItemsInSection)
  
  func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCellWithReuseIdentifier("PHOTO_CELL", forIndexPath: indexPath) as GalleryCell
    let asset = self.assetsFetchResults[indexPath.row] as PHAsset
    self.imageManager.requestImageForAsset(asset, targetSize: CGSize(width: 100, height: 100), contentMode: PHImageContentMode.AspectFill, options: nil) { (requestedImage, info) -> Void in
      cell.imageView.image = requestedImage
    } // closure
    
    return cell
  } // collectionView(cellForItemAtIndexPath)
  
  func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
    // request image for correct size
    let selectedAsset = self.assetsFetchResults[indexPath.row] as PHAsset
    
    self.imageManager.requestImageForAsset(selectedAsset, targetSize: self.destinationImageSize, contentMode: PHImageContentMode.AspectFill, options: nil) { (requestedImage, info) -> Void in
      self.delegate?.controllerDidSelectImage(requestedImage)
      self.navigationController?.popToRootViewControllerAnimated(true)
    } // closure
  } // collectionView(didSelectItemAtIndexPath)

} // PhotosViewController
