/**@file IconGenerateWindowController.swift

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
import CoreGraphics
import CoreText

class IconGenerateWindowController: NSWindowController {
    static let nibName = "IconGenerateWindow"
    
    @IBOutlet weak var imageSample: NSImageView!
    @IBOutlet weak var comboBoxColor: NSComboBox!
    @IBOutlet weak var comboBoxImageSize: NSComboBox!
    @IBOutlet weak var comboBoxFontSize: NSComboBox!
    @IBOutlet weak var comboBox: NSComboBox!
    
    @IBOutlet weak var checkSizeX2: NSButton!
    @IBOutlet weak var checkSizeX3: NSButton!
    @IBOutlet weak var checkAutoFontSize: NSButton!
    
    @IBOutlet weak var textFileName: NSTextField!
    
    @IBOutlet weak var progressIndicator: NSProgressIndicator!
    @IBOutlet weak var textProgress: NSTextField!
    
    var bundle: NSBundle?
    var iconGenerater: IconGenerator?
    
    /**
    Initializer
    
    @param bundle
    */
    convenience init(bundle: NSBundle?) {
        self.init(windowNibName: IconGenerateWindowController.nibName)
        self.bundle = bundle
    }
    
    /**
    
    */
    override func windowDidLoad() {
        super.windowDidLoad()
        
        if let path = bundle?.pathForResource("fontawesome-webfont", ofType: "ttf") {
            iconGenerater = IconGenerator(fontPath: path)
        }
        
        //
        let nd = NSNotificationCenter.defaultCenter()
        nd.addObserver(self, selector: "progressStarted:", name: "start", object: nil)
        nd.addObserver(self, selector: "progressFinished:", name: "stop", object: nil)
        
        //
        comboBoxColor.selectItemAtIndex(0)
        
        //
        for (index, value) in enumerate(8...128) {
            comboBoxImageSize.insertItemWithObjectValue("\(value)", atIndex: index)
            comboBoxFontSize.insertItemWithObjectValue("\(value)", atIndex: index)
        }
        comboBoxImageSize.selectItemWithObjectValue("32")
        comboBoxFontSize.selectItemWithObjectValue("28")
        
        //
        let sortedKeys = Array(FontAwesomeIconList.keys).sorted(<)
        for (index, key) in  enumerate(sortedKeys) {
            comboBox.insertItemWithObjectValue(key, atIndex: index)
        }
        comboBox.selectItemAtIndex(0)
        setImage()
    }
    
    @IBAction func comboBoxClicked(sender: AnyObject) {
        setImage()
    }
    
    @IBAction func click(sender: AnyObject) {
        setImage()
        
        var filenames = [fileName]
        if isSizeX2 {
            filenames.append(fileNameX2)
        }
        if isSizeX3 {
            filenames.append(fileNameX3)
        }
        
        NSNotificationCenter.defaultCenter().postNotificationName("start", object: nil)
        
        let documentsPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as! String
        NSLog(documentsPath)
        if let unicode = unicode {
            for (index, filename) in enumerate(filenames) {
                let scale = index + 1
                if let img = iconGenerater?.generate(unicode, width: width * scale, height: height * scale, fontsize: fontSize * scale) {
                    iconGenerater?.save(documentsPath + "/" + filename, image: img)
                }
                usleep(300000)
            }
        }
        
        
        NSNotificationCenter.defaultCenter().postNotificationName("stop", object: nil)
    }
    
    @IBAction func checkAuto(sender: AnyObject) {
        comboBoxFontSize.enabled = !isAutoFontSize
    }
    
    private func setImage() {
        if let unicode = unicode {
            textFileName.stringValue = fileName
            let img = iconGenerater?.generate(unicode, width: width, height: height, fontsize: fontSize)
            imageSample.image = img
        }
    }
    
    private var fileName: String {
        return "\(comboBox.stringValue)_\(comboBoxColor.stringValue)_\(width).png"
    }
    private var fileNameX2: String {
        return "\(comboBox.stringValue)_\(comboBoxColor.stringValue)_\(width*2).png"
    }
    private var fileNameX3: String {
        return "\(comboBox.stringValue)_\(comboBoxColor.stringValue)_\(width*3).png"
    }
    
    private var unicode: String? {
        return FontAwesomeIconList[comboBox.stringValue]
    }
    
    private var width: Int {
        return comboBoxImageSize.stringValue.toInt()!
    }
    
    private var height: Int {
        return comboBoxImageSize.stringValue.toInt()!
    }
    
    private var fontSize: Int {
        if isAutoFontSize {
            return Int((CGFloat(width) / 10.0) * 6.0)
        } else {
            return comboBoxFontSize.stringValue.toInt()!
        }
    }
    
    private var isAutoFontSize: Bool {
        return checkAutoFontSize.state == NSOnState
    }
    
    private var isSizeX2: Bool {
        return checkSizeX2.state == NSOnState
    }
    
    private var isSizeX3: Bool {
        return checkSizeX3.state == NSOnState
    }
    
    func progressStarted(notification: NSNotification) {
        NSLog("START")
        //progressIndicator.hidden = false
        progressIndicator.startAnimation(self)
    }
    
    func progressFinished(notification: NSNotification) {
        NSLog("STOP")
        //progressIndicator.hidden = true
        progressIndicator.stopAnimation(self)
    }
}

