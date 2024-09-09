//
//  SwiftRichString
//  Elegant Strings & Attributed Strings Toolkit for Swift
//
//  Created by Daniele Margutti.
//  Copyright © 2018 Daniele Margutti. All rights reserved.
//
//    Web: http://www.danielemargutti.com
//    Email: hello@danielemargutti.com
//    Twitter: @danielemargutti
//
//
//    Permission is hereby granted, free of charge, to any person obtaining a copy
//    of this software and associated documentation files (the "Software"), to deal
//    in the Software without restriction, including without limitation the rights
//    to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//    copies of the Software, and to permit persons to whom the Software is
//    furnished to do so, subject to the following conditions:
//
//    The above copyright notice and this permission notice shall be included in
//    all copies or substantial portions of the Software.
//
//    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//    AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//    OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//    THE SOFTWARE.

import Foundation

#if os(OSX)
import AppKit
#else
import UIKit
#endif

// This solution was taken from https://petehare.com/inline-nstextattachment-rendering-in-uitextview/
// in an attempt to provide a way to align images vertically with the text surrounding them.
public class InilineTextAttachment: NSTextAttachment {
    
    /// Set this to the value of Font.descender in order to align the bottom of the image with the bottom of the text being rendered around
    /// the image attachment.  Defaults to 0.0, leaving the image vertical alignment alone.
    public var fontDescender: CGFloat = 0.0
    
    public override func attachmentBounds(
        for textContainer: NSTextContainer?,
        proposedLineFragment lineFrag: CGRect,
        glyphPosition position: CGPoint,
        characterIndex charIndex: Int) -> CGRect {
            var superRect = super.attachmentBounds(for: textContainer, proposedLineFragment: lineFrag, glyphPosition: position, characterIndex: charIndex)
            superRect.origin.y = self.fontDescender
            
            return superRect
    }
    
}
public extension AttributedString {
    
    #if os(iOS)

    /// Initialize a new text attachment with a remote image resource.
    /// Image will be loaded asynchronously after the text appear inside the control.
    ///
    /// - Parameters:
    ///   - imageURL: url of the image. If url is not valid resource will be not downloaded.
    ///   - bounds: set a non `nil` value to express set the rect of attachment.
    convenience init?(imageURL: String?, bounds: String? = nil) {
        guard let imageURL = imageURL, let url = URL(string: imageURL) else {
            return nil
        }
                
        let attachment = AsyncTextAttachment()
        attachment.imageURL = url
        
        if let bounds = CGRect(string: bounds) {
            attachment.bounds = bounds
        }
    
        self.init(attachment: attachment)
    }
    
    #endif
    
    #if os(iOS) || os(OSX)

    /// Initialize a new text attachment with local image contained into the assets.
    ///
    /// - Parameters:
    ///   - imageNamed: name of the image into the assets; if `nil` resource will be not loaded.
    ///   - bounds: set a non `nil` value to express set the rect of attachment.
    convenience init?(imageNamed: String?, bounds: String? = nil) {
        guard let imageNamed = imageNamed else {
            return nil
        }
        
        let image = Image(named: imageNamed)
        self.init(image: image, bounds: bounds)
    }
    
    /// Initialize a new attributed string from an image.
    ///
    /// - Parameters:
    ///   - image: image to use.
    ///   - bounds: location and size of the image, if `nil` the default bounds is applied.
    convenience init?(image: Image?, bounds: String? = nil, descender: CGFloat = 0.0) {
        guard let image = image else {
            return nil
        }
        
        var imageBounds: CGRect = CGRect(origin: .zero, size: image.size)
        
        var finalImage: Image = image
        
        if let boundsRect = CGRect(string: bounds) {
            imageBounds = boundsRect
        }

        #if os(OSX)
        if imageBounds.size != image.size {
            finalImage.size = imageBounds.size
        }
        
        let attachment = InilineTextAttachment()
        attachment.image = finalImage
        #else
        var attachment: InilineTextAttachment!
        
        if imageBounds.size != image.size {
            finalImage = image.resized(to: imageBounds.size)
        }
        
        if #available(iOS 13.0, *) {
            attachment = InilineTextAttachment(image: finalImage)
        } else {
            // It does not work on iOS12, return empty set.s
            // attachment = NSTextAttachment(data: image.pngData()!, ofType: "png")
            attachment =  InilineTextAttachment()
            attachment.image = finalImage.withRenderingMode(.alwaysOriginal)
        }
        #endif
        
        attachment.bounds = imageBounds

        // align the image attachment vertically so that it sits on the bottom of the text line (not the baseline).
        attachment.fontDescender = descender
        
        self.init(attachment: attachment)
    }
    
    #endif
        
}
