//
//  MakeTodoView.swift
//  PhotoTodo
//
//  Created by leejina on 7/31/24.
//

import SwiftUI
import SkeletonUI
import UIKit
import SwiftData
import PhotosUI

enum startViewType {
    case camera
    case edit
    case gridMain
    case gridSingleFolder
}

struct SharedImage: Transferable {
    static var transferRepresentation: some TransferRepresentation {
        ProxyRepresentation(exporting: \.image)
    }
    
    public var image: Image
    
    init(image: Image) {
        self.image = image
    }
}


struct MakeTodoView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var cameraVM = CameraViewModel.shared
    @State private var cameraManager = CameraManager()
    @Binding var chosenFolder: Folder?
    var startViewType: startViewType
    
    // 내부 컨텐츠
    @Binding var contentAlarm: Date?
    @Binding var alarmID: String?
    @State private var folderMenuisActive: Bool = false
    @State private var alarmisActive: Bool = false
    @Binding var alarmDataisEmpty: Bool?
    @State private var memoisActive: Bool = false
    @Binding var memo: String?
    @State var newMemo: String = ""
    @Query private var folders: [Folder]
    @Binding var home: Bool?
    
    // 이미지 처리관련
    @State private var imageClickisActive: Bool = false
    @State private var clickedImage: UIImage?
    @State private var imageScale: CGFloat = 1.0
    private var magnification: some Gesture {
        MagnifyGesture()
            .onChanged { value in
                imageScale = value.magnification
            }
    }
    
    //이미지 추가 관련 변수들
    @State private var showingImagePicker = false
    @State private var selectedItems = [PhotosPickerItem]()
    @State private var selectedIndexs: Int = 0
    
    //알람 설정 관련
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    @State var isCameraSheetOn: Bool = false
    
    
    let manager = NotificationManager.instance
    
    
    var chosenFolderColor : Color{
        return chosenFolder != nil ? changeStringToColor(colorName: chosenFolder?.color ?? "green") : changeStringToColor(colorName: folders[0].color)
    }
    var chosenFolderName : String{
        return chosenFolder != nil ? chosenFolder!.name : folders[0].name
    }
    
    var body: some View {
        ScrollView {
            ZStack {
                VStack(alignment: .center, spacing: 20){
                    ZStack(alignment: .topTrailing) {
                        TabView(selection: $selectedIndexs) {
                            ForEach(cameraVM.photoData.indices, id: \.self) { index in
                                let imageData: Data = cameraVM.photoData[index]
                                let uiImage = UIImage(data: imageData)
                                ZStack(alignment: .trailing) {
                                    Button(action: {
                                        imageClickisActive = true
                                        clickedImage = uiImage
                                    }, label: {
                                        Image(uiImage: uiImage)
                                            .resizable()
                                            .scaledToFill()
                                            .skeleton(with: cameraVM.photoData.isEmpty,
                                                      animation: .pulse(),
                                                      appearance: .solid(color: Color.paleGray, background: Color.lightGray),
                                                      shape: .rectangle,
                                                      lines: 1,
                                                      scales: [1: 1])
                                            .frame(height: UIScreen.main.bounds.size.height * 0.6)
                                            .clipShape(RoundedRectangle(cornerRadius: 25))
                                    })
                                }
                            }
                        }
                        .tabViewStyle(PageTabViewStyle())
                        .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
                        .frame(height: UIScreen.main.bounds.size.height * 0.6)
                        .clipShape(RoundedRectangle(cornerRadius: 25))
                        
                        HStack {
                            if startViewType == .edit {
                                Button {
                                    let imageData: Data = cameraVM.photoData[self.selectedIndexs]
                                    let uiImage = UIImage(data: imageData)
                                    if let shareImage = uiImage {
                                        saveImageToAlbum(image: shareImage)
                                    }
                                } label: {
                                    Image(systemName: "square.and.arrow.up")
                                        .resizable()
                                        .frame(width: 20, height: 30)
                                }
                                .alert(isPresented: $showAlert) {
                                    Alert(title: Text("이미지 저장완료"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
                                }
                                
                            } else {
                                if cameraVM.photoData.count > 1 {
                                    Button {
                                        cameraVM.photoData.remove(at: self.selectedIndexs)
                                    } label: {
                                        Image("deleteImage")
                                            .aspectRatio(contentMode: .fit)
                                    }
                                }
                            }
                        }
                        .padding(.trailing, 20)
                        .padding(.top, 20)
                    }
                    VStack {
                        ZStack{
                            RoundedRectangle(cornerRadius: 20) // 원하는 radius 값
                                .fill(Color.paleGray) // 배경색 설정
                            List {
                                Section{
                                    HStack{
                                        Text("폴더")
                                        Spacer()
                                        Group{
                                            Circle()
                                                .frame(width: 12, height: 12)
                                                .foregroundStyle(chosenFolderColor)
                                            
                                            Menu {
                                                ForEach(folders, id: \.self.id){ folder in
                                                    Button(action: {
                                                        chosenFolder = folder
                                                    }) {
                                                        HStack {
                                                            if chosenFolder == folder {
                                                                Image(systemName: "checkmark")
                                                            } else {
                                                                Image(systemName: "checkmark").hidden()
                                                            }
                                                            
                                                            Text("\(folder.name)")
                                                            Spacer()
                                                            HStack {
                                                                if chosenFolder == folder {
                                                                    Image(systemName: "checkmark")
                                                                } else {
                                                                    Image(systemName: "checkmark").hidden()
                                                                }
                                                            }
                                                            .frame(width: 30)
                                                        }
                                                    }
                                                }
                                            } label: {
                                                Text("\(chosenFolderName)")
                                                //                                Text(chosenFolder.name)
                                                Image(systemName: "chevron.up.chevron.down")
                                                    .resizable()
                                                    .frame(width: 10, height: 15)
                                            }
                                            
                                            
                                        }
                                    }
                                    Button {
                                        alarmisActive.toggle()
                                    } label: {
                                        HStack{
                                            Text("알람")
                                            Spacer()
                                            Text(alarmDataisEmpty ?? true ? "없음" : Date().makeAlarmDate(alarmData: contentAlarm ?? Date()))
                                        }
                                    }
                                    .sheet(isPresented: $alarmisActive, content: {
                                        VStack{
                                            HStack{
                                                Button(action: {
                                                    contentAlarm = Date()
                                                    alarmDataisEmpty = true
                                                    alarmisActive.toggle()
                                                }, label: {
                                                    Text("리셋")
                                                })
                                                Spacer()
                                                Button(action: {
                                                    alarmDataisEmpty = false
                                                    alarmisActive.toggle()
                                                }, label: {
                                                    Text("완료")
                                                })
                                            }
                                            
                                            DatePicker(
                                                "Select Date",
                                                selection: $contentAlarm.withDefault(Date()),
                                                in: Date()...,
                                                displayedComponents: [.date, .hourAndMinute]
                                            )
                                            .labelsHidden()
                                            .datePickerStyle(.wheel)
                                        }
                                        .padding()
                                        .presentationDetents([.height(CGFloat(300))])
                                    })
                                    
                                    
                                    Button(action: {
                                        memoisActive.toggle()
                                        newMemo = memo ?? ""
                                    }, label: {
                                        HStack{
                                            //                                        Image(systemName: "pencil")
                                            //                                            .resizable()
                                            //                                            .frame(width: 15, height: 15)
                                            Text("메모")
                                            Spacer()
                                            if let memo = memo {
                                                Text(memo.count > 5 ? String("\(memo.prefix(5))...") : memo)
                                                    .lineLimit(1)
                                                    .truncationMode(.tail)
                                            }
                                            
                                            Image(systemName: "chevron.right")
                                                .resizable()
                                                .frame(width: 8, height: 12)
                                        }
                                    })
                                    .sheet(isPresented: $memoisActive, content: {
                                        VStack{
                                            HStack{
                                                Spacer()
                                                Button(action: {
                                                    memoisActive.toggle()
                                                    memo = newMemo
                                                }, label: {
                                                    Text("완료")
                                                })
                                            }
                                            
                                            VStack{
                                                TextField("메모를 입력해주세요.", text: $newMemo, axis: .vertical	)
                                            }.frame(height: 100, alignment: .top)
                                            
                                            Spacer()
                                        }
                                        .padding()
                                        .presentationDetents([.height(CGFloat(200))])
                                    })
                                }
                                .listRowBackground(Color.clear)
                                .foregroundStyle(Color.black)
                            }
                            .padding(.leading, -16)
                            .padding(.top, -34)
                            .background(Color.clear) // List의 배경색을 투명하게 설정
                            .scrollContentBackground(.hidden)
                            .scrollDisabled(true)
                            .frame(minHeight: 132)
                        }
                        .clipShape(RoundedRectangle(cornerRadius: 20)) // 모서리 둥글게
                    }
                    .frame(width: 350, height: 132)
                }
                .padding(.horizontal, 20)
                if imageClickisActive {
                    ZStack{
                        Color.black
                            .opacity(0.7)
                            .ignoresSafeArea()
                        VStack {
                            HStack{
                                Button(action: {
                                    imageClickisActive = false
                                }, label: {
                                    Text("X")
                                        .foregroundStyle(Color.white)
                                        .bold()
                                })
                                Spacer()
                            }
                            .padding()
                            
                            Spacer()
                            Image(uiImage: clickedImage)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .clipShape(RoundedRectangle(cornerRadius: 25))
                                .scaleEffect(imageScale >= 1.0 ? imageScale : 1.0)
                                .gesture(magnification)
                            Spacer()
                            Spacer()
                        }
                        .padding(.horizontal, 20)
                    }
                }
            }
        }
        .sheet(isPresented: $isCameraSheetOn, content: {
            NavigationStack{
                CameraView(isCameraSheetOn: $isCameraSheetOn)
            }
        })
        .photosPicker(isPresented: $showingImagePicker, selection: $selectedItems,  maxSelectionCount: 10-cameraVM.photoData.count, matching: .not(.videos))
        .onChange(of: selectedItems, loadImage)
        .toolbar(startViewType == .edit ? .hidden : .visible)
        .toolbar(content: {
            // 완료 및 저장 버튼
            Button {
                saveTodoItem()
            } label: {
                Text("완료")
            }
        })
        .toolbar(.visible, for: .bottomBar)
        .toolbar{
            ToolbarItemGroup(placement: .bottomBar) {
                //TODO: 업로드 창에서 선택 후 이미지 넣기
                Button {
                    showingImagePicker = true
                } label : {
                    Image(systemName: "photo.on.rectangle")
                }
                .disabled(10 <= cameraVM.photoData.count)
                Button {
                    if cameraVM.photoData.count < 10 {
                        isCameraSheetOn = true
                    } else {
                        //TODO: 토스트 메세지 출력하기
                        print("이미지는 10장 이상 추가할 수 없습니다.")
                    }
                }label: {
                    Image(systemName: "camera")
                }
                .disabled(10 <= cameraVM.photoData.count)
            }
        }
    }
    
    func saveTodoItem() {
        var id: String = ""
        // 알람 데이터가 있으면
        
        // MARK: 생성 시 만들어 지는 곳 -> 알람 데이터 삭제 필요 없음
        if alarmDataisEmpty != nil && !alarmDataisEmpty! {
            // alarmDataisEmpty == false일 경우 알림을 설정하는 것이기 때문에 데이터가 무조건 있다고 봄
            let calendar = Calendar.current
            let year = calendar.component(.year, from: contentAlarm!)
            let month = calendar.component(.month, from: contentAlarm!)
            let day = calendar.component(.day, from: contentAlarm!)
            let hour = calendar.component(.hour, from: contentAlarm!)
            let minute = calendar.component(.minute, from: contentAlarm!)
            
            // Notification 알람 생성 및 id Todo에 저장하기
            id = manager.makeTodoNotification(year: year, month: month, day: day, hour: hour, minute: minute)
        }
        
        
        
        let newTodo: Todo = Todo(folder: chosenFolder, id: UUID(), images: cameraVM.photoData, createdAt: Date(), options: Options(alarm: alarmDataisEmpty ?? true ? nil : contentAlarm, alarmUUID: alarmDataisEmpty ?? true ? nil : id,  memo: memo), isDone: false)
        if let chosenFolder = chosenFolder {
            chosenFolder.todos.append(newTodo)
        } else {
            folders[0].todos.append(newTodo)
        }
        modelContext.insert(newTodo)
        try? modelContext.save()
        home = true
        
        if startViewType == .gridMain {  //startViewType이 .gridMain일 경우 (.gridSingleFolder의 경우에는 제외)
            chosenFolder = nil //model에 삽입이 끝난 후 chosneFolder를 초기화함
        }
        if startViewType == .gridMain || startViewType == .gridSingleFolder {
            alarmDataisEmpty = nil //model에 삽입 후 바인딩되어 넘어온 값들을 초기화함 → 다음 추가시 초기화되어 있을 수 있도록
            contentAlarm = nil
            memo = nil
            cameraVM.photoData = []
        }
        
        dismiss()
        
    }
    
    
    func saveImageToAlbum(image: UIImage) {
        PHPhotoLibrary.requestAuthorization { status in
            if status == .authorized {
                UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
                DispatchQueue.main.async {
                    alertMessage = "이미지가 앨범에 저장되었습니다!"
                    showAlert = true
                }
            } else {
                DispatchQueue.main.async {
                    alertMessage = "설정에서 앨범 저장 권한을 허용해주세요!"
                    showAlert = true
                }
            }
        }
    }
    
    ///a method that will be called when the ImagePicker view has been dismissed
    func loadImage() {
        Task {
            for item in selectedItems {
                if let imageData = try? await item.loadTransferable(type: Data.self) {
                    cameraVM.photoData.append(imageData)
                }
            }
            selectedItems.removeAll()
        }
    }
}

extension Binding {
    func withDefault<T>(_ defaultValue: T) -> Binding<T> where Value == Optional<T> {
        return Binding<T>(get: {
            self.wrappedValue ?? defaultValue
        }, set: { newValue in
            self.wrappedValue = newValue
        })
    }
}

#Preview {
    @Previewable @State var chosenFolder: Folder? = Folder(id: UUID(), name: "기본폴더", color: "red", todos: [])
    @Previewable @State var contentAlarm = Date()
    @Previewable @State var memo: String = ""
    @Previewable @State var alarmDataisEmpty: Bool = true
    @Previewable @State var home: Bool = false
    @Previewable @State var alarmID = ""
    return MakeTodoView(chosenFolder: $chosenFolder, startViewType: .camera, contentAlarm: .constant(Date()), alarmID: .constant(""), alarmDataisEmpty: .constant(true), memo: .constant(""), home: .constant(true))
    
}
