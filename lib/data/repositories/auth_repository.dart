import 'package:audio_background/data/datasource/datasource.dart';
import 'package:audio_background/data/dto/dto.dart';

class AuthRepository {
  AuthApiService authApiService = AuthApiService();

  Future<AuthenticationDto> login(String userName, String passWord) {
    return authApiService.login(userName, passWord);
  }

  Future logout() {
    return authApiService.logout();
  }

  Future<ProfileDto> profile() {
    return authApiService.profile();
  }
}
