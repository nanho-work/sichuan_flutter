import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user_model.dart';
import 'user_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final UserService _userService = UserService();

  // =======================================================
  // 🔹 로그인 상태 스트림
  // =======================================================
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // =======================================================
  // 🔹 현재 UID
  // =======================================================
  String? get currentUid => _auth.currentUser?.uid;

  // =======================================================
  // 🔹 Google 로그인
  // =======================================================
  Future<UserModel?> signInWithGoogle() async {
    try {
      final googleUser = await GoogleSignIn(scopes: ['email', 'profile']).signIn();
      if (googleUser == null) return null;

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
        accessToken: googleAuth.accessToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user;
      if (user == null) return null;

      // ✅ Firestore 초기화
      return await _userService.initializeUserData(user, loginType: 'google');
    } catch (e) {
      print('❌ Google 로그인 오류: $e');
      return null;
    }
  }

  // =======================================================
  // 🔹 게스트 로그인
  // =======================================================
  Future<UserModel?> signInAsGuest() async {
    try {
      final userCredential = await _auth.signInAnonymously();
      final user = userCredential.user;
      if (user == null) return null;

      return await _userService.initializeUserData(user, loginType: 'guest');
    } catch (e) {
      print('❌ 게스트 로그인 오류: $e');
      return null;
    }
  }

  // =======================================================
  // 🔹 게스트 → 구글 계정 연동
  // =======================================================
  Future<UserModel?> linkGuestToGoogle() async {
    final user = _auth.currentUser;
    if (user == null || !user.isAnonymous) return null;

    try {
      final googleUser = await GoogleSignIn(scopes: ['email', 'profile']).signIn();
      if (googleUser == null) return null;

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
        accessToken: googleAuth.accessToken,
      );

      final linkedUserCredential = await user.linkWithCredential(credential);
      final linkedUser = linkedUserCredential.user;
      if (linkedUser == null) return null;

      // 🔹 기존 유저 데이터 갱신
      await _userService.updateUserData(linkedUser.uid, {
        'login_type': 'google',
        'nickname': linkedUser.displayName ?? '사용자',
        'email': linkedUser.email ?? 'unknown@koofy.games',
        'last_login': DateTime.now(),
      });

      return await _userService.getUserModel(linkedUser.uid);
    } catch (e) {
      print('❌ 게스트 → 구글 연동 오류: $e');
      return null;
    }
  }

  // =======================================================
  // 🔹 로그아웃
  // =======================================================
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      await GoogleSignIn().signOut();
      print('✅ 로그아웃 완료');
    } catch (e) {
      print('❌ 로그아웃 실패: $e');
    }
  }

  // =======================================================
  // 🔹 회원 탈퇴
  // =======================================================
  Future<void> deleteAccount() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      await _userService.deleteUserData(user.uid); // 🔹 Firestore 데이터 삭제
      await user.delete(); // 🔹 Auth 계정 삭제
      print('✅ 회원 탈퇴 완료');
    } catch (e) {
      print('❌ 회원 탈퇴 실패: $e');
    }
  }
}