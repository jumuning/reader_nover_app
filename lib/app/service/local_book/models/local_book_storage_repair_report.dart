enum LocalBookStorageIssueType {
  missingStoredFile,
  pathOutsideManagedDirectory,
  fileSizeMismatch,
  missingCover,
  orphanedManagedEntry,
}

class LocalBookStorageIssue {
  const LocalBookStorageIssue({
    required this.type,
    required this.path,
    this.bookId,
    this.detail,
  });

  final LocalBookStorageIssueType type;
  final String path;
  final int? bookId;
  final String? detail;
}

class LocalBookStorageRepairReport {
  const LocalBookStorageRepairReport({
    required this.issues,
    required this.deletedPaths,
    required this.reclaimedBytes,
  });

  final List<LocalBookStorageIssue> issues;
  final List<String> deletedPaths;
  final int reclaimedBytes;

  bool get isHealthy => issues.isEmpty;
  int get repairedCount => deletedPaths.length;
}
