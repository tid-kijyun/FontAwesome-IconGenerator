/**@file IconGenerator.swift

FontAwesome-IconGenerator

Copyright (c) 2015 Atsushi Kiwaki (@_tid_)

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:
The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.
THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
*/
import Foundation
import AppKit

final class IconGenerator {
    var fontPath: String
    
    init(fontPath: String) {
        self.fontPath = fontPath
    }
    
    func generate(unicode: String, width: Int, height: Int, fontsize: Int) -> NSImage? {
        let data = NSData(contentsOfFile: fontPath)
        var error: Unmanaged<CFError>?
        let provider = CGDataProviderCreateWithCFData(data)
        let registerFont: CGFont = CGFontCreateWithDataProvider(provider)
        if CTFontManagerRegisterGraphicsFont(registerFont, &error) == false {
            return nil
        }
        
        let fontName = CGFontCopyPostScriptName(registerFont) as String
        NSLog(fontName)
        if let font = NSFont(name: fontName, size: CGFloat(fontsize)) {
            let size = CGSizeMake(CGFloat(width), CGFloat(height))
            let attrs: [NSObject: AnyObject] = [NSFontAttributeName: font]
            var attribute = NSMutableAttributedString(string: unicode, attributes: attrs)
            let rect = getRect(attribute, size: size)

            if let offscreenRep = NSBitmapImageRep(bitmapDataPlanes: nil,
                                                   pixelsWide: width,
                                                   pixelsHigh: height,
                                                   bitsPerSample: 8,
                                                   samplesPerPixel: 4,
                                                   hasAlpha: true,
                                                   isPlanar: false,
                                                   colorSpaceName: NSDeviceRGBColorSpace,
                                                   bitmapFormat: NSBitmapFormat.NSAlphaFirstBitmapFormat,
                                                   bytesPerRow: 0,
                                                   bitsPerPixel: 0),
                let g = NSGraphicsContext(bitmapImageRep: offscreenRep) {
                    // begin --------
                    NSGraphicsContext.saveGraphicsState()
                    NSGraphicsContext.setCurrentContext(g)
                
                    let ctx = g.CGContext
                    CGContextSetRGBFillColor(ctx, 1, 0, 0, 0.0)
                    CGContextFillRect(ctx, CGRectMake(0, 0, size.width, size.height))
                    
                    attribute.drawInRect(rect)
                    
                    // end ----------
                    CTFontManagerUnregisterGraphicsFont(registerFont, &error)
                    NSGraphicsContext.restoreGraphicsState()
                    
                    let img = NSImage(size: size)
                    img.addRepresentation(offscreenRep)
                    
                    return img
            }
        }
        
        CTFontManagerUnregisterGraphicsFont(registerFont, &error)
        return nil
    }

    func save(path: String, image: NSImage) {
        var interlaced: Bool = true
        var properties: [NSObject: AnyObject] = [NSImageInterlaced: NSNumber(bool: interlaced)]
        if let data = image.TIFFRepresentation,
            let bitmapImageRep = NSBitmapImageRep(data: data),
            let png = bitmapImageRep.representationUsingType(.NSPNGFileType, properties: properties) {
                png.writeToFile(path, atomically: true)
        }
    }
    
    private func getRect(attributeString: NSAttributedString, size: CGSize) -> CGRect {
        let iconSize = attributeString.size
        let xoff     = (size.width - iconSize.width) / 2.0
        let yoff     = (size.height - iconSize.height) / 2.0
        
        return CGRectMake(xoff, yoff, iconSize.width, iconSize.height)
    }
}
