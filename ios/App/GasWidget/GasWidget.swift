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
    let expenseTotal: Int
    let expenseFormatted: String
    let updatedAt: String
    let isLive: Bool

    static var placeholder: GasShiftEntry {
        GasShiftEntry(
            date: Date(),
            shiftName: "Ca hôm nay",
            count: 12,
            total: 7440000,
            totalFormatted: "7tr440",
            daNop: 10,
            chuaNop: 2,
            expenseTotal: 62000,
            expenseFormatted: "-62k",
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
        let fallback = UserDefaults.standard

        var shiftName: String?
        var shiftKey: String = ""
        var totalFormatted: String?
        var count = 0
        var total = 0
        var daNop = 0
        var chuaNop = 0
        var expenseTotal = 0
        var expenseFormatted = "0 đ"
        var updatedAt = "Vừa xong"
        var savedDate: Date = Date()
        var expensesByShift: [String: Int] = [:]

        // 1. Đọc từ file JSON trong App Group container (nếu có)
        if let containerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: groupID) {
            let fileURL = containerURL.appendingPathComponent("widget_data.json")
            if let data = try? Data(contentsOf: fileURL),
               let dict = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                shiftName = dict["shift"] as? String
                shiftKey = dict["shiftKey"] as? String ?? ""
                totalFormatted = dict["totalFormatted"] as? String
                count = (dict["count"] as? NSNumber)?.intValue ?? (dict["count"] as? Int) ?? 0
                total = (dict["total"] as? NSNumber)?.intValue ?? (dict["total"] as? Int) ?? 0
                daNop = (dict["daNop"] as? NSNumber)?.intValue ?? (dict["daNop"] as? Int) ?? 0
                chuaNop = (dict["chuaNop"] as? NSNumber)?.intValue ?? (dict["chuaNop"] as? Int) ?? 0
                expenseTotal = (dict["expenseTotal"] as? NSNumber)?.intValue ?? (dict["expenseTotal"] as? Int) ?? 0
                if let ef = dict["expenseFormatted"] as? String, !ef.isEmpty && ef != "0 đ" {
                    expenseFormatted = ef
                } else if expenseTotal > 0 {
                    expenseFormatted = "-\(formatCompactCurrency(expenseTotal))"
                }
                updatedAt = dict["updatedAt"] as? String ?? "Vừa xong"
                if let map = dict["expensesByShift"] as? [String: Int] {
                    expensesByShift = map
                }
            }
        }

        // 2. Bổ sung từ Shared UserDefaults / Fallback
        if shiftName == nil {
            shiftName = defaults.string(forKey: "widget_shift") ?? fallback.string(forKey: "widget_shift")
        }
        if totalFormatted == nil {
            totalFormatted = defaults.string(forKey: "widget_totalFormatted") ?? fallback.string(forKey: "widget_totalFormatted")
        }
        if shiftKey.isEmpty {
            shiftKey = defaults.string(forKey: "widget_shiftKey") ?? fallback.string(forKey: "widget_shiftKey") ?? ""
        }
        if count == 0 {
            count = defaults.object(forKey: "widget_count") != nil ? defaults.integer(forKey: "widget_count") : fallback.integer(forKey: "widget_count")
        }
        if total == 0 {
            total = defaults.object(forKey: "widget_total") != nil ? defaults.integer(forKey: "widget_total") : fallback.integer(forKey: "widget_total")
        }
        if daNop == 0 {
            daNop = defaults.object(forKey: "widget_daNop") != nil ? defaults.integer(forKey: "widget_daNop") : fallback.integer(forKey: "widget_daNop")
        }
        if chuaNop == 0 {
            chuaNop = defaults.object(forKey: "widget_chuaNop") != nil ? defaults.integer(forKey: "widget_chuaNop") : fallback.integer(forKey: "widget_chuaNop")
        }
        let savedTime = defaults.double(forKey: "widget_timestamp") > 0 ? defaults.double(forKey: "widget_timestamp") : fallback.double(forKey: "widget_timestamp")
        if savedTime > 0 {
            savedDate = Date(timeIntervalSince1970: savedTime)
        }

        // 3. Nếu expenseTotal vẫn = 0, tìm từ expensesByShift hoặc key theo ca
        if expenseTotal == 0 {
            if !shiftKey.isEmpty, let val = expensesByShift[shiftKey], val > 0 {
                expenseTotal = val
                expenseFormatted = "-\(formatCompactCurrency(val))"
            } else if !shiftKey.isEmpty {
                let keyExp = defaults.integer(forKey: "widget_expenseTotal_\(shiftKey)") != 0 ? defaults.integer(forKey: "widget_expenseTotal_\(shiftKey)") : fallback.integer(forKey: "widget_expenseTotal_\(shiftKey)")
                if keyExp > 0 {
                    expenseTotal = keyExp
                    expenseFormatted = defaults.string(forKey: "widget_expenseFormatted_\(shiftKey)") ?? fallback.string(forKey: "widget_expenseFormatted_\(shiftKey)") ?? "-\(formatCompactCurrency(keyExp))"
                }
            }
        }
        if expenseTotal == 0 {
            let defExp = defaults.object(forKey: "widget_expenseTotal") != nil ? defaults.integer(forKey: "widget_expenseTotal") : fallback.integer(forKey: "widget_expenseTotal")
            if defExp > 0 {
                expenseTotal = defExp
                expenseFormatted = defaults.string(forKey: "widget_expenseFormatted") ?? fallback.string(forKey: "widget_expenseFormatted") ?? "-\(formatCompactCurrency(defExp))"
            }
        }
        if expenseTotal == 0 && !expensesByShift.isEmpty {
            let sortedKeys = expensesByShift.keys.sorted(by: >)
            if let firstKey = sortedKeys.first, let val = expensesByShift[firstKey], val > 0 {
                expenseTotal = val
                expenseFormatted = "-\(formatCompactCurrency(val))"
            }
        }

        guard let finalShiftName = shiftName, let finalTotalFormatted = totalFormatted else {
            return nil
        }

        return GasShiftEntry(
            date: savedDate,
            shiftName: finalShiftName,
            count: count,
            total: total,
            totalFormatted: finalTotalFormatted,
            daNop: daNop,
            chuaNop: chuaNop,
            expenseTotal: expenseTotal,
            expenseFormatted: expenseFormatted,
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

                // 1. Phân tích ngày ca chuẩn theo múi giờ Việt Nam (UTC+7)
                var latestKey = ""
                var latestDate: Date? = nil

                for item in items {
                    if let raw = item.ca, let d = self.parseShiftDate(raw) {
                        let key = self.getShiftKey(raw)
                        if key > latestKey {
                            latestKey = key
                            latestDate = d
                        }
                    }
                }

                // 2. Lọc các bản ghi thuộc ca mới nhất (theo khóa chuẩn yyyy-MM-dd)
                let shiftItems = items.filter { self.getShiftKey($0.ca) == latestKey }
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

                // 3. Format tên ca hiển thị theo giờ Việt Nam
                let shiftDisplay: String
                if let d = latestDate {
                    shiftDisplay = self.formatShiftDisplayFromDate(d)
                } else {
                    shiftDisplay = "Ca gần nhất"
                }

                let formattedTotal = formatCompactCurrency(total)

                let timeFormatter = DateFormatter()
                timeFormatter.dateFormat = "HH:mm"
                let updatedTime = timeFormatter.string(from: Date())

                // 4. Tìm số tiền chi tiêu thực tế khớp với ca mới nhất (latestKey)
                var expenseTotal = 0
                var expenseFormatted = "0 đ"
                var expensesByShift: [String: Int] = [:]

                // A. Thử đọc từ widget_data.json trong App Group container
                if let containerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: groupID) {
                    let fileURL = containerURL.appendingPathComponent("widget_data.json")
                    if let d = try? Data(contentsOf: fileURL),
                       let dict = try? JSONSerialization.jsonObject(with: d) as? [String: Any] {
                        if let map = dict["expensesByShift"] as? [String: Int] {
                            expensesByShift = map
                        }
                        if let mapVal = expensesByShift[latestKey], mapVal > 0 {
                            expenseTotal = mapVal
                        } else {
                            let fileShiftKey = dict["shiftKey"] as? String ?? ""
                            let exp = (dict["expenseTotal"] as? NSNumber)?.intValue ?? (dict["expenseTotal"] as? Int) ?? 0
                            if exp > 0 && (fileShiftKey.isEmpty || fileShiftKey == latestKey) {
                                expenseTotal = exp
                            }
                        }
                        if expenseTotal > 0 {
                            if let ef = dict["expenseFormatted"] as? String, !ef.isEmpty && ef != "0 đ" && (dict["shiftKey"] as? String ?? "") == latestKey {
                                expenseFormatted = ef
                            } else {
                                expenseFormatted = "-\(formatCompactCurrency(expenseTotal))"
                            }
                        }
                    }
                }

                // B. Nếu chưa có hoặc = 0, đọc từ Shared UserDefaults
                let defaults = UserDefaults(suiteName: groupID) ?? UserDefaults.standard
                let fallback = UserDefaults.standard
                if expenseTotal == 0 {
                    let keySpecific = defaults.integer(forKey: "widget_expenseTotal_\(latestKey)") != 0 ? defaults.integer(forKey: "widget_expenseTotal_\(latestKey)") : fallback.integer(forKey: "widget_expenseTotal_\(latestKey)")
                    if keySpecific > 0 {
                        expenseTotal = keySpecific
                        expenseFormatted = defaults.string(forKey: "widget_expenseFormatted_\(latestKey)") ?? fallback.string(forKey: "widget_expenseFormatted_\(latestKey)") ?? "-\(formatCompactCurrency(keySpecific))"
                    } else if let data = defaults.data(forKey: "widget_expensesByShift") ?? fallback.data(forKey: "widget_expensesByShift"),
                              let map = try? JSONSerialization.jsonObject(with: data) as? [String: Int],
                              let val = map[latestKey], val > 0 {
                        expenseTotal = val
                        expenseFormatted = "-\(formatCompactCurrency(val))"
                    } else {
                        let savedExp = defaults.object(forKey: "widget_expenseTotal") != nil ? defaults.integer(forKey: "widget_expenseTotal") : fallback.integer(forKey: "widget_expenseTotal")
                        if savedExp > 0 {
                            expenseTotal = savedExp
                            expenseFormatted = defaults.string(forKey: "widget_expenseFormatted") ?? fallback.string(forKey: "widget_expenseFormatted") ?? "-\(formatCompactCurrency(savedExp))"
                        }
                    }
                }

                // C. Nếu vẫn = 0 nhưng có ca gần nhất có chi tiêu trong expensesByShift
                if expenseTotal == 0 && !expensesByShift.isEmpty {
                    let sortedKeys = expensesByShift.keys.sorted(by: >)
                    if let firstKey = sortedKeys.first, let val = expensesByShift[firstKey], val > 0 {
                        expenseTotal = val
                        expenseFormatted = "-\(formatCompactCurrency(val))"
                    }
                }

                let entry = GasShiftEntry(
                    date: Date(),
                    shiftName: shiftDisplay,
                    count: count,
                    total: total,
                    totalFormatted: formattedTotal,
                    daNop: daNop,
                    chuaNop: chuaNop,
                    expenseTotal: expenseTotal,
                    expenseFormatted: expenseFormatted,
                    updatedAt: updatedTime,
                    isLive: true
                )

                // Lưu vào cache
                defaults.set(shiftDisplay, forKey: "widget_shift")
                defaults.set(latestKey, forKey: "widget_shiftKey")
                defaults.set(count, forKey: "widget_count")
                defaults.set(total, forKey: "widget_total")
                defaults.set(formattedTotal, forKey: "widget_totalFormatted")
                defaults.set(daNop, forKey: "widget_daNop")
                defaults.set(chuaNop, forKey: "widget_chuaNop")
                defaults.set(updatedTime, forKey: "widget_updatedAt")
                if expenseTotal > 0 {
                    defaults.set(expenseTotal, forKey: "widget_expenseTotal")
                    defaults.set(expenseFormatted, forKey: "widget_expenseFormatted")
                    defaults.set(expenseTotal, forKey: "widget_expenseTotal_\(latestKey)")
                    defaults.set(expenseFormatted, forKey: "widget_expenseFormatted_\(latestKey)")
                }
                defaults.set(Date().timeIntervalSince1970, forKey: "widget_timestamp")

                completion(entry)
            } catch {
                completion(nil)
            }
        }.resume()
    }

    // Parse ngày ca chính xác theo giờ Việt Nam (UTC+7)
    private func parseShiftDate(_ rawCa: String) -> Date? {
        let trimmed = rawCa.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty { return nil }

        // Dạng ISO 8601 (ví dụ 2026-11-08T17:00:00.000Z từ Google Apps Script)
        let isoFormatter = ISO8601DateFormatter()
        isoFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let d = isoFormatter.date(from: trimmed) { return d }
        isoFormatter.formatOptions = [.withInternetDateTime]
        if let d = isoFormatter.date(from: trimmed) { return d }

        let vnTimeZone = TimeZone(identifier: "Asia/Ho_Chi_Minh") ?? TimeZone(secondsFromGMT: 7 * 3600)!

        // Dạng yyyy-MM-dd
        let dfYMD = DateFormatter()
        dfYMD.dateFormat = "yyyy-MM-dd"
        dfYMD.timeZone = vnTimeZone
        if let d = dfYMD.date(from: trimmed) { return d }

        // Dạng Ca dd-MM-yyyy hoặc dd-MM-yyyy
        let cleaned = trimmed.replacingOccurrences(of: "Ca ", with: "", options: .caseInsensitive)
        let dfDMY = DateFormatter()
        dfDMY.dateFormat = "dd-MM-yyyy"
        dfDMY.timeZone = vnTimeZone
        if let d = dfDMY.date(from: cleaned) { return d }

        return nil
    }

    // Chuyển chuỗi ca bất kỳ thành khóa chuẩn yyyy-MM-dd theo giờ Việt Nam
    private func getShiftKey(_ rawCa: String?) -> String {
        guard let raw = rawCa, let date = parseShiftDate(raw) else { return "" }
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        df.timeZone = TimeZone(identifier: "Asia/Ho_Chi_Minh") ?? TimeZone(secondsFromGMT: 7 * 3600)!
        return df.string(from: date)
    }

    // Hiển thị tên ca dạng Ca dd-MM theo giờ Việt Nam
    private func formatShiftDisplayFromDate(_ date: Date) -> String {
        let df = DateFormatter()
        df.dateFormat = "dd-MM"
        df.timeZone = TimeZone(identifier: "Asia/Ho_Chi_Minh") ?? TimeZone(secondsFromGMT: 7 * 3600)!
        let dayMonth = df.string(from: date)
        return "Ca \(dayMonth)"
    }

    private func formatCompactCurrency(_ amount: Int) -> String {
        let absAmount = abs(amount)
        let millions = absAmount / 1_000_000
        let thousands = (absAmount % 1_000_000) / 1_000
        let sign = amount < 0 ? "-" : ""

        if absAmount == 0 { return "0 đ" }
        if absAmount < 1_000 { return "\(sign)\(absAmount) đ" }
        if millions > 0 && thousands > 0 {
            return "\(sign)\(millions)tr\(thousands)"
        }
        if millions > 0 {
            return "\(sign)\(millions)tr"
        }
        return "\(sign)\(thousands)k"
    }
}

