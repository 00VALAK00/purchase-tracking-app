class Item {
  final String name;
  final int? quantity;
  final double amount;

  Item({
    required this.name,
    this.quantity,
    required this.amount,
  });

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      name: json['name'],
      quantity: json['quantity'],
      amount: json['amount'].toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'quantity': quantity,
      'amount': amount,
    };
  }
}

class Transaction {
  final String transactionId;
  final int userId;
  final DateTime createdAt;
  final double totalAmount;
  final List<Item> items;
  final String? rawOcrText;
  final String? fidelityCardNumber;
  final bool fidelityCardApplied;

  Transaction({
    required this.transactionId,
    required this.userId,
    required this.createdAt,
    required this.totalAmount,
    required this.items,
    this.rawOcrText,
    this.fidelityCardNumber,
    required this.fidelityCardApplied,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      transactionId: json['transaction_id'],
      userId: json['user_id'],
      createdAt: DateTime.parse(json['created_at']),
      totalAmount: json['total_amount'].toDouble(),
      items: (json['items'] as List)
          .map((item) => Item.fromJson(item))
          .toList(),
      rawOcrText: json['raw_ocr_text'],
      fidelityCardNumber: json['fidelity_card_number'],
      fidelityCardApplied: json['fidelity_card_applied'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'transaction_id': transactionId,
      'user_id': userId,
      'created_at': createdAt.toIso8601String(),
      'total_amount': totalAmount,
      'items': items.map((item) => item.toJson()).toList(),
      'raw_ocr_text': rawOcrText,
      'fidelity_card_number': fidelityCardNumber,
      'fidelity_card_applied': fidelityCardApplied,
    };
  }
}
