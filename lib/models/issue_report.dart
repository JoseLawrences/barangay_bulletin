import 'package:hive/hive.dart';
part 'issue_report.g.dart';

@HiveType(typeId: 2)
enum IssueReportCategory{
  @HiveField(0) road,
  @HiveField(1) power,
  @HiveField(2) water,
  @HiveField(3) safety,
  @HiveField(4) other,
}

@HiveType(typeId: 3)
enum IssueReportStatus{
  @HiveField(0) pending,
  @HiveField(1) inProgress,
  @HiveField(2) resolved,
}

@HiveType(typeId: 4)
class IssueReport extends HiveObject{
  @HiveField(0) final String id;
  @HiveField(1) String title;
  @HiveField(2) String description;
  @HiveField(3) IssueReportCategory category;
  @HiveField(4) IssueReportStatus status;
  @HiveField(5) DateTime dateReported;
  @HiveField(6) bool isDeleted;
  @HiveField(7) DateTime? deletedAt;

  IssueReport({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    this.status = IssueReportStatus.pending,
    required this.dateReported,
    this.isDeleted = false,
    this.deletedAt,
  });
}

