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
    @State private var isTriggered = false

    let triggerThreshhold: CGFloat = -250
    let expansionThreshhold: CGFloat = -60
    let actions: [Action]

    var expansionOffset: CGFloat { CGFloat(actions.count) * -60 }

    var body: some View {
        content
            .offset(x: offset)
            .padding()
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
            .overlay(alignment: .trailing) {
                ZStack(alignment: .trailing) {
                    ForEach(Array(actions.enumerated()), id: \.offset) { index, action in
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
            .background {
                HorizontalPanGestureInstaller(
                    isOpen: offset != 0,
                    onBegan: {
                        startOffset = offset
                    },
                    onChanged: { translationX in
                        offset = min(0, startOffset + translationX)
                        isTriggered = offset < triggerThreshhold
                    },
                    onEnded: { translationX, velocityX in
                        finishSwipe(
                            translationX: translationX,
                            velocityX: velocityX
                        )
                    },
                    onCancelled: {
                        withAnimation {
                            offset = startOffset
                        }
                        isTriggered = false
                    }
                )
            }
    }

    private func finishSwipe(
        translationX: CGFloat,
        velocityX: CGFloat
    ) {
        if let action = actions.last,
           offset < triggerThreshhold {
            withAnimation {
                offset = -UIScreen.main.bounds.width + 30
            }

            action.action {
                withAnimation {
                    offset = 0
                }
            }
        } else {
            // UIKit에는 predictedEndTranslation이 없으므로 현재 속도로 투영한다.
            let projectedOffset = startOffset
                + translationX
                + velocityX * 0.2

            withAnimation {
                offset = projectedOffset < expansionThreshhold
                    ? expansionOffset
                    : 0
            }
        }

        isTriggered = false
    }
}

private struct HorizontalPanGestureInstaller: UIViewRepresentable {
    let isOpen: Bool
    let onBegan: () -> Void
    let onChanged: (CGFloat) -> Void
    let onEnded: (CGFloat, CGFloat) -> Void
    let onCancelled: () -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    func makeUIView(context: Context) -> UIView {
        let markerView = HierarchyTrackingView(frame: .zero)
        let coordinator = context.coordinator

        markerView.onHierarchyChange = { [weak coordinator] view in
            DispatchQueue.main.async {
                coordinator?.attachIfNeeded(from: view)
            }
        }
        markerView.isUserInteractionEnabled = false
        return markerView
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        context.coordinator.parent = self

        DispatchQueue.main.async {
            context.coordinator.attachIfNeeded(from: uiView)
        }
    }

    static func dismantleUIView(
        _ uiView: UIView,
        coordinator: Coordinator
    ) {
        (uiView as? HierarchyTrackingView)?.onHierarchyChange = nil
        coordinator.deactivate()
    }

    final class Coordinator: NSObject, UIGestureRecognizerDelegate {
        var parent: HorizontalPanGestureInstaller

        private var isActive = true
        private weak var targetView: UIView?
        private lazy var panGesture: UIPanGestureRecognizer = {
            let gesture = UIPanGestureRecognizer(
                target: self,
                action: #selector(handlePan(_:))
            )
            gesture.delegate = self
            gesture.cancelsTouchesInView = true
            gesture.maximumNumberOfTouches = 1
            return gesture
        }()

        init(parent: HorizontalPanGestureInstaller) {
            self.parent = parent
        }

        func attachIfNeeded(from markerView: UIView) {
            guard isActive,
                  let gestureTargetView = markerView.gestureTargetView else {
                return
            }

            guard targetView !== gestureTargetView else {
                return
            }

            targetView?.removeGestureRecognizer(panGesture)
            targetView = gestureTargetView
            gestureTargetView.addGestureRecognizer(panGesture)
        }

        func deactivate() {
            isActive = false
            targetView?.removeGestureRecognizer(panGesture)
            targetView = nil
        }

        func gestureRecognizerShouldBegin(
            _ gestureRecognizer: UIGestureRecognizer
        ) -> Bool {
            guard let pan = gestureRecognizer as? UIPanGestureRecognizer else {
                return false
            }

            let velocity = pan.velocity(in: pan.view)
            guard abs(velocity.x) > abs(velocity.y) else {
                return false
            }

            return parent.isOpen || velocity.x < 0
        }

        func gestureRecognizer(
            _ gestureRecognizer: UIGestureRecognizer,
            shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer
        ) -> Bool {
            guard let scrollView = otherGestureRecognizer.view as? UIScrollView else {
                return false
            }

            return otherGestureRecognizer === scrollView.panGestureRecognizer
        }

        @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
            let translationX = gesture.translation(in: gesture.view).x
            let velocityX = gesture.velocity(in: gesture.view).x

            switch gesture.state {
            case .began:
                parent.onBegan()
            case .changed:
                parent.onChanged(translationX)
            case .ended:
                parent.onEnded(translationX, velocityX)
            case .cancelled, .failed:
                parent.onCancelled()
            default:
                break
            }
        }
    }
}

private final class HierarchyTrackingView: UIView {
    var onHierarchyChange: ((UIView) -> Void)?

    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        onHierarchyChange?(self)
    }
}

private extension UIView {
    var gestureTargetView: UIView? {
        let fallbackView = superview
        var candidate = superview

        while let view = candidate {
            if let cell = view as? UICollectionViewCell {
                return cell.contentView
            }

            if let cell = view as? UITableViewCell {
                return cell.contentView
            }

            candidate = view.superview
        }

        return fallbackView
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
