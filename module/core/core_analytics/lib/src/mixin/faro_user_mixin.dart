import 'faro_mixin.dart' show FaroMixin;

mixin FaroUserMixin on FaroMixin {

  void setUser({required String userId, String? userName, String? userEmail}) {
    faro.setUserMeta(userId: userId, userEmail: userEmail, userName: userName);
  }
}