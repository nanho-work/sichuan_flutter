import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import 'firestore_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirestoreService _firestoreService = FirestoreService();

  // =======================================================
  // 🔹 현재 로그인 상태 스트림
  // =======================================================
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // =======================================================
  // 🔹 현재 유저 UID
  // =======================================================
  String? get currentUid => _auth.currentUser?.uid;

  // =======================================================
  // 🔹 Firebase 유저 → UserModel 변환
  // =======================================================
  Future<UserModel> _userToModel(User user, {String loginType = 'google'}) async {
    final exists = await _firestoreService.checkUserExists(user.uid);
    if (!exists) {
      final newUser = UserModel(
        uid: user.uid,
        nickname: user.displayName ?? "게스트",
        email: user.email ?? "guest@koofy.games",
        loginType: loginType,
        gold: 100,
        gems: 3,
        energy: 7,
        energyMax: 7,
        createdAt: DateTime.now(),
        lastLogin: DateTime.now(),
      );
      await _firestoreService.createUser(newUser);
      return newUser;
    } else {
      await _firestoreService.updateUser(user.uid, {
        'last_login': DateTime.now(),
      });
      final existing = await _firestoreService.getUser(user.uid);
      return existing ?? UserModel(
        uid: user.uid,
        nickname: user.displayName ?? "게스트",
        email: user.email ?? "guest@koofy.games",
        loginType: loginType,
        gold: 100,
        gems: 3,
        energy: 7,
        energyMax: 7,
        createdAt: DateTime.now(),
        lastLogin: DateTime.now(),
      );
    }
  }

  // =======================================================
  // 🔹 Google 로그인
  // =======================================================
  Future<UserModel?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn(
        scopes: ['email', 'profile'],
      ).signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
        accessToken: googleAuth.serverAuthCode,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      final user = userCredential.user;
      if (user == null) return null;

      return await _userToModel(user, loginType: "google");
    } catch (e) {
      print("Google 로그인 오류: $e");
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

      return await _userToModel(user, loginType: "guest");
    } catch (e) {
      print("게스트 로그인 오류: $e");
      return null;
    }
  }

  // =======================================================
  // 🔹 게스트 계정을 구글 계정으로 연동
  // =======================================================
  Future<UserModel?> linkGuestToGoogle() async {
    final user = _auth.currentUser;
    if (user == null || !user.isAnonymous) return null;

    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn(
        scopes: ['email', 'profile'],
      ).signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
        accessToken: googleAuth.serverAuthCode,
      );

      final linkedUserCredential = await user.linkWithCredential(credential);
      final linkedUser = linkedUserCredential.user;
      if (linkedUser == null) return null;

      await _firestoreService.updateUser(linkedUser.uid, {
        'login_type': 'google',
        'last_login': DateTime.now(),
      });

      return await _userToModel(linkedUser, loginType: 'google');
    } on FirebaseAuthException catch (e) {
      if (e.code == 'credential-already-in-use') {
        print('⚠️ 이미 구글 계정으로 가입된 유저입니다. 데이터 이관이 필요합니다.');
      } else {
        print('❌ 게스트 → 구글 연동 오류: $e');
      }
      return null;
    } catch (e) {
      print('❌ 예외 발생: $e');
      return null;
    }
  }
  // =======================================================
  // 🔹 로그아웃
  // =======================================================
  Future<void> signOut() async {
    await _auth.signOut();
    final googleSignIn = GoogleSignIn();
    await googleSignIn.signOut();
  }

  // =======================================================
  // 🔹 현재 로그인 중인 유저 모델 반환
  // =======================================================
  Future<UserModel?> getCurrentUserModel() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    return await _firestoreService.getUser(user.uid);
  }
}