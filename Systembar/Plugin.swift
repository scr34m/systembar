//
//  Plugin.swift
//  Systembar
//
//  Created by Győrvári Gábor on 2024. 10. 21..
//

import AppKit
import Foundation

enum RefreshUnit {
    case second
    case minute
    case hour
}

protocol PluginDelegate {
    func pluginDidRefresh(plugin: Plugin);
}

class Plugin {
    var name: String
    var file: URL
    var refreshUnit: RefreshUnit
    var refreshValue: Int
    
    var title : String
    var items : [Item]!
    
    var delegate: PluginDelegate?
    var disp : DispatchSourceTimer!
    
    init(name: String, file: URL, refreshUnit: RefreshUnit, refreshValue: Int) {
        self.title = ""
        self.name = name
        self.file = file
        self.refreshUnit = refreshUnit
        self.refreshValue = refreshValue
    }
    
    func refresh() {
        var sec : Int;
        if refreshUnit == .hour {
            sec = refreshValue * 3600
        } else if refreshUnit == .minute {
            sec = refreshValue * 60
        } else if refreshUnit == .second {
            sec = refreshValue
        } else {
            return
        }
        
        let (raw, _, _) = run();

        let p = Parser()
        self.items = p.parseRaw(raw)
        if self.items.count > 0 {
            self.title = self.items[0].text!
        }

        if let d = delegate {
            d.pluginDidRefresh(plugin: self)
        }
        
        timer(delay: sec)
    }
    
    func timer(delay: Int) {
        disp = DispatchSource.makeTimerSource(queue: DispatchQueue.main)
        disp.schedule(deadline: .now() + DispatchTimeInterval.seconds(delay))
        disp.setEventHandler {
            self.refresh()
        }
        disp.resume()
    }
    
    func run() -> (output: [String], error: [String], exitCode: Int32) {
        var output : [String] = []
        var error : [String] = []
        
        let task = Process()
        task.launchPath = "/usr/bin/env"
        task.arguments = [file.path]
        
        let outpipe = Pipe()
        task.standardOutput = outpipe
        
        let errpipe = Pipe()
        task.standardError = errpipe
        
        task.launch()

        let outdata = outpipe.fileHandleForReading.readDataToEndOfFile()
        if var string = String(data: outdata, encoding: .utf8) {
            string = string.trimmingCharacters(in: .newlines)
            output = string.components(separatedBy: "\n")
        }
        
        let errdata = errpipe.fileHandleForReading.readDataToEndOfFile()
        if var string = String(data: errdata, encoding: .utf8) {
            string = string.trimmingCharacters(in: .newlines)
            error = string.components(separatedBy: "\n")

        }

        task.waitUntilExit()
        let status = task.terminationStatus
        
        return (output, error, status)
    }
}
