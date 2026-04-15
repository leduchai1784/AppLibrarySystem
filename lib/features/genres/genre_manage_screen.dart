import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/app_text_styles.dart';
import '../../gen/l10n/app_localizations.dart';

/// CRUD collection `genres` (thể loại nội dung).
class GenreManageScreen extends StatefulWidget {
  const GenreManageScreen({super.key});

  static const _col = 'genres';

  @override
  State<GenreManageScreen> createState() => _GenreManageScreenState();
}

class _GenreManageScreenState extends State<GenreManageScreen> {
  final _q = TextEditingController();

  @override
  void dispose() {
    _q.dispose();
    super.dispose();
  }

  bool _matches(String q, String name) {
    final s = q.trim().toLowerCase();
    if (s.isEmpty) return true;
    return name.toLowerCase().contains(s);
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    if (!AppUser.isStaff) {
      return Scaffold(
        appBar: AppBar(title: Text(t.genresManageTitle)),
        body: Center(child: Text(t.staffOnlyGenreManage)),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(t.genresManageTitle)),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance.collection(GenreManageScreen._col).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text(t.genresLoadError('${snapshot.error}')));
          }
          final docs = List<QueryDocumentSnapshot<Map<String, dynamic>>>.from(snapshot.data?.docs ?? []);
          docs.sort((a, b) {
            final na = (a.data()['name'] ?? '').toString().toLowerCase();
            final nb = (b.data()['name'] ?? '').toString().toLowerCase();
            return na.compareTo(nb);
          });
          if (docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(t.genresEmpty, style: AppTextStyles.body),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    onPressed: () => _showAdd(context),
                    icon: const Icon(Icons.add),
                    label: Text(t.genresAddFirst),
                  ),
                ],
              ),
            );
          }
          final q = _q.text;
          final items = docs.where((d) {
            final name = (d.data()['name'] ?? '').toString();
            return _matches(q, name);
          }).toList();

          final theme = Theme.of(context);
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: TextField(
                  controller: _q,
                  onChanged: (_) => setState(() {}),
                  textInputAction: TextInputAction.search,
                  decoration: InputDecoration(
                    hintText: 'Tìm theo tên thể loại…',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _q.text.trim().isEmpty
                        ? null
                        : IconButton(
                            onPressed: () {
                              _q.clear();
                              setState(() {});
                            },
                            icon: const Icon(Icons.close),
                          ),
                  ),
                ),
              ),
              Expanded(
                child: items.isEmpty
                    ? Center(child: Text('Không tìm thấy kết quả.', style: AppTextStyles.body))
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                        itemCount: items.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final doc = items[index];
                          final name = (doc.data()['name'] ?? '') as String;
                          final display = name.isEmpty ? t.genresUntitled : name;
                          return DecoratedBox(
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: theme.dividerColor.withValues(alpha: 0.28)),
                            ),
                            child: ListTile(
                              dense: true,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              leading: CircleAvatar(
                                radius: 18,
                                backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.12),
                                foregroundColor: theme.colorScheme.primary,
                                child: const Icon(Icons.label_outline_rounded, size: 18),
                              ),
                              title: Text(
                                display,
                                style: AppTextStyles.h3.copyWith(fontSize: 15.5),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              trailing: PopupMenuButton<String>(
                                onSelected: (v) {
                                  if (v == 'edit') _showEdit(context, doc.id, name);
                                  if (v == 'delete') _confirmDelete(context, doc.id, name);
                                },
                                itemBuilder: (context) => [
                                  PopupMenuItem(value: 'edit', child: Text(t.updateAction)),
                                  PopupMenuItem(
                                    value: 'delete',
                                    child: Text(t.commonDelete, style: const TextStyle(color: AppColors.error)),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAdd(context),
        icon: const Icon(Icons.add),
        label: Text(t.genresAdd),
      ),
    );
  }

  Future<void> _showAdd(BuildContext context) async {
    final t = AppLocalizations.of(context)!;
    final c = TextEditingController();
    try {
      final name = await showDialog<String>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(t.genresAddTitle),
          content: TextField(
            controller: c,
            decoration: InputDecoration(hintText: t.genresNameHint),
            autofocus: true,
            onSubmitted: (v) {
              final n = v.trim();
              if (n.isNotEmpty) Navigator.pop(ctx, n);
            },
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: Text(t.commonCancel)),
            FilledButton(
              onPressed: () {
                final n = c.text.trim();
                if (n.isEmpty) {
                  ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text(t.genresNameRequired)));
                  return;
                }
                Navigator.pop(ctx, n);
              },
              child: Text(t.commonDone),
            ),
          ],
        ),
      );
      if (name == null || name.isEmpty || !context.mounted) return;
      await FirebaseFirestore.instance.collection(GenreManageScreen._col).add({
        'name': name,
        'createdAt': FieldValue.serverTimestamp(),
      });
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t.genresAdded(name))));
      }
    } finally {
      c.dispose();
    }
  }

  Future<void> _showEdit(BuildContext context, String docId, String current) async {
    final t = AppLocalizations.of(context)!;
    final c = TextEditingController(text: current);
    try {
      final name = await showDialog<String>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(t.genresEditTitle),
          content: TextField(controller: c, decoration: InputDecoration(hintText: t.genresNameHint)),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: Text(t.commonCancel)),
            FilledButton(
              onPressed: () {
                final n = c.text.trim();
                if (n.isEmpty) return;
                Navigator.pop(ctx, n);
              },
              child: Text(t.commonSave),
            ),
          ],
        ),
      );
      if (name == null || name.isEmpty || !context.mounted) return;
      await FirebaseFirestore.instance.collection(GenreManageScreen._col).doc(docId).update({
        'name': name,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t.genresUpdated)));
      }
    } finally {
      c.dispose();
    }
  }

  Future<void> _confirmDelete(BuildContext context, String docId, String name) async {
    final t = AppLocalizations.of(context)!;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(t.genresDeleteTitle),
        content: Text(t.genresDeleteBody(name)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(t.commonCancel)),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(t.commonDelete),
          ),
        ],
      ),
    );
    if (ok != true) return;
    try {
      await FirebaseFirestore.instance.collection(GenreManageScreen._col).doc(docId).delete();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t.genresDeleted)));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t.genresDeleteError('$e'))));
      }
    }
  }
}
