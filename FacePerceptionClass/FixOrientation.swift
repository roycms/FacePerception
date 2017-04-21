//
//  FixOrientation.swift
//  FacePerception
//
//  Created by roycms on 2017/4/21.
//  Copyright © 2017年 杜耀辉. All rights reserved.
//

import Foundation
import UIKit
import ImageIO
import CoreImage

class FixOrientation:NSObject {
    
    
    class func imageFixOrientation(img:UIImage) -> UIImage {
        
        // No-op if the orientation is already correct
        if (img.imageOrientation == UIImageOrientation.up) {
            return img;
        }
        // We need to calculate the proper transformation to make the image upright.
        // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
        var transform = CGAffineTransform.identity
        
        switch (img.imageOrientation) {
        case .down: fallthrough
        case .downMirrored:
            transform = transform.translatedBy(x: img.size.width, y: img.size.height);
            transform = transform.rotated(by: .pi);
            break;
            
        case .left: fallthrough
        case .leftMirrored:
            transform = transform.translatedBy(x: img.size.width, y: 0);
            transform = transform.rotated(by: .pi*2);
            break;
            
        case .right: fallthrough
        case .rightMirrored:
            transform = transform.translatedBy(x: 0, y: img.size.height);
            transform = transform.rotated(by: -.pi*2);
            break;
        default:
            break;
        }
        
        switch (img.imageOrientation) {
        case .upMirrored:fallthrough
        case .downMirrored:
            transform = transform.translatedBy(x: img.size.width, y: 0);
            transform = transform.scaledBy(x: -1, y: 1);
            break;
            
        case .leftMirrored:fallthrough
        case .rightMirrored:
            transform = transform.translatedBy(x: img.size.height, y: 0);
            transform = transform.scaledBy(x: -1, y: 1);
            break;
        default:
            break;
        }
        
        // Now we draw the underlying CGImage into a new context, applying the transform
        // calculated above.
        let ctx:CGContext = CGContext(data: nil, width: Int(img.size.width), height: Int(img.size.height),
                                      bitsPerComponent: img.cgImage!.bitsPerComponent, bytesPerRow: 0,
                                      space: img.cgImage!.colorSpace!,
                                      bitmapInfo: img.cgImage!.bitmapInfo.rawValue)!
        
        ctx.concatenate(transform)
        
        
        if (img.imageOrientation == UIImageOrientation.left
            || img.imageOrientation == UIImageOrientation.leftMirrored
            || img.imageOrientation == UIImageOrientation.right
            || img.imageOrientation == UIImageOrientation.rightMirrored
            ) {
            
            
            ctx.draw(img.cgImage!, in: CGRect(x:0,y:0,width:img.size.height,height:img.size.width))
            
        } else {
            ctx.draw(img.cgImage!, in: CGRect(x:0,y:0,width:img.size.width,height:img.size.height))
        }
        
        
        // And now we just create a new UIImage from the drawing context
        let cgimg:CGImage = ctx.makeImage()!
        let imgEnd:UIImage = UIImage(cgImage: cgimg)
        
        return imgEnd
    }
}
