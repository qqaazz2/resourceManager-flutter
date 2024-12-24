import 'package:json_annotation/json_annotation.dart';
import 'package:resourcemanager/entity/UserInfo.dart';

part 'Login.g.dart';
@JsonSerializable()
class Login extends Object {

  @JsonKey(name: 'token')
  String token;

  @JsonKey(name:"userInfo")
  UserInfo userInfo;

  Login(this.token,this.userInfo);

  factory Login.fromJson(Map<String, dynamic> srcJson) => _$LoginFromJson(srcJson);

  Map<String, dynamic> toJson() => _$LoginToJson(this);

  }
