import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  AuthCubit() : super(AuthInitial()) {
    print('AuthCubit CTOR');
    Future.delayed(Duration(seconds: 1), () {
      logout();
    });
  }

  void login(
          {required String fname,
          required String lname,
          required String phone,
          required DateTime bday}) =>
      emit(AuthLogged(fname: fname, lname: lname, phone: phone, bday: bday));
  void logout() => emit(AuthUnlogged());
}
