class ItemGrant {
  final String itemId;
  final int quantity;

  const ItemGrant(this.itemId, {this.quantity = 1});
}

class StartingEquipmentOption {
  final String id;
  final String label;
  final List<ItemGrant> items;
  final int goldPieces;

  const StartingEquipmentOption({
    required this.id,
    required this.label,
    this.items = const [],
    this.goldPieces = 0,
  });
}
