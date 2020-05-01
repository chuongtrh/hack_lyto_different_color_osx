//
//  ImageConversion.swift
//  hackcolor
//
//  Created by Sam on 5/1/20.
//  Copyright © 2020 Sam. All rights reserved.
//

import Foundation

extension NSImage {
   /// Create a CIImage using the first available bitmap representation of the image
   ///
   ///  NSImage can contain multiple representations of the image. This function uses the first 'bitmappable' image
   ///
   /// - Returns: Converted image, or nil
   func asCIImage() -> CIImage? {
      if let tiffdata = self.tiffRepresentation,
         let bitmap = NSBitmapImageRep(data: tiffdata) {
         return CIImage(bitmapImageRep: bitmap)
      }
      return nil
   }

   /// Create a CGImage using the first available bitmap representation of the image
   ///
   ///  NSImage can contain multiple representations of the image. This function uses the first 'bitmappable' image
   ///
   /// - Returns: Converted image, or nil
   func asCGImage() -> CGImage? {
      if let imageData = self.tiffRepresentation,
         let sourceData = CGImageSourceCreateWithData(imageData as CFData, nil) {
         return CGImageSourceCreateImageAtIndex(sourceData, 0, nil)
      }
      return nil
   }
}

extension CIImage {
   /// Create a CGImage version of this image
   ///
   /// - Returns: Converted image, or nil
   func asCGImage(context: CIContext? = nil) -> CGImage? {
      let ctx = context ?? CIContext(options: nil)
      return ctx.createCGImage(self, from: self.extent)
   }

   /// Create an NSImage version of this image
   ///
   /// - Returns: Converted image, or nil
   func asNSImage() -> NSImage? {
      let rep = NSCIImageRep(ciImage: self)
      let updateImage = NSImage(size: rep.size)
      updateImage.addRepresentation(rep)
      return updateImage
   }
}

extension CGImage {
   /// Create a CIImage version of this image
   ///
   /// - Returns: Converted image, or nil
   func asCIImage() -> CIImage {
      return CIImage(cgImage: self)
   }

   /// Create an NSImage version of this image
   ///
   /// - Returns: Converted image, or nil
   func asNSImage() -> NSImage? {
      return NSImage(cgImage: self, size: .zero)
   }
}
