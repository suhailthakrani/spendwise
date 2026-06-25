enum ExpenseSortBy {
  dateDesc('Newest first'),
  dateAsc('Oldest first'),
  amountDesc('Highest amount'),
  amountAsc('Lowest amount');

  const ExpenseSortBy(this.label);
  final String label;
}
