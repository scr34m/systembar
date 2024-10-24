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
        
        let (output, _) = run(path: file.path, args: []);
        
        let p = Parser()
        self.items = p.parseRaw(output)
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
    
    func run(path: String, args: [String]) -> (output: [String], error: [String]) {
        var output : [String] = []
        var error : [String] = []
        
        let process = Process()
        process.launchPath = path
        process.arguments = args
        
        let group = DispatchGroup()
        
        var tempStdOutStorage = Data()
        let stdOutPipe = Pipe()
        process.standardOutput = stdOutPipe
        group.enter()
        stdOutPipe.fileHandleForReading.readabilityHandler = { stdOutFileHandle in
            let stdOutPartialData = stdOutFileHandle.availableData
            if stdOutPartialData.isEmpty { // EOF on stdin
                stdOutPipe.fileHandleForReading.readabilityHandler = nil
                group.leave()
            } else {
                tempStdOutStorage.append(stdOutPartialData)
            }
        }
        
        var tempStdErrStorage = Data()
        let stdErrPipe = Pipe()
        process.standardError = stdErrPipe
        group.enter()
        stdErrPipe.fileHandleForReading.readabilityHandler = { stdErrFileHandle in
            let stdErrPartialData = stdErrFileHandle.availableData
            if stdErrPartialData.isEmpty { // EOF on stderr
                stdErrPipe.fileHandleForReading.readabilityHandler = nil
                group.leave()
            } else {
                tempStdErrStorage.append(stdErrPartialData)
            }
        }
        
        process.standardOutput = stdOutPipe
        process.standardError = stdErrPipe
        
        process.launch()
        
        process.terminationHandler = { process in
            group.wait()
            if var string = String(data: tempStdOutStorage, encoding: .utf8) {
                string = string.trimmingCharacters(in: .newlines)
                output = string.components(separatedBy: "\n")
            }
            if var string = String(data: tempStdErrStorage, encoding: .utf8) {
                string = string.trimmingCharacters(in: .newlines)
                error = string.components(separatedBy: "\n")
            }
        }
        process.waitUntilExit()
        
        return (output, error)
    }
    
}
