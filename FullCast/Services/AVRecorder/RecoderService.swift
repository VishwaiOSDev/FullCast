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
    
    func recordAudio(_ fileName: String, on category: Category, completion: @escaping (Result<RecorderStatus,RecorderError>) -> ()) {
        let audioPath = URL.documents.appendingPathComponent(fileName)
        if !isRecording {
            do {
                audioRecorder = try AVAudioRecorder(url: audioPath, settings: Constants.settings)
                audioRecorder.prepareToRecord()
                audioRecorder.record()
                completion(.success(.startRecorder))
                CoreDataController.shared.saveRecording(fileName, category)
                isRecording = true
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
            isRecording = false
            audioRecorder = nil
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



