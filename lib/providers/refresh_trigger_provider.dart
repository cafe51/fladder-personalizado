import 'package:flutter_riverpod/flutter_riverpod.dart';

final refreshTriggerProvider = StateProvider<void Function()>( (ref) => () {});
