//
//  ActionButton.swift
//
//  Kit Langton의 코드를 참고함
//

import SwiftUI

struct Action {
  let color: Color
  let name: String
  let systemIcon: String
  let action: (@escaping () -> Void) -> Void
}

struct ActionButton: View {
  let action: Action
  var width: CGFloat
  var dismiss: () -> Void
  var onActionTriggered: () -> Void

  var body: some View {
    Button {
      onActionTriggered()
      action.action {
        dismiss()
      }
    } label: {
      action.color
        .overlay(alignment: .leading) {
          Label(action.name, systemImage: action.systemIcon)
            .labelStyle(.iconOnly)
            .foregroundColor(.white)
            .padding(.leading)
        }
        .clipped()
        .frame(width: abs(width))
        .font(.title2)
    }.buttonStyle(.plain)
  }
}
