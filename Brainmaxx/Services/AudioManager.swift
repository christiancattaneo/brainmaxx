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
        
        // Try to find the file in the bundle
        if let url = Bundle.main.url(forResource: "backgroundmusic", withExtension: "mp3", subdirectory: "Resources/music") {
            print("✅ Found music file in bundle at: \(url.path)")
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
        } else {
            print("❌ Could not find background music file in bundle")
            print("🔍 Attempted to find: backgroundmusic.mp3 in Resources/music")
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