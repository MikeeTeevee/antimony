/// Activity View — spreadsheet-style execution engine for SOX compliance.
/// Shows all 38 controls in a grid with Owner, Target Date, Status, and Tasks.
library;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/compliance_models.dart';
import '../models/activity_models.dart';
import '../data/regulatory_text.dart';

class SoxActivityView extends StatefulWidget {
  final List<ComplianceQuestion> questions;
  final Map<String, String?> answers;
  final Map<String, ControlRowData> controlRows;
  final void Function(String questionId, String? answer) onAnswerChanged;
  final void Function(String questionId, ControlRowData updated) onRowChanged;

  const SoxActivityView({
    super.key,
    required this.questions,
    required this.answers,
    required this.controlRows,
    required this.onAnswerChanged,
    required this.onRowChanged,
  });

  @override
  State<SoxActivityView> createState() => _SoxActivityViewState();
}

class _SoxActivityViewState extends State<SoxActivityView> {
  // ── Column widths ──────────────────────────────────────────────────────────
  static const double _colQ = 44;
  static const double _colQuestion = 264;
  static const double _colAnswer = 108;
  static const double _colCriticality = 88;
  static const double _colStatus = 152;
  static const double _colOwner = 156;
  static const double _colDate = 124;
  static const double _colTasks = 80;
  // 7 vertical dividers (1 px each) sit between the 8 columns
  static const double _tableWidth =
      _colQ +
      _colQuestion +
      _colAnswer +
      _colCriticality +
      _colStatus +
      _colOwner +
      _colDate +
      _colTasks +
      7;

  // ── Local UI state ─────────────────────────────────────────────────────────
  final Set<String> _expandedQuestions = {};
  final Map<String, TextEditingController> _ownerControllers = {};
  int? _focusedRowIndex;
  final FocusNode _tableFocusNode = FocusNode();
  final ScrollController _listScrollController = ScrollController();

  static const _categoryOrder = [
    'Governance & Ownership',
    'Risk & Fraud Awareness',
    'Control Activities',
    'Monitoring & Testing',
    'Documentation & Evidence',
    'Gap Questions (Robustness)',
    'Process Questions (Vulnerabilities)',
  ];

