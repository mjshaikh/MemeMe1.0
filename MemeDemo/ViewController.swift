//
//  ViewController.swift
//  MemeDemo
//
//  Created by Mohammed Shaikh on 2015-12-02.
//  Copyright © 2015 Zaytun Lab. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate,
                      UITextFieldDelegate, UIPickerViewDataSource, UIPickerViewDelegate {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var topToolBar: UIToolbar!
    @IBOutlet weak var bottomToolBar: UIToolbar!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var fontButton: UIBarButtonItem!

    // variable to hold our modified memed image
    var memedImage: UIImage!
    
    // Variables to hold our fonts and font attributes
    
    var fonts : [String]!
    var myFont: String!
    var memeTextAttributes: [String : AnyObject]!
    
    let blackOutlineColor = UIColor.blackColor()
    let textColor = UIColor.whiteColor()
    
    let defaultTopText = "TOP"
    let defaultBottomText = "BOTTOM"
    let fontButtonText = "Font"
    let doneButtonText = "Done"
    let impactFontName = "Impact"
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Get an array of system fonts
        
        fonts = UIFont.familyNames()
        
        // Get the index of the font named "Impact"
        
        if let index = fonts.indexOf(impactFontName){
            myFont = fonts[index]
            pickerView.selectRow(index, inComponent: 0, animated: true)
        }
        else{
            // Impact was not found in system fonts array so we manually set it
            myFont = impactFontName
        }
        
        
        // Assign the viewController to be the delegate of both textFields and apply text attributes
        
        topTextField.delegate = self
        applyTextAttributes(topTextField)
        bottomTextField.delegate = self
        applyTextAttributes(bottomTextField)
        
        
        // We disable share button when the view is first loaded
        shareButton.enabled = false
        
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // we set the visibity of cameraButton depending on the device camera availability
        cameraButton.enabled = UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)
        
        // We disable the picker view when the view appears
        pickerView.hidden = true
        
        subscribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }
    
    
    /* This function hides the status bar within our ViewController */
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    
    /* Protocol functions of UIPickerViewDataSource and UIPickerViewDelegate class
       to bind our data i.e fonts array to the pickerView */
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return fonts.count
    }

    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return fonts[row]
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        // Once a font is selected in the pickerView we assign that font to myFont variable and apply text attributes
        myFont = fonts[row]
        applyTextAttributes(topTextField)
        applyTextAttributes(bottomTextField)
    }
    
    
    
    /* This function is called when Font button is clicked. It toggles the visibilty of pickerView
        and switches the title of the button accordingly */
    
    @IBAction func pickFont(sender: UIBarButtonItem) {
        if pickerView.hidden {
            fontButton.title = doneButtonText
            pickerView.hidden = false
        }
        else{
            fontButton.title = fontButtonText
            pickerView.hidden = true
        }
    }
    
    
    /* This function is called when the share button is clicked. It generates a memedImage and presents
        the ActivityViewController to share the meme. */
    
    @IBAction func shareMeme(sender: UIBarButtonItem) {
        
        memedImage = generateMemedImage()
        
        let viewController = UIActivityViewController(activityItems: [memedImage], applicationActivities: nil)
        viewController.completionWithItemsHandler = { activity, completed, items, error in

            if completed {
                // Save the meme
                self.saveMeme()
                
                //Dismiss Activity ViewController
                self.dismissViewControllerAnimated(true, completion: nil)
            }
            
            else {
                // Something went wrong.
                self.dismissViewControllerAnimated(true, completion: nil)
            }

        }
        
        
        // We set the modalPresentationStyle to Popover in case of an iPad.
        viewController.modalPresentationStyle = UIModalPresentationStyle.Popover
        
        self.presentViewController(viewController, animated: true, completion: nil)
        
        // we assign our sender button to popover's barButtonItem property as a position to pop out from the button
        let popover = viewController.popoverPresentationController
        popover?.barButtonItem = sender
    }
    
    
    /* This function is called when the cancel button is clicked. It resets the imageView and textfields */

    @IBAction func resetView(sender: UIBarButtonItem) {
        
        imageView.image = nil
        topTextField.text = defaultTopText
        bottomTextField.text = defaultBottomText
        shareButton.enabled = false
    }
    
    
    /* This function is called when Album button is clicked */
    
    @IBAction func pickAnImageFromAlbum(sender: UIBarButtonItem) {
        
        initImagePicker(sender, sourceType: UIImagePickerControllerSourceType.PhotoLibrary)
    }
    
    
    /* This function is called when Camera button is clicked */
    
    @IBAction func pickAnImageFromCamera(sender: UIBarButtonItem) {
        
        initImagePicker(sender, sourceType: UIImagePickerControllerSourceType.Camera)
    }
    
    
    /* This function initializes UIImagePickerController for both Camera and Album depending on the sourceType */
    
    func initImagePicker(sender: UIBarButtonItem, sourceType: UIImagePickerControllerSourceType){
        
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.sourceType = sourceType
        self.presentViewController(pickerController, animated: true, completion: nil)
    }
    
    
    
    /* Protocol functions of UIImagePickerControllerDelegate which allows us to set imageView upon selection
        and also to respond to cancel action in case user closes the pickerController */
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imageView.image = image
            shareButton.enabled = true
        }
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    /* Protocol function to clear the default text in both textfields when user starts typing */
    
    func textFieldDidBeginEditing(textField: UITextField) {
        if textField.text == defaultTopText || textField.text == defaultBottomText {
            textField.text = ""
        }
    }
    
    /* Protocol function to restore the default text in both textfield incase user did not typing anything */
    
    func textFieldDidEndEditing(textField: UITextField) {
        
        if topTextField.text == "" {
            textField.text = defaultTopText
        }
        else if bottomTextField.text == "" {
            textField.text = defaultBottomText
        }
    }
    
    
    /* Protocol functions of UITextFieldDelegate to apply text attributes upon typing as well as to dismiss
        keyboard when return button is pressed */
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        
        applyTextAttributes(textField)
        return true
    }
    
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
    /* Function to apply attributes to a given textFiled */
    
    func applyTextAttributes(textField: UITextField){
        
        memeTextAttributes = [
            NSStrokeColorAttributeName : blackOutlineColor,
            NSForegroundColorAttributeName : textColor,
            NSFontAttributeName : UIFont(name: myFont, size: 40)!,
            NSStrokeWidthAttributeName : -2
        ]
        
        textField.defaultTextAttributes = memeTextAttributes
        textField.borderStyle = UITextBorderStyle.None
        textField.textAlignment = .Center
    }
    
    
    /* Function to generate the modified image containing the meme text */
    
    func generateMemedImage() -> UIImage {
        
        // Hide toolbar and navbar
        toolBarVisibility(true)
        
        // Render view to an image
        UIGraphicsBeginImageContext(self.view.frame.size)
        self.view.drawViewHierarchyInRect(self.view.frame, afterScreenUpdates: true)
        let memedImage : UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        // Show toolbar and navbar
        toolBarVisibility(false)
        
        return memedImage
    }
    
    /* Function to save the meme object */
    
    func saveMeme(){
        
        _ = Meme(topText: topTextField.text!, bottomText: bottomTextField.text!,
            originalImage: imageView.image!, memedImage: memedImage)
    }
    
    
    /* Function to toggle the visibilty of top and bottom toolbars */
    
    func toolBarVisibility(hidden: Bool){
        topToolBar.hidden = hidden
        bottomToolBar.hidden = hidden
    }
    
    
    func keyboardWillShow(notification: NSNotification) {
        
        /* We only shift the view up if bottomTextField is being manipulated and view origin.y
           is unchanged(i.e zero). Guarding the code with origin.y == 0 fixes the bug where keyboardWillShow
           is invoked everytime there is a orientation change and view keeps shifting upward until its offscreen.*/
        
        if(bottomTextField.isFirstResponder() && view.frame.origin.y == 0){
           view.frame.origin.y -=  getKeyboardHeight(notification)
        }
    }
    
    
    func keyboardWillHide(notification: NSNotification) {
        
        /* We will shift the view downward only if bottomTextField is manipulated and if view origin.y was changed from original
           position. Guarding the code with origin.y != 0 fixes the bug where the emulator don't popup the software keyboard when
           clicking on the textfield. For some weird reason function keyboardWillHide is called everytime and to avoid moving view
           down in that case we check if the view height was modified with origin.y if yes then only we move the view down */
        
        if(bottomTextField.isFirstResponder() && view.frame.origin.y != 0){
            view.frame.origin.y += getKeyboardHeight(notification)
        }
    }
    
    
    /* Function to get the height of the keyboard */
    
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.CGRectValue().height
    }
    
    
    /* Function to enable notification for events like UIKeyboardWillShowNotification and
        UIKeyboardWillHideNotification */
    
    func subscribeToKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
    }
    
    
    /* Function to disable notification for events like UIKeyboardWillShowNotification and
        UIKeyboardWillHideNotification */
    
    func unsubscribeFromKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name:
            UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name:
            UIKeyboardWillHideNotification, object: nil)
    }
    
}

