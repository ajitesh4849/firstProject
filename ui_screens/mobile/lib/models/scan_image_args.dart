class ScanImageArgs {
  const ScanImageArgs({
    required this.bytes,
    required this.filename,
    this.forceFailure = false,
  });

  final List<int> bytes;
  final String filename;
  final bool forceFailure;
}
