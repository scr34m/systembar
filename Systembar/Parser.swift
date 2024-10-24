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
    var Color: NSColor!
    var Shell: String!
    var ShellParams: [String] = []
    var Href: String!
    var Refresh: Bool!
}

class Parser {
    var nesting = "--"
    var separator = "---"
    var colors = [
        "lightseagreen":        "#20b2aa",
        "floralwhite":          "#fffaf0",
        "lightgray":            "#d3d3d3",
        "darkgoldenrod":        "#b8860b",
        "paleturquoise":        "#afeeee",
        "goldenrod":            "#daa520",
        "skyblue":              "#87ceeb",
        "indianred":            "#cd5c5c",
        "darkgray":             "#a9a9a9",
        "khaki":                "#f0e68c",
        "blue":                 "#0000ff",
        "darkred":              "#8b0000",
        "lightyellow":          "#ffffe0",
        "midnightblue":         "#191970",
        "chartreuse":           "#7fff00",
        "lightsteelblue":       "#b0c4de",
        "slateblue":            "#6a5acd",
        "firebrick":            "#b22222",
        "moccasin":             "#ffe4b5",
        "salmon":               "#fa8072",
        "sienna":               "#a0522d",
        "slategray":            "#708090",
        "teal":                 "#008080",
        "lightsalmon":          "#ffa07a",
        "pink":                 "#ffc0cb",
        "burlywood":            "#deb887",
        "gold":                 "#ffd700",
        "springgreen":          "#00ff7f",
        "lightcoral":           "#f08080",
        "black":                "#000000",
        "blueviolet":           "#8a2be2",
        "chocolate":            "#d2691e",
        "aqua":                 "#00ffff",
        "darkviolet":           "#9400d3",
        "indigo":               "#4b0082",
        "darkcyan":             "#008b8b",
        "orange":               "#ffa500",
        "antiquewhite":         "#faebd7",
        "peru":                 "#cd853f",
        "silver":               "#c0c0c0",
        "purple":               "#800080",
        "saddlebrown":          "#8b4513",
        "lawngreen":            "#7cfc00",
        "dodgerblue":           "#1e90ff",
        "lime":                 "#00ff00",
        "linen":                "#faf0e6",
        "lightblue":            "#add8e6",
        "darkslategray":        "#2f4f4f",
        "lightskyblue":         "#87cefa",
        "mintcream":            "#f5fffa",
        "olive":                "#808000",
        "hotpink":              "#ff69b4",
        "papayawhip":           "#ffefd5",
        "mediumseagreen":       "#3cb371",
        "mediumspringgreen":    "#00fa9a",
        "cornflowerblue":       "#6495ed",
        "plum":                 "#dda0dd",
        "seagreen":             "#2e8b57",
        "palevioletred":        "#db7093",
        "bisque":               "#ffe4c4",
        "beige":                "#f5f5dc",
        "darkorchid":           "#9932cc",
        "royalblue":            "#4169e1",
        "darkolivegreen":       "#556b2f",
        "darkmagenta":          "#8b008b",
        "orange red":           "#ff4500",
        "lavender":             "#e6e6fa",
        "fuchsia":              "#ff00ff",
        "darkseagreen":         "#8fbc8f",
        "lavenderblush":        "#fff0f5",
        "wheat":                "#f5deb3",
        "steelblue":            "#4682b4",
        "lightgoldenrodyellow": "#fafad2",
        "lightcyan":            "#e0ffff",
        "mediumaquamarine":     "#66cdaa",
        "turquoise":            "#40e0d0",
        "dark blue":            "#00008b",
        "darkorange":           "#ff8c00",
        "brown":                "#a52a2a",
        "dimgray":              "#696969",
        "deeppink":             "#ff1493",
        "powderblue":           "#b0e0e6",
        "red":                  "#ff0000",
        "darkgreen":            "#006400",
        "ghostwhite":           "#f8f8ff",
        "white":                "#ffffff",
        "navajowhite":          "#ffdead",
        "navy":                 "#000080",
        "ivory":                "#fffff0",
        "palegreen":            "#98fb98",
        "whitesmoke":           "#f5f5f5",
        "gainsboro":            "#dcdcdc",
        "mediumslateblue":      "#7b68ee",
        "olivedrab":            "#6b8e23",
        "mediumpurple":         "#9370db",
        "darkslateblue":        "#483d8b",
        "blanchedalmond":       "#ffebcd",
        "darkkhaki":            "#bdb76b",
        "green":                "#008000",
        "limegreen":            "#32cd32",
        "snow":                 "#fffafa",
        "tomato":               "#ff6347",
        "darkturquoise":        "#00ced1",
        "orchid":               "#da70d6",
        "yellow":               "#ffff00",
        "green yellow":         "#adff2f",
        "azure":                "#f0ffff",
        "mistyrose":            "#ffe4e1",
        "cadetblue":            "#5f9ea0",
        "oldlace":              "#fdf5e6",
        "gray":                 "#808080",
        "honeydew":             "#f0fff0",
        "peachpuff":            "#ffdab9",
        "tan":                  "#d2b48c",
        "thistle":              "#d8bfd8",
        "palegoldenrod":        "#eee8aa",
        "mediumorchid":         "#ba55d3",
        "rosybrown":            "#bc8f8f",
        "mediumturquoise":      "#48d1cc",
        "lemonchiffon":         "#fffacd",
        "maroon":               "#800000",
        "mediumvioletred":      "#c71585",
        "violet":               "#ee82ee",
        "yellow green":         "#9acd32",
        "coral":                "#ff7f50",
        "lightgreen":           "#90ee90",
        "cornsilk":             "#fff8dc",
        "mediumblue":           "#0000cd",
        "aliceblue":            "#f0f8ff",
        "forestgreen":          "#228b22",
        "aquamarine":           "#7fffd4",
        "deepskyblue":          "#00bfff",
        "lightslategray":       "#778899",
        "darksalmon":           "#e9967a",
        "crimson":              "#dc143c",
        "sandybrown":           "#f4a460",
        "lightpink":            "#ffb6c1",
        "seashell":             "#fff5ee",
    ]
    
