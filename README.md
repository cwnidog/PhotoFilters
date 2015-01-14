# PhotoFilters
==============

#Initial
--------

Initial:
--------

* Setup your interface with the Nav Controller, the photo button at the bottom, and an image view that takes up most of the screen. Use autolayout in code to
properly layout your interface
* Add an alert controller with the style set to action sheet
* Add a gallery action that pushes a gallery view controller onto the nav controller
* In the gallery view controller, display at least 6 photos in your gallery (https://unsplash.com is great)

NavBar:
---------

* Adding Jon Vogel's code to have the collection view's vertical constraint set to the navigation bar, rather than the top of the root view, so that sectopns of photos don't get lost under the nav bar.

initialFilters
----------------

* Setup your custom protocol & delegate, which will allow your gallery view controller to communicate back to the home view controller which image was selected from the gallery
* Setup a collection view to show filtered thumbnails of the image
* Setup your collection view's bottom constraint to start the collection view off screen, and then animate it up when the user clicks the filter option in the action sheet
* Following my (insane) workflow for applying filters to the thumbnails. Don't worry if you don't get it 100%, we will spend a lot of time tomorrow going over it and refining it.
