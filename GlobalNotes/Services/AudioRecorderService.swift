import AVFoundation
import Combine

/// Manages audio recording through AVAudioRecorder.
@MainActor
final class AudioRecorderService: ObservableObject {

    @Published var isRecording = false
    @Published var duration: TimeInterval = 0
    @Published var errorMessage: String?

    private var recorder: AVAudioRecorder?
    private var fileURL: URL?
    private var timer: Timer?

    // MARK: - Public

    func startRecording() {
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.playAndRecord, mode: .default, options: .defaultToSpeaker)
            try session.setActive(true)
        } catch {
            errorMessage = "Audio session error: \(error.localizedDescription)"
            return
        }

        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
            .appendingPathExtension("m4a")

        let settings: [String: Any] = [
            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
            AVSampleRateKey: 44100,
            AVNumberOfChannelsKey: 1,
            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
        ]

        do {
            recorder = try AVAudioRecorder(url: url, settings: settings)
            recorder?.record()
            fileURL = url
            isRecording = true
            duration = 0
            errorMessage = nil

            timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
                Task { @MainActor [weak self] in
                    guard let self, self.isRecording else { return }
                    self.duration = self.recorder?.currentTime ?? 0
                }
            }
        } catch {
            errorMessage = "Recording error: \(error.localizedDescription)"
        }
    }

    func stopRecording() -> URL? {
        timer?.invalidate()
        timer = nil
        recorder?.stop()
        isRecording = false
        return fileURL
    }

    func cancelRecording() {
        timer?.invalidate()
        timer = nil
        recorder?.stop()
        isRecording = false

        if let url = fileURL {
            try? FileManager.default.removeItem(at: url)
        }
        fileURL = nil
        duration = 0
    }
}
