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
            recorderViewModel.getRecordings(of: selectedCategory)
        }
    }
    
    private var listView : some View {
        List {
            ForEach($recorderViewModel.listOfRecordings, id: \.id) { $recording in
                RecordingCell(record: $recording, recorderViewModel: recorderViewModel) {
                    if recording.isPlaying {
                        recorderViewModel.stopPlaying(id : recording.id)
                    } else {
                        recorderViewModel.startPlaying(id: recording.id, sliderDuration: recording.elapsedDuration)
                    }
                }
                .frame(height: 150)
                .buttonStyle(PlainButtonStyle())
            }
            .onDelete(perform: recorderViewModel.deleteRecordingOn)
            .onReceive(recorderViewModel.timer) { _ in
                if recorderViewModel.audioIsPlaying {
                    recorderViewModel.updateSlider()
                } else {
                    recorderViewModel.timer.upstream.connect().cancel()
                }
            }
        }
        .listStyle(GroupedListStyle())
        .onAppear {
            UITableViewCell.appearance().selectionStyle = .none
            UITableView.appearance().separatorStyle = .none
        }
    }
    
    private var footer : some View {
        recordingButton
            .onTapGesture(perform: recordButtonPressed)
            .alert(isPresented: $recorderViewModel.showAlert) {
                AlertService.shared.showSettingsAlertBox(title: MicrophoneAlertContent.title.rawValue, message: MicrophoneAlertContent.message.rawValue)
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
        RoundedRectangle(cornerRadius: recorderViewModel.recorderStatus == .startRecorder ? 5 : 80)
            .frame(width: recorderViewModel.recorderStatus == .startRecorder ? 40 : 60, height: recorderViewModel.recorderStatus == .startRecorder ? 40 : 60, alignment: .center)
            .foregroundColor(Color(UIColor.red))
    }
    
    private func recordButtonPressed() {
        guard let selectedCategory = selectedCategory else { return }
        recorderViewModel.checkPermissionAndStartOrStopRecorder(for: selectedCategory)
    }
}

//struct VoiceRecodingView_Previews: PreviewProvider {
//
//    static let recorderViewModel = RecorderViewModel()
//
//    static var previews: some View {
//        RecorderView(viewModel: recorderViewModel, category: Category())
//            .preferredColorScheme(.dark)
//    }
//}
