extension Int {
    func formatRuntime() -> String {
        var runtimeText = ""
        let hours = self / 60
        let minutes = self % 60

        if hours <= 0 {
            runtimeText = "\(minutes)m"
        } else {
            runtimeText = "\(hours)h \(minutes)m"
        }

        return runtimeText
    }
}
