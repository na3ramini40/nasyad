part of 'tag_list_bloc.dart';

sealed class TagListState extends Equatable {
  const TagListState();

  @override
  List<Object?> get props => [];
}

final class TagListInitial extends TagListState {
  const TagListInitial();
}

final class TagListLoading extends TagListState {
  const TagListLoading();
}

final class TagListLoaded extends TagListState {
  const TagListLoaded(this.tags);

  final List<Tag> tags;

  @override
  List<Object?> get props => [tags];
}

final class TagListError extends TagListState {
  const TagListError(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
