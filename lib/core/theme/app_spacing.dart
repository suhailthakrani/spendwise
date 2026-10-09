abstract final class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 24;
  static const double xxxl = 32;

  /// Standard horizontal page inset.
  static const double page = 20;

  /// Tab AppBars with title + subtitle (matches Home SliverAppBar).
  /// Sized for Nunito’s taller line metrics vs Montserrat.
  static const double tabAppBarHeight = 84;

  /// Clearance above bottom nav + FAB.
  static const double navClearance = 92;

  /// Comfortable vertical padding inside list rows with Nunito.
  static const double listTileVertical = 6;
}

abstract final class AppRadii {
  static const double sm = 10;
  static const double md = 14;
  static const double lg = 18;
  static const double xl = 24;
  static const double pill = 28;
  static const double full = 999;
}
