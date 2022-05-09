class UpdateCatch {
  final int? targetNumber;
  final bool isDelete;
  final String? kind;
  final String? url;
  final bool isRegeneration;

  const UpdateCatch({
    required this.targetNumber,
    required this.isDelete,
    required this.kind,
    required this.url,
    required this.isRegeneration,
  });
}
