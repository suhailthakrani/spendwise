enum PaymentMethod {
  cash('Cash', 'payments'),
  card('Card', 'credit_card'),
  bankTransfer('Bank Transfer', 'account_balance'),
  digitalWallet('Digital Wallet', 'account_balance_wallet'),
  other('Other', 'more_horiz');

  const PaymentMethod(this.label, this.iconName);

  final String label;
  final String iconName;
}
