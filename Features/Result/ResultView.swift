//
//  ResultView.swift
//  Peetime
//
//  Created by Rafael Hajjar on 5/28/25.
//
import SwiftUI

struct ResultView: View {
    @StateObject private var vm: ResultViewModel

    init(image: UIImage) { _vm = StateObject(wrappedValue: ResultViewModel(image: image)) }

    var body: some View {
        switch vm.state {
        case .loading:
            ProgressView("Analyzing…").navigationTitle("Result")
        case .failure:
            VStack {
                Image(systemName: "xmark.octagon").font(.system(size: 60))
                Text("Couldn’t analyze photo").padding()
                Button("Retry") { /* pop back */ }
            }
        case let .success(res):
            VStack(spacing: 20) {
                Circle()
                    .fill(Color(res.averageColor))
                    .frame(width: 140, height: 140)
                    .overlay(Text("\(res.level.rawValue)/8").font(.title).bold().foregroundColor(.white))
                Text(res.level.description).multilineTextAlignment(.center)
            }
            .navigationTitle("Hydration")
        }
    }
}
