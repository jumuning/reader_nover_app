import 'package:flutter/material.dart';

class SourceSearchBar extends StatefulWidget {
  const SourceSearchBar({
    super.key,
    required this.value,
    this.groupFilter,
    required this.onChanged,
    required this.onClearGroupFilter,
    this.autofocus = false,
  });

  final String value;
  final String? groupFilter;
  final ValueChanged<String> onChanged;
  final VoidCallback onClearGroupFilter;
  final bool autofocus;

  @override
  State<SourceSearchBar> createState() => _SourceSearchBarState();
}

class _SourceSearchBarState extends State<SourceSearchBar> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
    _focusNode = FocusNode();
    if (widget.autofocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _focusNode.requestFocus();
      });
    }
  }

  @override
  void didUpdateWidget(covariant SourceSearchBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != _controller.text) {
      _controller.text = widget.value;
      _controller.selection = TextSelection.collapsed(
        offset: _controller.text.length,
      );
    }
    if (widget.autofocus && !oldWidget.autofocus) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _focusNode.requestFocus();
      });
    }
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final groupFilter = widget.groupFilter?.trim();

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _controller,
            focusNode: _focusNode,
            autofocus: widget.autofocus,
            onChanged: (value) {
              widget.onChanged(value);
              setState(() {});
            },
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: '搜索名称、地址或分组',
              hintStyle: TextStyle(
                color: colorScheme.onSurface.withValues(alpha: 0.38),
                fontSize: 14,
              ),
              prefixIcon: Icon(
                Icons.search_rounded,
                color: colorScheme.onSurface.withValues(alpha: 0.4),
                size: 20,
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              filled: true,
              fillColor:
                  colorScheme.surfaceContainerHighest.withValues(alpha: 0.55),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(
                  color: colorScheme.primary.withValues(alpha: 0.55),
                  width: 1.2,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              suffixIcon: _controller.text.isEmpty
                  ? null
                  : IconButton(
                      icon: Icon(
                        Icons.cancel_rounded,
                        size: 18,
                        color: colorScheme.onSurface.withValues(alpha: 0.4),
                      ),
                      tooltip: '清空',
                      onPressed: () {
                        _controller.clear();
                        widget.onChanged('');
                        setState(() {});
                      },
                    ),
            ),
          ),
          if (groupFilter != null && groupFilter.isNotEmpty) ...[
            const SizedBox(height: 8),
            InputChip(
              avatar: Icon(
                Icons.folder_rounded,
                size: 16,
                color: colorScheme.primary,
              ),
              label: Text('分组：$groupFilter'),
              onDeleted: widget.onClearGroupFilter,
              deleteIconColor: colorScheme.primary,
              backgroundColor:
                  colorScheme.primaryContainer.withValues(alpha: 0.45),
              side: BorderSide.none,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              visualDensity: VisualDensity.compact,
            ),
          ],
        ],
      ),
    );
  }
}
