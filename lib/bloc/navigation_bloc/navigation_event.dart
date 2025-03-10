part of 'navigation_bloc.dart';

abstract class NavigationEvent {}

class OnTap extends NavigationEvent {
  int index;
  OnTap(this.index);
}
