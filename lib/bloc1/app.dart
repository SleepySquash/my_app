import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:my_app/bloc1/auth/bloc/auth_cubit.dart';

class Bloc1App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AuthCubit(),
      child: MaterialApp(
        title: "Bloc1 test",
        initialRoute: '/',
        routes: {
          '/': (context) => LoadingScreen(),
          '/home': (context) => HomeScreen(),
          '/login': (context) => LoginScreen(),
        },
      ),
    );
  }
}

class FadeInRoute extends PageRouteBuilder {
  final Widget page;

  FadeInRoute({required this.page, String? routeName})
      : super(
          settings: RouteSettings(name: routeName),
          pageBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
          ) =>
              page,
          transitionsBuilder: (
            BuildContext context,
            Animation<double> animation,
            Animation<double> secondaryAnimation,
            Widget child,
          ) =>
              FadeTransition(
            opacity: animation,
            child: child,
          ),
          transitionDuration: Duration(milliseconds: 500),
        );

  @override
  bool get maintainState => true;

  @override
  Duration get transitionDuration => Duration(milliseconds: 500);
}

class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(builder: (context, state) {
      if (state is AuthLogged)
        Future.delayed(Duration.zero, () {
          Navigator.of(context).pushReplacementNamed('/home');
        });
      return Scaffold(
        body: ElevatedButton(
          onPressed: () => context.read<AuthCubit>().login(
                fname: '123',
                lname: '321',
                phone: '8911',
                bday: DateTime.now(),
              ),
          child: Text('Login'),
        ),
      );
    });
  }
}

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(builder: (context, state) {
      if (state is AuthUnlogged)
        Future.delayed(Duration.zero,
            () => Navigator.of(context).pushReplacementNamed('/login'));
      return Scaffold(
        body: Column(
          children: [
            Text('Welcome, ${state.fname}!'),
            ElevatedButton(
              onPressed: () => context.read<AuthCubit>().logout(),
              child: Text('Logout'),
            )
          ],
        ),
      );
    });
  }
}

class LoadingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(builder: (context, state) {
      if (state is AuthLogged)
        Future.delayed(
          Duration.zero,
          () => Navigator.of(context)
              .pushReplacement(FadeInRoute(page: HomeScreen())),
        );
      else if (state is AuthUnlogged)
        Future.delayed(
          Duration.zero,
          () => Navigator.of(context)
              .pushReplacement(FadeInRoute(page: LoginScreen())),
        );
      return Center(child: CircularProgressIndicator());
    });
  }
}
