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

class ShareViewController: SLComposeServiceViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        // 이 자리에 공유 뷰의 구성 자리가 나옴
        isModalInPresentation = true
        
        if let itemProviders = (extensionContext!.inputItems.first as? NSExtensionItem)?.attachments {
            let hostingView = UIHostingController(rootView: ShareView(itemProviders: itemProviders, extensionContext: extensionContext))
            hostingView.view.frame = view.frame
            view.addSubview(hostingView.view)
        }
        
//        let screenCaptureView =
    }
}

fileprivate struct ShareView: View {
    @Environment(\.modelContext) private var modelContext
    var itemProviders: [NSItemProvider]
    var extensionContext: NSExtensionContext?
    @State private var items: [ImageItem] = []
    @Query private var folders: [Folder]
    //    @State var defaultFolder: Folder = Folder(id: UUID(), name: "임시저장폴더", color: "green", todos: [])
    
    var body: some View {
        GeometryReader {
            let size = $0.size
            VStack{
                Text("이미지 Todo 추가")
                    .font(.title3.bold())
                    .frame(maxWidth: .infinity)
                    .overlay(alignment: .leading) {
                        Button("취소"){
                            dismiss()
                        }
                        .tint(.red)
                    }
                    .padding(.bottom, 10)
                
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
                
                Button {
                    saveItems()
                } label: {
                    Text("저장")
                        .font(.title3)
                        .fontWeight(.semibold)
                        .padding(.vertical, 10)
                        .frame(maxWidth: .infinity)
                }
                
                
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
                let _ = provider.loadDataRepresentation(for: .image) { data, error in
                    if let data, let image = UIImage(data: data), let thumnail = image.preparingThumbnail(of: .init(width: size.width, height: 300)) {
                        // UI는 메인스레드에서 무조건 업데이트 되어야 함
                        DispatchQueue.main.async {
                            print("Test: \(data)")
                            items.append(.init(imageData: data, previewImage: thumnail))
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
            Options.self
        ])
        do {
            let context = try ModelContext(.init(for: schema.self))
            var imageData : [Data] = []
            for i in items {
                imageData.append(i.imageData)
            }
            let newTodo = Todo(id: UUID(), images: imageData, createdAt: Date(), options: Options(), isDone: false)
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
