//
//  FaceAiManager.swift
//  SharePhoto 人脸识别
//
//  Created by roycms on 2017/4/6.
//  Copyright © 2017年 北京三芳科技有限公司. All rights reserved.
//

import UIKit
import ImageIO
import CoreImage


class FaceAiManager: NSObject {
    
    static let share = FaceAiManager()
    
    // 开始识别脸部
    func detectFace(imageId:String,cacheUrl:String) {
        
        let url: NSURL = NSURL(fileURLWithPath:cacheUrl)
        let readData = NSData(contentsOfFile: url.path!)
        
        if (readData != nil)  {
            
            //处理不同方向的图片
            let image =  FixOrientation.imageFixOrientation(img: UIImage.init(data: readData! as Data)!)
            let inputImage = CIImage.init(image: image)
            
            // detector init
            let detector = CIDetector(ofType: CIDetectorTypeFace,
                                      context: nil,
                                      options: [CIDetectorAccuracy:CIDetectorAccuracyHigh
                ])
            
            if detector != nil {
                
                let faces = detector?.features(in: inputImage!) as! [CIFaceFeature]
                
                // 纠正坐标位置
                let inputImageSize = inputImage?.extent.size
                var transform = CGAffineTransform.identity
                
                transform = transform.scaledBy(x: 1, y: -1)
                transform = transform.translatedBy(x: 0, y: -(inputImageSize?.height)!)
                
                for face in faces {
                    let faceViewBounds = face.bounds.applying(transform)
                    self.clipFaceImage(rect: faceViewBounds, image: image)
                }
            }
            
        } else {
            print("识别人脸时读取文件失败")
        }
    }
    
    func clipFaceImage(rect:CGRect,image:UIImage) {
        
        let resourceRef = image.cgImage
        let newImageRef = resourceRef?.cropping(to: rect); //抠图
        let newImage = UIImage.init(cgImage: newImageRef!)
        
        let imageData = UIImageJPEGRepresentation(newImage,1.0);
        
        let fileName = String(NSDate().timeIntervalSince1970) + ".jpg"
        
        _ = self.writeFile(fileName: fileName ,fileData:imageData!)
        
    }
    
    func writeFile(fileName:String,fileData:Data) -> String{
        let path = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first
        let resourceCacheDir = path!+"/facePhoto/"
        let resourceCacheUrl = resourceCacheDir + fileName
        
        if (!FileManager.default.fileExists(atPath: resourceCacheDir)) {
            do {
                try FileManager.default.createDirectory(at:URL.init(fileURLWithPath: resourceCacheDir), withIntermediateDirectories:true, attributes:nil)
            }catch{
                print("出现异常 NSHomeDirectory 目录创建失败 error:\(error)")
            }
        }
        do {
            try fileData.write(to: URL.init(fileURLWithPath: resourceCacheUrl))
        }catch{
            print("出现异常  write 创建文件失败 error:\(error)")
        }
        
        return resourceCacheUrl
    }
}
