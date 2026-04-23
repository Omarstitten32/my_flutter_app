class FileItem {
  final String name;
  final String path;
  final bool isDirectory;
  final int size;
  final DateTime modified;
  final String extension;
  final bool isHidden;

  const FileItem({
    required this.name,
    required this.path,
    required this.isDirectory,
    required this.size,
    required this.modified,
    required this.extension,
    required this.isHidden,
  });
}