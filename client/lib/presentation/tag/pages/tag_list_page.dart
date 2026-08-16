import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:nasyad/core/l10n/l10n.dart';
import 'package:nasyad/core/theme/app_spacing.dart';
import 'package:nasyad/core/ui/ui.dart';
import 'package:nasyad/domain/entities/tag.dart';
import 'package:nasyad/presentation/tag/bloc/tag_list_bloc.dart';

class TagListPage extends StatelessWidget {
  const TagListPage({super.key});

  Future<void> _promptName({
    required BuildContext context,
    required String title,
    required String confirmLabel,
    String initial = '',
    required ValueChanged<String> onSubmit,
  }) async {
    final l10n = AppLocalizations.of(context);
    final controller = TextEditingController(text: initial);
    final name = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: InputDecoration(
              labelText: l10n.tagName,
              hintText: l10n.tagNameHint,
            ),
            textInputAction: TextInputAction.done,
            onSubmitted: (value) => Navigator.of(context).pop(value),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l10n.cancel),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(controller.text),
              child: Text(confirmLabel),
            ),
          ],
        );
      },
    );
    controller.dispose();
    if (name == null) return;
    final trimmed = name.trim();
    if (trimmed.isEmpty) return;
    onSubmit(trimmed);
  }

  Future<void> _confirmDelete(BuildContext context, Tag tag) async {
    final l10n = AppLocalizations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(l10n.deleteTagTitle),
          content: Text(l10n.deleteTagBody(tag.name)),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(l10n.cancel),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(l10n.delete),
            ),
          ],
        );
      },
    );
    if (confirmed == true && context.mounted) {
      context.read<TagListBloc>().add(TagListDeleteRequested(tag.id));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
          tooltip: l10n.back,
        ),
        title: Text(l10n.tags),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _promptName(
          context: context,
          title: l10n.addTag,
          confirmLabel: l10n.createTag,
          onSubmit: (name) =>
              context.read<TagListBloc>().add(TagListCreateRequested(name)),
        ),
        tooltip: l10n.addTag,
        child: const Icon(Icons.add),
      ),
      body: AppContent(
        child: BlocBuilder<TagListBloc, TagListState>(
          builder: (context, state) {
            return switch (state) {
              TagListInitial() || TagListLoading() => const Center(
                child: CircularProgressIndicator(),
              ),
              TagListError(:final message) => Center(child: Text(message)),
              TagListLoaded(:final tags) when tags.isEmpty => _EmptyTags(
                l10n: l10n,
              ),
              TagListLoaded(:final tags) => ListView.separated(
                itemCount: tags.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(height: AppSpacing.sm),
                itemBuilder: (context, index) {
                  final tag = tags[index];
                  return Card(
                    child: ListTile(
                      leading: Icon(
                        Icons.label_outline,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                      title: Text(tag.name),
                      trailing: IconButton(
                        tooltip: l10n.delete,
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () => _confirmDelete(context, tag),
                      ),
                      onTap: () => _promptName(
                        context: context,
                        title: l10n.editTag,
                        confirmLabel: l10n.save,
                        initial: tag.name,
                        onSubmit: (name) => context.read<TagListBloc>().add(
                          TagListRenameRequested(tag: tag, name: name),
                        ),
                      ),
                    ),
                  );
                },
              ),
            };
          },
        ),
      ),
    );
  }
}

class _EmptyTags extends StatelessWidget {
  const _EmptyTags({required this.l10n});

  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.label_outline,
              size: 40,
              color: theme.colorScheme.secondary,
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(l10n.noTagsTitle, style: theme.textTheme.titleMedium),
            const SizedBox(height: AppSpacing.xxs),
            Text(
              l10n.noTagsHint,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
