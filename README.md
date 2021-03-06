# PhotoFilters
==============

PhotoFilters is an Instagram-like application. It allows the user to select a photo from their stored photos and apply a single filter to the selected photo. The app provides a sample of thumbnails showing the selected photos with each of the available filters applied. The user can then select a filtered photo, which is displayed full-sized on the device screen. The app also provides an option for the user to share the (non-)filtered photo to a social network. Right now, the only social network supported is Twitter.

#Initial
--------

* Setup your interface with the Nav Controller, the photo button at the bottom, and an image view that takes up most of the screen. Use autolayout in code to
properly layout your interface
* Add an alert controller with the style set to action sheet
* Add a gallery action that pushes a gallery view controller onto the nav controller
* In the gallery view controller, display at least 6 photos in your gallery (https://unsplash.com is great)

#NavBar:
---------

* Adding Jon Vogel's code to have the collection view's vertical constraint set to the navigation bar, rather than the top of the root view, so that sectopns of photos don't get lost under the nav bar.

#initialFilters
----------------

* Setup your custom protocol & delegate, which will allow your gallery view controller to communicate back to the home view controller which image was selected from the gallery
* Setup a collection view to show filtered thumbnails of the image
* Setup your collection view's bottom constraint to start the collection view off screen, and then animate it up when the user clicks the filter option in the action sheet
* Following my (insane) workflow for applying filters to the thumbnails. Don't worry if you don't get it 100%, we will spend a lot of time tomorrow going over it and refining it.

#basicPhotos
------------

* Setup your Share and Done buttons for your home view controller's navigation item
* Add a UIimagePickerController to allow the user to take images from their device's camera. Only show this option if the camera exists on the device
* Add a third view controller for photos pulled from the Photos framework. Use the same protocol & delegate methods from the galleryVC
* Use the SLCompViewController to post a photo up to twitter #ellensburg
* When entering filter mode, shrink the main image view down by adding to its constraints constant values. Make this animated (of course)
* Figure out some way to apply the selected filter from the filter thumbnail collection view to the image in the main image view

#Gestures
----------

* Add the pinch gesture recognizer to your gallery view controller, and change the item size when the pinching takes place
* Add a 2nd language to your app and correctly translate your user facing strings
* Using the assets catalogue, add 2x and 3x version of your gallery images to your app
