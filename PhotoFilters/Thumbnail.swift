//
//  Thumbnail.swift
//  PhotoFilters
//
//  Created by John Leonard on 1/13/15.
//  Copyright (c) 2015 John Leonard. All rights reserved.
//

import UIKit

class Thumbnail {
  
  var originalImage: UIImage?
  var filteredImage: UIImage?
  
  var filterName: String
  var imageQueue: NSOperationQueue
  var gpuContext: CIContext
  
  // need a real init()
  init(filterName: String, operationQueue: NSOperationQueue, context: CIContext) {
    self.filterName = filterName
    self.imageQueue = operationQueue
    self.gpuContext = context
  } // init()
  
  // does just what its name suggests
  func generateFilteredImage() {
    
    let startImage = CIImage(image: self.originalImage)
    let filter = CIFilter(name: self.filterName)
    
    // use default values for any keys that the filter may need
    filter.setDefaults()
    filter.setValue(startImage, forKey: kCIInputImageKey)
    
    // apply the filters and get the filtered image
    let result = filter.valueForKey(kCIOutputImageKey) as CIImage
    let extent = result.extent()
    let imageRef = self.gpuContext.createCGImage(result, fromRect: extent)
    self.filteredImage = UIImage(CGImage: imageRef)
  } // generateFilteredImage()
  
} // Thumbnail
