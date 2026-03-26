import SwiftUI

/// Records audio and inserts an HTML placeholder into the editor.
struct AudioRecorderView: View {
    let onInsert: (String) -> Void

    @StateObject private var recorder = AudioRecorderService()
    @State private var recordedURL: URL?
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Spacer()

                // Duration display
                Text(formattedDuration)
                    .font(.system(size: 48, weight: .light, design: .monospaced))
                    .foregroundStyle(recorder.isRecording ? .red : .primary)

                // Record / Stop button
                Button {
                    if recorder.isRecording {
                        recordedURL = recorder.stopRecording()
                    } else {
                        recorder.startRecording()
                        recordedURL = nil
                    }
                } label: {
                    Image(systemName: recorder.isRecording ? "stop.circle.fill" : "mic.circle.fill")
                        .font(.system(size: 72))
                        .foregroundStyle(recorder.isRecording ? .red : .accentColor)
                }

                if let error = recorder.errorMessage {
                    Text(error)
                        .font(.caption)
                        .foregroundStyle(.red)
                }

                // Insert button (shown after recording)
                if recordedURL != nil {
                    Button {
                        let html = """
                        <div style="display:flex;align-items:center;gap:8px;\
                        padding:12px;background:#e8f4fd;border-radius:8px;\
                        margin:8px 0;font-family:system-ui;">
                            <span style="font-size:24px;">🎙️</span>
                            <span>Audio Recording — \(formattedDuration)</span>
                        </div>
                        """
                        onInsert(html)
                        dismiss()
                    } label: {
                        Label("Insert Recording", systemImage: "plus.circle.fill")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.accentColor)
                            .foregroundStyle(.white)
                            .cornerRadius(12)
                    }
                    .padding(.horizontal)
                }

                Spacer()
            }
            .padding()
            .navigationTitle("Audio Recorder")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        recorder.cancelRecording()
                        dismiss()
                    }
                }
            }
        }
    }

    private var formattedDuration: String {
        let total = Int(recorder.duration)
        let minutes = total / 60
        let seconds = total % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
