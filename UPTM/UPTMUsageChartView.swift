import SwiftUI
import Charts

struct UptimeChartView: View {
    var data: [Date: TimeInterval]

    var body: some View {
        Chart {
            ForEach(data.sorted(by: { $0.key < $1.key }), id: \.key) { date, uptime in
                BarMark(
                    x: .value("Date", date, unit: .day),
                    y: .value("Uptime", uptime)
                )
            }
        }
        .chartXAxis {
            AxisMarks(values: .stride(by: .day)) { value in
                AxisValueLabel(format: .dateTime.weekday(.abbreviated))
            }
        }
        .chartYAxis {
            //AxisMarks { value in
            //    AxisValueLabel(format: .number.precision(.fractionLength(1)))
            //}
        }
        .frame(height: 200)
    }
}
