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
                            Text(recording.fileName)
                        }
                        Button(action: {
                            if recording.isPlaying {
                                viewModel.stopPlaying(url : recording.audioURL)
                            }else{
                                viewModel.startPlaying(url : recording.audioURL)
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
        ZStack(alignment : .center) {
            Circle()
                .stroke(.white, lineWidth: 3)
                .frame(width: 70, height: 70)
                .overlay(animatedRecording)
        }
    }
    
    var animatedRecording : some View {
        if viewModel.isRecording {
            return Image(systemName: "square.fill")
                .font(.system(size: 45))
                .foregroundColor(.red)
        } else {
            return Image(systemName: "circle.fill")
                .font(.system(size: 58))
                .foregroundColor(.red)
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
