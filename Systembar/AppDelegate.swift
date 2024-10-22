//
//  AppDelegate.swift
//  Systembar
//
//  Created by Győrvári Gábor on 2024. 10. 21..
//

import AppKit

class AppDelegate: NSObject, NSApplicationDelegate, PluginDelegate {

    struct PluginMenu {
        var plugin: Plugin
        var statusBarItem: NSStatusItem
    }
    
    var statusBarItem: NSStatusItem!

    var plugins: [Plugin]?
    var pluginsMenu = [PluginMenu]()
    
    override init() {
        super.init()
    }
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        let manager = PluginManager();
        
        plugins = manager.refreshAll();
        for plugin in plugins! {
            plugin.delegate = self
            plugin.refresh();
        }
    }

    @objc func refresh(sender: NSMenuItem) {
    }

    @objc func refreshAll(sender: NSMenuItem) {
    }

    @objc func quit(sender: NSMenuItem) {
        NSApplication.shared.terminate(nil)
    }
    
    func pluginDidRefresh(plugin: Plugin) {
        print("Refresh \"\(plugin.name)\" \(plugin.title)")

        for (index, p) in plugins!.enumerated() {
            if p.name != plugin.name {
                continue;
            }
            
            if !pluginsMenu.indices.contains(index) {
                pluginsMenu.insert(buildMenu(index: index, plugin: plugin), at: index)
            } else if let button = pluginsMenu[index].statusBarItem.button {
                button.title = plugin.title
            }
        }
    }
    
    @objc func menu(sender: NSMenuItem) {
        print(1)
    }

    
    func buildMenu(index: Int, plugin: Plugin) -> PluginMenu {
        let statusBarItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        if let button = statusBarItem.button {
            button.title = plugin.title
            button.target = self
            button.action = #selector(menu)

            let menu = NSMenu()
            
            var menuItem = NSMenuItem(title: "Refresh", action: #selector(refresh), keyEquivalent: "")
            menuItem.target = self
            menuItem.tag = index
            menu.addItem(menuItem)
            
            menuItem = NSMenuItem(title: "Refresh all", action: #selector(refreshAll), keyEquivalent: "")
            menuItem.target = self
            menuItem.tag = index
            menu.addItem(menuItem)
            
            menu.addItem(.separator())
            
            menuItem = NSMenuItem(title: "Quit", action: #selector(quit), keyEquivalent: "")
            menuItem.target = self
            menu.addItem(menuItem)
            
            statusBarItem.menu = menu
        }
        return PluginMenu(plugin: plugin, statusBarItem: statusBarItem);
    }
    
}
