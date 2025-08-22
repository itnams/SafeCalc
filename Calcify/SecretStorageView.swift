import SwiftUI
import PhotosUI
import UniformTypeIdentifiers
import Foundation
import UIKit
import AVKit

struct SecretStorageView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var dataManager = DataManager.shared
    @State private var selectedTab = 0
    @State private var showingAddNote = false
    @State private var showingFilePicker = false
    @State private var showingImagePicker = false
    @State private var showingVideoPicker = false
    @State private var selectedImages: [PhotosPickerItem] = []
    @State private var selectedVideos: [PhotosPickerItem] = []
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Tab selector
                Picker("Storage Type", selection: $selectedTab) {
                    Text("Notes").tag(0)
                    Text("Files").tag(1)
                    Text("Images").tag(2)
                    Text("Videos").tag(3)
                    Text("About").tag(4)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                // Content based on selected tab
                Group {
                    switch selectedTab {
                    case 0:
                        NotesView(showingAddNote: $showingAddNote)
                    case 1:
                        FilesView(showingFilePicker: $showingFilePicker)
                    case 2:
                        ImagesView(showingImagePicker: $showingImagePicker)
                    case 3:
                        VideosView(showingVideoPicker: $showingVideoPicker)
                    case 4:
                        AboutView()
                    default:
                        EmptyView()
                    }
                }
                
                Spacer()
            }
            .navigationTitle("Secret Storage")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: addNewItem) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddNote) {
                AddNoteView()
            }
            .fileImporter(
                isPresented: $showingFilePicker,
                allowedContentTypes: [.data],
                allowsMultipleSelection: true
            ) { result in
                handleFileImport(result)
            }
            .photosPicker(
                isPresented: $showingImagePicker,
                selection: $selectedImages,
                matching: .images
            )
            .photosPicker(
                isPresented: $showingVideoPicker,
                selection: $selectedVideos,
                matching: .videos
            )
            .onChange(of: selectedImages) { _ in
                if !selectedImages.isEmpty {
                    handleImageSelection()
                }
            }
            .onChange(of: selectedVideos) { _ in
                if !selectedVideos.isEmpty {
                    handleVideoSelection()
                }
            }
        }
    }
    
    private func addNewItem() {
        switch selectedTab {
        case 0:
            showingAddNote = true
        case 1:
            showingFilePicker = true
        case 2:
            showingImagePicker = true
        case 3:
            showingVideoPicker = true
        default:
            break
        }
    }
    
    private func handleFileImport(_ result: Result<[URL], Error>) {
        switch result {
        case .success(let urls):
            for url in urls {
                let fileName = url.lastPathComponent
                let file = StoredFile(
                    name: fileName,
                    url: url,
                    dateAdded: Date()
                )
                dataManager.addFile(file)
            }
        case .failure(let error):
            print("File import error: \(error)")
        }
    }
    
    private func handleImageSelection() {
        Task {
            for item in selectedImages {
                if let data = try? await item.loadTransferable(type: Data.self) {
                    let image = StoredImage(
                        name: "Image \(Date())",
                        imageData: data,
                        dateAdded: Date()
                    )
                    dataManager.addImage(image)
                }
            }
            selectedImages.removeAll()
        }
    }
    
    private func handleVideoSelection() {
        Task {
            for item in selectedVideos {
                if let data = try? await item.loadTransferable(type: Data.self) {
                    let video = StoredVideo(
                        name: "Video \(Date())",
                        videoData: data,
                        dateAdded: Date()
                    )
                    dataManager.addVideo(video)
                }
            }
            selectedVideos.removeAll()
        }
    }
}

// MARK: - Notes
struct Note: Identifiable, Codable {
    let id = UUID()
    var title: String
    var content: String
    var dateCreated: Date
}

struct NotesView: View {
    @ObservedObject private var dataManager = DataManager.shared
    @Binding var showingAddNote: Bool
    
    var body: some View {
        ScrollView {
            if dataManager.notes.isEmpty {
                VStack(spacing: 20) {
                    Image(systemName: "note.text")
                        .font(.system(size: 60))
                        .foregroundColor(.secondary)
                    Text("No notes yet")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    Text("Tap + button to add notes")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding()
            } else {
                LazyVStack(spacing: 12) {
                    ForEach(dataManager.notes) { note in
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(note.title)
                                        .font(.headline)
                                        .foregroundColor(.primary)
                                    
                                    Text(note.content)
                                        .font(.body)
                                        .lineLimit(3)
                                        .foregroundColor(.secondary)
                                    
                                    Text(note.dateCreated, style: .date)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                
                                Spacer()
                                
                                Button(action: {
                                    if let index = dataManager.notes.firstIndex(where: { $0.id == note.id }) {
                                        dataManager.deleteNote(at: index)
                                    }
                                }) {
                                    Image(systemName: "trash")
                                        .foregroundColor(.red)
                                        .font(.title3)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(12)
                        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
            }
        }
    }
}

struct AddNoteView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var dataManager = DataManager.shared
    @State private var title = ""
    @State private var content = ""
    
    var body: some View {
        NavigationView {
            Form {
                Section("Note Information") {
                    TextField("Title", text: $title)
                    TextField("Content", text: $content, axis: .vertical)
                        .lineLimit(5...10)
                }
            }
            .navigationTitle("Add Note")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveNote()
                    }
                    .disabled(title.isEmpty || content.isEmpty)
                }
            }
        }
    }
    
