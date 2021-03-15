part of 'auth_cubit.dart';

@immutable
abstract class AuthState {
  final String? fname;
  final String? lname;
  final String? phone;
  final DateTime? bday;

  AuthState(
      // ignore: avoid_init_to_null
      {this.fname = null,
      // ignore: avoid_init_to_null
      this.lname = null,
      // ignore: avoid_init_to_null
      this.phone = null,
      // ignore: avoid_init_to_null
      this.bday = null});
}

class AuthInitial extends AuthState {}

class AuthLogged extends AuthState {
  AuthLogged({
    @required fname,
    @required lname,
    @required phone,
    @required bday,
  }) : super(fname: fname, lname: lname, phone: phone, bday: bday);
}

class AuthUnlogged extends AuthState {}
