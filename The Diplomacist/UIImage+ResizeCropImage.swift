//
//  UIImage+ResizeCropImage.swift
//  The Diplomacist
//
//  Created by Amrinder Grewal on 2016-12-19.
//  Copyright © 2016 The Diplomacist. All rights reserved.
//

import UIKit

//  MARK: Code Never Called

extension UIImage {
    //  The following lines existed because I had created a bug, I was assigning the newImage to cellToUpdate.imageView, not featuredImage
    //  in PostsTableViewController.swift
    func resizedImageByRatio (image: UIImage, ratio: CGFloat) -> UIImage{
        //  Creating a new size using the ratio and the size of the image that already exists
        let newSize = CGSize(width: image.size.width * ratio, height: image.size.height * ratio);
        //  Calcuated rect, what is used below to create the actual image
        let rectForResizeImage = CGRect(origin: CGPoint.zero, size: newSize);
        
        //  Doing the actual resizing using UIGraphics image context stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0);
        image.draw(in: rectForResizeImage)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
    /*func cropByAspectRatio(image: UIImage, ratio: CGFloat, width: CGFloat) -> UIImage{
        //  let contextSize =
    }*/
}
