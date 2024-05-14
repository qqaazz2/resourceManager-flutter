import 'package:json_annotation/json_annotation.dart';

part 'Login.g.dart';
@JsonSerializable()
class Login extends Object {

  @JsonKey(name: 'token')
  String token;

  Login(this.token);

  factory Login.fromJson(Map<String, dynamic> srcJson) => _$LoginFromJson(srcJson);

  Map<String, dynamic> toJson() => _$LoginToJson(this);

  }