extension GasShiftEntry {
    var displayAmount: String {
        let cleaned = totalFormatted
            .replacingOccurrences(of: " ngàn", with: "")
            .replacingOccurrences(of: "ngàn", with: "")
            .trimmingCharacters(in: .whitespaces)
        return cleaned.isEmpty ? totalFormatted : cleaned
    }
}

// MARK: - Component: Nút tròn Chi tiêu ca (Interactive Deep Link)

struct GasExpenseCircleButton: View {
    let expenseFormatted: String
    let expenseTotal: Int

    var body: some View {
        Link(destination: URL(string: "gasmanager://expense")!) {
            ZStack {
                // Vòng nền mờ hiệu ứng Amber / Orange đồng bộ với nút Chi tiêu ca trong app
                Circle()
                    .stroke(
                        LinearGradient(
                            colors: [
                                Color(red: 245/255, green: 158/255, blue: 11/255), // Amber
                                Color(red: 217/255, green: 119/255, blue: 6/255)   // Deep Amber
                            ],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 3.5
                    )
                    .background(
                        Circle()
                            .fill(
                                LinearGradient(
                                    colors: [
                                        Color(red: 245/255, green: 158/255, blue: 11/255).opacity(0.12),
                                        Color(red: 217/255, green: 119/255, blue: 6/255).opacity(0.06)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                    )

                // Thông số ở giữa: Icon thẻ + Số tiền chi tiêu + Chữ CHI TIÊU
                VStack(spacing: 2) {
                    Image(systemName: "creditcard.fill")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(Color(red: 245/255, green: 158/255, blue: 11/255))

                    Text(expenseFormatted)
                        .font(.system(size: 15, weight: .heavy, design: .rounded))
                        .foregroundColor(expenseTotal > 0 ? Color(red: 239/255, green: 68/255, blue: 68/255) : Color(red: 245/255, green: 158/255, blue: 11/255))
                        .lineLimit(1)
                        .minimumScaleFactor(0.65)

                    Text("CHI TIÊU")
                        .font(.system(size: 8.5, weight: .heavy))
                        .foregroundColor(.secondary)
                        .tracking(0.3)
                }
                .padding(4)
            }
            .frame(width: 86, height: 86)
        }
    }
}

// MARK: - Widget 1 Views: Tổng quan Ca & Doanh thu

// Kích thước 2x2 (.systemSmall): Bỏ số điểm và chữ 'doanh thu ca', phóng to số tiền vừa khung
struct GasWidgetSmallView: View {
    let entry: GasShiftEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header: Tên ca & Chấm xanh Live
            HStack(spacing: 5) {
                Image(systemName: "flame.fill")
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(Color(red: 239/255, green: 68/255, blue: 68/255))

                Text(entry.shiftName)
                    .font(.system(size: 13, weight: .bold))
                    .foregroundColor(.primary)
                    .lineLimit(1)

                Spacer()

                Circle()
                    .fill(Color(red: 16/255, green: 185/255, blue: 129/255))
                    .frame(width: 7, height: 7)
            }

            Spacer()

            // Doanh thu khổng lồ, phóng to tối đa vừa vặn toàn bộ khung
            Text(entry.displayAmount)
                .font(.system(size: 36, weight: .black, design: .rounded))
                .foregroundColor(Color(red: 16/255, green: 185/255, blue: 129/255))
                .lineLimit(1)
                .minimumScaleFactor(0.5)
                .frame(maxWidth: .infinity, alignment: .leading)

            Spacer()
        }
        .padding(14)
        .widgetURL(URL(string: "gasmanager://open"))
    }
}

// Kích thước 4x2 (.systemMedium): Thiết kế dạng Nút tròn Chi tiêu ca & bảng số liệu không tràn
struct GasWidgetMediumView: View {
    let entry: GasShiftEntry

    var body: some View {
        HStack(spacing: 14) {
            // 1. Nút tròn chi tiêu ca (Bấm vào mở modal Chi tiêu, bình thường hiện số tiền đã chi)
            GasExpenseCircleButton(expenseFormatted: entry.expenseFormatted, expenseTotal: entry.expenseTotal)

            // 2. Nội dung thông tin chi tiết
            VStack(alignment: .leading, spacing: 0) {
                // Header: Tên ca bên trái & Huy hiệu tổng điểm bên phải
                HStack(spacing: 5) {
                    Image(systemName: "flame.fill")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(Color(red: 239/255, green: 68/255, blue: 68/255))

                    Text(entry.shiftName)
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.primary)
                        .lineLimit(1)

                    Spacer()

                    // Huy hiệu tổng số điểm (gọn gàng, không chiếm dòng dưới)
                    HStack(spacing: 3) {
                        Image(systemName: "doc.text.fill")
                            .font(.system(size: 9, weight: .bold))
                        Text("\(entry.count) điểm")
                            .font(.system(size: 11, weight: .bold))
                    }
                    .foregroundColor(Color(red: 0/255, green: 91/255, blue: 166/255))
                    .padding(.horizontal, 7)
                    .padding(.vertical, 3)
                    .background(Color(red: 0/255, green: 91/255, blue: 166/255).opacity(0.12))
                    .cornerRadius(6)
                }

                Spacer(minLength: 4)

                // Doanh thu ca: Chữ to đậm nét, không tràn chữ
                VStack(alignment: .leading, spacing: 1) {
                    Text(entry.displayAmount)
                        .font(.system(size: 25, weight: .black, design: .rounded))
                        .foregroundColor(Color(red: 16/255, green: 185/255, blue: 129/255))
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)

                    Text("Tổng doanh thu ca")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(.secondary)
                }

                Spacer(minLength: 6)

                // 2 Thẻ trạng thái phân bổ đều 50/50 (Đã nộp & Chưa nộp) - Không còn bị chấm chấm (...)
                HStack(spacing: 8) {
                    // Thẻ Đã nộp
                    HStack(spacing: 4) {
                        Circle()
                            .fill(Color(red: 16/255, green: 185/255, blue: 129/255))
                            .frame(width: 7, height: 7)
                        Text("Đã nộp:")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(.secondary)
                        Text("\(entry.daNop)")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.primary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 5)
                    .background(Color(red: 16/255, green: 185/255, blue: 129/255).opacity(0.12))
                    .cornerRadius(7)

                    // Thẻ Chưa nộp
                    HStack(spacing: 4) {
                        Circle()
                            .fill(Color.orange)
                            .frame(width: 7, height: 7)
                        Text("Chưa:")
                            .font(.system(size: 11, weight: .medium))
                            .foregroundColor(.secondary)
                        Text("\(entry.chuaNop)")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.orange)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 5)
                    .background(Color.orange.opacity(0.12))
                    .cornerRadius(7)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(13)
        .widgetURL(URL(string: "gasmanager://open"))
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
