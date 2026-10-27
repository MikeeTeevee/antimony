/// Models for the Activity (Execution) view of compliance controls.
/// Tracks owners, target dates, statuses, and tasks per question/control.
library;

import 'package:flutter/material.dart';

// ---------------------------------------------------------------------------
// Control Status
// ---------------------------------------------------------------------------

enum ControlStatus { unscoped, notStarted, inProgress, complete }

extension ControlStatusExtension on ControlStatus {
  String get label {
    switch (this) {
      case ControlStatus.unscoped:
        return 'Unscoped';
      case ControlStatus.notStarted:
        return 'Not Started';
      case ControlStatus.inProgress:
        return 'In Progress';
      case ControlStatus.complete:
        return 'Complete';
    }
  }

  Color get backgroundColor {
    switch (this) {
      case ControlStatus.unscoped:
        return const Color(0xFFF3F4F6);
      case ControlStatus.notStarted:
        return const Color(0xFFFEF3C7);
      case ControlStatus.inProgress:
        return const Color(0xFFDBEAFE);
      case ControlStatus.complete:
        return const Color(0xFFD1FAE5);
    }
  }

  Color get foregroundColor {
    switch (this) {
      case ControlStatus.unscoped:
        return const Color(0xFF6B7280);
      case ControlStatus.notStarted:
        return const Color(0xFFD97706);
      case ControlStatus.inProgress:
        return const Color(0xFF1D4ED8);
      case ControlStatus.complete:
        return const Color(0xFF059669);
    }
  }

  Color get borderColor {
    switch (this) {
      case ControlStatus.unscoped:
        return const Color(0xFFD1D5DB);
      case ControlStatus.notStarted:
        return const Color(0xFFFCD34D);
      case ControlStatus.inProgress:
        return const Color(0xFF93C5FD);
      case ControlStatus.complete:
        return const Color(0xFF6EE7B7);
    }
  }

  IconData get icon {
    switch (this) {
      case ControlStatus.unscoped:
        return Icons.radio_button_unchecked;
      case ControlStatus.notStarted:
        return Icons.pause_circle_outline;
      case ControlStatus.inProgress:
        return Icons.timelapse;
      case ControlStatus.complete:
        return Icons.check_circle_outline;
    }
  }
}

// ---------------------------------------------------------------------------
// Control Task
// ---------------------------------------------------------------------------

/// A single actionable task assigned to a compliance control.
class ControlTask {
  final String id;
  String taskText;
  String owner;
  DateTime? targetDate;
  ControlStatus status;

  ControlTask({
    required this.id,
    required this.taskText,
    this.owner = '',
    this.targetDate,
    this.status = ControlStatus.notStarted,
  });

  ControlTask copyWith({
    String? taskText,
    String? owner,
    DateTime? targetDate,
    ControlStatus? status,
  }) => ControlTask(
        id: id,
        taskText: taskText ?? this.taskText,
        owner: owner ?? this.owner,
        targetDate: targetDate ?? this.targetDate,
        status: status ?? this.status,
      );
}

// ---------------------------------------------------------------------------
// Control Row Data
// ---------------------------------------------------------------------------

/// The execution-layer state for one SOX question/control.
class ControlRowData {
  final String questionId;
  String? answer;
  String owner;
  DateTime? targetDate;
  ControlStatus status;
  List<ControlTask> tasks;

  ControlRowData({
    required this.questionId,
    this.answer,
    this.owner = '',
    this.targetDate,
    this.status = ControlStatus.unscoped,
    List<ControlTask>? tasks,
  }) : tasks = tasks ?? [];

  ControlRowData copyWith({
    String? answer,
    String? owner,
    DateTime? targetDate,
    ControlStatus? status,
    List<ControlTask>? tasks,
  }) => ControlRowData(
        questionId: questionId,
        answer: answer ?? this.answer,
        owner: owner ?? this.owner,
        targetDate: targetDate ?? this.targetDate,
        status: status ?? this.status,
        tasks: tasks ?? List<ControlTask>.from(this.tasks),
      );
}
