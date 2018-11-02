//
//  UIViewAnimationExtension.swift
//  The Diplomacist
//
//  Created by Amrinder Grewal on 2017-06-06.
//  Copyright © 2017 The Diplomacist. All rights reserved.
//

import UIKit

extension UIView {
    //  Will be used to fade views in
    func fadeIn() {
        //  The animation is triggered
        UIView.animate(withDuration: 1.0,
                       delay: 0,
                       options: .curveEaseIn,
                       animations: { self.alpha = 1 },
                       completion: {
                        finished in
                        if !finished {
                            //  If the animation is terminted, then the alpha is set to 1
                            //  So the image is visible
                            self.alpha = 1
                        } else {
                            //  Otherwise animation continues
                            self.fadeOut()
                        }
        })
    }
    
    //  Will be used to fade views out
    func fadeOut() {
        UIView.animate(withDuration: 1.0,
                       delay: 0,
                       options: .curveEaseOut,
                       animations: { self.alpha = 0 },
                       completion: {
                        finished in
                        if !finished {
                            //  If the animation is terminted, then the alpha is set to 1
                            //  So the image is visible
                            self.alpha = 1
                        } else {
                            //  Otherwise animation continues
                            self.fadeIn()
                        }
        })
    }
}
