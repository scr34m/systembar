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
        plugins?[sender.tag].refresh()
    }

    @objc func refreshAll(sender: NSMenuItem) {
        for plugin in plugins! {
            plugin.refresh();
        }
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
       
    @objc func pluginMenuClick(sender: NSMenuItem) {
        let item_index = sender.tag / 100
        let index = sender.tag - (item_index * 100)
        
        let item = plugins![index].items[item_index];
        
        if let href = item.params?.Href {
            if let url = URL(string: href) {
                NSWorkspace.shared.open(url)
            }
        }
    }

    func buildMenu(index: Int, plugin: Plugin) -> PluginMenu {
        let statusBarItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        if let button = statusBarItem.button {
            button.title = plugin.title

            let menu = NSMenu()
                       
            for (item_index, item) in plugin.items.enumerated() {
                if item_index == 0 {
                    continue;
                }
                
                let menuItem = NSMenuItem(title: item.text!, action: #selector(pluginMenuClick), keyEquivalent: "")
                if let color = item.params?.Color {
                    menuItem.attributedTitle = NSAttributedString(string: item.text!, attributes: [NSAttributedString.Key.foregroundColor: color])
                }
                menuItem.target = self
                menuItem.tag = (item_index * 100) + index
                menu.addItem(menuItem)
            }
            
            if menu.numberOfItems > 0 {
                menu.addItem(.separator())
            }
            
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
