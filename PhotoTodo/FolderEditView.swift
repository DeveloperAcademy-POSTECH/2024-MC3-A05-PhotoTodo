//
//  FolderEditView.swift
//  PhotoTodo
//
//  Created by JiaeShin on 8/2/24.
//


import SwiftUI

struct FolderEditView: View {
    @State private var isSheetPresented = false
    @State private var textFieldValue = ""
    @State private var showAlert = false
    @State private var selectedColor: Color? = nil

    let colors: [Color] = [.red, .orange, .yellow, .green, .blue, .purple]

    var body: some View {
        VStack {
            Button("Show Sheet") {
                self.isSheetPresented = true
            }
        }
        .sheet(isPresented: $isSheetPresented) {
            VStack {
                HStack {
                    Button("Cancel") {
                        if !textFieldValue.isEmpty {
                            showAlert = true
                        } else {
                            isSheetPresented = false
                        }
                    }
                    Spacer()
                    Button("Done") {
                        // Save action
                        isSheetPresented = false
                    }
                }
                .padding()

                VStack(alignment: .leading) {
                    Text("폴더명")
                        .font(.caption)
                        .foregroundColor(.gray)
                    TextField("", text: $textFieldValue)
                        .textFieldStyle(PlainTextFieldStyle())
                        .padding(.vertical, 8)
                        .overlay(Rectangle().frame(height: 1).padding(.top, 35))
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                // Automatically focus the TextField and show keyboard
                                UITextField.appearance(whenContainedInInstancesOf: [UIView.self]).becomeFirstResponder()
                            }
                        }
                }
                .padding()

                VStack(alignment: .leading) {
                    Text("색상")
                        .font(.caption)
                        .foregroundColor(.gray)
                    HStack {
                        ForEach(colors, id: \.self) { color in
                            Button(action: {
                                selectedColor = color
                            }) {
                                Circle()
                                    .fill(color)
                                    .frame(width: 40, height: 40)
                                    .padding(5)  // 5px 마진
                                    .overlay(
                                        Circle()
                                            .stroke(Color.black, lineWidth: selectedColor == color ? 3 : 0)
                                    )
                            }
                        }
                    }
                    .padding(.vertical, 8)
                }
                .padding()

                Spacer()
            }
            .presentationDetents([.medium])
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("Unsaved Changes"),
                    message: Text("You have unsaved changes. Do you really want to discard them?"),
                    primaryButton: .destructive(Text("Discard")) {
                        isSheetPresented = false
                    },
                    secondaryButton: .cancel()
                )
            }
            .interactiveDismissDisabled(!textFieldValue.isEmpty)
        }
    }
}

struct FolderEditView_Previews: PreviewProvider {
    static var previews: some View {
        FolderEditView()
    }
}
