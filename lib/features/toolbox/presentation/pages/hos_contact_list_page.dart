import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:shoo/core/feedback/hos_toast.dart';
import 'package:shoo/core/pages/hos_pages.dart';
import 'package:shoo/core/theme/hos_spacing.dart';
import 'package:shoo/core/utils/hos_contact_group_utils.dart';
import 'package:shoo/core/utils/hos_debouncer.dart';
import 'package:shoo/core/widgets/hos_empty_state.dart';
import 'package:shoo/core/widgets/hos_loading_state.dart';
import 'package:shoo/core/widgets/hos_text_field.dart';
import 'package:shoo/features/toolbox/domain/entities/hos_contact.dart';
import 'package:shoo/features/toolbox/presentation/state/hos_contact_list_provider.dart';
import 'package:shoo/features/toolbox/presentation/widgets/hos_contact_index_bar.dart';
import 'package:shoo/features/toolbox/presentation/widgets/hos_contact_list_tile.dart';
import 'package:shoo/l10n/app_localizations.dart';

const _kContactSearchBorderColor = Color(0xFF666666);

/// 百宝箱 — 通用联系人列表（仿微信：模糊搜索 + A-Z 侧边索引 + 字母气泡）。
class SHOContactListPage extends ConsumerStatefulWidget {
  const SHOContactListPage({super.key});

  @override
  ConsumerState<SHOContactListPage> createState() => _SHOContactListPageState();
}

