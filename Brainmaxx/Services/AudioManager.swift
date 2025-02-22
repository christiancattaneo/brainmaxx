import Foundation
import AVFoundation

class AudioManager: ObservableObject {
    static let shared = AudioManager()
    private var audioPlayer: AVAudioPlayer?
    @Published var isPlaying = false
    
    private init() {
        setupAudioSession()
    }
    
    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.ambient, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("❌ Failed to setup audio session: \(error)")
        }
    }
    
    func playBackgroundMusic() {
        print("🎵 Attempting to play background music...")
        
        // Try direct file path first
        let directPath = "/Users/christiancattaneo/Projects/brainmaxx/Brainmaxx/Resources/Audio/backgroundmusic.mp3"
        let fileURL = URL(fileURLWithPath: directPath)
        
        if FileManager.default.fileExists(atPath: directPath) {
            print("✅ Found music file at direct path: \(directPath)")
            playAudioFromURL(fileURL)
        } else {
            // Try bundle as fallback
            if let url = Bundle.main.url(forResource: "backgroundmusic", withExtension: "mp3") {
                print("✅ Found music file in bundle at: \(url.path)")
                playAudioFromURL(url)
            } else {
                print("❌ Could not find background music file")
                print("📍 Tried paths:")
                print("   - Direct: \(directPath)")
                print("   - Bundle: \(Bundle.main.bundlePath)/backgroundmusic.mp3")
                
                // List contents of directory for debugging
                let resourcePath = (directPath as NSString).deletingLastPathComponent
                if let items = try? FileManager.default.contentsOfDirectory(atPath: resourcePath) {
                    print("📂 Contents of \(resourcePath):")
                    items.forEach { print("   - \($0)") }
                }
            }
        }
    }
    
    private func playAudioFromURL(_ url: URL) {
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.numberOfLoops = -1 // Loop indefinitely
            audioPlayer?.volume = 0.5 // Set to 50% volume
            audioPlayer?.prepareToPlay() // Prepare the audio
            audioPlayer?.play()
            isPlaying = true
            print("✅ Successfully started playing background music")
            print("🔊 Volume: \(audioPlayer?.volume ?? 0), Duration: \(audioPlayer?.duration ?? 0)s")
        } catch {
            print("❌ Failed to play background music: \(error)")
            print("🔍 Error details: \(error.localizedDescription)")
        }
    }
    
    func stopBackgroundMusic() {
        audioPlayer?.stop()
        isPlaying = false
        print("✅ Stopped background music")
    }
    
    func toggleBackgroundMusic() {
        if isPlaying {
            stopBackgroundMusic()
        } else {
            playBackgroundMusic()
        }
    }
} 