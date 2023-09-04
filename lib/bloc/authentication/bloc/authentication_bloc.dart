import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:plantpulse/data/authentication/models/user.dart';
import 'package:plantpulse/data/authentication/repositories/authentication_repository.dart';

part 'authentication_state.dart';

class AuthenticationBloc extends Cubit<AuthenticationState> {
  AuthenticationBloc({
    required AuthenticationRepository authenticationRepository,
  })  : _authenticationRepository = authenticationRepository,
        super(const AuthenticationState.unknown()) {
    _appUserSubscription = FirebaseAuth.instance.authStateChanges().listen(
      (firebaseUser) {
        if (firebaseUser == null)
          emit(AuthenticationState.unauthenticated());
        else {
          final appUser = AppUser(
            id: firebaseUser.uid,
            email: firebaseUser.email ?? '',
            name: firebaseUser.displayName ?? '',
            photo: firebaseUser.photoURL ?? '',
          );
          emit(AuthenticationState.authenticated(appUser));
        }
      },
    );
  }

  final AuthenticationRepository _authenticationRepository;
  late StreamSubscription _appUserSubscription;

  @override
  Future<void> close() {
    _appUserSubscription.cancel();
    return super.close();
  }

  void login() {
    _authenticationRepository.logInWithGoogle();
  }

  Future<void> logout() async {
    await _authenticationRepository.logOut();
  }
}
