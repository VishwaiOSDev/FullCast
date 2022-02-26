//
//  RecoderService.swift
//  FullCast
//
//  Created by Vishwa  R on 25/02/22.
//

import AVFoundation

enum RecorderError: Error {
    case permissionNotGranted
    case someOtherError(String)
}

enum RecorderStatus {
    case startRecorder
    case stopRecorder
}

final class RecorderService {
    
    static let shared = RecorderService() // Singleton
    
    private var microphonePermission: AVAudioSession.RecordPermission?
    private var audioRecorder: AVAudioRecorder!
    private var audioSession: AVAudioSession = AVAudioSession.sharedInstance()
    private var isRecording = false
    
    private init() {
        self.microphonePermission = setupRecordingSession()
    }
    
    func startRecording(completion: @escaping (Result<Bool, RecorderError>)->()) {
        switch(microphonePermission) {
        case.undetermined:
            audioSession.requestRecordPermission { $0 ? completion(.success(true)) : completion(.failure(.permissionNotGranted)) }
        case .denied:
            completion(.failure(.permissionNotGranted))
        case .granted:
            completion(.success(true))
        default:
            completion(.failure(.someOtherError("Permission Not Listed in here")))
            fatalError("Apple has introduced something new.")
        }
    }
    
    func recordAudio(_ url: URL, completion: @escaping (Result<RecorderStatus,RecorderError>) -> ()) {
        defer {
            isRecording = true
        }
        if !isRecording {
            do {
                audioRecorder = try AVAudioRecorder(url: url, settings: Constants.settings)
                audioRecorder.prepareToRecord()
                audioRecorder.record()
                completion(.success(.startRecorder))
            } catch {
                completion(.failure(.someOtherError(error.localizedDescription)))
                fatalError("Error while recording the audio file \(error.localizedDescription)")
            }
        } else {
            stopRecorder()
            completion(.success(.stopRecorder))
        }
    }
    
    func stopRecorder() {
        defer {
            audioRecorder = nil
            isRecording = false
        }
        audioRecorder.stop()
    }
    
    private func setupRecordingSession() -> AVAudioSession.RecordPermission {
        do {
            try audioSession.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker])
            try audioSession.setActive(true)
        } catch {
            print("Cannot setup recording \(error.localizedDescription)")
        }
        return audioSession.recordPermission
    }
}

extension RecorderError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .permissionNotGranted:
            return NSLocalizedString("Mirophone is not enabled", comment: "Enable Permission")
        case .someOtherError(let error):
            return NSLocalizedString(error, comment: "Catch Error")
        }
    }
}

