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
    @Query var folders: [Folder]
    @Environment(\.modelContext) private var modelContext
    
    @State private var showActionSheet = false
    let colors: [Color] = [.red, .orange, .yellow, .green, .blue, .purple]
    let colorDictionary: [Color: String] = [
        .red: "red",
        .orange: "orange",
        .yellow: "yellow",
        .green: "green",
        .blue: "blue",
        .purple: "purple"
    ]

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
                    
                    isSheetPresented = false
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
    
    private func addFolders() {
        withAnimation {
            let newFolder = Folder(
                id: UUID(),
                name: folderNameInput,
                color: selectedColor != nil ? colorDictionary[selectedColor!, default: "green"] : "green",
                todos: []
            )
            modelContext.insert(newFolder)
        }
        
        folderNameInput = ""
        isSheetPresented = false
        selectedColor = nil
    }
}
