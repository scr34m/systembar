//
//  PluginManager.swift
//  Systembar
//
//  Created by Győrvári Gábor on 2024. 10. 21..
//
import AppKit

class PluginManager {
    
    func refreshAll() -> [Plugin] {
        let fileUrl = URL(string: "/Users/scr34m/Library/Application Support/xbar/plugins/")
        return search(pathURL: fileUrl!)
    }
    
    func search(pathURL: URL) -> [Plugin] {
        var items = [Plugin]()
        let fileManager = FileManager.default
        let keys = [URLResourceKey.isDirectoryKey, URLResourceKey.localizedNameKey]
        let options: FileManager.DirectoryEnumerationOptions = [.skipsPackageDescendants, .skipsSubdirectoryDescendants, .skipsHiddenFiles]
        
        let enumerator = fileManager.enumerator(
            at: pathURL,
            includingPropertiesForKeys: keys,
            options: options,
            errorHandler: {(url, error) -> Bool in
                return true
            })
        
        if enumerator != nil {
            while let file = enumerator!.nextObject() {
                if let item = parseFile(pathURL: (file as! URL)) {
                    items.append(item);
                }
            }
        }
        
        return items
    }
    
    func parseFile(pathURL: URL) -> Plugin? {
        let url = URL(fileURLWithPath: pathURL.absoluteString, relativeTo: pathURL)
        let name = url.lastPathComponent;
        
        var components = name.components(separatedBy: ".")
        guard components.count == 3 else { return nil }
        
        if components[2] != "sh" {
            return nil
        }
        
        var unit : RefreshUnit;
        if components[1].last == "h" {
            unit = .hour
        } else if components[1].last == "m" {
            unit = .minute
        } else if components[1].last == "s" {
            unit = .second
        } else {
            return nil
        }
        
        let value = Int(components[1].dropLast()) ?? 0;
        
        return Plugin(name: components[0], file: pathURL, refreshUnit: unit, refreshValue: value)
    }
}