  // ── Lifecycle ──────────────────────────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    for (final q in widget.questions) {
      final row = widget.controlRows[q.id];
      _ownerControllers[q.id] = TextEditingController(text: row?.owner ?? '');
    }
  }

  @override
  void didUpdateWidget(SoxActivityView oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Sync new questions that don't yet have controllers
    for (final q in widget.questions) {
      if (!_ownerControllers.containsKey(q.id)) {
        final row = widget.controlRows[q.id];
        _ownerControllers[q.id] = TextEditingController(text: row?.owner ?? '');
      }
    }
  }

  @override
  void dispose() {
    for (final c in _ownerControllers.values) {
      c.dispose();
    }
    _listScrollController.dispose();
    _tableFocusNode.dispose();
    super.dispose();
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  void _updateRow(String questionId, ControlRowData updated) {
    widget.onRowChanged(questionId, updated);
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${date.day.toString().padLeft(2, '0')} ${months[date.month - 1]} ${date.year}';
  }

  List<MapEntry<String, List<ComplianceQuestion>>> _groupedQuestions() {
    final map = <String, List<ComplianceQuestion>>{};
    for (final q in widget.questions) {
      map.putIfAbsent(q.categoryName, () => []).add(q);
    }
    return [
      for (final cat in _categoryOrder)
        if (map.containsKey(cat)) MapEntry(cat, map[cat]!),
    ];
  }

  // ── Keyboard navigation helpers ────────────────────────────────────────────

  List<String> _orderedQuestionIds() => [
    for (final entry in _groupedQuestions())
      for (final q in entry.value) q.id,
  ];

  void _moveFocus(int delta) {
    final ids = _orderedQuestionIds();
    if (ids.isEmpty) return;
    final next = ((_focusedRowIndex ?? -1) + delta).clamp(0, ids.length - 1);
    setState(() => _focusedRowIndex = next);
    _scrollToFocused(next);
  }

  void _scrollToFocused(int index) {
    if (!_listScrollController.hasClients) return;
    double y = 0;
    int qi = 0;
    for (final entry in _groupedQuestions()) {
      y += 32; // category header
      for (final q in entry.value) {
        if (qi == index) {
          final viewH = _listScrollController.position.viewportDimension;
          final offset = _listScrollController.offset;
          if (y < offset) {
            _listScrollController.animateTo(
              y,
              duration: const Duration(milliseconds: 150),
              curve: Curves.easeOut,
            );
          } else if (y + 56 > offset + viewH) {
            _listScrollController.animateTo(
              y + 56 - viewH,
              duration: const Duration(milliseconds: 150),
              curve: Curves.easeOut,
            );
          }
          return;
        }
        y += 56;
        if (_expandedQuestions.contains(q.id)) {
          final row = widget.controlRows[q.id];
          y += (row?.tasks.length ?? 0) * 44 + 36;
        }
        qi++;
      }
    }
  }

  void _activateFocused({String? shortcut}) {
    if (_focusedRowIndex == null) return;
    final ids = _orderedQuestionIds();
    if (_focusedRowIndex! >= ids.length) return;
    final qId = ids[_focusedRowIndex!];
    final q = widget.questions.firstWhere(
      (q) => q.id == qId,
      orElse: () => widget.questions.first,
    );
    final row = widget.controlRows[qId] ?? ControlRowData(questionId: qId);
    switch (shortcut) {
      case 's':
        _showStatusPicker(qId, row);
      case 'd':
        _pickDate(qId, row);
      case 't':
        _showAddTaskDialog(q);
      default:
        _showAnswerPicker(q);
    }
  }

  Widget _buildKeyboardHintBar() {
    return Container(
      height: 28,
      color: const Color(0xFF1E3A7A),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        children: [
          const Icon(Icons.keyboard, size: 12, color: Colors.white54),
          const SizedBox(width: 8),
          _kbHint('↵', 'Answer'),
          _kbHint('S', 'Status'),
          _kbHint('D', 'Date'),
          _kbHint('T', 'Task'),
          _kbHint('▲▼', 'Navigate'),
          _kbHint('Esc', 'Deselect'),
        ],
      ),
    );
  }

  Widget _kbHint(String key, String label) {
    return Padding(
      padding: const EdgeInsets.only(right: 14),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(3),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.3),
                width: 0.5,
              ),
            ),
            child: Text(
              key,
              style: const TextStyle(
                fontSize: 9,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 10, color: Colors.white70),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildAllRows() {
    final rows = <Widget>[];
    int rowIndex = 0;
    for (final entry in _groupedQuestions()) {
      rows.add(_buildCategoryHeader(entry.key, entry.value.length));
      for (final q in entry.value) {
        final currentIndex = rowIndex;
        final row =
            widget.controlRows[q.id] ?? ControlRowData(questionId: q.id);
        rows.add(
          Listener(
            onPointerDown: (_) {
              if (_focusedRowIndex != currentIndex) {
                setState(() => _focusedRowIndex = currentIndex);
              }
              _tableFocusNode.requestFocus();
            },
            child: _buildQuestionRow(q, row, rowIndex % 2 == 0, rowIndex),
          ),
        );
        if (_expandedQuestions.contains(q.id)) {
          for (final task in row.tasks) {
            rows.add(_buildTaskRow(q.id, task, row));
          }
          rows.add(_buildAddTaskRow(q));
        }
        rowIndex++;
      }
    }
    rows.add(const SizedBox(height: 24));
    return rows;
  }

  // ── Summary bar ────────────────────────────────────────────────────────────

  Widget _buildSummaryBar() {
    int unscoped = 0, notStarted = 0, inProgress = 0, complete = 0;
    for (final q in widget.questions) {
      switch (widget.controlRows[q.id]?.status ?? ControlStatus.unscoped) {
        case ControlStatus.unscoped:
          unscoped++;
        case ControlStatus.notStarted:
          notStarted++;
        case ControlStatus.inProgress:
          inProgress++;
        case ControlStatus.complete:
          complete++;
      }
    }
    return Container(
      height: 52,
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB))),
      ),
      child: Row(
        children: [
          const SizedBox(width: 16),
          _summaryChip('Unscoped', unscoped, ControlStatus.unscoped),
          const SizedBox(width: 8),
          _summaryChip('Not Started', notStarted, ControlStatus.notStarted),
          const SizedBox(width: 8),
          _summaryChip('In Progress', inProgress, ControlStatus.inProgress),
          const SizedBox(width: 8),
          _summaryChip('Complete', complete, ControlStatus.complete),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Text(
              '${widget.questions.length} controls',
              style: const TextStyle(fontSize: 11, color: Color(0xFF9CA3AF)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryChip(String label, int count, ControlStatus status) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: status.backgroundColor,
        border: Border.all(color: status.borderColor),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$count',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: status.foregroundColor,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(fontSize: 11, color: status.foregroundColor),
          ),
        ],
      ),
    );
  }

  // ── Column header ──────────────────────────────────────────────────────────

  Widget _buildColumnHeader() {
    return Container(
      height: 40,
      color: const Color(0xFF1F4788),
      child: Row(
        children: [
          _hCell('Q#', _colQ, center: true),
          _hDivider(),
          _hCell('Control / Question', _colQuestion),
          _hDivider(),
          _hCell('Answer', _colAnswer, center: true),
          _hDivider(),
          _hCell('Priority', _colCriticality, center: true),
          _hDivider(),
          _hCell('Status', _colStatus),
          _hDivider(),
          _hCell('Owner', _colOwner),
          _hDivider(),
          _hCell('Target Date', _colDate),
          _hDivider(),
          _hCell('Tasks', _colTasks, center: true),
        ],
      ),
    );
  }

  Widget _hCell(String label, double width, {bool center = false}) => SizedBox(
    width: width,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Text(
        label,
        textAlign: center ? TextAlign.center : TextAlign.left,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: Colors.white,
          letterSpacing: 0.4,
        ),
        overflow: TextOverflow.ellipsis,
      ),
    ),
  );

  Widget _hDivider() => Container(width: 1, color: const Color(0xFF1E3A7A));

  Widget _vDivider() => Container(width: 1, color: const Color(0xFFE5E7EB));

  // ── Category header ────────────────────────────────────────────────────────

  Widget _buildCategoryHeader(String name, int count) {
    return Container(
      height: 32,
      decoration: const BoxDecoration(
        color: Color(0xFFEFF6FF),
        border: Border(
          top: BorderSide(color: Color(0xFFBFDBFE)),
          bottom: BorderSide(color: Color(0xFFBFDBFE)),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          children: [
            Text(
              name,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1E40AF),
                letterSpacing: 0.2,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
              decoration: BoxDecoration(
                color: const Color(0xFF1E40AF),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '$count',
                style: const TextStyle(
                  fontSize: 10,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Question row ───────────────────────────────────────────────────────────

  Widget _buildQuestionRow(
    ComplianceQuestion q,
    ControlRowData row,
    bool isEven,
    int rowIndex,
  ) {
    final isFocused = _focusedRowIndex == rowIndex;
    final answer = widget.answers[q.id];
    return Stack(
      children: [
        Container(
          height: 56,
          decoration: BoxDecoration(
            color: isFocused
                ? const Color(0xFFEFF6FF)
                : (isEven ? Colors.white : const Color(0xFFFAFAFA)),
            border: const Border(bottom: BorderSide(color: Color(0xFFE5E7EB))),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Q#
              SizedBox(
                width: _colQ,
                child: Center(
                  child: Text(
                    '${q.order}',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1E40AF),
                    ),
                  ),
                ),
              ),
              _vDivider(),
              // Question text + info icon
              SizedBox(
                width: _colQuestion,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          q.questionText,
                          style: const TextStyle(
                            fontSize: 11.5,
                            color: Color(0xFF1F2937),
                            height: 1.3,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Tooltip(
                        message: 'Why am I doing this?',
                        child: GestureDetector(
                          onTap: () => _showEducationDrawer(q),
                          child: const Icon(
                            Icons.help_outline,
                            size: 14,
                            color: Color(0xFF9CA3AF),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              _vDivider(),
              // Answer
              SizedBox(
                width: _colAnswer,
                child: Center(child: _buildAnswerChip(q, answer)),
              ),
              _vDivider(),
              // Criticality
              SizedBox(
                width: _colCriticality,
                child: Center(child: _buildCriticalityBadge(q.criticality)),
              ),
              _vDivider(),
              // Status
              SizedBox(
                width: _colStatus,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: _buildStatusChip(q.id, row),
                ),
              ),
              _vDivider(),
              // Owner
              SizedBox(
                width: _colOwner,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: TextField(
                    controller: _ownerControllers[q.id],
                    style: const TextStyle(
                      fontSize: 11.5,
                      color: Color(0xFF1F2937),
                    ),
                    decoration: const InputDecoration(
                      hintText: 'Assign...',
                      hintStyle: TextStyle(
                        fontSize: 11,
                        color: Color(0xFFD1D5DB),
                      ),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                    onSubmitted: (val) =>
                        _updateRow(q.id, row.copyWith(owner: val)),
                  ),
                ),
              ),
              _vDivider(),
              // Target date
              SizedBox(
                width: _colDate,
                child: GestureDetector(
                  onTap: () => _pickDate(q.id, row),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Row(
                      children: [
                        Icon(
                          Icons.calendar_today_outlined,
                          size: 11,
                          color: row.targetDate != null
                              ? const Color(0xFF1F4788)
                              : const Color(0xFFD1D5DB),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            row.targetDate != null
                                ? _formatDate(row.targetDate!)
                                : 'Set date',
                            style: TextStyle(
                              fontSize: 11,
                              color: row.targetDate != null
                                  ? const Color(0xFF1F2937)
                                  : const Color(0xFFD1D5DB),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              _vDivider(),
              // Tasks
              SizedBox(width: _colTasks, child: _buildTasksCell(q, row)),
            ],
          ),
        ),
        if (isFocused)
          const Positioned(
            left: 0,
            top: 0,
            bottom: 0,
            child: SizedBox(
              width: 3,
              child: ColoredBox(color: Color(0xFF1F4788)),
            ),
          ),
      ],
    );
  }

  Widget _buildAnswerChip(ComplianceQuestion q, String? answer) {
    if (answer == null) {
      return GestureDetector(
        onTap: () => _showAnswerPicker(q),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFD1D5DB)),
            borderRadius: BorderRadius.circular(4),
          ),
          child: const Text(
            '— Set',
            style: TextStyle(fontSize: 10, color: Color(0xFFD1D5DB)),
          ),
        ),
      );
    }
    late Color bg, fg, border;
    switch (answer) {
      case 'Yes':
        bg = const Color(0xFFD1FAE5);
        fg = const Color(0xFF059669);
        border = const Color(0xFF6EE7B7);
      case 'No':
        bg = const Color(0xFFFEE2E2);
        fg = const Color(0xFFDC2626);
        border = const Color(0xFFFCA5A5);
      case 'Partially':
        bg = const Color(0xFFFEF3C7);
        fg = const Color(0xFFD97706);
        border = const Color(0xFFFCD34D);
      case 'N/A':
        bg = const Color(0xFFEDE9FE);
        fg = const Color(0xFF7C3AED);
        border = const Color(0xFFC4B5FD);
      default:
        bg = const Color(0xFFF3F4F6);
        fg = const Color(0xFF6B7280);
        border = const Color(0xFFD1D5DB);
    }
    return GestureDetector(
      onTap: () => _showAnswerPicker(q),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
        decoration: BoxDecoration(
          color: bg,
          border: Border.all(color: border),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          answer,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: fg,
          ),
        ),
      ),
    );
  }

  Widget _buildCriticalityBadge(String criticality) {
    final isHigh = criticality == 'High';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: isHigh ? const Color(0xFFFEE2E2) : const Color(0xFFFEF3C7),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        criticality,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: isHigh ? const Color(0xFFDC2626) : const Color(0xFFD97706),
        ),
      ),
    );
  }

  Widget _buildStatusChip(String questionId, ControlRowData row) {
    return GestureDetector(
      onTap: () => _showStatusPicker(questionId, row),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
        decoration: BoxDecoration(
          color: row.status.backgroundColor,
          border: Border.all(color: row.status.borderColor),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(row.status.icon, size: 12, color: row.status.foregroundColor),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                row.status.label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: row.status.foregroundColor,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(
              Icons.expand_more,
              size: 12,
              color: row.status.foregroundColor,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTasksCell(ComplianceQuestion q, ControlRowData row) {
    final count = row.tasks.length;
    final isExpanded = _expandedQuestions.contains(q.id);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (count > 0)
          GestureDetector(
            onTap: () => setState(() {
              if (isExpanded) {
                _expandedQuestions.remove(q.id);
              } else {
                _expandedQuestions.add(q.id);
              }
            }),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFBFDBFE)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$count',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1E40AF),
                    ),
                  ),
                  const SizedBox(width: 2),
                  Icon(
                    isExpanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    size: 11,
                    color: const Color(0xFF1E40AF),
                  ),
                ],
              ),
            ),
          ),
        const SizedBox(width: 4),
        GestureDetector(
          onTap: () => _showAddTaskDialog(q),
          child: Container(
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: const Color(0xFF1F4788),
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Icon(Icons.add, size: 14, color: Colors.white),
          ),
        ),
      ],
    );
  }

  // ── Task rows ──────────────────────────────────────────────────────────────

  Widget _buildTaskRow(
    String questionId,
    ControlTask task,
    ControlRowData row,
  ) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFF8FAFC),
        border: Border(
          bottom: BorderSide(color: Color(0xFFEEF2F6)),
          left: BorderSide(color: Color(0xFF1F4788), width: 3),
        ),
      ),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(width: 48),
          const Padding(
            padding: EdgeInsets.only(top: 2),
            child: Icon(
              Icons.subdirectory_arrow_right,
              size: 13,
              color: Color(0xFF9CA3AF),
            ),
          ),
          const SizedBox(width: 6),
          // Task text
          Expanded(
            flex: 4,
            child: GestureDetector(
              onTap: () => _showEditTaskDialog(questionId, task, row),
              child: Text(
                task.taskText,
                style: const TextStyle(
                  fontSize: 11.5,
                  color: Color(0xFF374151),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Owner
          SizedBox(
            width: 100,
            child: Text(
              task.owner.isEmpty ? '—' : task.owner,
              style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280)),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          // Date
          SizedBox(
            width: 96,
            child: Text(
              task.targetDate != null ? _formatDate(task.targetDate!) : '—',
              style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280)),
            ),
          ),
          // Task status chip
          SizedBox(
            width: 108,
            child: GestureDetector(
              onTap: () => _showTaskStatusPicker(questionId, task, row),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color: task.status.backgroundColor,
                  border: Border.all(color: task.status.borderColor),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  task.status.label,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: task.status.foregroundColor,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ),
          const SizedBox(width: 4),
          // Delete
          GestureDetector(
            onTap: () => _deleteTask(questionId, task.id, row),
            child: const Padding(
              padding: EdgeInsets.all(8),
              child: Icon(Icons.close, size: 13, color: Color(0xFFD1D5DB)),
            ),
          ),
          const SizedBox(width: 4),
        ],
      ),
    );
  }

  Widget _buildAddTaskRow(ComplianceQuestion q) {
    return Container(
      height: 36,
      decoration: const BoxDecoration(
        color: Color(0xFFF8FAFC),
        border: Border(
          bottom: BorderSide(color: Color(0xFFE5E7EB)),
          left: BorderSide(color: Color(0xFF1F4788), width: 3),
        ),
      ),
      child: GestureDetector(
        onTap: () => _showAddTaskDialog(q),
        child: const Padding(
          padding: EdgeInsets.only(left: 68),
          child: Row(
            children: [
              Icon(Icons.add, size: 13, color: Color(0xFF1F4788)),
              SizedBox(width: 4),
              Text(
                'Add task',
                style: TextStyle(
                  fontSize: 11,
                  color: Color(0xFF1F4788),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Interactions ───────────────────────────────────────────────────────────

  Future<void> _showAnswerPicker(ComplianceQuestion q) async {
    final current = widget.answers[q.id];
    // (label, description, foreground, background)
    const options = [
      ('Yes', 'Fully in place', Color(0xFF059669), Color(0xFFD1FAE5)),
      ('No', 'Not yet in place', Color(0xFFDC2626), Color(0xFFFEE2E2)),
      (
        'Partially',
        'Partially implemented',
        Color(0xFFD97706),
        Color(0xFFFEF3C7),
      ),
      ('N/A', 'Not applicable to us', Color(0xFF7C3AED), Color(0xFFEDE9FE)),
    ];

    final selected = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF6FF),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: const Color(0xFFBFDBFE)),
              ),
              child: Text(
                'Q${q.order}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1E40AF),
                ),
              ),
            ),
            const SizedBox(width: 10),
            const Expanded(
              child: Text('Current Posture', style: TextStyle(fontSize: 15)),
            ),
          ],
        ),
        contentPadding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: options.map<Widget>((option) {
            final (label, desc, fg, bg) = option;
            final isSelected = current == label;
            return GestureDetector(
              onTap: () => Navigator.pop(ctx, label),
              child: Container(
                margin: const EdgeInsets.symmetric(vertical: 4),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? bg : Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected ? fg : const Color(0xFFE5E7EB),
                    width: isSelected ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isSelected ? fg : Colors.transparent,
                        border: Border.all(
                          color: isSelected ? fg : const Color(0xFFD1D5DB),
                          width: 1.5,
                        ),
                      ),
                      child: isSelected
                          ? const Icon(
                              Icons.check,
                              size: 10,
                              color: Colors.white,
                            )
                          : null,
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          label,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: fg,
                          ),
                        ),
                        Text(
                          desc,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Color(0xFF9CA3AF),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
        actions: [
          if (current != null)
            TextButton(
              onPressed: () => Navigator.pop(ctx, '__clear__'),
              child: const Text('Clear', style: TextStyle(color: Colors.red)),
            ),
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );

    if (selected == null) return;
    widget.onAnswerChanged(q.id, selected == '__clear__' ? null : selected);

    // Auto-advance status from Unscoped when posture is recorded
    if (selected != '__clear__') {
      final row = widget.controlRows[q.id] ?? ControlRowData(questionId: q.id);
      if (row.status == ControlStatus.unscoped) {
        final ControlStatus newStatus;
        switch (selected) {
          case 'Yes':
          case 'Partially':
            newStatus = ControlStatus.inProgress;
          case 'N/A':
            newStatus = ControlStatus.complete;
          default: // 'No'
            newStatus = ControlStatus.notStarted;
        }
        widget.onRowChanged(q.id, row.copyWith(status: newStatus));
      }
    }
  }

  Future<void> _showStatusPicker(String questionId, ControlRowData row) async {
    final selected = await showDialog<ControlStatus>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Set Status', style: TextStyle(fontSize: 15)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ControlStatus.values
              .map(
                (status) => RadioListTile<ControlStatus>(
                  title: Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: status.foregroundColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(status.label, style: const TextStyle(fontSize: 13)),
                    ],
                  ),
                  value: status,
                  groupValue: row.status,
                  dense: true,
                  onChanged: (val) => Navigator.pop(ctx, val),
                ),
              )
              .toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
    if (selected != null) {
      _updateRow(questionId, row.copyWith(status: selected));
    }
  }

  Future<void> _pickDate(String questionId, ControlRowData row) async {
    final date = await showDatePicker(
      context: context,
      initialDate:
          row.targetDate ?? DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 3)),
      helpText: 'Select Target Date',
    );
    if (date != null) {
      _updateRow(questionId, row.copyWith(targetDate: date));
    }
  }

  Future<void> _showAddTaskDialog(ComplianceQuestion q) async {
    final row = widget.controlRows[q.id] ?? ControlRowData(questionId: q.id);
    final textCtrl = TextEditingController();
    final ownerCtrl = TextEditingController();
    DateTime? selectedDate;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialog) => AlertDialog(
          title: Row(
            children: [
              const Icon(Icons.add_task, size: 18, color: Color(0xFF1F4788)),
              const SizedBox(width: 8),
              Text(
                'Add Task — Q${q.order}',
                style: const TextStyle(fontSize: 15),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: textCtrl,
                  autofocus: true,
                  decoration: const InputDecoration(
                    labelText: 'Task description *',
                    hintText: 'e.g. Draft CEO certification template',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: ownerCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Owner (optional)',
                    hintText: 'e.g. Sarah / Finance Team',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Text(
                      'Target Date:',
                      style: TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
                    ),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: () async {
                        final d = await showDatePicker(
                          context: ctx,
                          initialDate: DateTime.now().add(
                            const Duration(days: 14),
                          ),
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(
                            const Duration(days: 365 * 2),
                          ),
                        );
                        if (d != null) {
                          setDialog(() => selectedDate = d);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xFFD1D5DB)),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          selectedDate != null
                              ? _formatDate(selectedDate!)
                              : 'Select date',
                          style: TextStyle(
                            fontSize: 12,
                            color: selectedDate != null
                                ? const Color(0xFF1F2937)
                                : const Color(0xFF9CA3AF),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (textCtrl.text.trim().isNotEmpty) {
                  Navigator.pop(ctx, true);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1F4788),
                foregroundColor: Colors.white,
              ),
              child: const Text('Add Task'),
            ),
          ],
        ),
      ),
    );

    if (confirmed == true) {
      final task = ControlTask(
        id: '${q.id}_task_${DateTime.now().millisecondsSinceEpoch}',
        taskText: textCtrl.text.trim(),
        owner: ownerCtrl.text.trim(),
        targetDate: selectedDate,
      );
      _updateRow(q.id, row.copyWith(tasks: [...row.tasks, task]));
      setState(() => _expandedQuestions.add(q.id));
    }

    textCtrl.dispose();
    ownerCtrl.dispose();
  }

  Future<void> _showEditTaskDialog(
    String questionId,
    ControlTask task,
    ControlRowData row,
  ) async {
    final textCtrl = TextEditingController(text: task.taskText);
    final ownerCtrl = TextEditingController(text: task.owner);
    DateTime? selectedDate = task.targetDate;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialog) => AlertDialog(
          title: const Text('Edit Task', style: TextStyle(fontSize: 15)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: textCtrl,
                  autofocus: true,
                  decoration: const InputDecoration(
                    labelText: 'Task description',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: ownerCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Owner',
                    border: OutlineInputBorder(),
                    isDense: true,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Text(
                      'Target Date:',
                      style: TextStyle(fontSize: 13, color: Color(0xFF6B7280)),
                    ),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: () async {
                        final d = await showDatePicker(
                          context: ctx,
                          initialDate:
                              selectedDate ??
                              DateTime.now().add(const Duration(days: 14)),
                          firstDate: DateTime.now(),
                          lastDate: DateTime.now().add(
                            const Duration(days: 365 * 2),
                          ),
                        );
                        if (d != null) {
                          setDialog(() => selectedDate = d);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xFFD1D5DB)),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          selectedDate != null
                              ? _formatDate(selectedDate!)
                              : 'Select date',
                          style: TextStyle(
                            fontSize: 12,
                            color: selectedDate != null
                                ? const Color(0xFF1F2937)
                                : const Color(0xFF9CA3AF),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1F4788),
                foregroundColor: Colors.white,
              ),
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );

    if (confirmed == true) {
      final updated = task.copyWith(
        taskText: textCtrl.text.trim(),
        owner: ownerCtrl.text.trim(),
        targetDate: selectedDate,
      );
      _updateRow(
        questionId,
        row.copyWith(
          tasks: row.tasks.map((t) => t.id == task.id ? updated : t).toList(),
        ),
      );
    }
    textCtrl.dispose();
    ownerCtrl.dispose();
  }

  Future<void> _showTaskStatusPicker(
    String questionId,
    ControlTask task,
    ControlRowData row,
  ) async {
    final selected = await showDialog<ControlStatus>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Task Status', style: TextStyle(fontSize: 15)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ControlStatus.values
              .map(
                (s) => RadioListTile<ControlStatus>(
                  title: Text(s.label, style: const TextStyle(fontSize: 13)),
                  value: s,
                  groupValue: task.status,
                  dense: true,
                  onChanged: (val) => Navigator.pop(ctx, val),
                ),
              )
              .toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
    if (selected != null) {
      _updateRow(
        questionId,
        row.copyWith(
          tasks: row.tasks
              .map((t) => t.id == task.id ? t.copyWith(status: selected) : t)
              .toList(),
        ),
      );
    }
  }

  void _deleteTask(String questionId, String taskId, ControlRowData row) {
    final updated = row.tasks.where((t) => t.id != taskId).toList();
    _updateRow(questionId, row.copyWith(tasks: updated));
    if (updated.isEmpty) {
      setState(() => _expandedQuestions.remove(questionId));
    }
  }

  // ── Education drawer ───────────────────────────────────────────────────────

  void _showEducationDrawer(ComplianceQuestion q) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.75,
        minChildSize: 0.4,
        maxChildSize: 0.95,
        builder: (ctx, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Drag handle
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Sheet header
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 16, 12),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: const Color(0xFFBFDBFE)),
                      ),
                      child: Text(
                        'Q${q.order}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1E40AF),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'Why am I doing this?',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(ctx),
                      icon: const Icon(Icons.close),
                      iconSize: 20,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              // Scrollable content
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  children: [
                    Text(
                      q.questionText,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1F2937),
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (q.legalReference != null) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1F4788),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Legal Reference',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Colors.white70,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              q.legalReference!,
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1F4788).withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: const Color(0xFF1F4788).withValues(alpha: 0.2),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Category: ${q.categoryName}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                              color: Color(0xFF1F4788),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Text(
                                'Criticality: ',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: q.criticality == 'High'
                                      ? Colors.red[100]
                                      : Colors.orange[100],
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  q.criticality,
                                  style: TextStyle(
                                    color: q.criticality == 'High'
                                        ? Colors.red[700]
                                        : Colors.orange[700],
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Guidance:',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 8),
                    MarkdownBody(
                      data:
                          q.description ?? 'No additional guidance available.',
                      styleSheet: MarkdownStyleSheet(
                        p: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[700],
                          height: 1.5,
                        ),
                        strong: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[800],
                          fontWeight: FontWeight.w700,
                        ),
                        a: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF1F4788),
                          fontWeight: FontWeight.w600,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                      onTapLink: (text, href, title) {
                        if (href != null &&
                            (href.startsWith('http') ||
                                href.startsWith('https'))) {
                          launchUrl(
                            Uri.parse(href),
                            mode: LaunchMode.externalApplication,
                          );
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    if (q.legalReference != null &&
                        q.legalReference!.isNotEmpty)
                      _RegTextExpansion(legalReference: q.legalReference!),
                    const SizedBox(height: 60),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: _tableFocusNode,
      autofocus: false,
      onKeyEvent: (node, event) {
        if (event is! KeyDownEvent && event is! KeyRepeatEvent) {
          return KeyEventResult.ignored;
        }
        final k = event.logicalKey;
        if (k == LogicalKeyboardKey.arrowDown) {
          _moveFocus(1);
          return KeyEventResult.handled;
        } else if (k == LogicalKeyboardKey.arrowUp) {
          _moveFocus(-1);
          return KeyEventResult.handled;
        } else if (k == LogicalKeyboardKey.enter ||
            k == LogicalKeyboardKey.keyA) {
          _activateFocused();
          return KeyEventResult.handled;
        } else if (k == LogicalKeyboardKey.keyS) {
          _activateFocused(shortcut: 's');
          return KeyEventResult.handled;
        } else if (k == LogicalKeyboardKey.keyD) {
          _activateFocused(shortcut: 'd');
          return KeyEventResult.handled;
        } else if (k == LogicalKeyboardKey.keyT) {
          _activateFocused(shortcut: 't');
          return KeyEventResult.handled;
        } else if (k == LogicalKeyboardKey.escape) {
          setState(() => _focusedRowIndex = null);
          return KeyEventResult.handled;
        }
        return KeyEventResult.ignored;
      },
      child: Column(
        children: [
          _buildSummaryBar(),
          if (_focusedRowIndex != null) _buildKeyboardHintBar(),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) => SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  width: _tableWidth,
                  height: constraints.maxHeight,
                  child: Column(
                    children: [
                      _buildColumnHeader(),
                      Expanded(
                        child: ListView(
                          controller: _listScrollController,
                          children: _buildAllRows(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Expandable regulatory text (self-contained stateful widget)
// ---------------------------------------------------------------------------

class _RegTextExpansion extends StatefulWidget {
  final String legalReference;
  const _RegTextExpansion({required this.legalReference});

  @override
  State<_RegTextExpansion> createState() => _RegTextExpansionState();
}

class _RegTextExpansionState extends State<_RegTextExpansion> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final text = getRegulatoryText(widget.legalReference);
    return Container(
      decoration: BoxDecoration(
        color: Colors.amber[50],
        border: Border.all(color: Colors.amber[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Icon(
                    _expanded ? Icons.expand_less : Icons.expand_more,
                    color: Colors.amber[800],
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'View Full Regulatory Text',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: Colors.amber[900],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_expanded)
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border(top: BorderSide(color: Colors.amber[300]!)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: MarkdownBody(
                  data: text,
                  styleSheet: MarkdownStyleSheet(
                    p: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[800],
                      height: 1.6,
                      fontFamily: 'Courier',
                    ),
                    a: const TextStyle(
                      color: Color(0xFF1F4788),
                      decoration: TextDecoration.underline,
                    ),
                  ),
                  onTapLink: (text, href, title) {
                    if (href != null && href.startsWith('https://')) {
                      launchUrl(
                        Uri.parse(href),
                        mode: LaunchMode.externalApplication,
                      );
                    }
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }
}
