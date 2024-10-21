//
//  Plugin.swift
//  Systembar
//
//  Created by Győrvári Gábor on 2024. 10. 21..
//

import AppKit

enum RefreshUnit {
    case second
    case minute
    case hour
}

class Plugin {
    var name: String;
    var file: URL;
    var refreshUnit: RefreshUnit;
    var refreshValue: Int;
    
    init(name: String, file: URL, refreshUnit: RefreshUnit, refreshValue: Int) {
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
        
        DispatchQueue.main.asyncAfter(deadline: .now() + DispatchTimeInterval.seconds(sec)) {
        }
    }
    
}
