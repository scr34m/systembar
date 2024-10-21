//
//  AppDelegate.swift
//  Systembar
//
//  Created by Győrvári Gábor on 2024. 10. 21..
//

import AppKit

class AppDelegate: NSObject, NSApplicationDelegate {
    
    var statusBar: NSStatusBar!
    var statusBarItem: NSStatusItem!
    var isMuted: Bool = false
    
    override init() {
        super.init()
        let manager = PluginManager();
        let plugins = manager.refreshAll();
        print(plugins)
    }
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        statusBar = NSStatusBar()
        statusBarItem = statusBar.statusItem(withLength: NSStatusItem.variableLength)
        
        if let button = statusBarItem.button {
            button.image = NSImage(systemSymbolName: isMuted ? "mic.slash" : "mic", accessibilityDescription: nil)
        }
        
        if let button = statusBarItem.button {
            let groupMenuItem = NSMenuItem()
            groupMenuItem.title = "Toggle mute!"
            groupMenuItem.target = self
            
            groupMenuItem.action = #selector(mutePressed)
            
            let mainMenu = NSMenu()
            mainMenu.addItem(groupMenuItem)
            
            statusBarItem.menu = mainMenu
        }
    }
    
    @objc func mutePressed() {
        if let button = statusBarItem.button {
            // 5
            isMuted.toggle()
            button.image = NSImage(systemSymbolName: isMuted ? "mic.slash" : "mic", accessibilityDescription: nil)
        }
    }
    
}
