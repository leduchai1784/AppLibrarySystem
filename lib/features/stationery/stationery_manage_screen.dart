import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/constants/app_text_styles.dart';
import '../../gen/l10n/app_localizations.dart';

/// CRUD collection `stationery` (văn phòng phẩm).
class StationeryManageScreen extends StatelessWidget {
  const StationeryManageScreen({super.key});

  static const _col = 'stationery';

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    if (!AppUser.isStaff) {
      return Scaffold(
        appBar: AppBar(title: Text(t.stationeryManageTitle)),
        body: Center(child: Text(t.staffOnlyStationeryManage)),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(t.stationeryManageTitle)),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance.collection(_col).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text(t.stationeryLoadError('${snapshot.error}')));
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
                  Text(t.stationeryEmpty, style: AppTextStyles.body),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    onPressed: () => _showAddEdit(context, null, null),
                    icon: const Icon(Icons.add),
                    label: Text(t.stationeryAddFirst),
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
              final m = doc.data();
              final name = (m['name'] ?? '') as String;
              final qty = (m['quantity'] is int) ? m['quantity'] as int : int.tryParse('${m['quantity']}') ?? 0;
              final unit = (m['unit'] ?? '') as String;
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: const Icon(Icons.inventory_2_outlined),
                  title: Text(name.isEmpty ? t.stationeryUntitled : name, style: AppTextStyles.h3),
                  subtitle: Text(t.stationeryQtyLine('$qty', unit.isEmpty ? '—' : unit)),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit_outlined),
                        onPressed: () => _showAddEdit(context, doc.id, m),
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
        onPressed: () => _showAddEdit(context, null, null),
        icon: const Icon(Icons.add),
        label: Text(t.stationeryAdd),
      ),
    );
  }

  static Future<void> _showAddEdit(
    BuildContext context,
    String? docId,
    Map<String, dynamic>? existing,
  ) async {
    final t = AppLocalizations.of(context)!;
    final nameC = TextEditingController(text: existing == null ? '' : '${existing['name'] ?? ''}');
    final qtyC = TextEditingController(
      text: existing == null ? '0' : '${existing['quantity'] ?? 0}',
    );
    final unitC = TextEditingController(text: existing == null ? '' : '${existing['unit'] ?? ''}');
    try {
      final ok = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(docId == null ? t.stationeryAddTitle : t.stationeryEditTitle),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameC,
                  decoration: InputDecoration(labelText: t.stationeryNameLabel),
                  autofocus: true,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: qtyC,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(labelText: t.stationeryQuantityLabel),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: unitC,
                  decoration: InputDecoration(labelText: t.stationeryUnitLabel),
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
      if (n.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t.stationeryNameRequired)));
        return;
      }
      final q = int.tryParse(qtyC.text.trim()) ?? 0;
      final qty = q < 0 ? 0 : q;
      final unit = unitC.text.trim();
      if (docId == null) {
        await FirebaseFirestore.instance.collection(_col).add({
          'name': n,
          'quantity': qty,
          'unit': unit,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t.stationeryAdded)));
        }
      } else {
        await FirebaseFirestore.instance.collection(_col).doc(docId).update({
          'name': n,
          'quantity': qty,
          'unit': unit,
          'updatedAt': FieldValue.serverTimestamp(),
        });
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t.stationeryUpdated)));
        }
      }
    } finally {
      nameC.dispose();
      qtyC.dispose();
      unitC.dispose();
    }
  }

  static Future<void> _confirmDelete(BuildContext context, String id, String name) async {
    final t = AppLocalizations.of(context)!;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(t.stationeryDeleteTitle),
        content: Text(t.stationeryDeleteBody(name)),
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
      await FirebaseFirestore.instance.collection(_col).doc(id).delete();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t.stationeryDeleted)));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(t.stationeryDeleteError('$e'))));
      }
    }
  }
}