    func setValueByKey(params: inout ItemParams, key: String, value: String) {
        switch key {
        case "color":
            if value.hasPrefix("#") && value.count == 7 {
                params.Color = NSColor.fromHex(hexColor: value)
            } else if let c = colors[value] {
                params.Color = NSColor.fromHex(hexColor: c)
            }
            break
        case "bash", "shell":
            params.Shell = value
            break
        case "href":
            params.Href = value
            break
        case "refresh":
            params.Refresh = value == "true"
            break
        default:
            if key.hasPrefix("param") {
                let idx = key[key.index(key.startIndex, offsetBy: 5)...]
                if let index = Int(idx) {
                    while params.ShellParams.count != index {
                        params.ShellParams.append("")
                    }
                    params.ShellParams.insert(value, at: index - 1)
                    break
                } else {
                    print("bad parameter: \(key)")
                }
            } else {
                print("unknown parameter: \(key)")
            }
            break
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
            let offset = s.index(index, offsetBy: offsetShift)
            let keySub = s[...s.index(index, offsetBy: -1)]
            var key: String
            if keySub.first == "|" {
                key = String(keySub.dropFirst()).trimmingCharacters(in: .whitespacesAndNewlines)
            } else {
                key = String(keySub)
            }
            let valuePart = s[offset...]
            var end = valuePart.firstIndex(of: endStr)
            if end == nil {
                end = valuePart.firstIndex(of: "|")
                if end == nil {
                    end = valuePart.endIndex
                }
            }
            let value = s[offset...(s.index(end!, offsetBy: -1))]
            setValueByKey(params: &params, key: key, value: String(value))
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
