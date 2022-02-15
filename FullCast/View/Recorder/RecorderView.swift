//
//  VoiceRecodingView.swift
//  FullCast
//
//  Created by Vishwa  R on 04/02/22.
//

import SwiftUI

struct RecorderView: View {
    
    @StateObject var recorderViewModel = RecorderViewModel()
    var selectedCategory : Category?
    
    var body: some View {
        VStack {
            listView
            Spacer()
            footer
        }
        .navigationTitle(selectedCategory!.wrappedCategoryName)
        .onAppear {
            guard let selectedCategory = selectedCategory else { return }
            recorderViewModel.getStoredRecordings(for: selectedCategory)
        }
    }
    
    private var listView : some View {
        List {
            ForEach($recorderViewModel.recordingsList) { $recording in
                RecordingCell(record: $recording, recorderViewModel: recorderViewModel) {
                    if recording.isPlaying {
                        recorderViewModel.stopPlaying(url : recording.audioURL)
                    } else {
                        recorderViewModel.startPlaying(url : recording.audioURL, sliderDuration: recording.elapsedDuration)
                    }
                }
                .buttonStyle(PlainButtonStyle())
            }
            .onDelete(perform: recorderViewModel.deleteRecordingOn)
            .onReceive(recorderViewModel.timer) { time in
                if recorderViewModel.audioIsPlaying {
                    recorderViewModel.updateSlider()
                }
            }
        }
        .listStyle(PlainListStyle())
        .onAppear {
            UITableViewCell.appearance().selectionStyle = .none
            UITableView.appearance().separatorStyle = .none
        }
    }
    
    private var footer : some View {
        recordingButton
            .onTapGesture(perform: recordButtonPressed)
            .alert(isPresented: $recorderViewModel.showAlert) {
                guard let alertDetails = recorderViewModel.alertDetails else { fatalError("Failed to load alert details") }
                return Alert(
                    title: Text(alertDetails.alertTitle),
                    message: Text(alertDetails.alertMessage),
                    primaryButton: .cancel(Text("Cancel")),
                    secondaryButton: .default(Text("Settings"), action: recorderViewModel.openSettings)
                )
            }
            .frame(maxWidth : .infinity)
            .padding()
            .padding(.vertical, 14)
            .background(Color(UIColor(Color(hue: 1.0, saturation: 0.0, brightness: 0.101))))
    }
    
    private var recordingButton : some View {
        ZStack(alignment : .center) {
            Circle()
                .stroke(.white, lineWidth: 3)
                .frame(width: 70, height: 70)
                .overlay(animatedRecording)
        }
    }
    
    private var animatedRecording : some View {
        RoundedRectangle(cornerRadius: recorderViewModel.isRecording ? 5 : 80)
            .frame(width: recorderViewModel.isRecording ? 40 : 60, height: recorderViewModel.isRecording ? 40 : 60, alignment: .center)
            .foregroundColor(Color(UIColor.red))
    }
    
    private func recordButtonPressed() {
        guard let selectedCategory = selectedCategory else { return }
        if recorderViewModel.isRecording {
            recorderViewModel.stopRecording()
            recorderViewModel.getStoredRecordings(for: selectedCategory)
        } else {
            recorderViewModel.startRecording(on: selectedCategory)
        }
    }
    
    private func performDelete(at offset : IndexSet) {
        recorderViewModel.recordingsList.remove(atOffsets: offset)
    }
}

struct VoiceRecodingView_Previews: PreviewProvider {
    static var previews: some View {
        RecorderView()
            .preferredColorScheme(.dark)
    }
}
