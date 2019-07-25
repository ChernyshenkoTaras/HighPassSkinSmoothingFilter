//
//  UIViewExtension.swift
//  Malibu
//
//  Created by Taras Chernyshenko on 11/28/18.
//  Copyright © 2018 Salon Software. All rights reserved.
//

import UIKit

extension UIView {
    class var nib: UINib {
        return UINib(nibName: String(describing: self), bundle: nil)
    }
}

extension UIView {
    func addShadow(height: CGFloat = 15, radius: CGFloat = 10, alpha: CGFloat = 1.0) {
        self.layer.shadowOffset = CGSize(width: 0, height: height)
        self.layer.shadowColor = UIColor(red:0, green:0, blue:0, alpha:alpha).cgColor
        self.layer.shadowOpacity = 1
        self.layer.shadowRadius = radius
    }
}

extension UIView {
    func insertSubviewWithConstraints(view:UIView, top:CGFloat = 0, left:CGFloat = 0, bottom:CGFloat = 0, right:CGFloat = 0, at viewIndex: Int? = nil) {
        view.translatesAutoresizingMaskIntoConstraints = false
        if let viewIndex = viewIndex {
            self.insertSubview(view, at: viewIndex)
        } else {
            self.addSubview(view)
        }
        let left = view.leftAnchor.constraint(equalTo: self.leftAnchor, constant: left)
        let right = self.rightAnchor.constraint(equalTo: view.rightAnchor, constant: right)
        let top = view.topAnchor.constraint(equalTo: self.topAnchor, constant: top)
        let bottom = self.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: bottom)
        NSLayoutConstraint.activate([left, right, top, bottom])
    }
    
    func constraintSize(to size: CGSize) {
        translatesAutoresizingMaskIntoConstraints = false
        addConstraints([NSLayoutConstraint(
            item: self,
            attribute: .width,
            relatedBy: .equal,
            toItem: nil,
            attribute: .notAnAttribute,
            multiplier: 1,
            constant: size.width),
                        NSLayoutConstraint(
                            item: self,
                            attribute: .height,
                            relatedBy: .equal,
                            toItem: nil,
                            attribute: .notAnAttribute,
                            multiplier: 1,
                            constant: size.height)
            ])
    }
}

extension UIView {
    func imageSnapshotCroppedToFrame(frame: CGRect?, size: CGSize) -> UIImage {
        let scaleFactor = UIScreen.main.scale
        UIGraphicsBeginImageContextWithOptions(size, false, scaleFactor)
        self.drawHierarchy(in: bounds, afterScreenUpdates: true)
        var image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        if let frame = frame {
            let scaledRect = frame.applying(CGAffineTransform(scaleX: scaleFactor, y: scaleFactor))
            
            if let imageRef = image.cgImage!.cropping(to: scaledRect) {
                image = UIImage(cgImage: imageRef)
            }
        }
        return image
    }
}
