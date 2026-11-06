import WidgetKit
import SwiftUI

// MARK: - Data Models

struct GasShiftEntry: TimelineEntry {
    let date: Date
    let shiftName: String
    let count: Int
    let total: Int
    let totalFormatted: String
    let daNop: Int
    let chuaNop: Int
    let updatedAt: String
    let isLive: Bool

    static var placeholder: GasShiftEntry {
        GasShiftEntry(
            date: Date(),
            shiftName: "Ca hôm nay",
            count: 12,
            total: 7440000,
            totalFormatted: "7tr440 ngàn",
            daNop: 10,
            chuaNop: 2,
            updatedAt: "Vừa xong",
            isLive: true
        )
    }
}

// Model for decoding Google Apps Script entries
struct GasItemResponse: Codable {
    let id: String?
    let ten_diem: String?
    let so_tien: FlexibleAmount?
    let trang_thai: String?
    let ca: String?
    let timestamp: String?
}

// Flexible decoder for so_tien (can be String, Int, or Double)
struct FlexibleAmount: Codable {
    let value: Int

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let intVal = try? container.decode(Int.self) {
            self.value = intVal
        } else if let doubleVal = try? container.decode(Double.self) {
            self.value = Int(doubleVal)
        } else if let strVal = try? container.decode(String.self) {
            let cleaned = strVal.replacingOccurrences(of: ",", with: "").replacingOccurrences(of: ".", with: "").trimmingCharacters(in: .whitespacesAndNewlines)
            self.value = Int(cleaned) ?? 0
        } else {
            self.value = 0
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(value)
    }
}

// MARK: - Timeline Provider

struct GasWidgetProvider: TimelineProvider {
    let scriptURL = "https://script.google.com/macros/s/AKfycbyRnnoEd2BnD7u1pXHER17Cv95BN9Z77yUeO6oR7CFRtbUqd-SiVJqBv5ENYyARwX77fw/exec?action=getData"
    let groupID = "group.com.vnpost.gasmanager"

    func placeholder(in context: Context) -> GasShiftEntry {
        .placeholder
    }

