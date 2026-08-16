part of 'tag_list_bloc.dart';

sealed class TagListEvent extends Equatable {
  const TagListEvent();

  @override
  List<Object?> get props => [];
}

final class TagListStarted extends TagListEvent {
  const TagListStarted();
}

final class TagListCreateRequested extends TagListEvent {
  const TagListCreateRequested(this.name);

  final String name;

  @override
  List<Object?> get props => [name];
}

final class TagListRenameRequested extends TagListEvent {
  const TagListRenameRequested({required this.tag, required this.name});

  final Tag tag;
  final String name;

  @override
  List<Object?> get props => [tag, name];
}

final class TagListDeleteRequested extends TagListEvent {
  const TagListDeleteRequested(this.tagId);

  final String tagId;

  @override
  List<Object?> get props => [tagId];
}

final class _TagListUpdated extends TagListEvent {
  const _TagListUpdated(this.tags);

  final List<Tag> tags;

  @override
  List<Object?> get props => [tags];
}

final class _TagListFailed extends TagListEvent {
  const _TagListFailed(this.error);

  final Object error;

  @override
  List<Object?> get props => [error];
}
