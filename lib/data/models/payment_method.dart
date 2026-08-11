enum PaymentMethod {
  cash('Cash', 'payments'),
  bankTransfer('Bank Transfer', 'account_balance'),
  digitalWallet('Digital Wallet', 'account_balance_wallet'),
  card('Card', 'credit_card'),
  other('Other', 'more_horiz');

  const PaymentMethod(this.label, this.iconName);

  final String label;
  final String iconName;
}