    private func saveNote() {
        let note = Note(
            title: title,
            content: content,
            dateCreated: Date()
        )
        dataManager.addNote(note)
        dismiss()
    }
}

// MARK: - Files
struct StoredFile: Identifiable, Codable {
    let id = UUID()
    var name: String
    var urlString: String
    var dateAdded: Date
    
    var url: URL {
        URL(string: urlString) ?? URL(fileURLWithPath: "")
    }
    
    init(name: String, url: URL, dateAdded: Date) {
        self.name = name
        self.urlString = url.absoluteString
        self.dateAdded = dateAdded
    }
}

struct FilesView: View {
    @ObservedObject private var dataManager = DataManager.shared
    @Binding var showingFilePicker: Bool
    
    var body: some View {
        ScrollView {
            if dataManager.files.isEmpty {
                VStack(spacing: 20) {
                    Image(systemName: "doc.on.doc")
                        .font(.system(size: 60))
                        .foregroundColor(.secondary)
                    Text("No files yet")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    Text("Tap + button to add files")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding()
            } else {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 2), spacing: 12) {
                    ForEach(dataManager.files) { file in
                        ZStack(alignment: .topTrailing) {
                            NavigationLink(destination: FileViewer(file: file)) {
                                VStack(spacing: 8) {
                                    // File icon with background
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(Color.blue.opacity(0.1))
                                            .frame(width: UIScreen.main.bounds.width / 2 - 24, height: UIScreen.main.bounds.width / 2 - 24)
                                        
                                        Image(systemName: "doc.fill")
                                            .font(.system(size: 40))
                                            .foregroundColor(.blue)
                                    }
                                    .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                                    
                                    VStack(spacing: 4) {
                                        Text(file.name)
                                            .font(.caption)
                                            .fontWeight(.medium)
                                            .foregroundColor(.primary)
                                            .lineLimit(1)
                                        
                                        Text(file.dateAdded, style: .date)
                                            .font(.caption2)
                                            .foregroundColor(.secondary)
                                    }
                                    .frame(maxWidth: .infinity)
                                }
                            }
                            .buttonStyle(PlainButtonStyle())
                            
                            // Delete button overlay
                            Button(action: {
                                if let index = dataManager.files.firstIndex(where: { $0.id == file.id }) {
                                    dataManager.deleteFile(at: index)
                                }
                            }) {
                                Image(systemName: "trash.circle.fill")
                                    .font(.title2)
                                    .foregroundColor(.red)
                                    .background(Color.white)
                                    .clipShape(Circle())
                                    .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 1)
                            }
                            .buttonStyle(PlainButtonStyle())
                            .padding(8)
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
            }
        }
    }
}

// MARK: - Images
struct StoredImage: Identifiable, Codable {
    let id = UUID()
    var name: String
    var imageData: Data
    var dateAdded: Date
}

struct ImagesView: View {
    @ObservedObject private var dataManager = DataManager.shared
    @Binding var showingImagePicker: Bool
    
    var body: some View {
        ScrollView {
            if dataManager.images.isEmpty {
                VStack(spacing: 20) {
                    Image(systemName: "photo.on.rectangle.angled")
                        .font(.system(size: 60))
                        .foregroundColor(.secondary)
                    Text("No images yet")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    Text("Tap + button to add images")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding()
            } else {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 2), spacing: 12) {
                    ForEach(dataManager.images) { image in
                        ZStack(alignment: .topTrailing) {
                            NavigationLink(destination: ImageViewer(image: image)) {
                                VStack(spacing: 8) {
                                    if let uiImage = UIImage(data: image.imageData) {
                                        Image(uiImage: uiImage)
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(width: UIScreen.main.bounds.width / 2 - 24, height: UIScreen.main.bounds.width / 2 - 24)
                                            .clipped()
                                            .cornerRadius(12)
                                            .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                                    }
                                    
                                    VStack(spacing: 4) {
                                        Text(image.name)
                                            .font(.caption)
                                            .fontWeight(.medium)
                                            .foregroundColor(.primary)
                                            .lineLimit(1)
                                        
                                        Text(image.dateAdded, style: .date)
                                            .font(.caption2)
                                            .foregroundColor(.secondary)
                                    }
                                    .frame(maxWidth: .infinity)
                                }
                            }
                            .buttonStyle(PlainButtonStyle())
                            
                            // Delete button overlay
                            Button(action: {
                                if let index = dataManager.images.firstIndex(where: { $0.id == image.id }) {
                                    dataManager.deleteImage(at: index)
                                }
                            }) {
                                Image(systemName: "trash.circle.fill")
                                    .font(.title2)
                                    .foregroundColor(.red)
                                    .background(Color.white)
                                    .clipShape(Circle())
                                    .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 1)
                            }
                            .buttonStyle(PlainButtonStyle())
                            .padding(8)
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
            }
        }
    }
}

// MARK: - Videos
struct StoredVideo: Identifiable, Codable {
    let id = UUID()
    var name: String
    var videoData: Data
    var dateAdded: Date
}

struct VideosView: View {
    @ObservedObject private var dataManager = DataManager.shared
    @Binding var showingVideoPicker: Bool
    