class _SHOContactListPageState extends ConsumerState<SHOContactListPage>
    with SHOPageRouteAnalyticsMixin, SHOAppPageMixin, SHOAppTrackedPageMixin {
  final _searchController = TextEditingController();
  final _searchFocusNode = FocusNode();
  final _debouncer = SHODebouncer(
    duration: const Duration(milliseconds: 300),
  );

  /// 实际请求用的关键字；进入页面默认空 → 全量列表。
  String _searchQuery = '';
  List<SHOContact> _cachedContacts = const [];

  @override
  String get pageName => 'toolbox_contacts';

  @override
  void dispose() {
    _debouncer.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    final query = value.trim();
    if (query.isEmpty) {
      _debouncer.cancel();
      if (!mounted) return;
      if (_searchQuery.isEmpty) return;
      setState(() => _searchQuery = '');
      return;
    }
    _debouncer.run(() {
      if (!mounted) return;
      if (_searchQuery == query) return;
      setState(() => _searchQuery = query);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final contactsAsync = ref.watch(contactListProvider(_searchQuery));

    if (contactsAsync.hasValue) {
      _cachedContacts = contactsAsync.requireValue;
    }

    // 搜索刷新时保留上次结果，避免盖住输入框 / 打断聚焦。
    final contacts = contactsAsync.valueOrNull ?? _cachedContacts;
    final isInitialLoading = contacts.isEmpty && contactsAsync.isLoading;
    final error = contactsAsync.hasError ? contactsAsync.error : null;

    return buildTrackedPage(
      Scaffold(
        appBar: AppBar(
          title: Text(l10n.toolboxContacts),
        ),
        body: Column(
          children: [
            _SearchField(
              controller: _searchController,
              focusNode: _searchFocusNode,
              hint: l10n.contactSearchHint,
              onChanged: _onSearchChanged,
            ),
            Expanded(
              child: _ContactListSection(
                contacts: contacts,
                searchQuery: _searchQuery,
                showInitialLoading: isInitialLoading,
                error: error,
                emptyTitle: l10n.contactListEmpty,
                loadFailedTitle: l10n.contactListLoadFailed,
                retryLabel: l10n.retry,
                onRetry: () =>
                    ref.invalidate(contactListProvider(_searchQuery)),
                onUserScroll: () {
                  if (_searchFocusNode.hasFocus) {
                    _searchFocusNode.unfocus();
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ContactListSection extends StatefulWidget {
  const _ContactListSection({
    required this.contacts,
    required this.searchQuery,
    required this.showInitialLoading,
    required this.error,
    required this.emptyTitle,
    required this.loadFailedTitle,
    required this.retryLabel,
    required this.onRetry,
    required this.onUserScroll,
  });

  final List<SHOContact> contacts;
  final String searchQuery;
  final bool showInitialLoading;
  final Object? error;
  final String emptyTitle;
  final String loadFailedTitle;
  final String retryLabel;
  final VoidCallback onRetry;
  final VoidCallback onUserScroll;

  @override
  State<_ContactListSection> createState() => _ContactListSectionState();
}

class _ContactListSectionState extends State<_ContactListSection> {
  final _scrollController = ScrollController();
  Timer? _bubbleHideTimer;

  String? _activeLetter;
  String? _bubbleLetter;
  double _bubbleAnchorY = 0;
  bool _showBubble = false;
  bool _isIndexDragging = false;
  String? _pinnedLetter;
  bool _clearPinOnNextScroll = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void didUpdateWidget(_ContactListSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.searchQuery != widget.searchQuery) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        if (_scrollController.hasClients) {
          _scrollController.jumpTo(0);
        }
      });
      setState(() {
        _activeLetter = null;
        _pinnedLetter = null;
      });
    }
  }

  @override
  void dispose() {
    _bubbleHideTimer?.cancel();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  List<SHOContactListRow> get _rows {
    return SHOContactGroupUtils.buildRows(widget.contacts);
  }

  void _onScroll() {
    if (_isIndexDragging) return;

    final rows = _rows;
    if (rows.isEmpty) return;

    if (_pinnedLetter != null) {
      if (_clearPinOnNextScroll) {
        _clearPinOnNextScroll = false;
        setState(() => _pinnedLetter = null);
      } else {
        return;
      }
    }

    final letter = SHOContactGroupUtils.letterForScrollOffset(
      rows,
      _scrollController.offset,
    );

    if (letter != _activeLetter) {
      setState(() => _activeLetter = letter);
    }
  }

  void _scrollToLetter(String letter) {
    final rows = _rows;
    if (rows.isEmpty) return;
    final index = SHOContactGroupUtils.rowIndexForLetter(rows, letter);
    final offset = SHOContactGroupUtils.offsetForRowIndex(rows, index);
    // _scrollController.hasClients 的作用是： 检查滚动控制器是否已经连接到滚动视图
    if (!_scrollController.hasClients) return;
    _scrollController
        .animateTo(
          offset.clamp(0, _scrollController.position.maxScrollExtent),
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
        )
        .whenComplete(() {
          if (!mounted) return;
          setState(() {
            _isIndexDragging = false;
            _activeLetter = letter;
            _pinnedLetter = letter;
          });
        });
  }

  void _onLetterSelected(String letter, double letterCenterDy) {
    setState(() {
      _activeLetter = letter;
      _pinnedLetter = letter;
      _bubbleLetter = letter;
      _bubbleAnchorY = letterCenterDy;
      _showBubble = true;
      _isIndexDragging = true;
    });
    _scrollToLetter(letter);
    _scheduleBubbleHide();
  }

  void _onIndexInteractionEnd() {
    setState(() => _isIndexDragging = false);
    _scheduleBubbleHide();
  }

  void _scheduleBubbleHide() {
    _bubbleHideTimer?.cancel();
    _bubbleHideTimer = Timer(const Duration(milliseconds: 550), () {
      if (!mounted) return;
      setState(() => _showBubble = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.showInitialLoading) {
      return const SHOAppLoadingState(state: SHOLoadingState.loading);
    }

    if (widget.error != null && widget.contacts.isEmpty) {
      return SHOEmptyState(
        title: widget.loadFailedTitle,
        actionLabel: widget.retryLabel,
        onAction: widget.onRetry,
      );
    }

    if (widget.contacts.isEmpty) {
      return SHOEmptyState(title: widget.emptyTitle);
    }

    final rows = _rows;
    final indexLetters = SHOContactGroupUtils.availableIndexLetters(rows);

    return Stack(
      clipBehavior: Clip.none,
      children: [
        NotificationListener<ScrollNotification>(
          onNotification: (notification) {
            if (notification is ScrollStartNotification &&
                notification.dragDetails != null) {
              widget.onUserScroll();
              if (_pinnedLetter != null) {
                _clearPinOnNextScroll = true;
              }
            }
            // 只处理自己关心的逻辑，但不阻止其他组件接收滚动通知 。
            return false;
          },
          child: ListView.builder(
            controller: _scrollController,
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.only(right: 28),
            itemCount: rows.length,
            itemBuilder: (context, index) {
              final row = rows[index];
              final height = SHOContactGroupUtils.rowHeight(row);
              return SizedBox(
                height: height,
                child: switch (row) {
                  SHOContactSectionHeaderRow(:final letter) =>
                    SHOContactSectionHeader(letter: letter),
                  SHOContactItemRow(:final contact) => SHOContactListTile(
                    key: ValueKey(contact.id),
                    contact: contact,
                    searchQuery: widget.searchQuery,
                    onTap: () => context.showToast(
                      '${contact.name} · ${contact.phone}',
                    ),
                  ),
                },
              );
            },
          ),
        ),
        if (indexLetters.isNotEmpty)
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            child: SHOContactIndexBar(
              letters: indexLetters,
              activeLetter: _activeLetter,
              onLetterSelected: _onLetterSelected,
              onInteractionEnd: _onIndexInteractionEnd,
            ),
          ),
        Positioned(
          right: 22,
          top: _bubbleAnchorY - SHOContactLetterBubble.bubbleSize / 2,
          child: SHOContactLetterBubble(
            letter: _bubbleLetter ?? '',
            visible: _showBubble && _bubbleLetter != null,
          ),
        ),
      ],
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({
    required this.controller,
    required this.focusNode,
    required this.hint,
    required this.onChanged,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final String hint;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        SHOAppSpacing.pagePadding,
        SHOAppSpacing.sm,
        SHOAppSpacing.pagePadding,
        SHOAppSpacing.sm,
      ),
      child: SHOAppTextField(
        controller: controller,
        focusNode: focusNode,
        hint: hint,
        prefixIcon: const Icon(Icons.search, size: 18),
        enabledBorderColor: _kContactSearchBorderColor,
        fieldBorderRadius: BorderRadius.circular(18),
        onChanged: onChanged,
      ),
    );
  }
}
