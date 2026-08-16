import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nasyad/core/utils/id_generator.dart';
import 'package:nasyad/domain/entities/tag.dart';
import 'package:nasyad/domain/usecases/tag/create_tag_usecase.dart';
import 'package:nasyad/domain/usecases/tag/delete_tag_usecase.dart';
import 'package:nasyad/domain/usecases/tag/update_tag_usecase.dart';
import 'package:nasyad/domain/usecases/tag/watch_tags_usecase.dart';

part 'tag_list_event.dart';
part 'tag_list_state.dart';

class TagListBloc extends Bloc<TagListEvent, TagListState> {
  TagListBloc({
    required WatchTagsUsecase watchTags,
    required CreateTagUsecase createTag,
    required UpdateTagUsecase updateTag,
    required DeleteTagUsecase deleteTag,
  }) : _watchTags = watchTags,
       _createTag = createTag,
       _updateTag = updateTag,
       _deleteTag = deleteTag,
       super(const TagListInitial()) {
    on<TagListStarted>(_onStarted);
    on<TagListCreateRequested>(_onCreate);
    on<TagListRenameRequested>(_onRename);
    on<TagListDeleteRequested>(_onDelete);
    on<_TagListUpdated>(_onUpdated);
    on<_TagListFailed>(_onFailed);
  }

  final WatchTagsUsecase _watchTags;
  final CreateTagUsecase _createTag;
  final UpdateTagUsecase _updateTag;
  final DeleteTagUsecase _deleteTag;
  StreamSubscription? _subscription;

  Future<void> _onStarted(
    TagListStarted event,
    Emitter<TagListState> emit,
  ) async {
    emit(const TagListLoading());
    await _subscription?.cancel();
    _subscription = _watchTags().listen(
      (tags) => add(_TagListUpdated(tags)),
      onError: (Object error, StackTrace _) => add(_TagListFailed(error)),
    );
  }

  Future<void> _onCreate(
    TagListCreateRequested event,
    Emitter<TagListState> emit,
  ) async {
    final name = event.name.trim();
    if (name.isEmpty) return;
    final now = DateTime.now();
    await _createTag(
      Tag(id: IdGenerator.newId(), name: name, createdAt: now, updatedAt: now),
    );
  }

  Future<void> _onRename(
    TagListRenameRequested event,
    Emitter<TagListState> emit,
  ) async {
    final name = event.name.trim();
    if (name.isEmpty) return;
    await _updateTag(event.tag.copyWith(name: name, updatedAt: DateTime.now()));
  }

  Future<void> _onDelete(
    TagListDeleteRequested event,
    Emitter<TagListState> emit,
  ) async {
    await _deleteTag(event.tagId);
  }

  void _onUpdated(_TagListUpdated event, Emitter<TagListState> emit) {
    emit(TagListLoaded(event.tags));
  }

  void _onFailed(_TagListFailed event, Emitter<TagListState> emit) {
    emit(TagListError(event.error.toString()));
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
