//
//  GalleryCell.swift
//  PhotoFilters
//
//  Created by John Leonard on 1/12/15.
//  Copyright (c) 2015 John Leonard. All rights reserved.
//

import UIKit

class GalleryCell: UICollectionViewCell {
  let imageView = UIImageView()
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    
    self.addSubview(self.imageView)
    
    // set image attributes
    imageView.frame = self.bounds
    imageView.contentMode = UIViewContentMode.ScaleAspectFill
    imageView.layer.masksToBounds = true
    
    let views = ["imageView" : self.imageView]
    imageView.setTranslatesAutoresizingMaskIntoConstraints(false)
    let imageViewConstraintsHorizontal = NSLayoutConstraint.constraintsWithVisualFormat("H:|[imageView]|", options: nil, metrics: nil, views: views)
    let imageViewConstraintsVertical = NSLayoutConstraint.constraintsWithVisualFormat("V:|[imageView]|", options: nil, metrics: nil, views: views)
    self.addConstraints(imageViewConstraintsHorizontal)
    self.addConstraints(imageViewConstraintsVertical)
  } // override init()
  
  // we gotta do this to keep Xcode happy
  required init(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  } // required init()
  
} // GalleryCell