    var body: some View {
        ScrollView {
            if dataManager.videos.isEmpty {
                VStack(spacing: 20) {
                    Image(systemName: "video.badge.plus")
                        .font(.system(size: 60))
                        .foregroundColor(.secondary)
                    Text("No videos yet")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    Text("Tap + button to add videos")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding()
            } else {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 2), spacing: 12) {
                    ForEach(dataManager.videos) { video in
                        ZStack(alignment: .topTrailing) {
                            NavigationLink(destination: VideoPlayerViewer(video: video)) {
                                VStack(spacing: 8) {
                                    // Video thumbnail with play button overlay
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(Color.gray.opacity(0.2))
                                            .frame(width: UIScreen.main.bounds.width / 2 - 24, height: UIScreen.main.bounds.width / 2 - 24)
                                        
                                        Image(systemName: "play.circle.fill")
                                            .font(.system(size: 50))
                                            .foregroundColor(.white)
                                            .foregroundColor(.white)
                                            .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                                    }
                                    .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                                    
                                    VStack(spacing: 4) {
                                        Text(video.name)
                                            .font(.caption)
                                            .fontWeight(.medium)
                                            .foregroundColor(.primary)
                                            .lineLimit(1)
                                        
                                        Text(video.dateAdded, style: .date)
                                            .font(.caption2)
                                            .foregroundColor(.secondary)
                                    }
                                    .frame(maxWidth: .infinity)
                                }
                            }
                            .buttonStyle(PlainButtonStyle())
                            
                            // Delete button overlay
                            Button(action: {
                                if let index = dataManager.videos.firstIndex(where: { $0.id == video.id }) {
                                    dataManager.deleteVideo(at: index)
                                }
                            }) {
                                Image(systemName: "trash.circle.fill")
                                    .font(.title2)
                                    .foregroundColor(.red)
                                    .background(Color.white)
                                    .clipShape(Circle())
                                    .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 1)
                            }
                            .buttonStyle(PlainButtonStyle())
                            .padding(8)
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
            }
        }
    }
}

#Preview {
    SecretStorageView()
}

// MARK: - Image Viewer
struct ImageViewer: View {
    let image: StoredImage
    @Environment(\.dismiss) private var dismiss
    @State private var showingShareSheet = false
    
    var body: some View {
        NavigationView {
            VStack {
                Spacer()
                
                if let uiImage = UIImage(data: image.imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding()
                } else {
                    VStack(spacing: 20) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 60))
                            .foregroundColor(.red)
                        Text("Failed to load image")
                            .font(.headline)
                            .foregroundColor(.red)
                        Text("Image data is corrupted or invalid")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                
                Spacer()
            }
            .background(Color.black)
            .navigationTitle(image.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingShareSheet = true
                    }) {
                        Image(systemName: "square.and.arrow.up")
                            .foregroundColor(.white)
                    }
                }
            }
        }
        .sheet(isPresented: $showingShareSheet) {
            if let uiImage = UIImage(data: image.imageData) {
                ShareSheet(activityItems: [uiImage])
            }
        }
    }
}

// MARK: - Video Player
struct VideoPlayerViewer: View {
    let video: StoredVideo
    @Environment(\.dismiss) private var dismiss
    @State private var showingShareSheet = false
    
    var body: some View {
        NavigationView {
            VStack {
                Spacer()
                
                CustomVideoPlayer(videoData: video.videoData)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding()
                
                Spacer()
            }
            .background(Color.black)
            .navigationTitle(video.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingShareSheet = true
                    }) {
                        Image(systemName: "square.and.arrow.up")
                            .foregroundColor(.white)
                    }
                }
            }
        }
        .sheet(isPresented: $showingShareSheet) {
            ShareSheet(activityItems: [video.videoData])
        }
    }
}

