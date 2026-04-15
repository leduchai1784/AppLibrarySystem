import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/app_text_styles.dart';
import '../../gen/l10n/app_localizations.dart';

/// Quản lý danh mục — collection Firestore `categories` (name, createdAt).
class CategoryManageScreen extends StatelessWidget {
  const CategoryManageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    if (!AppUser.isStaff) {
      return Scaffold(
        appBar: AppBar(title: Text(t.categoriesManageTitle)),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              t.staffOnlyCategoryEdit,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(t.categoriesManageBooksTitle)),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        // Không dùng orderBy('name') — tránh phải tạo index; sắp xếp ở client.
        stream: FirebaseFirestore.instance.collection('categories').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
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
                  Text(t.noCategoriesYet, style: AppTextStyles.body),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    onPressed: () => _showAddDialog(context),
                    icon: const Icon(Icons.add),
                    label: Text(t.addFirstCategory),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final name = (doc.data()['name'] ?? '') as String;
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: const Icon(Icons.category_outlined),
                  title: Text(name.isEmpty ? t.categoryUntitled : name, style: AppTextStyles.h3),
                  subtitle: Text(
                    t.categoryUsedWhenAddingBooks,
                    style: AppTextStyles.caption,
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _showEditDialog(context, doc.id, name),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () => _confirmDelete(context, doc.id, name),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddDialog(context),
        icon: const Icon(Icons.add),
        label: Text(t.addCategory),
      ),
    );
  }

  static String _firestoreMessage(AppLocalizations t, Object e) {
    final s = e.toString();
    if (s.contains('permission-denied')) {
      return t.categoryPermissionDeniedHint;
    }
    return t.categoryErrorGeneric('$e');
  }

  static Future<void> _showAddDialog(BuildContext context) async {
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
            TextButton(onPressed: () => Navigator.pop(ctx), child: Text(t.commonCancel)),
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
      if (name == null || name.isEmpty || !context.mounted) return;
      try {
        await FirebaseFirestore.instance.collection('categories').add({
          'name': name,
          'createdAt': FieldValue.serverTimestamp(),
        });
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t.categoryAddedToast(name))));
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_firestoreMessage(t, e))));
        }
      }
    } finally {
      controller.dispose();
    }
  }

  static Future<void> _showEditDialog(BuildContext context, String docId, String current) async {
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
            TextButton(onPressed: () => Navigator.pop(ctx), child: Text(t.commonCancel)),
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
      if (name == null || name.isEmpty || !context.mounted) return;
      try {
        await FirebaseFirestore.instance.collection('categories').doc(docId).update({
          'name': name,
          'updatedAt': FieldValue.serverTimestamp(),
        });
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t.categoryUpdatedToast)));
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_firestoreMessage(t, e))));
        }
      }
    } finally {
      controller.dispose();
    }
  }

  /// Sách lưu `category` / `categoryId` là **tên** nhóm (chuỗi), trùng `categories.name`.
  static Future<Set<String>> _bookIdsUsingCategoryName(String categoryName) async {
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

  /// Tên danh mục đích (khác doc đang xóa và khác tên đang xóa); luôn ưu tiên [kDefaultBookCategory] nếu hợp lệ.
  static Future<List<String>> _reassignTargetNames(String excludeDocId, String deletingName) async {
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

  static Future<void> _deleteCategoryDoc(String docId) async {
    await FirebaseFirestore.instance.collection('categories').doc(docId).delete();
  }

  static Future<void> _batchUpdateBooksCategory(Set<String> bookIds, String newCategory) async {
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

  static Future<void> _batchDeleteBooks(Set<String> bookIds) async {
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

  static Future<void> _confirmDelete(BuildContext context, String docId, String name) async {
    final t = AppLocalizations.of(context)!;
    final trimmed = name.trim();
    final bookIds = await _bookIdsUsingCategoryName(trimmed);
    if (!context.mounted) return;

    if (bookIds.isEmpty) {
      final ok = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(t.categoryDeleteTitle),
          content: Text(t.categoryDeleteBody(trimmed)),
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
        await _deleteCategoryDoc(docId);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t.categoryDeletedToast)));
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_firestoreMessage(t, e))));
        }
      }
      return;
    }

    final targets = await _reassignTargetNames(docId, trimmed);
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
                      Text(t.categoryDeleteMoveToLabel, style: AppTextStyles.caption),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<String>(
                        value: selected,
                        items: targets
                            .map(
                              (e) => DropdownMenuItem(value: e, child: Text(e)),
                            )
                            .toList(),
                        onChanged: (v) => setState(() => selected = v),
                      ),
                    ] else
                      Text(
                        t.categoryDeleteNoMoveTarget(trimmed),
                        style: AppTextStyles.caption.copyWith(color: AppColors.error),
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx, null), child: Text(t.commonCancel)),
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
                  onPressed: () => Navigator.pop(ctx, const _CategoryDeleteFlowPurge()),
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
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(t.commonCancel)),
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
        await _batchDeleteBooks(bookIds);
        await _deleteCategoryDoc(docId);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t.categoryDeleteToastPurged)));
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_firestoreMessage(t, e))));
        }
      }
      return;
    }

    if (choice is _CategoryDeleteFlowReassign) {
      try {
        await _batchUpdateBooksCategory(bookIds, choice.targetName.trim());
        await _deleteCategoryDoc(docId);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t.categoryDeleteToastReassigned)));
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_firestoreMessage(t, e))));
        }
      }
    }
  }
}

final class _CategoryDeleteFlowReassign {
  final String targetName;
  const _CategoryDeleteFlowReassign(this.targetName);
}

final class _CategoryDeleteFlowPurge {
  const _CategoryDeleteFlowPurge();
}
