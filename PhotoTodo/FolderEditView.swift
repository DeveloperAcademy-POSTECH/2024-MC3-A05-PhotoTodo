//
//  SwiftUIView.swift
//  PhotoTodo
//
//  Created by JiaeShin on 8/5/24.
//
import SwiftUI
import SwiftData

struct FolderEditView: View {
    @Binding var isSheetPresented: Bool
    @Binding var folderNameInput: String
    @Binding var selectedColor: Color?
    @Binding var selectedFolder: Folder?
    
    @Query var folders: [Folder]
    @Query var folderOrders: [FolderOrder]
    @Environment(\.modelContext) private var modelContext
    
    @State private var showActionSheet = false
    let colors: [Color] = [Color("folder_color/red"), Color("folder_color/yellow"), Color("folder_color/sky"), Color("folder_color/green"), Color("folder_color/blue"), Color("folder_color/purple")]
    
    let colorDictionary: [Color: String] = [
        Color("folder_color/red"): "red",
        Color("folder_color/sky"): "sky",
        Color("folder_color/yellow"): "yellow",
        Color("folder_color/green"): "green",
        Color("folder_color/blue"): "blue",
        Color("folder_color/purple"): "purple"
    ]
    
    var folderManager = FolderManager()
    
    var body: some View {
        VStack (alignment: .leading) {
            HStack {
                Button("취소") {
                    if !folderNameInput.isEmpty {
                        showActionSheet = true
                    } else {
                        isSheetPresented = false
                    }
                }
                Spacer()
                
                Text("폴더 정보")
                    .font(.headline)
                Spacer()
                Button("저장") {
                    saveFolder()
                }
            }
            .padding()

            HStack {
                Text("폴더명")
                    .font(.subheadline)
                    .foregroundColor(.primary)
                    .frame(width: 60, alignment: .leading)
                
                TextField("폴더명 입력", text: $folderNameInput)
                    .textFieldStyle(PlainTextFieldStyle())
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                
                if !folderNameInput.isEmpty {
                    Button(action: {
                        folderNameInput = ""
                    }) {
                        Image(systemName: "multiply.circle.fill")
                            .foregroundColor(.gray)
                    }
                }
            }
            .overlay(
                Rectangle()
                    .frame(height: 1)
                    .padding(.top, 50)
                    .foregroundColor(.lightGray)
            )
            .padding()
            .padding(.bottom, 8)

            VStack(alignment: .leading) {
                Text("색상")
                    .font(.subheadline)
                    .foregroundColor(.primary)
                    .padding(.horizontal)

                HStack {
                    Spacer()
                    ForEach(colors, id: \.self) { color in
                        Button(action: {
                            selectedColor = color
                        }) {
                            Circle()
                                .fill(color)
                                .frame(width: 40, height: 40)
                                .padding(7)
                                .overlay(
                                    Circle()
                                        .stroke(Color.gray, lineWidth: selectedColor == color ? 1 : 0)
                                )
                        }
                        Spacer()
                    }
                }
                .padding(.vertical, 8)
            }
            Spacer()
        }
        .padding(.vertical, 14)
        .padding(.horizontal, 20)
        .presentationDetents([.medium])
        .actionSheet(isPresented: $showActionSheet) {
            ActionSheet(
                title: Text("변경 사항을 저장하지 않고 나가시겠습니까?"),
                buttons: [
                    .destructive(Text("변경 사항 폐기")) {
                        folderNameInput = ""
                        isSheetPresented = false
                    },
                    .cancel()
                ]
            )
        }
        .interactiveDismissDisabled(!folderNameInput.isEmpty)
    }
    
    private func saveFolder() {
        folderManager.saveFolder(folderOrders, folderNameInput, selectedFolder, selectedColor, modelContext)
        
        //초기화 해주기
        folderNameInput = ""
        isSheetPresented = false
        selectedColor = nil
    }
}