    func getSnapshot(in context: Context, completion: @escaping (GasShiftEntry) -> Void) {
        if let cached = loadLocalCache() {
            completion(cached)
        } else {
            completion(.placeholder)
        }
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<GasShiftEntry>) -> Void) {
        let currentDate = Date()
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 15, to: currentDate) ?? currentDate.addingTimeInterval(900)

        // 1. Thử đọc dữ liệu đồng bộ nhanh từ Shared UserDefaults
        if let localEntry = loadLocalCache(), currentDate.timeIntervalSince(localEntry.date) < 300 {
            let timeline = Timeline(entries: [localEntry], policy: .after(nextUpdate))
            completion(timeline)
            return
        }

        // 2. Fetch dữ liệu trực tiếp từ Google Apps Script API
        fetchRemoteData { entry in
            let finalEntry = entry ?? loadLocalCache() ?? .placeholder
            let timeline = Timeline(entries: [finalEntry], policy: .after(nextUpdate))
            completion(timeline)
        }
    }

    // Đọc cache từ Shared Container hoặc App Group
    private func loadLocalCache() -> GasShiftEntry? {
        let defaults = UserDefaults(suiteName: groupID) ?? UserDefaults.standard
        guard let shiftName = defaults.string(forKey: "widget_shift"),
              let totalFormatted = defaults.string(forKey: "widget_totalFormatted") else {
            return nil
        }
        let count = defaults.integer(forKey: "widget_count")
        let total = defaults.integer(forKey: "widget_total")
        let daNop = defaults.integer(forKey: "widget_daNop")
        let chuaNop = defaults.integer(forKey: "widget_chuaNop")
        let updatedAt = defaults.string(forKey: "widget_updatedAt") ?? ""
        let savedTime = defaults.double(forKey: "widget_timestamp")
        let date = savedTime > 0 ? Date(timeIntervalSince1970: savedTime) : Date()

        return GasShiftEntry(
            date: date,
            shiftName: shiftName,
            count: count,
            total: total,
            totalFormatted: totalFormatted,
            daNop: daNop,
            chuaNop: chuaNop,
            updatedAt: updatedAt.isEmpty ? "Vừa xong" : updatedAt,
            isLive: true
        )
    }

    // Tải dữ liệu từ Google Apps Script
    private func fetchRemoteData(completion: @escaping (GasShiftEntry?) -> Void) {
        guard let url = URL(string: scriptURL) else {
            completion(nil)
            return
        }

        var request = URLRequest(url: url)
        request.timeoutInterval = 12

        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil else {
                completion(nil)
                return
            }

            do {
                let items = try JSONDecoder().decode([GasItemResponse].self, from: data)
                if items.isEmpty {
                    completion(nil)
                    return
                }

                // Tìm ca mới nhất
                var latestCa = ""
                for item in items.reversed() {
                    if let ca = item.ca, !ca.isEmpty {
                        latestCa = ca
                        break
                    }
                }

                // Lọc các bản ghi thuộc ca mới nhất
                let shiftItems = items.filter { $0.ca == latestCa }
                let targetItems = shiftItems.isEmpty ? Array(items.suffix(20)) : shiftItems

                var total = 0
                var daNop = 0
                var chuaNop = 0

                for it in targetItems {
                    let amount = it.so_tien?.value ?? 0
                    total += amount
                    if it.trang_thai == "Đã nộp" {
                        daNop += 1
                    } else {
                        chuaNop += 1
                    }
                }

                let count = targetItems.count

                // Format tên ca hiển thị
                let shiftDisplay = formatShiftDisplay(latestCa)
                let formattedTotal = formatCompactCurrency(total)

                let timeFormatter = DateFormatter()
                timeFormatter.dateFormat = "HH:mm"
                let updatedTime = timeFormatter.string(from: Date())

                let entry = GasShiftEntry(
                    date: Date(),
                    shiftName: shiftDisplay,
                    count: count,
                    total: total,
                    totalFormatted: formattedTotal,
                    daNop: daNop,
                    chuaNop: chuaNop,
                    updatedAt: updatedTime,
                    isLive: true
                )

                // Lưu vào cache
                let defaults = UserDefaults(suiteName: groupID) ?? UserDefaults.standard
                defaults.set(shiftDisplay, forKey: "widget_shift")
                defaults.set(count, forKey: "widget_count")
                defaults.set(total, forKey: "widget_total")
                defaults.set(formattedTotal, forKey: "widget_totalFormatted")
                defaults.set(daNop, forKey: "widget_daNop")
                defaults.set(chuaNop, forKey: "widget_chuaNop")
                defaults.set(updatedTime, forKey: "widget_updatedAt")
                defaults.set(Date().timeIntervalSince1970, forKey: "widget_timestamp")

                completion(entry)
            } catch {
                completion(nil)
            }
        }.resume()
    }

    private func formatShiftDisplay(_ rawCa: String) -> String {
        if rawCa.isEmpty { return "Ca hôm nay" }
        let parts = rawCa.prefix(10).split(separator: "-")
        if parts.count == 3 {
            return "Ca \(parts[2])-\(parts[1])"
        }
        return "Ca gần nhất"
    }

    private func formatCompactCurrency(_ amount: Int) -> String {
        let absAmount = abs(amount)
        let millions = absAmount / 1_000_000
        let thousands = (absAmount % 1_000_000) / 1_000
        let sign = amount < 0 ? "-" : ""

        if absAmount == 0 { return "0 đ" }
        if millions > 0 && thousands > 0 {
            return "\(sign)\(millions)tr\(thousands) ngàn"
        }
        if millions > 0 {
            return "\(sign)\(millions)tr"
        }
        return "\(sign)\(thousands) ngàn"
    }
}

// MARK: - Widget 1 Views: Tổng quan Ca & Doanh thu

struct GasWidgetSmallView: View {
    let entry: GasShiftEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            // Header
            HStack(spacing: 5) {
                Image(systemName: "flame.fill")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(Color(red: 239/255, green: 68/255, blue: 68/255))

                Text(entry.shiftName)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.secondary)
                    .lineLimit(1)

                Spacer()

