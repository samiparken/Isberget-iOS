import Foundation

func stringToDateForLogin(with dateString: String) -> Date {
    let formatter = DateFormatter()
    formatter.dateFormat = "E, d MMM yyyy HH:mm:ss Z"
    return formatter.date(from: dateString) ?? Date()
}

func stringToDate(with dateString: String) -> Date {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
    return formatter.date(from: dateString) ?? Date()
}
func stringToDate2(with dateString: String) -> Date {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
    return formatter.date(from: dateString) ?? Date()
}
func stringToDate3(with dateString: String) -> Date {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    return formatter.date(from: dateString) ?? Date()
}

func dateToString_hm(with date: Date) -> String {
    let calendar = Calendar.current
    let hour = calendar.component(.hour, from: date)
    let min = calendar.component(.minute, from: date)
    return String(format: "%02d:%02d", hour, min)
}

func dateToString_mdhm(with date: Date) -> String {
    let calendar = Calendar.current
    let month = calendar.component(.month, from: date)
    let day = calendar.component(.day, from: date)
    let hour = calendar.component(.hour, from: date)
    let min = calendar.component(.minute, from: date)
    return "\(day)/\(month) " + String(format: "%02d:%02d", hour, min)
}

func dateToString_ymd(with date: Date) -> String {
    let calendar = Calendar.current
    let year = calendar.component(.year, from: date)
    let month = calendar.component(.month, from: date)
    let day = calendar.component(.day, from: date)
    return String(format: "%04d-%02d-%02d", year,month,day)
}

func dateToString_ymdhms(with date: Date) -> String {
    let calendar = Calendar.current
    let year = calendar.component(.year, from: date)
    let month = calendar.component(.month, from: date)
    let day = calendar.component(.day, from: date)
    let hour = calendar.component(.hour, from: date)
    let min = calendar.component(.minute, from: date)
    let sec = calendar.component(.second, from: date)
    return "\(year)-" + String(format: "%02d-%02d %02d:%02d:%02d", month, day, hour, min, sec)
}

func dateToString_ymdhm(with date: Date) -> String {
    let calendar = Calendar.current
    let year = calendar.component(.year, from: date)
    let month = calendar.component(.month, from: date)
    let day = calendar.component(.day, from: date)
    let hour = calendar.component(.hour, from: date)
    let min = calendar.component(.minute, from: date)
    return "\(year)-" + String(format: "%02d-%02d %02d:%02d", month, day, hour, min)
}

func dateToString_ymdThm(with date: Date) -> String {
    let calendar = Calendar.current
    let year = calendar.component(.year, from: date)
    let month = calendar.component(.month, from: date)
    let day = calendar.component(.day, from: date)
    let hour = calendar.component(.hour, from: date)
    let min = calendar.component(.minute, from: date)
    return "\(year)-" + String(format: "%02d-%02dT%02d:%02d", month, day, hour, min)
}

func isSameDay(_ date1: Date,_ date2: Date) -> Bool {

    let string1 = dateToString_ymd(with: date1)
    let string2 = dateToString_ymd(with: date2)

    return string1 == string2
}

func isSameTimeInMinute(_ date1: Date, _ date2: Date) -> Bool {
    let string1 = dateToString_ymdhm(with: date1)
    let string2 = dateToString_ymdhm(with: date2)

    return string1 == string2
}

//For performance measurements
func printDate(_ string: String) {
    let date = Date()
    let formatter = DateFormatter()
    formatter.dateFormat = "HH:mm:ss.SSSS"
    print(string + formatter.string(from: date))
}

extension Date {
    func timeAgoDisplay() -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        formatter.locale = NSLocale(localeIdentifier: "sv") as Locale
        return formatter.localizedString(for: self, relativeTo: Date())
    }
}
