import 'package:envied/envied.dart';

part 'env.g.dart';

@Envied(path: ".env")
abstract class Env {
  @EnviedField(varName: 'OPEN_AI_API_KEY', obfuscate: true)
  static final String apiKey = _Env.apiKey;
  @EnviedField(varName: 'IMGFLIP_USERNAME', obfuscate: true)
  static final String imgFlipUsername = _Env.imgFlipUsername;
  @EnviedField(varName: 'IMGFLIP_PASSWORD', obfuscate: true)
  static final String imgFlipPassword = _Env.imgFlipPassword;
}
