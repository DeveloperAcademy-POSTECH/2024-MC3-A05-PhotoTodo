//
//  ShareViewController.swift
//  ShareTodoImage
//
//  Created by leejina on 8/7/24.
//
import SwiftUI
import UIKit
import Social
import SwiftData
import UniformTypeIdentifiers

class ShareViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        // 이 자리에 공유 뷰의 구성 자리가 나옴
        do{
            // 📌 App Group 기반 SwiftData Configuration
           let config = ModelConfiguration(
               groupContainer: .identifier("group.PhotoTodo-com.2024-MC3-A05-team5.PhotoTodo")
           )
           let container = try ModelContainer(
               for: Folder.self, FolderOrder.self, Todo.self, Options.self,
               configurations: config
           )
           let context = ModelContext(container)

            if let itemProviders = (extensionContext!.inputItems.first as? NSExtensionItem)?.attachments {
                let shareView = ShareView(
                                itemProviders: itemProviders,
                                extensionContext: extensionContext
                            )
                            .modelContainer(container)
                let hostingView = UIHostingController(rootView: shareView)
                hostingView.view.frame = view.frame
                view.addSubview(hostingView.view)
            }
    //        let screenCaptureView =
        }  catch {
            fatalError("Failed to configure SwiftData container.")
        }
    }
}

struct ShareView: View {
    @Environment(\.modelContext) private var modelContext
    var itemProviders: [NSItemProvider]
    var extensionContext: NSExtensionContext?
    @State private var items: [ImageItem] = []
    @State private var chosenFolder: Folder? = nil
    @State private var inputText = ""
    //    @State var defaultFolder: Folder = Folder(id: UUID(), name: "임시저장폴더", color: "green", todos: [])
    
    var body: some View {
        GeometryReader {
            let size = $0.size
            VStack{
                HStack{
                    Button("취소"){
                        dismiss()
                    }
                    .tint(.red)
                    Spacer()
                    Text("이미지 Todo 추가")
                        .font(.title3.bold())
                    Spacer()
                    Button {
                        saveItems()
                    } label: {
                        Text("저장")
                            .tint(.blue)
                            .fontWeight(.semibold)
                    }
                }
                .padding(.vertical, 10)
                .frame(maxWidth: .infinity)
                
                FolderCarouselView(chosenFolder: $chosenFolder)
                
                ScrollView(.horizontal) {
                    HStack {
                        ForEach(items) { item in
                            Image(uiImage: item.previewImage)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: size.width - 30)
                            
                        }
                    }
                }
                .scrollTargetBehavior(.viewAligned)
                .frame(height: 300) // 이미지 사진 크기를 줄일 때 사용됨
                .scrollIndicators(.hidden)
                TextField("메모를 입력하세요", text: $inputText)
                Spacer(minLength: 0)
            }
            .padding(15)
            .onAppear(perform: {
                extractItems(size: size)
                //                defaultFolder = folders.first ?? Folder(id: UUID(), name: "임시저장폴더", color: "green", todos: [])
            })
        }
    }
    
    func extractItems(size: CGSize) {
        guard items.isEmpty else { return }

        DispatchQueue.global(qos: .userInteractive).async {
            for provider in itemProviders {
                // Attempt to load the item as a UIImage first (screenshots might be UIImages)
                provider.loadItem(forTypeIdentifier: UTType.image.identifier, options: nil) { item, error in
                    if let image = item as? UIImage {
                        DispatchQueue.main.async {
                            // Generate a thumbnail
                            if let thumbnail = image.preparingThumbnail(of: .init(width: size.width, height: 300)) {
                                items.append(.init(imageData: image.pngData() ?? Data(), previewImage: thumbnail))
                            }
                        }
                    } else {
                        // Fallback to loading data representation if it's not a direct UIImage
                        provider.loadDataRepresentation(for: .image) { data, error in
                            if let data, let image = UIImage(data: data), let thumbnail = image.preparingThumbnail(of: .init(width: size.width, height: 300)) {
                                DispatchQueue.main.async {
                                    items.append(.init(imageData: data, previewImage: thumbnail))
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    func saveItems() {
        let schema = Schema([
            Folder.self,
            Todo.self,
            Options.self,
            FolderOrder.self
        ])
        do {
            let context = try ModelContext(.init(for: schema.self))
            var imageData : [Data] = []
            for i in items {
                imageData.append(i.imageData)
            }
            // SwiftData에 저장된 Folder의 기본폴더로 초기화 저장됨
            let fetchDescriptor = FetchDescriptor<Folder>()
            let result = try context.fetch(fetchDescriptor)
            let newTodo = Todo(folder: chosenFolder ?? result.first ?? Folder(id: UUID(), name: "기본", color: "green", todos: []), id: UUID(), images: imageData, createdAt: Date(), options: Options(memo: inputText), isDone: false)
            context.insert(newTodo)
            try context.save()
            dismiss()
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
        
//        let newTodo = Todo(id: UUID(), image: Data(), createdAt: Date(), options: Options(), isDone: false)
//        modelContext.insert(newTodo)
        dismiss()
    }
    
    func dismiss() {
        extensionContext?.completeRequest(returningItems: [])
    }
    
    private struct ImageItem: Identifiable {
        let id: UUID = .init()
        var imageData: Data
        var previewImage: UIImage
    }
}
