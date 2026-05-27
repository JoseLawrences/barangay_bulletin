// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'issue_report.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class IssueReportAdapter extends TypeAdapter<IssueReport> {
  @override
  final int typeId = 4;

  @override
  IssueReport read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return IssueReport(
      id: fields[0] as String,
      title: fields[1] as String,
      description: fields[2] as String,
      category: fields[3] as IssueReportCategory,
      status: fields[4] as IssueReportStatus,
      dateReported: fields[5] as DateTime,
      isDeleted: fields[6] as bool,
      deletedAt: fields[7] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, IssueReport obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.category)
      ..writeByte(4)
      ..write(obj.status)
      ..writeByte(5)
      ..write(obj.dateReported)
      ..writeByte(6)
      ..write(obj.isDeleted)
      ..writeByte(7)
      ..write(obj.deletedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is IssueReportAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class IssueReportCategoryAdapter extends TypeAdapter<IssueReportCategory> {
  @override
  final int typeId = 2;

  @override
  IssueReportCategory read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return IssueReportCategory.road;
      case 1:
        return IssueReportCategory.power;
      case 2:
        return IssueReportCategory.water;
      case 3:
        return IssueReportCategory.safety;
      case 4:
        return IssueReportCategory.other;
      default:
        return IssueReportCategory.road;
    }
  }

  @override
  void write(BinaryWriter writer, IssueReportCategory obj) {
    switch (obj) {
      case IssueReportCategory.road:
        writer.writeByte(0);
        break;
      case IssueReportCategory.power:
        writer.writeByte(1);
        break;
      case IssueReportCategory.water:
        writer.writeByte(2);
        break;
      case IssueReportCategory.safety:
        writer.writeByte(3);
        break;
      case IssueReportCategory.other:
        writer.writeByte(4);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is IssueReportCategoryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class IssueReportStatusAdapter extends TypeAdapter<IssueReportStatus> {
  @override
  final int typeId = 3;

  @override
  IssueReportStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return IssueReportStatus.pending;
      case 1:
        return IssueReportStatus.inProgress;
      case 2:
        return IssueReportStatus.resolved;
      default:
        return IssueReportStatus.pending;
    }
  }

  @override
  void write(BinaryWriter writer, IssueReportStatus obj) {
    switch (obj) {
      case IssueReportStatus.pending:
        writer.writeByte(0);
        break;
      case IssueReportStatus.inProgress:
        writer.writeByte(1);
        break;
      case IssueReportStatus.resolved:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is IssueReportStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
