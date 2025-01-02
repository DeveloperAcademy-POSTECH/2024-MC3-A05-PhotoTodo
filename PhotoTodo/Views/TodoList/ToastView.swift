//
//  ToastView.swift
//  PhotoTodo
//
//  Created by Lyosha's MacBook   on 8/27/24.
//

import SwiftUI

struct ToastView: View {
    @State var toastOption: ToastOption
    @State var toastMessage: String
    @Binding var recentlyDoneTodo: Todo?
    
    var body: some View {
        RoundedRectangle(cornerRadius: 35)
            .fill(Color("green/green-500"))
            .frame(width: 200, height: 50)
            .overlay {
                HStack{
                    Button{
                        if recentlyDoneTodo == nil { return }
                        recentlyDoneTodo!.isDone.toggle()
                        toastOption = .none
                    } label : {
                        Image(systemName: "arrow.uturn.backward")
                            .foregroundColor(.paleGray)
                    }
                    Text(toastMessage)
                        .fontWeight(.bold)
                        .font(.system(size: 15))
                        .foregroundColor(.paleGray)
                        .padding()
                }
            }
            .offset(y: 250)
    }
}


#Preview {
    @Previewable @State var editMode: EditMode = .inactive
    @Previewable @State var toastMessage: String = ""
    @Previewable @State var toastOption: ToastOption = .none
    @Previewable @State var recentlyDoneTodo: Todo? = nil
    
    return ToastView(toastOption: toastOption, toastMessage: toastMessage, recentlyDoneTodo: $recentlyDoneTodo)
}
