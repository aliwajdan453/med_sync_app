import 'package:go_router/go_router.dart';
import 'package:med_sync/core/routing/app_router.dart';
import 'package:med_sync/core/types.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part '../../generated/core/navigation/app_navigator.g.dart';

@Riverpod(keepAlive: true)
AppNavigator appNavigator(Ref ref) => AppNavigator(ref.read(appRouterProvider));

class AppNavigator {
  const AppNavigator(this._router);

  final GoRouter _router;

  void push(String path) => _router.push(path);

  void pushNamed(
    String name, {
    Map<String, String> pathParameters = const {},
    Json queryParameters = const {},
  }) => _router.pushNamed(
    name,
    pathParameters: pathParameters,
    queryParameters: queryParameters,
  );

  void pushReplacement(String path) => _router.pushReplacement(path);

  void go(String path) => _router.go(path);

  void goNamed(
    String name, {
    Map<String, String> pathParameters = const {},
    Json queryParameters = const {},
  }) => _router.goNamed(
    name,
    pathParameters: pathParameters,
    queryParameters: queryParameters,
  );

  void pop() => _router.pop();

  bool canPop() => _router.canPop();
}
