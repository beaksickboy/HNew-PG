import 'package:flutter/material.dart';
import 'package:hacker_new/src/shared/models/hn_bloc.dart';

import './src/app.dart';

void main() {
  final hnBloc = NewsBloc();
  runApp(App(bloc: hnBloc));
}
