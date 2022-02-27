//
//  PlayingService.swift
//  FullCast
//
//  Created by Vishwa  R on 26/02/22.
//

import AVFoundation

final class PlayingService {
    
    static let shared = PlayingService() // Singleton
    
    var player: AVAudioPlayer!
    
    func getDetailsOfEachRecording(on selectedCategory: Category, recordingList: [Recording]) -> [Recorder.Details] {
        var recordings: [Recorder.Details] = []
        let path = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        for record in recordingList {
            let audioURL = URL(fileURLWithPath: path).appendingPathComponent(record.wrappedfileName)
            if let durationOfAudio = getDurationOfEachAudio(of: audioURL) {
                recordings.append(Recorder.Details(id: record.id!, fileName: record.wrappedfileName, audioURL: audioURL, createdAt: record.createdAt!, duration: durationOfAudio, elapsedDuration: 0.0, reminderDate: (record.whenToRemind ?? record.createdAt)!, reminderEnabled: record.reminderEnabled))
            }
        }
        return recordings
    }
    
    private func getDurationOfEachAudio(of url: URL) -> Double? {
        do {
            player = try AVAudioPlayer(contentsOf: url)
            return player.duration
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }
}


