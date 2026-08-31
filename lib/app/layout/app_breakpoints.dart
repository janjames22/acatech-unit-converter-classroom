enum WindowSizeClass { compact, medium, expanded }

abstract final class AppBreakpoints {
  static const double compact = 600;
  static const double expanded = 1024;
  static const double contentMaxWidth = 1280;

  static WindowSizeClass sizeClassFor(double width) {
    if (width < compact) {
      return WindowSizeClass.compact;
    }
    if (width < expanded) {
      return WindowSizeClass.medium;
    }
    return WindowSizeClass.expanded;
  }
}
