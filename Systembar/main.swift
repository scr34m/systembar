//
//  main.swift
//  Systembar
//
//  Created by Győrvári Gábor on 2024. 10. 21..
//

import AppKit

let app = NSApplication.shared

let delegate = AppDelegate()
app.delegate = delegate
app.setActivationPolicy(.accessory)
app.run()
