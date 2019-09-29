//
//  ViewController.swift
//  hawking
//
//  Created by Rodrigo Pacheco Curro on 9/28/19.
//  Copyright © 2019 ropc. All rights reserved.
//

import Cocoa
import AppKit
import os

class ViewController: NSViewController {
    
    @IBOutlet var realHistoryView: NSTextView!

    let speechSynth = NSSpeechSynthesizer()
    var lastLength = 0

    var fontSize: CGFloat = 36

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        realHistoryView.delegate = self
        realHistoryView.font = .systemFont(ofSize: fontSize)
    }

    @IBAction func decreaseFontSize(_ sender: NSButton) {
        fontSize = max(fontSize - 4, 2)
        realHistoryView.font = .systemFont(ofSize: fontSize)
    }

    @IBAction func increaseFontSize(_ sender: NSButton) {
        fontSize += 4
        realHistoryView.font = .systemFont(ofSize: fontSize)
    }
}

extension ViewController: NSTextViewDelegate {

    var lastLine: String? {
        // this is kinda slow for large strings, should fix
        return realHistoryView.string.split(separator: "\n").last.flatMap { String($0) }
    }

    func textViewDidChangeSelection(_ notification: Notification) {
        let range = realHistoryView.selectedRange()
        if range.length > 0, let text = realHistoryView.string.substring(with: range) {
            speechSynth.say(text: String(text))
        }
    }

    func textDidChange(_ notification: Notification) {
        let allText = realHistoryView.string
        let oldLastLength = lastLength
        lastLength = allText.count
        guard allText.last == "\n", let text = lastLine, oldLastLength < allText.count else { return }
        speechSynth.say(text: text)
    }
}

extension String {
    func substring(with nsrange: NSRange) -> Substring? {
        guard let range = Range(nsrange, in: self) else { return nil }
        return self[range]
    }
}

extension NSSpeechSynthesizer {
    func say(text: String) {
        let speakableText = text
            .replacingOccurrences(of: "\\bidk\\b", with: "I D K", options: [.regularExpression, .caseInsensitive])
            .replacingOccurrences(of: "\\breddit\\b", with: "red itt", options: [.regularExpression, .caseInsensitive])
            .replacingOccurrences(of: "\\bminecraft\\b", with: "mine craft", options: [.regularExpression, .caseInsensitive])

        startSpeaking(speakableText)
    }
}

class IgnoreShiftTextView: NSTextView {
    var isShifting = false
    override func flagsChanged(with event: NSEvent) {
        isShifting = event.modifierFlags.contains(.shift)
        os_log("set isShifting %", isShifting ? "true" : "false")
        super.flagsChanged(with: event)
    }
    override func didChangeText() {
        if !isShifting {
            os_log("callidng super.didChangeText")
            super.didChangeText()
        }
    }
}
