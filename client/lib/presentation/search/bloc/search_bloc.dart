import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:nasyad/domain/entities/search_results.dart';
import 'package:nasyad/domain/usecases/search/search_usecase.dart';

part 'search_event.dart';
part 'search_state.dart';

class SearchBloc extends Bloc<SearchEvent, SearchState> {
  SearchBloc({required SearchUsecase search})
    : _search = search,
      super(const SearchInitial()) {
    on<SearchQueryChanged>(_onQueryChanged);
  }

  final SearchUsecase _search;

  Future<void> _onQueryChanged(
    SearchQueryChanged event,
    Emitter<SearchState> emit,
  ) async {
    final query = event.query;
    if (query.trim().isEmpty) {
      emit(SearchInitial(query: query));
      return;
    }

    emit(SearchLoading(query: query));
    try {
      final results = await _search(query);
      emit(SearchLoaded(query: query, results: results));
    } catch (error) {
      emit(SearchError(query: query, message: error.toString()));
    }
  }
}
