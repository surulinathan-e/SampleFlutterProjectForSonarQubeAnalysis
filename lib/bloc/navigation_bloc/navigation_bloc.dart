import 'package:bloc/bloc.dart';

part 'navigation_event.dart';
part 'navigation_state.dart';

class NavigationBloc extends Bloc<NavigationEvent, NavigationState> {
  NavigationBloc() : super(NavigationInitial(0)) {
    on<NavigationEvent>((event, emit) {
      if (event is OnTap) {
        emit(NavigationLoading());
        emit(NavigationIndex(event.index));
      }
    });
  }
}
