/// What a ledger row represents. Kept small on purpose — only what people record.
enum LedgerEntryType {
  expense,
  income;

  /// Maps DB/backup strings. Unknown values and legacy `transfer` → expense.
  static LedgerEntryType fromDb(String value) {
    if (value == 'income') return LedgerEntryType.income;
    return LedgerEntryType.expense;
  }
}