// MARK: - File Viewer
struct FileViewer: View {
    let file: StoredFile
    @Environment(\.dismiss) private var dismiss
    @State private var showingShareSheet = false
    @State private var fileContent: String = ""
    
    var body: some View {
        NavigationView {
            VStack {
                ScrollView {
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Image(systemName: "doc")
                                .foregroundColor(.blue)
                                .font(.title2)
                            
                            VStack(alignment: .leading) {
                                Text(file.name)
                                    .font(.headline)
                                Text(file.dateAdded, style: .date)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            Spacer()
                        }
                        .padding(.bottom)
                        
                        if !fileContent.isEmpty {
                            Text("File Content:")
                                .font(.headline)
                            Text(fileContent)
                                .font(.body)
                                .padding()
                                .background(Color.gray.opacity(0.1))
                                .cornerRadius(8)
                        } else {
                            Text("File preview not available")
                                .foregroundColor(.secondary)
                                .padding()
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("File Viewer")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showingShareSheet = true
                    }) {
                        Image(systemName: "square.and.arrow.up")
                    }
                }
            }
        }
        .sheet(isPresented: $showingShareSheet) {
            ShareSheet(activityItems: [file.url])
        }
        .onAppear {
            loadFileContent()
        }
    }
    
    private func loadFileContent() {
        // Try to load file content as text
        do {
            let data = try Data(contentsOf: file.url)
            if let content = String(data: data, encoding: .utf8) {
                fileContent = content
            }
        } catch {
            print("Could not load file content: \(error)")
        }
    }
}

// MARK: - Video Player View (AVKit)
import AVKit

struct CustomVideoPlayer: View {
    let videoData: Data
    @State private var player: AVPlayer?
    
    var body: some View {
        Group {
            if let player = player {
                VideoPlayer(player: player)
                    .onAppear {
                        player.play()
                    }
                    .onDisappear {
                        player.pause()
                    }
            } else {
                VStack {
                    Image(systemName: "video")
                        .font(.system(size: 60))
                        .foregroundColor(.secondary)
                    Text("Video loading...")
                        .foregroundColor(.secondary)
                }
            }
        }
        .onAppear {
            setupPlayer()
        }
    }
    
    private func setupPlayer() {
        // Create temporary file and setup player
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("temp_video.mp4")
        
        do {
            try videoData.write(to: tempURL)
            player = AVPlayer(url: tempURL)
        } catch {
            print("Error setting up video player: \(error)")
        }
    }
}

// MARK: - Share Sheet
struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// MARK: - About
struct AboutView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                // App Icon
                Image(systemName: "lock.shield.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.blue)
                
                // App Name and Version
                VStack(spacing: 10) {
                    Text("SafeCalc")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Secret Calculator & Storage")
                        .font(.title2)
                        .foregroundColor(.secondary)
                    
                    Text("Version 1.0.0")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                // App Description
                VStack(spacing: 15) {
                    Text("About")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Text("Calcify is a secret calculator app that disguises itself as a regular calculator while providing a hidden secure storage for your private files, notes, images, and videos.")
                        .font(.body)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                        .padding(.horizontal)
                }
                
                // Features
                VStack(spacing: 15) {
                    Text("Features")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    VStack(spacing: 10) {
                        FeatureRow(icon: "plus.forwardslash.minus", title: "Full Calculator", description: "Complete mathematical operations")
                        FeatureRow(icon: "lock.shield", title: "Password Protection", description: "Secure access with numeric password")
                        FeatureRow(icon: "note.text", title: "Secret Notes", description: "Store private text notes")
                        FeatureRow(icon: "doc.on.doc", title: "File Storage", description: "Hide important documents")
                        FeatureRow(icon: "photo", title: "Image Vault", description: "Secure photo storage")
                        FeatureRow(icon: "video", title: "Video Archive", description: "Private video collection")
                    }
                }
                
                // Developer Info
                VStack(spacing: 15) {
                    Text("Developer")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    VStack(spacing: 10) {
                        HStack {
                            Image(systemName: "person.circle.fill")
                                .foregroundColor(.blue)
                            Text("Nael Nguyen")
                                .font(.title3)
                                .fontWeight(.medium)
                        }
                        
                        Button(action: {
                            if let url = URL(string: "https://naelnguyen.dev") {
                                UIApplication.shared.open(url)
                            }
                        }) {
                            HStack {
                                Image(systemName: "globe")
                                    .foregroundColor(.blue)
                                Text("naelnguyen.dev")
                                    .foregroundColor(.blue)
                                    .underline()
                            }
                        }
                    }
                }
                
                // Copyright
                Text("© 2025 Calcify. All rights reserved.")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.top, 20)
            }
            .padding()
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.blue)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding(.horizontal)
    }
}
