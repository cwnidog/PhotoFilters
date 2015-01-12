//
//  ViewController.swift
//  PhotoFilters
//
//  Created by John Leonard on 1/12/15.
//  Copyright (c) 2015 John Leonard. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
  
  let alertController = UIAlertController(title: "Photos", message: "Pick one  to filter", preferredStyle: UIAlertControllerStyle.ActionSheet)
  
  override func loadView() {
    
    let rootView = UIView(frame: UIScreen.mainScreen().bounds)
    rootView.backgroundColor = UIColor.whiteColor()
    
    let photoButton = UIButton()
    photoButton.setTitle("Photos", forState: .Normal)
    photoButton.setTitleColor(UIColor.blackColor(), forState: .Normal)
    photoButton.setTranslatesAutoresizingMaskIntoConstraints(false)
    rootView.addSubview(photoButton)
    photoButton.addTarget(self, action: "photoButtonPressed:", forControlEvents: UIControlEvents.TouchUpInside)
    
    // set up the views dictionary for VFL
    let views = ["photoButton" : photoButton]
    
    // setup constraints
    self.setupConstraintsOnRootView(rootView, forViews: views)
    
    self.view = rootView
  } // loadView()

  override func viewDidLoad() {
    super.viewDidLoad()
    
    let galleryOption = UIAlertAction(title: "Gallery", style: UIAlertActionStyle.Default) { (action) -> Void in
      println("Gallery pressed")
      
      let galleryVC = GalleryViewController()
      self.navigationController?.pushViewController(galleryVC, animated: true)
    }
      self.alertController.addAction(galleryOption)
      
  } // viewDidLoad()

  // MARK: Button Selectors
  
  func photoButtonPressed(sender: UIButton) {
    self.presentViewController(self.alertController, animated: true, completion: nil)
  } // photoButtonPressed()
  
  // MARK: Autolayout Constraints
  func setupConstraintsOnRootView(rootView: UIView, forViews views: [String : AnyObject])
  {
    let photoButtonConstraintVertical = NSLayoutConstraint.constraintsWithVisualFormat("V:[photoButton]-20-|", options: nil, metrics: nil, views: views)
    rootView.addConstraints(photoButtonConstraintVertical)
    let photoButton = views["photoButton"] as UIView!
    
    let photoButtonConstraintHorizontal = NSLayoutConstraint(item: photoButton, attribute: .CenterX, relatedBy: NSLayoutRelation.Equal, toItem: rootView, attribute: NSLayoutAttribute.CenterX, multiplier: 1.0, constant: 0.0)
    rootView.addConstraint(photoButtonConstraintHorizontal)
  } // setupConstraintsOnRootView()

} // ViewController

