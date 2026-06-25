abstract final class AppIcons {
  static const _base = 'assets/icons';

  // Navigation
  static const home = '$_base/home.svg';
  static const expenses = '$_base/expenses.svg';
  static const reports = '$_base/reports.svg';
  static const budget = '$_base/budget.svg';
  static const account = '$_base/account.svg';
  static const add = '$_base/add.svg';

  // Actions
  static const search = '$_base/search.svg';
  static const filter = '$_base/filter.svg';
  static const notifications = '$_base/notifications.svg';
  static const edit = '$_base/edit.svg';
  static const delete = '$_base/delete.svg';
  static const sort = '$_base/sort.svg';
  static const clear = '$_base/clear.svg';
  static const chevronRight = '$_base/chevron_right.svg';

  // Account & settings
  static const darkMode = '$_base/dark_mode.svg';
  static const lightMode = '$_base/light_mode.svg';
  static const exportCsv = '$_base/export_csv.svg';
  static const exportExcel = '$_base/export_excel.svg';
  static const category = '$_base/category.svg';
  static const logout = '$_base/logout.svg';
  static const globe = '$_base/globe.svg';
  static const currency = '$_base/currency.svg';
  static const profile = '$_base/profile.svg';
  static const settings = '$_base/settings.svg';
  static const logo = '$_base/logo.svg';

  // Status
  static const savings = '$_base/savings.svg';
  static const warning = '$_base/warning.svg';
  static const arrowUp = '$_base/arrow_up.svg';
  static const arrowDown = '$_base/arrow_down.svg';
  static const info = '$_base/info.svg';
  static const error = '$_base/error.svg';
  static const receiptEmpty = '$_base/receipt_empty.svg';
  static const searchOff = '$_base/search_off.svg';
  static const wallet = '$_base/wallet.svg';

  // Detail fields
  static const calendar = '$_base/calendar.svg';
  static const clock = '$_base/clock.svg';
  static const repeat = '$_base/repeat.svg';

  // Categories
  static const restaurant = '$_base/restaurant.svg';
  static const car = '$_base/car.svg';
  static const shoppingBag = '$_base/shopping_bag.svg';
  static const receipt = '$_base/receipt.svg';
  static const movie = '$_base/movie.svg';
  static const heart = '$_base/heart.svg';
  static const school = '$_base/school.svg';

  // Payment methods
  static const payments = '$_base/payments.svg';
  static const creditCard = '$_base/credit_card.svg';
  static const bank = '$_base/bank.svg';
  static const more = '$_base/more.svg';

  static String categoryIcon(String iconName) => switch (iconName) {
        'restaurant' => restaurant,
        'directions_car' => car,
        'shopping_bag' => shoppingBag,
        'receipt_long' => receipt,
        'movie' => movie,
        'favorite' => heart,
        'school' => school,
        _ => category,
      };

  static String paymentIcon(String iconName) => switch (iconName) {
        'payments' => payments,
        'credit_card' => creditCard,
        'account_balance' => bank,
        'account_balance_wallet' => wallet,
        _ => more,
      };
}
