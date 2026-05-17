import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/app_text_styles.dart';
import '../../gen/l10n/app_localizations.dart';

String _categoryFirestoreMessage(AppLocalizations t, Object e) {
  final s = e.toString();
  if (s.contains('permission-denied')) {
    return t.categoryPermissionDeniedHint;
  }
  return t.categoryErrorGeneric('$e');
}

/// Sách lưu `category` / `categoryId` là **tên** nhóm (chuỗi), trùng `categories.name`.
Future<Set<String>> _categoryBookIdsUsingCategoryName(
  String categoryName,
) async {
  final n = categoryName.trim();
  if (n.isEmpty) return {};
  final books = FirebaseFirestore.instance.collection('books');
  final q1 = await books.where('category', isEqualTo: n).get();
  final q2 = await books.where('categoryId', isEqualTo: n).get();
  final ids = <String>{};
  for (final d in q1.docs) {
    ids.add(d.id);
  }
  for (final d in q2.docs) {
    ids.add(d.id);
  }
  return ids;
}

Future<List<String>> _categoryReassignTargetNames(
  String excludeDocId,
  String deletingName,
) async {
  final del = deletingName.trim();
  final snap = await FirebaseFirestore.instance.collection('categories').get();
  final out = <String>[];
  for (final d in snap.docs) {
    if (d.id == excludeDocId) continue;
    final name = (d.data()['name'] ?? '').toString().trim();
    if (name.isNotEmpty && name != del) out.add(name);
  }
  if (del != kDefaultBookCategory && !out.contains(kDefaultBookCategory)) {
    out.insert(0, kDefaultBookCategory);
  }
  out.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
  return out;
}

Future<void> _categoryDeleteDoc(String docId) async {
  await FirebaseFirestore.instance.collection('categories').doc(docId).delete();
}

Future<void> _categoryBatchUpdateBooksCategory(
  Set<String> bookIds,
  String newCategory,
) async {
  if (bookIds.isEmpty) return;
  final ref = FirebaseFirestore.instance.collection('books');
  const chunk = 450;
  final list = bookIds.toList();
  for (var i = 0; i < list.length; i += chunk) {
    final end = (i + chunk > list.length) ? list.length : i + chunk;
    final batch = FirebaseFirestore.instance.batch();
    for (var j = i; j < end; j++) {
      batch.update(ref.doc(list[j]), {
        'category': newCategory,
        'categoryId': newCategory,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }
    await batch.commit();
  }
}

Future<void> _categoryBatchDeleteBooks(Set<String> bookIds) async {
  if (bookIds.isEmpty) return;
  final ref = FirebaseFirestore.instance.collection('books');
  const chunk = 450;
  final list = bookIds.toList();
  for (var i = 0; i < list.length; i += chunk) {
    final end = (i + chunk > list.length) ? list.length : i + chunk;
    final batch = FirebaseFirestore.instance.batch();
    for (var j = i; j < end; j++) {
      batch.delete(ref.doc(list[j]));
    }
    await batch.commit();
  }
}

Future<void> _categoryConfirmSingleDelete(
  BuildContext context,
  String docId,
  String name,
) async {
  final t = AppLocalizations.of(context)!;
  final trimmed = name.trim();
  final bookIds = await _categoryBookIdsUsingCategoryName(trimmed);
  if (!context.mounted) return;

  if (bookIds.isEmpty) {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(t.categoryDeleteTitle),
        content: Text(t.categoryDeleteBody(trimmed)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(t.commonCancel),
          ),
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
      await _categoryDeleteDoc(docId);
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(t.categoryDeletedToast)));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_categoryFirestoreMessage(t, e))),
        );
      }
    }
    return;
  }

  final targets = await _categoryReassignTargetNames(docId, trimmed);
  if (!context.mounted) return;

  final choice = await showDialog<Object?>(
    context: context,
    builder: (ctx) {
      String? selected = targets.isNotEmpty ? targets.first : null;
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text(t.categoryDeleteHasBooksTitle),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(t.categoryDeleteHasBooksBody(bookIds.length, trimmed)),
                  const SizedBox(height: 16),
                  if (targets.isNotEmpty) ...[
                    Text(
                      t.categoryDeleteMoveToLabel,
                      style: AppTextStyles.caption,
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: selected,
                        items: targets
                            .map(
                              (e) => DropdownMenuItem(value: e, child: Text(e)),
                            )
                            .toList(),
                        onChanged: (v) => setState(() => selected = v),
                      ),
                    ),
                  ] else
                    Text(
                      t.categoryDeleteNoMoveTarget(trimmed),
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.error,
                      ),
                    ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, null),
                child: Text(t.commonCancel),
              ),
              if (targets.isNotEmpty)
                FilledButton(
                  onPressed: selected == null
                      ? null
                      : () => Navigator.pop(
                          ctx,
                          _CategoryDeleteFlowReassign(selected!),
                        ),
                  child: Text(t.categoryDeleteButtonReassign),
                ),
              FilledButton(
                style: FilledButton.styleFrom(backgroundColor: AppColors.error),
                onPressed: () =>
                    Navigator.pop(ctx, const _CategoryDeleteFlowPurge()),
                child: Text(t.categoryDeleteButtonPurgeBooks),
              ),
            ],
          );
        },
      );
    },
  );

  if (choice == null) return;
  if (!context.mounted) return;

  if (choice is _CategoryDeleteFlowPurge) {
    final sure = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(t.categoryDeletePurgeConfirmTitle),
        content: Text(t.categoryDeletePurgeConfirmBody(bookIds.length)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(t.commonCancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(t.commonDelete),
          ),
        ],
      ),
    );
    if (sure != true || !context.mounted) return;
    try {
      await _categoryBatchDeleteBooks(bookIds);
      await _categoryDeleteDoc(docId);
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(t.categoryDeleteToastPurged)));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_categoryFirestoreMessage(t, e))),
        );
      }
    }
    return;
  }

  if (choice is _CategoryDeleteFlowReassign) {
    try {
      await _categoryBatchUpdateBooksCategory(
        bookIds,
        choice.targetName.trim(),
      );
      await _categoryDeleteDoc(docId);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(t.categoryDeleteToastReassigned)),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_categoryFirestoreMessage(t, e))),
        );
      }
    }
  }
}

