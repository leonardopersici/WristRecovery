//
//  SpeechService.swift
//  WristRecovery
//
//  Created by leonardo persici on 29/09/22.
//  Copyright © 2022 Apple. All rights reserved.
//

import Foundation
import AVKit

class SpeechService: NSObject {
    
    static let shared = SpeechService()
    
    let speechSythisizer = AVSpeechSynthesizer()
    
    func startSpeech (text: String){
        self.stopSpeeching()
        
        if let language = NSLinguisticTagger.dominantLanguage(for: text) {
        
            let utterence = AVSpeechUtterance(string: text)
            utterence.voice = AVSpeechSynthesisVoice(language: language)
            
            speechSythisizer.speak(utterence)
        }
    }
    
    func stopSpeeching() {
        speechSythisizer.stopSpeaking(at: .immediate)
    }
}
