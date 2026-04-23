class AppState {
  final String currentPath;
  final List<String> breadcrumb;
  final List<String> favorites;
  final List<String> clipboard;
  final bool cutMode;
  final bool showHidden;
  final bool rootMode;

  const AppState({
    required this.currentPath,
    required this.breadcrumb,
    required this.favorites,
    required this.clipboard,
    required this.cutMode,
    required this.showHidden,
    required this.rootMode,
  });
}