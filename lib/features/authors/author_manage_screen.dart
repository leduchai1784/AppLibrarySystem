import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/app_text_styles.dart';
import '../../gen/l10n/app_localizations.dart';

/// CRUD collection `authors`.
class AuthorManageScreen extends StatefulWidget {
  const AuthorManageScreen({super.key});

  static const _col = 'authors';

  @override
  State<AuthorManageScreen> createState() => _AuthorManageScreenState();
}

class _AuthorManageScreenState extends State<AuthorManageScreen> {
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

  Widget _leadingAvatar(ThemeData theme, String name) {
    final t = name.trim().isEmpty ? '?' : name.trim();
    final initial = t.characters.first.toUpperCase();
    return CircleAvatar(
      radius: 18,
      backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.12),
      foregroundColor: theme.colorScheme.primary,
      child: Text(
        initial,
        style: const TextStyle(fontWeight: FontWeight.w800),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    if (!AppUser.isStaff) {
      return Scaffold(
        appBar: AppBar(title: Text(t.authorsManageTitle)),
        body: Center(child: Text(t.staffOnlyAuthorManage)),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(t.authorsManageTitle)),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance.collection(AuthorManageScreen._col).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text(t.authorsLoadError('${snapshot.error}')));
          }
          final docs = List<QueryDocumentSnapshot<Map<String, dynamic>>>.from(snapshot.data?.docs ?? []);
          docs.sort((a, b) {
            final na = (a.data()['name'] ?? '').toString().toLowerCase();
            final nb = (b.data()['name'] ?? '').toString().toLowerCase();
            return na.compareTo(nb);
          });
          final q = _q.text;
          final items = docs.where((d) {
            final name = (d.data()['name'] ?? '').toString();
            return _matches(q, name);
          }).toList();

          final theme = Theme.of(context);
          if (docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(t.authorsEmpty, style: AppTextStyles.body),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    onPressed: () => _showAdd(context),
                    icon: const Icon(Icons.add),
                    label: Text(t.authorsAddFirst),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: TextField(
                  controller: _q,
                  onChanged: (_) => setState(() {}),
                  textInputAction: TextInputAction.search,
                  decoration: InputDecoration(
                    hintText: 'Tìm theo tên tác giả…',
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
                          final desc = (doc.data()['description'] ?? '') as String;

                          return DecoratedBox(
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: theme.dividerColor.withValues(alpha: 0.28)),
                            ),
                            child: ListTile(
                              dense: true,
                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              leading: _leadingAvatar(theme, name.isEmpty ? t.authorsUntitled : name),
                              title: Text(
                                name.isEmpty ? t.authorsUntitled : name,
                                style: AppTextStyles.h3.copyWith(fontSize: 15.5),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              subtitle: desc.trim().isEmpty
                                  ? null
                                  : Text(
                                      desc.trim(),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: AppTextStyles.caption.copyWith(fontSize: 12.5),
                                    ),
                              trailing: PopupMenuButton<String>(
                                onSelected: (v) {
                                  if (v == 'edit') {
                                    _showEdit(context, doc.id, name, desc);
                                  }
                                  if (v == 'delete') {
                                    _confirmDelete(context, doc.id, name);
                                  }
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
        label: Text(t.authorsAdd),
      ),
    );
  }

  Future<void> _showAdd(BuildContext context) async {
    final t = AppLocalizations.of(context)!;
    final nameC = TextEditingController();
    final descC = TextEditingController();
    try {
      final ok = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(t.authorsAddTitle),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameC,
                  decoration: InputDecoration(labelText: t.authorsNameLabel),
                  autofocus: true,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descC,
                  decoration: InputDecoration(labelText: t.authorsDescLabel),
                  maxLines: 3,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(t.commonCancel)),
            FilledButton(onPressed: () => Navigator.pop(ctx, true), child: Text(t.commonDone)),
          ],
        ),
      );
      if (ok != true || !context.mounted) return;
      final n = nameC.text.trim();
      if (n.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t.authorsNameRequired)));
        return;
      }
      await FirebaseFirestore.instance.collection(AuthorManageScreen._col).add({
        'name': n,
        'description': descC.text.trim(),
        'createdAt': FieldValue.serverTimestamp(),
      });
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t.authorsAdded(n))));
      }
    } finally {
      nameC.dispose();
      descC.dispose();
    }
  }

  Future<void> _showEdit(
    BuildContext context,
    String id,
    String currentName,
    String currentDesc,
  ) async {
    final t = AppLocalizations.of(context)!;
    final nameC = TextEditingController(text: currentName);
    final descC = TextEditingController(text: currentDesc);
    try {
      final ok = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(t.authorsEditTitle),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameC,
                  decoration: InputDecoration(labelText: t.authorsNameLabel),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descC,
                  decoration: InputDecoration(labelText: t.authorsDescLabel),
                  maxLines: 3,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(t.commonCancel)),
            FilledButton(onPressed: () => Navigator.pop(ctx, true), child: Text(t.commonSave)),
          ],
        ),
      );
      if (ok != true || !context.mounted) return;
      final n = nameC.text.trim();
      if (n.isEmpty) return;
      await FirebaseFirestore.instance.collection(AuthorManageScreen._col).doc(id).update({
        'name': n,
        'description': descC.text.trim(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t.authorsUpdated)));
      }
    } finally {
      nameC.dispose();
      descC.dispose();
    }
  }

  Future<void> _confirmDelete(BuildContext context, String id, String name) async {
    final t = AppLocalizations.of(context)!;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(t.authorsDeleteTitle),
        content: Text(t.authorsDeleteBody(name)),
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
      await FirebaseFirestore.instance.collection(AuthorManageScreen._col).doc(id).delete();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t.authorsDeleted)));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t.authorsDeleteError('$e'))));
      }
    }
  }
}
