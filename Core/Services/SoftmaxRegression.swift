import Foundation

struct SoftmaxRegression {
    var weights: [[Double]]
    private let classes: Int

    init(classes: Int = 8) {
        self.classes = classes
        self.weights = Array(repeating: Array(repeating: 0.0, count: 4), count: classes)
    }

    static func train(points: [HSVPoint],
                      classes: Int = 8,
                      iterations: Int = 200,
                      learningRate: Double = 0.5) -> SoftmaxRegression {
        var model = SoftmaxRegression(classes: classes)
        guard !points.isEmpty else { return model }

        for _ in 0..<iterations {
            var gradient = Array(repeating: Array(repeating: 0.0, count: 4), count: classes)

            for pt in points {
                let x = [pt.h, pt.s, pt.v, 1.0]
                let logits = (0..<classes).map { Self.dot(model.weights[$0], x) }
                let exps = logits.map { exp($0) }
                let sumExp = exps.reduce(0, +)
                let probs = exps.map { $0 / sumExp }

                for c in 0..<classes {
                    let indicator = (c + 1 == pt.label) ? 1.0 : 0.0
                    for j in 0..<4 {
                        gradient[c][j] += (indicator - probs[c]) * x[j]
                    }
                }
            }

            let n = Double(points.count)
            for c in 0..<classes {
                for j in 0..<4 {
                    model.weights[c][j] += learningRate * gradient[c][j] / n
                }
            }
        }
        return model
    }

    func predict(h: Double, s: Double, v: Double) -> Int {
        let x = [h, s, v, 1.0]
        let logits = weights.map { Self.dot($0, x) }
        let exps = logits.map { exp($0) }
        let sumExp = exps.reduce(0, +)
        let probs = exps.map { $0 / sumExp }
        let idx = probs.enumerated().max { $0.element < $1.element }!.offset
        return idx + 1
    }

    private static func dot(_ a: [Double], _ b: [Double]) -> Double {
        zip(a, b).map(*).reduce(0, +)
    }
}
