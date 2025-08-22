import Foundation
import UIKit

class DataManager: ObservableObject {
    static let shared = DataManager()
    
    @Published var notes: [Note] = []
    @Published var files: [StoredFile] = []
    @Published var images: [StoredImage] = []
    @Published var videos: [StoredVideo] = []
    
    private let notesKey = "SecretStorage_Notes"
    private let filesKey = "SecretStorage_Files"
    private let imagesKey = "SecretStorage_Images"
    private let videosKey = "SecretStorage_Videos"
    
    private init() {
        loadAllData()
    }
    
    // MARK: - Notes
    func addNote(_ note: Note) {
        notes.append(note)
        saveNotes()
    }
    
    func deleteNote(at index: Int) {
        notes.remove(at: index)
        saveNotes()
    }
    
    func updateNote(_ note: Note) {
        if let index = notes.firstIndex(where: { $0.id == note.id }) {
            notes[index] = note
            saveNotes()
        }
    }
    
    private func saveNotes() {
        if let encoded = try? JSONEncoder().encode(notes) {
            UserDefaults.standard.set(encoded, forKey: notesKey)
        }
    }
    
    private func loadNotes() {
        if let data = UserDefaults.standard.data(forKey: notesKey),
           let decoded = try? JSONDecoder().decode([Note].self, from: data) {
            notes = decoded
        }
    }
    
    // MARK: - Files
    func addFile(_ file: StoredFile) {
        files.append(file)
        saveFiles()
    }
    
    func deleteFile(at index: Int) {
        files.remove(at: index)
        saveFiles()
    }
    
    private func saveFiles() {
        if let encoded = try? JSONEncoder().encode(files) {
            UserDefaults.standard.set(encoded, forKey: filesKey)
        }
    }
    
    private func loadFiles() {
        if let data = UserDefaults.standard.data(forKey: filesKey),
           let decoded = try? JSONDecoder().decode([StoredFile].self, from: data) {
            files = decoded
        }
    }
    
    // MARK: - Images
    func addImage(_ image: StoredImage) {
        images.append(image)
        saveImages()
    }
    
    func deleteImage(at index: Int) {
        images.remove(at: index)
        saveImages()
    }
    
    private func saveImages() {
        if let encoded = try? JSONEncoder().encode(images) {
            UserDefaults.standard.set(encoded, forKey: imagesKey)
        }
    }
    
    private func loadImages() {
        if let data = UserDefaults.standard.data(forKey: imagesKey),
           let decoded = try? JSONDecoder().decode([StoredImage].self, from: data) {
            images = decoded
        }
    }
    
    // MARK: - Videos
    func addVideo(_ video: StoredVideo) {
        videos.append(video)
        saveVideos()
    }
    
    func deleteVideo(at index: Int) {
        videos.remove(at: index)
        saveVideos()
    }
    
    private func saveVideos() {
        if let encoded = try? JSONEncoder().encode(videos) {
            UserDefaults.standard.set(encoded, forKey: videosKey)
        }
    }
    
    private func loadVideos() {
        if let data = UserDefaults.standard.data(forKey: videosKey),
           let decoded = try? JSONDecoder().decode([StoredVideo].self, from: data) {
            videos = decoded
        }
    }
    
    // MARK: - Load All Data
    private func loadAllData() {
        loadNotes()
        loadFiles()
        loadImages()
        loadVideos()
    }
    
    // MARK: - Clear All Data
    func clearAllData() {
        notes.removeAll()
        files.removeAll()
        images.removeAll()
        videos.removeAll()
        
        UserDefaults.standard.removeObject(forKey: notesKey)
        UserDefaults.standard.removeObject(forKey: filesKey)
        UserDefaults.standard.removeObject(forKey: imagesKey)
        UserDefaults.standard.removeObject(forKey: videosKey)
    }
}
