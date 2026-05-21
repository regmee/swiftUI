import SwiftUI

struct CounterView: View {

    @State private var viewModel: CounterViewModel

    init(viewModel: CounterViewModel = CounterViewModel()) {
        _viewModel = State(initialValue: viewModel)
    }

    var body: some View {
        VStack(spacing: 32) {
            Text("\(viewModel.count)")
                .font(.largeTitle)
                .bold()

            HStack(spacing: 24) {
                Button("−") { viewModel.decrement() }
                    .disabled(!viewModel.canDecrement)

                Button("Reset") { viewModel.reset() }

                Button("+") { viewModel.increment() }
            }
            .buttonStyle(.bordered)
        }
    }
}

#Preview {
    CounterView()
}