                Circle()
                    .fill(Color(red: 16/255, green: 185/255, blue: 129/255))
                    .frame(width: 6, height: 6)
            }

            Spacer()

            // Doanh thu chính
            VStack(alignment: .leading, spacing: 1) {
                Text(entry.totalFormatted)
                    .font(.system(size: 19, weight: .heavy, design: .rounded))
                    .foregroundColor(Color(red: 16/255, green: 185/255, blue: 129/255))
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)

                Text("Tổng doanh thu")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(.secondary)
            }

            Spacer()

            // Thống kê số điểm và giờ
            HStack {
                HStack(spacing: 4) {
                    Image(systemName: "doc.text.fill")
                        .font(.system(size: 10))
                        .foregroundColor(Color(red: 0/255, green: 91/255, blue: 166/255))
                    Text("\(entry.count) điểm")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(Color(red: 0/255, green: 91/255, blue: 166/255))
                }
                .padding(.horizontal, 6)
                .padding(.vertical, 3)
                .background(Color(red: 0/255, green: 91/255, blue: 166/255).opacity(0.12))
                .cornerRadius(6)

                Spacer()

                Text(entry.updatedAt)
                    .font(.system(size: 9))
                    .foregroundColor(.secondary)
            }
        }
        .padding(12)
        .widgetURL(URL(string: "gasmanager://open"))
    }
}

struct GasWidgetMediumView: View {
    let entry: GasShiftEntry

    var body: some View {
        HStack(spacing: 12) {
            // Cột trái: Tên ca & Doanh thu
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 6) {
                    Image(systemName: "flame.fill")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(Color(red: 239/255, green: 68/255, blue: 68/255))

                    Text("Gas Manager")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.primary)

                    Text("• \(entry.shiftName)")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }

                Spacer()

                VStack(alignment: .leading, spacing: 2) {
                    Text(entry.totalFormatted)
                        .font(.system(size: 24, weight: .heavy, design: .rounded))
                        .foregroundColor(Color(red: 16/255, green: 185/255, blue: 129/255))
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)

                    Text("Tổng doanh thu ca hiện tại")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.secondary)
                }

                Spacer()

                HStack(spacing: 4) {
                    Image(systemName: "clock")
                        .font(.system(size: 9))
                    Text("Cập nhật: \(entry.updatedAt)")
                        .font(.system(size: 9))
                }
                .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Divider()

            // Cột phải: Số điểm & Phân loại nộp tiền & Nút tắt
            VStack(alignment: .leading, spacing: 7) {
                // Thẻ số giao dịch
                HStack(spacing: 6) {
                    Image(systemName: "doc.text.fill")
                        .font(.system(size: 12))
                        .foregroundColor(Color(red: 0/255, green: 91/255, blue: 166/255))
                    Text("\(entry.count) giao dịch")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(Color(red: 0/255, green: 91/255, blue: 166/255))
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color(red: 0/255, green: 91/255, blue: 166/255).opacity(0.12))
                .cornerRadius(7)

                // Phân loại
                VStack(alignment: .leading, spacing: 3) {
                    HStack(spacing: 5) {
                        Circle()
                            .fill(Color(red: 16/255, green: 185/255, blue: 129/255))
                            .frame(width: 7, height: 7)
                        Text("Đã nộp:")
                            .font(.system(size: 11))
                            .foregroundColor(.secondary)
                        Text("\(entry.daNop)")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.primary)
                    }

                    HStack(spacing: 5) {
                        Circle()
                            .fill(Color.orange)
                            .frame(width: 7, height: 7)
                        Text("Chưa nộp:")
                            .font(.system(size: 11))
                            .foregroundColor(.secondary)
                        Text("\(entry.chuaNop)")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.primary)
                    }
                }

                Spacer()

                // Nút mở nhanh
                Link(destination: URL(string: "gasmanager://add_point")!) {
                    HStack(spacing: 4) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 11))
                        Text("Thêm điểm")
                            .font(.system(size: 11, weight: .semibold))
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 5)
                    .background(Color(red: 239/255, green: 68/255, blue: 68/255))
                    .cornerRadius(6)
                }
            }
            .frame(width: 125)
        }
        .padding(14)
    }
}

struct GasWidgetEntryView: View {
    var entry: GasWidgetProvider.Entry
    @Environment(\.widgetFamily) var family

