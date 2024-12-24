import 'package:json_annotation/json_annotation.dart';

part 'UserInfo.g.dart';

@JsonSerializable()
class UserInfo extends Object {
  @JsonKey(name: 'name')
  String name;

  @JsonKey(name: 'email')
  String email;

  @JsonKey(name: 'mystery')
  int mystery;

  UserInfo(this.name, this.email, this.mystery);

  factory UserInfo.fromJson(Map<String, dynamic> srcJson) => _$UserInfoFromJson(srcJson);

  Map<String, dynamic> toJson() => _$UserInfoToJson(this);

  UserInfo copyWith({
    String? name,
    String? email,
    int? mystery
  }) {
    return UserInfo(
      name ?? this.name,
      email ?? this.email,
      mystery ?? this.mystery,
    );
  }
}