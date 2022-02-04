//
//  VoiceRecodingView.swift
//  FullCast
//
//  Created by Vishwa  R on 04/02/22.
//

import SwiftUI

struct VoiceRecodingView: View {
    
    @StateObject var viewModel = AudioRecorderViewModel()
    
    var body: some View {
        VStack {
            ScrollView(showsIndicators : false) {
                ForEach(viewModel.recordingsList) { recording in
                    VStack {
                        HStack {
                            Image(systemName : "headphones.circle.fill")
                                .font(.title)
                            Text("\(recording.fileURL.lastPathComponent)")
                        }
                        Button(action: {
                            if recording.isPlaying {
                                viewModel.stopPlaying(url : recording.fileURL)
                            }else{
                                viewModel.startPlaying(url: recording.fileURL)
                            }
                        }) {
                            Image(systemName: recording.isPlaying ? "stop.fill" : "play.fill")
                                .foregroundColor(.white)
                                .font(.system(size:30))
                        }
                    }
                    .padding()
                    .frame(maxWidth : .infinity)
                    .background(Color(UIColor(red: 0.34, green: 0.34, blue: 0.34, alpha: 1.00)))
                    .cornerRadius(12)
                    .padding(.horizontal)
                }
            }
            Spacer()
            Button(action : recordButtonPressed) {
                recordingButton
            }
        }
        .onAppear {
            viewModel.fetchAllRecoding()
        }
    }
    
    var recordingButton : some View {
        ZStack {
            Circle()
                .frame(width: 60, height: 60)
                .foregroundColor(.red)
            if viewModel.isRecording {
                Circle()
                    .stroke(.white, lineWidth: 3)
                    .frame(width: 70, height: 70)
            }
        }
    }
    
    private func recordButtonPressed() {
        if viewModel.isRecording {
            viewModel.stopRecording()
            viewModel.fetchAllRecoding()
        } else {
            viewModel.startRecording()
        }
    }
}

struct VoiceRecodingView_Previews: PreviewProvider {
    static var previews: some View {
        VoiceRecodingView()
            .preferredColorScheme(.dark)
    }
}
