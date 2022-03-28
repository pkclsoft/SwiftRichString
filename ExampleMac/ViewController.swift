//
//  ViewController.swift
//  ExampleMac
//
//  Created by Daniele Margutti on 05/05/2018.
//  Copyright © 2018 SwiftRichString. All rights reserved.
//

import Cocoa
import AppKit

class ViewController: NSViewController {

    let baseFontSize: CGFloat = 16

	override var representedObject: Any? {
		didSet {
        }
    }
    
    override func viewDidLoad() {
        // Update the view, if already loaded.
        let bodyHTML = try! String(contentsOfFile: Bundle.main.path(forResource: "file", ofType: "txt")!)
        
        // Create a set of styles
        
        let headerStyle = Style {
            $0.font = NSFont.boldSystemFont(ofSize: self.baseFontSize * 1.15)
            $0.lineSpacing = 1
            $0.kerning = Kerning.adobe(-20)
        }
        let boldStyle = Style {
            $0.font = NSFont.boldSystemFont(ofSize: self.baseFontSize)
        }
        let italicStyle = Style {
            $0.font = NSFont.boldSystemFont(ofSize: self.baseFontSize * 1.15)
        }
        
        let uppercasedRed = Style {
            $0.font = NSFont.boldSystemFont(ofSize: self.baseFontSize * 1.15)
            $0.color = NSColor.red
            $0.textTransforms = [
                .uppercase
            ]
        }
        
        // And a group of them
        let styleGroup = StyleGroup(base: Style {
            $0.font = NSFont.systemFont(ofSize: self.baseFontSize)
            $0.lineSpacing = 2
            $0.kerning = Kerning.adobe(-15)
        }, [
            "ur": uppercasedRed,
            "h3": headerStyle,
            "h4": headerStyle,
            "h5": headerStyle,
            "strong": boldStyle,
            "b": boldStyle,
            "em": italicStyle,
            "i": italicStyle,
            "a": uppercasedRed,
            "li": Style {
                $0.paragraphSpacingBefore = self.baseFontSize / 2
                $0.firstLineHeadIndent = self.baseFontSize
                $0.headIndent = self.baseFontSize * 1.71
            },
            "sup": Style {
                $0.font = NSFont.systemFont(ofSize: self.baseFontSize / 1.2)
                $0.baselineOffset = Float(self.baseFontSize) / 3.5
            }])
        
        // Apply a custom xml attribute resolver
        styleGroup.xmlAttributesResolver = MyXMLDynamicAttributesResolver()
        
        // Render
        self.textView?.textStorage?.setAttributedString(bodyHTML.set(style: styleGroup))
	}

    @IBOutlet var textView: NSTextView!
    
}

extension NSColor {
    
    public static func randomColors(_ count: Int) -> [NSColor] {
        return (0..<count).map { _ -> NSColor in
            randomColor()
        }
    }
    
    public static func randomColor() -> NSColor {
        let redValue = CGFloat.random(in: 0...1)
        let greenValue = CGFloat.random(in: 0...1)
        let blueValue = CGFloat.random(in: 0...1)
        
        let randomColor = NSColor(red: redValue, green: greenValue, blue: blueValue, alpha: 1.0)
        return randomColor
    }
    
}
public class MyXMLDynamicAttributesResolver: StandardXMLAttributesResolver {
    
    public override func styleForUnknownXMLTag(_ tag: String, to attributedString: inout AttributedString, attributes: [String : String]?, fromStyle forStyle: StyleXML) {
        super.styleForUnknownXMLTag(tag, to: &attributedString, attributes: attributes, fromStyle: forStyle)
        
        if tag == "rainbow" {
            let colors = NSColor.randomColors(attributedString.length)
            for i in 0..<attributedString.length {
                attributedString.add(style: Style({
                    $0.color = colors[i]
                }), range: NSMakeRange(i, 1))
            }
        }
        
    }
    
}
