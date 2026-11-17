
extension Set {
    mutating func unseenItems<Item: Identifiable>(_ items: [Item]) -> [Item] where Item.ID == Element {
        items.filter { insert($0.id).inserted }
    }
}
