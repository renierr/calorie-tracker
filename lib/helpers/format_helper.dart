/// Formats a byte count as a human readable size (e.g. `1.4 MB`).
String formatBytes(int bytes) {
  if (bytes <= 0) return '0 B';
  const suffixes = ['B', 'KB', 'MB', 'GB'];
  var i = 0;
  double dBytes = bytes.toDouble();
  while (dBytes >= 1024 && i < suffixes.length - 1) {
    dBytes /= 1024;
    i++;
  }
  return '${dBytes.toStringAsFixed(1)} ${suffixes[i]}';
}
