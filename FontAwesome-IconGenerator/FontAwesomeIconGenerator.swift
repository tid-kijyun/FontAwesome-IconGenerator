/**@file FontAwesomeIconGenerator.swift

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
import AppKit

class FontAwesomeIconGenerator: NSObject {
    static let sharedPlugin = FontAwesomeIconGenerator()
    
    var bundle: NSBundle?
    var windowController: IconGenerateWindowController?
    
    
    class func pluginDidLoad(plugin: NSBundle) {
        if let appName = NSBundle.mainBundle().infoDictionary?["CFBundleName"] as? String {
            if appName == "Xcode" {
                sharedPlugin.bundle = plugin
                NSNotificationCenter.defaultCenter().addObserver(sharedPlugin, selector: "addMenuItems:", name: NSApplicationDidFinishLaunchingNotification, object: nil)
            }
        }
    }
    
    override init() {
        super.init()
    }
    
    func addMenuItems(notification: NSNotification?) {
        let rootMenuName = "Plugin"
        
        var item = NSMenuItem(title: "FontAwesome-icon-generator", action: "show:", keyEquivalent: "")
        item.target = self
        
        if let mainMenu = NSApp.mainMenu ?? nil {
            if let pluginMenu = mainMenu.itemWithTitle(rootMenuName) {
                pluginMenu.submenu?.addItem(item)
            } else {
                var pluginMenu = NSMenu(title: rootMenuName)
                pluginMenu.addItem(item)
                
                var newMenuItem = NSMenuItem(title: rootMenuName, action: nil, keyEquivalent: "")
                newMenuItem.submenu = pluginMenu
                mainMenu.addItem(newMenuItem)
            }
        }
    }
    
    func show(sender: AnyObject?) {
        NSLog("MENU CLICK")
        NSLog("ABC")
        showWindow()
    }
    
    func showWindow() {
        if self.windowController?.window == nil {
            self.windowController = IconGenerateWindowController(bundle: bundle)
        }
        
        self.windowController?.window?.setFrameAutosaveName("MyKey")
        self.windowController?.window?.makeKeyAndOrderFront(self)
    }
}
