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
        let directPath = "/Users/christiancattaneo/Projects/brainmaxx/Brainmaxx/Resources/music/Lobby Music (Original Soundtrack) 4.mp3"
        if FileManager.default.fileExists(atPath: directPath) {
            let url = URL(fileURLWithPath: directPath)
            print("✅ Found music file at direct path: \(url.path)")
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: url)
                audioPlayer?.numberOfLoops = -1 // Loop indefinitely
                audioPlayer?.volume = 0.5 // Set to 50% volume
                audioPlayer?.prepareToPlay() // Prepare the audio
                audioPlayer?.play()
                isPlaying = true
                print("✅ Successfully started playing background music")
                print("🔊 Volume: \(audioPlayer?.volume ?? 0), Duration: \(audioPlayer?.duration ?? 0)s")
                return
            } catch {
                print("❌ Failed to play background music from direct path: \(error)")
            }
        }
        
        // Fall back to bundle resource if direct path fails
        guard let url = Bundle.main.url(forResource: "Lobby Music (Original Soundtrack) 4", withExtension: "mp3", subdirectory: "Resources/music") else {
            print("❌ Could not find background music file in bundle")
            print("🔍 Attempted paths:")
            print("1. Direct path: \(directPath)")
            print("2. Bundle resource: Resources/music/Lobby Music (Original Soundtrack) 4.mp3")
            return
        }
        
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