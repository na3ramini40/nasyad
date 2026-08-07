part of 'search_bloc.dart';

sealed class SearchState extends Equatable {
  const SearchState({required this.query});

  final String query;

  @override
  List<Object?> get props => [query];
}

final class SearchInitial extends SearchState {
  const SearchInitial({super.query = ''});
}

final class SearchLoading extends SearchState {
  const SearchLoading({required super.query});
}

final class SearchLoaded extends SearchState {
  const SearchLoaded({required super.query, required this.results});

  final SearchResults results;

  @override
  List<Object?> get props => [query, results];
}

final class SearchError extends SearchState {
  const SearchError({required super.query, required this.message});

  final String message;

  @override
  List<Object?> get props => [query, message];
}