    var body: some View {
        Group {
            switch family {
            case .systemMedium:
                GasWidgetMediumView(entry: entry)
            default:
                GasWidgetSmallView(entry: entry)
            }
        }
        .widgetBackground(Color(UIColor.systemBackground))
    }
}

// MARK: - Widget 2 Views: Thao tác nhanh 1 chạm (Gợi ý 2 với Báo cáo cuối ca)

struct GasQuickActionsWidgetView: View {
    var entry: GasWidgetProvider.Entry

    var body: some View {
        VStack(spacing: 10) {
            // Thanh tiêu đề
            HStack(spacing: 6) {
                Image(systemName: "flame.fill")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(Color(red: 239/255, green: 68/255, blue: 68/255))
                Text("Gas Manager • Thao tác nhanh")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(.primary)
                Spacer()
                Text(entry.shiftName)
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }

            // 4 Nút chức năng 1 chạm
            HStack(spacing: 8) {
                // 1. Thêm điểm gas
                QuickActionButton(
                    title: "Thêm điểm",
                    icon: "plus.circle.fill",
                    color: Color(red: 239/255, green: 68/255, blue: 68/255), // Red
                    url: "gasmanager://add_point"
                )

                // 2. Đếm tiền
                QuickActionButton(
                    title: "Đếm tiền",
                    icon: "banknote.fill",
                    color: Color(red: 0/255, green: 91/255, blue: 166/255), // Blue
                    url: "gasmanager://diemtien"
                )

                // 3. Clipboard
                QuickActionButton(
                    title: "Clipboard",
                    icon: "doc.on.clipboard.fill",
                    color: Color(red: 139/255, green: 92/255, blue: 246/255), // Purple
                    url: "gasmanager://clipboard"
                )

                // 4. Báo cáo cuối ca (Thay thế bản đồ theo yêu cầu người dùng)
                QuickActionButton(
                    title: "Báo cáo ca",
                    icon: "chart.bar.fill",
                    color: Color(red: 245/255, green: 158/255, blue: 11/255), // Amber
                    url: "gasmanager://report"
                )
            }
        }
        .padding(12)
        .widgetBackground(Color(UIColor.systemBackground))
    }
}

struct QuickActionButton: View {
    let title: String
    let icon: String
    let color: Color
    let url: String

    var body: some View {
        Link(destination: URL(string: url)!) {
            VStack(spacing: 6) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(color.opacity(0.14))
                        .frame(width: 48, height: 48)

                    Image(systemName: icon)
                        .font(.system(size: 23, weight: .semibold))
                        .foregroundColor(color)
                }

                Text(title)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(.primary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.85)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 4)
        }
    }
}

// Extension hỗ trợ containerBackground cho iOS 17+ và fallback cho iOS 15-16
extension View {
    @ViewBuilder
    func widgetBackground(_ backgroundView: some View) -> some View {
        if #available(iOS 17.0, *) {
            containerBackground(for: .widget) {
                backgroundView
            }
        } else {
            background(backgroundView)
        }
    }
}

// MARK: - Widget Definitions

// Widget 1: Tổng quan Ca & Doanh thu
struct GasShiftWidget: Widget {
    let kind: String = "GasShiftWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: GasWidgetProvider()) { entry in
            GasWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Tổng quan Ca & Doanh thu")
        .description("Xem số điểm gas, tổng doanh thu và trạng thái nộp tiền của ca hiện tại.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

// Widget 2: Thao tác nhanh 1 chạm (Thêm điểm, Đếm tiền, Clipboard, Báo cáo cuối ca)
struct GasQuickActionsWidget: Widget {
    let kind: String = "GasQuickActionsWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: GasWidgetProvider()) { entry in
            GasQuickActionsWidgetView(entry: entry)
        }
        .configurationDisplayName("Thao tác nhanh 1 chạm")
        .description("Mở nhanh: Thêm điểm gas, Đếm tiền, Clipboard và Báo cáo cuối ca.")
        .supportedFamilies([.systemMedium])
    }
}

// MARK: - Widget Bundle (Xuất cả 2 widget ra Widget Gallery của iOS)

@main
struct GasWidgetBundle: WidgetBundle {
    @WidgetBundleBuilder
    var body: some Widget {
        GasQuickActionsWidget()
        GasShiftWidget()
    }
}
