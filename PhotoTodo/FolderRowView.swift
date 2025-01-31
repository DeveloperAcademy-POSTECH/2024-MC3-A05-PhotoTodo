import SwiftUI

struct FolderRowView<Content: View>: View {
  init(
    actions: [Action],
    @ViewBuilder content: () -> Content
  ) {
    self.actions = actions
    self.content = content()
  }

  var content: Content

  @State private var offset: CGFloat = 0
  @State private var startOffset: CGFloat = 0
  @State private var isDragging = false
  @State private var isTriggered = false

  let triggerThreshhold: CGFloat = -250
  let expansionThreshhold: CGFloat = -60
  let actions: [Action]

  var expansionOffset: CGFloat { CGFloat(actions.count) * -60 }

  var dragGesture: some Gesture {
    DragGesture()
      .onChanged { value in
          if value.translation.width > 0 {
                  withAnimation(.interactiveSpring) {
                      offset = 0
                  }
                  return
              }

          
        if !isDragging {
          startOffset = offset
          isDragging = true
        }
          
        withAnimation(.interactiveSpring) {
          offset = startOffset + value.translation.width
        }
        
        isTriggered = offset < triggerThreshhold
      }
      .onEnded { value in
        isDragging = false

        if let action = actions.last, isTriggered {
          withAnimation {
            offset = -UIScreen.main.bounds.width + 30
              //화면 왼쪽의 패딩만큼 더 가야 함
              //리스트의 패딩값이 조정된다면 이부분도 조정 필요
          }
          action.action {
            withAnimation {
              offset = 0 // Reset after action completes
            }
          }
        } else {
          withAnimation {
            if value.predictedEndTranslation.width < expansionThreshhold {
              offset = expansionOffset
            } else {
              offset = 0
            }
          }
        }

        isTriggered = false
      }
  }

  var body: some View {
    content
      .offset(x: offset)
      .padding()
      .frame(maxWidth: .infinity)
      .contentShape(Rectangle())
      .overlay(alignment: .trailing) {
        ZStack(alignment: .trailing) {
          ForEach(Array(actions.enumerated()), id: \.offset) { index, action in
            let isDefault = index == actions.count - 1
            let width = isTriggered ? -offset : -offset * CGFloat(actions.count - index) / CGFloat(actions.count)

            ActionButton(
              action: action,
              width: width,
              dismiss: { withAnimation { offset = 0 } },
              onActionTriggered: {
                  withAnimation {
                      offset = -UIScreen.main.bounds.width + 30
                      isTriggered = true
                  }
              }
            )
          }
        }
        .animation(.spring, value: isTriggered)
        .onChange(of: isTriggered) {
          UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        }
      }
      .highPriorityGesture(dragGesture)
  }
}

#Preview {
    FolderRowView(actions: [
        Action(color: .indigo, name: "Like", systemIcon: "hand.thumbsup.fill", action: { completion in
            print("LIKE")
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                completion()
            }
        }),
        Action(color: .blue, name: "Subscribe", systemIcon: "figure.mind.and.body", action: { completion in
            print("SUBSCRIBE")
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                completion()
            }
        }),
    ]) {
        Text("**THANKS FOR WATCHING**").font(.title)
    }
}
