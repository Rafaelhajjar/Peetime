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
        Group {
            switch vm.state {
            case .loading:
                VStack { ProgressView(); Text("Analyzing…") }
            case .failure:
                VStack {
                    Image(systemName: "xmark.octagon").font(.largeTitle)
                    Text("Couldn’t analyze photo")
                }
            case .success(let res):
                VStack(spacing: 24) {
                    Circle()
                        .fill(Color(res.averageColor))
                        .frame(width: 150, height: 150)
                        .overlay(Text("\(res.level.rawValue)/8").font(.title).bold().foregroundColor(.white))
                    Text(res.level.description).multilineTextAlignment(.center)
                }
            }
        }
        .padding()
        .navigationTitle("Hydration")
    }
}
