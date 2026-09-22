/// What a ledger row represents. Kept small on purpose — only what people record.
enum LedgerEntryType {
  expense,
  income,
  transfer;

  static LedgerEntryType fromDb(String value) {
    for (final type in LedgerEntryType.values) {
      if (type.name == value) return type;
    }
    return LedgerEntryType.expense;
  }
}
