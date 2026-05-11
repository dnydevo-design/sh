enum PermissionKind {
  storage,
  location,
  bluetooth,
  camera,
}

class PermissionStep {
  const PermissionStep({
    required this.kind,
    required this.titleKey,
    required this.bodyKey,
  });

  final PermissionKind kind;
  final String titleKey;
  final String bodyKey;
}

