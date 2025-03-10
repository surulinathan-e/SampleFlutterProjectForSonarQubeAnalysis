part of 'navigation_bloc.dart';

abstract class NavigationState {}

final class NavigationInitial extends NavigationState {
  final int index;
  NavigationInitial(this.index);
}

class NavigationLoading extends NavigationState {
  NavigationLoading();
}

class NavigationIndex extends NavigationState {
  final int index;
  NavigationIndex(this.index);
}