/// Quản lý danh mục — collection Firestore `categories` (name, createdAt).
class CategoryManageScreen extends StatefulWidget {
  const CategoryManageScreen({super.key});

  @override
  State<CategoryManageScreen> createState() => _CategoryManageScreenState();
}

class _CategoryManageScreenState extends State<CategoryManageScreen> {
  bool _selectMode = false;
  final Set<String> _selectedIds = {};
  bool _bulkBusy = false;

  void _exitSelectMode() {
    setState(() {
      _selectMode = false;
      _selectedIds.clear();
    });
  }

  Future<void> _confirmBulkDelete(AppLocalizations t) async {
    if (_selectedIds.isEmpty) return;
    final n = _selectedIds.length;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(t.deleteConfirmTitle),
        content: Text(t.categoriesBulkDeleteConfirm(n)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(t.commonCancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(t.deleteAction),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    setState(() => _bulkBusy = true);
    final messenger = ScaffoldMessenger.of(context);
    try {
      var deleted = 0;
      var skipped = 0;
      final ids = _selectedIds.toList();
      for (final docId in ids) {
        final ds = await FirebaseFirestore.instance
            .collection('categories')
            .doc(docId)
            .get();
        if (!ds.exists) continue;
        final name = (ds.data()?['name'] ?? '').toString();
        final bookIds = await _categoryBookIdsUsingCategoryName(name);
        if (bookIds.isEmpty) {
          await _categoryDeleteDoc(docId);
          deleted++;
        } else {
          skipped++;
        }
      }
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(content: Text(t.categoriesBulkDeleteResult(deleted, skipped))),
      );
      _exitSelectMode();
    } catch (e) {
      if (mounted) {
        messenger.showSnackBar(
          SnackBar(content: Text(_categoryFirestoreMessage(t, e))),
        );
      }
    } finally {
      if (mounted) setState(() => _bulkBusy = false);
    }
  }

  Future<void> _showAddDialog() async {
    final t = AppLocalizations.of(context)!;
    final controller = TextEditingController();
    try {
      final name = await showDialog<String>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(t.categoryAddTitle),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(hintText: t.categoryNameHint),
            autofocus: true,
            textCapitalization: TextCapitalization.words,
            onSubmitted: (v) {
              final n = v.trim();
              if (n.isNotEmpty) Navigator.pop(ctx, n);
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(t.commonCancel),
            ),
            FilledButton(
              onPressed: () {
                final n = controller.text.trim();
                if (n.isEmpty) {
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    SnackBar(content: Text(t.categoryNameRequired)),
                  );
                  return;
                }
                Navigator.pop(ctx, n);
              },
              child: Text(t.commonDone),
            ),
          ],
        ),
      );
      if (name == null || name.isEmpty || !mounted) return;
      try {
        await FirebaseFirestore.instance.collection('categories').add({
          'name': name,
          'createdAt': FieldValue.serverTimestamp(),
        });
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(t.categoryAddedToast(name))));
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(_categoryFirestoreMessage(t, e))),
          );
        }
      }
    } finally {
      controller.dispose();
    }
  }

  Future<void> _showEditDialog(String docId, String current) async {
    final t = AppLocalizations.of(context)!;
    final controller = TextEditingController(text: current);
    try {
      final name = await showDialog<String>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(t.categoryRenameTitle),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(hintText: t.categoryNameHint),
            autofocus: true,
            textCapitalization: TextCapitalization.words,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(t.commonCancel),
            ),
            FilledButton(
              onPressed: () {
                final n = controller.text.trim();
                if (n.isEmpty) return;
                Navigator.pop(ctx, n);
              },
              child: Text(t.commonSave),
            ),
          ],
        ),
      );
      if (name == null || name.isEmpty || !mounted) return;
      try {
        await FirebaseFirestore.instance
            .collection('categories')
            .doc(docId)
            .update({'name': name, 'updatedAt': FieldValue.serverTimestamp()});
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(t.categoryUpdatedToast)));
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(_categoryFirestoreMessage(t, e))),
          );
        }
      }
    } finally {
      controller.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    if (!AppUser.isStaff) {
      return Scaffold(
        appBar: AppBar(title: Text(t.categoriesManageTitle)),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(t.staffOnlyCategoryEdit, textAlign: TextAlign.center),
          ),
        ),
      );
    }

    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            leading: _selectMode
                ? IconButton(
                    icon: const Icon(Icons.close),
                    tooltip: t.commonCancel,
                    onPressed: _exitSelectMode,
                  )
                : null,
            title: Text(
              _selectMode
                  ? t.bookListSelectedCount(_selectedIds.length)
                  : t.categoriesManageBooksTitle,
            ),
            actions: [
              if (kIsWeb && !_selectMode)
                IconButton(
                  icon: const Icon(Icons.checklist_rounded),
                  tooltip: t.bulkSelectMultipleTooltip,
                  onPressed: () {
                    setState(() {
                      _selectMode = true;
                      _selectedIds.clear();
                    });
                  },
                ),
              if (_selectMode && _selectedIds.isNotEmpty && !_bulkBusy)
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  color: AppColors.error,
                  tooltip: t.bookListBulkDelete(_selectedIds.length),
                  onPressed: () => _confirmBulkDelete(t),
                ),
            ],
          ),
          body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: FirebaseFirestore.instance
                .collection('categories')
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting &&
                  !snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      t.categoryLoadFailed('${snapshot.error}'),
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }
              final docs =
                  List<QueryDocumentSnapshot<Map<String, dynamic>>>.from(
                    snapshot.data?.docs ?? [],
                  );
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
                      Text(t.noCategoriesYet, style: AppTextStyles.body),
                      const SizedBox(height: 12),
                      FilledButton.icon(
                        onPressed: () => _showAddDialog(),
                        icon: const Icon(Icons.add),
                        label: Text(t.addFirstCategory),
                      ),
                    ],
                  ),
                );
              }

              final sel = _selectMode;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (sel) ...[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                      child: Text(
                        t.bulkSelectItemsHint,
                        style: AppTextStyles.small.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: docs.length,
                      itemBuilder: (context, index) {
                        final doc = docs[index];
                        final name = (doc.data()['name'] ?? '') as String;
                        final checked = _selectedIds.contains(doc.id);

                        Widget leading;
                        if (sel) {
                          leading = Checkbox(
                            value: checked,
                            onChanged: _bulkBusy
                                ? null
                                : (_) {
                                    setState(() {
                                      if (checked) {
                                        _selectedIds.remove(doc.id);
                                      } else {
                                        _selectedIds.add(doc.id);
                                      }
                                    });
                                  },
                          );
                        } else {
                          leading = const Icon(Icons.category_outlined);
                        }

                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: leading,
                            title: Text(
                              name.isEmpty ? t.categoryUntitled : name,
                              style: AppTextStyles.h3,
                            ),
                            subtitle: Text(
                              t.categoryUsedWhenAddingBooks,
                              style: AppTextStyles.caption,
                            ),
                            selected: sel && checked,
                            onTap: sel
                                ? (_bulkBusy
                                      ? null
                                      : () {
                                          setState(() {
                                            if (checked) {
                                              _selectedIds.remove(doc.id);
                                            } else {
                                              _selectedIds.add(doc.id);
                                            }
                                          });
                                        })
                                : null,
                            onLongPress: !sel && !_bulkBusy
                                ? () {
                                    setState(() {
                                      _selectMode = true;
                                      _selectedIds
                                        ..clear()
                                        ..add(doc.id);
                                    });
                                  }
                                : null,
                            trailing: sel
                                ? null
                                : Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit),
                                        onPressed: () =>
                                            _showEditDialog(doc.id, name),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.delete_outline),
                                        onPressed: () =>
                                            _categoryConfirmSingleDelete(
                                              context,
                                              doc.id,
                                              name,
                                            ),
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
          floatingActionButton: _selectMode
              ? null
              : FloatingActionButton.extended(
                  onPressed: () => _showAddDialog(),
                  icon: const Icon(Icons.add),
                  label: Text(t.addCategory),
                ),
        ),
        if (_bulkBusy)
          Positioned.fill(
            child: AbsorbPointer(
              child: ColoredBox(
                color: const Color(0x33000000),
                child: const Center(child: CircularProgressIndicator()),
              ),
            ),
          ),
      ],
    );
  }
}

final class _CategoryDeleteFlowReassign {
  final String targetName;
  const _CategoryDeleteFlowReassign(this.targetName);
}

final class _CategoryDeleteFlowPurge {
  const _CategoryDeleteFlowPurge();
}
