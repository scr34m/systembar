//
//  Parser.swift
//  Systembar
//
//  Created by Győrvári Gábor on 2024. 10. 22..
//

import AppKit

// https://github.com/matryer/xbar/blob/main/pkg/plugins/parse.go

struct Item {
    var text: String?
    var params: ItemParams?
}

struct ItemParams {
    var Color: String!
    var Shell: String!
    var Href: String!
}

class Parser {
    var nesting = "--"
    var separator = "---"
    
    func setValueByKey(params: inout ItemParams, key: String, value: String) -> Bool {
        switch key {
        case "color":
            params.Color = value
            return false
        case "shell":
            params.Shell = value
            return false
        case "href":
            params.Href = value
            return false
        default:
            print("unknown parameter: \(key)")
            return true
        }
    }
    
    func parseParamStr(params: inout ItemParams, text: String) -> Bool {
        var s = text
        var offsetShift = 0
        var endStr: Character
        while true {
            s = s.trimmingCharacters(in: .whitespacesAndNewlines)
            if s.count == 0 {
                return false
            }
            
            offsetShift = 1
            endStr = " "
            
            guard let index = s.firstIndex(of: "=") else {
                print("malformed parameters: missing equals")
                return true
            }
            
            if s.distance(from: s.startIndex, to: index) + 1 < s.count {
                let c = s[s.index(index, offsetBy: 1)]
                if c == "'" || c == "\"" {
                    // quotes
                    endStr = c
                    offsetShift += 1
                }
            }
            var offset = s.index(index, offsetBy: offsetShift)
            let key = s[...s.index(index, offsetBy: -1)]
            // if key[0] == '|' {
            //     key = key[1:]
            //     key = strings.TrimSpace(key)
            // }
            let valuePart = s[offset...]
            var end = valuePart.firstIndex(of: endStr)
            if end == nil {
                end = valuePart.firstIndex(of: "|")
                if end == nil {
                    end = valuePart.endIndex
                }
            }
            let value = s[offset...(s.index(end!, offsetBy: -1))]
            if setValueByKey(params: &params, key: String(key), value: String(value)) {
                return true
            }
            if s.distance(from: s.startIndex, to: end!) + 1 > s.count {
                return false
            }
            s = String(s[(s.index(end!, offsetBy: 1))...])
        }
    }
    
    func parseParams(_ s: String) -> (String, ItemParams, Bool) {
        var params = ItemParams()
        if let index = s.firstIndex(of: "|") {
            let text = String(s.prefix(upTo: index))
            let paramStr = s[s.index(index, offsetBy: 1)...]
            let e = parseParamStr(params: &params, text: String(paramStr))
            if e {
                return (text, params, e)
            }
            return (text, params, false)
        } else {
            return (s, params, false)
        }
    }
    
    func parseSeparator(_ line: String ) -> (String, Bool) {
        var l = line.trimmingCharacters(in: .whitespacesAndNewlines)
        if l == separator {
            return ("", true)
        }
        while l.hasPrefix(nesting) {
            l = String(l.trimmingPrefix(nesting))
            if l == separator {
                let index = line.index(line.startIndex, offsetBy: line.count - 3)
                return (String(line.prefix(upTo: index)), true)
            }
        }
        return (line, false)
    }
    
    func parseRaw(_ lines: [String]) -> [Item] {
        var captureExpanded = false
        var isSeparator = false
        var params: ItemParams;
        var items = [Item]()
        
        for line in lines {
            var l = line
            if l == "" {
                break
            }
            
            (l, params, _) = parseParams(l)
            
            if !captureExpanded && line.trimmingCharacters(in: .whitespacesAndNewlines) == separator {
                // first --- means end of cycle items,
                // start collecting expanded items now
                captureExpanded = true
                continue
            }
            
            (l, isSeparator) = parseSeparator(l)
            
            if captureExpanded && isSeparator {
                continue
            }
            
            items.append(Item(text: l, params: params));
        }
        
        return items
    }
}

/*
var s:String
var b:Bool
var ip:ItemParams;

(s, ip, b) = parseParams("no params")
assert(s=="no params")
assert(b==false)
(s, ip, b) = parseParams("Before params |color=#123def")
assert(s=="Before params ")
assert(ip.Color=="#123def")
assert(b==false)
(s, ip, b) = parseParams("Before params | shell=\"/annoying path with spaces/file.sh\"")
assert(s=="Before params ")
assert(b==false)
(s, ip, b) = parseParams("Before params | nope=badparam")
assert(b==true)

(s, b) = parseSeparator("no")
assert(s=="no")
assert(b==false)
(s, b) = parseSeparator(separator)
assert(s=="")
assert(b==true)
(s, b) = parseSeparator(nesting + separator)
assert(s==nesting)
assert(b==true)
(s, b) = parseSeparator(nesting + nesting + separator)
assert(s==nesting + nesting)
assert(b==true)
(s, b) = parseSeparator(nesting + nesting + "item")
assert(s==nesting + nesting + "item")
assert(b==false)
*/
