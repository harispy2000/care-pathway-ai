/// Compact local date+time used for analysis history entries.
String formatHistoryDateTime(DateTime d) {
  final local = d.toLocal();
  String two(int n) => n.toString().padLeft(2, '0');
  return '${two(local.day)}/${two(local.month)}/${local.year} · '
      '${two(local.hour)}:${two(local.minute)}';
}