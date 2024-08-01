import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:resourcemanager/common/Global.dart';
import 'package:crypto/crypto.dart';
import '../common/HttpApi.dart';
import '../models/BaseResult.dart';
import '../models/Login.dart';
import '../models/LoginCode.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<StatefulWidget> createState() => LoginPageState();
}

class LoginPageState extends State<LoginPage> {
  final ValueNotifier<String> _key = ValueNotifier<String>("");
  String img = "";
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController verifyController = TextEditingController();
  Widget padding = const Padding(padding: EdgeInsets.only(bottom: 20));
  getCodeImage() async {
    BaseResult baseResult = await HttpApi.request(
        "/user/code", (json) => LoginCode.fromJson(json),
        isLoading: false);
    _key.value = baseResult.result?.key ?? "";
    img = baseResult.result?.img.split(',')[1];
    verifyController.text = "";
  }

  @override
  void initState() {
    super.initState();
    getCodeImage();
  }

  @override
  Widget build(BuildContext context) {
    bool readMe = false;

    double boxSize(width) {
      if (width < 768) {
        return MediaQuery.of(context).size.width - 60;
      } else {
        return 500;
      }
    }

    return Scaffold(body: LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          children: [
            Align(
                alignment: constraints.maxWidth <= 768
                    ? Alignment.center
                    : Alignment.centerRight,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  width: boxSize(constraints.maxWidth),
                  height: boxSize(constraints.maxWidth),
                  margin: constraints.maxWidth <= 768
                      ? EdgeInsets.zero
                      : const EdgeInsets.only(right: 100),
                  decoration:
                      const BoxDecoration(color: Colors.white, boxShadow: [
                    BoxShadow(
                      color: Colors.black54,
                      offset: Offset(0, 2.0),
                      blurRadius: 4.0,
                    )
                  ]),
                  child: Form(
                      child: Column(
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      const SizedBox(
                        width: double.infinity,
                        child: Text(
                          "登录",
                          style: TextStyle(fontSize: 25),
                        ),
                      ),
                      TextFormField(
                        controller: emailController,
                        autofocus: true,
                        autocorrect: true,
                        decoration: const InputDecoration(
                            hintText: "请输入邮箱",
                            labelText: "邮箱",
                            prefixIcon: Icon(Icons.email_outlined),
                            border: OutlineInputBorder()),
                        validator: (v) {
                          if (v!.trim().isEmpty) {
                            return "邮箱不可以为空";
                          } else if (!RegExp(
                                  r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                              .hasMatch(v)) {
                            return "请输入正确的邮箱格式";
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: passwordController,
                        autocorrect: true,
                        obscureText: true,
                        decoration: const InputDecoration(
                            hintText: "请输入密码",
                            labelText: "密码",
                            prefixIcon: Icon(Icons.password_outlined),
                            border: OutlineInputBorder()),
                        validator: (v) =>
                            v!.trim().isNotEmpty ? null : "密码不可以为空",
                      ),
                      ValueListenableBuilder<String>(
                        builder: (BuildContext context, String value,
                            Widget? child) {
                          return Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              img == ""
                                  ? const SizedBox()
                                  : GestureDetector(
                                      child: Image.memory(base64Decode(img),
                                          width: 100),
                                      onTap: () => getCodeImage(),
                                    ),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 10),
                                  child: TextFormField(
                                    controller: verifyController,
                                    decoration: const InputDecoration(
                                        hintText: "请输入验证码",
                                        labelText: "验证码",
                                        prefixIcon:
                                            Icon(Icons.verified_outlined),
                                        border: OutlineInputBorder()),
                                    validator: (v) => v!.trim().isNotEmpty
                                        ? null
                                        : "验证码不可以为空",
                                  ),
                                ),
                              )
                            ],
                          );
                        },
                        valueListenable: _key,
                      ),
                      // Row(
                      //   mainAxisSize: MainAxisSize.max,
                      //   mainAxisAlignment: MainAxisAlignment.end,
                      //   children: [
                      //     StatefulBuilder(builder: (context, setState) {
                      //       return Checkbox(
                      //           value: readMe,
                      //           onChanged: (value) =>
                      //               setState(() => readMe = value!));
                      //     }),
                      //     const Text("记住我")
                      //   ],
                      // ),
                      Builder(builder: (context) {
                        return ElevatedButton(
                            onPressed: () async {
                              bool status = Form.of(context).validate();
                              if (status) {
                                String email = emailController.text;
                                String password = md5.convert(utf8.encode(passwordController.text)).toString();
                                String verify = verifyController.text;
                                BaseResult baseResult = await HttpApi.request(
                                    "/user/login",
                                    (json) => Login.fromJson(json),
                                    method: "post",
                                    params: {
                                      'password': password,
                                      'email': email,
                                      'code': verify,
                                      'key': _key.value
                                    });
                                if (baseResult.code != "2000") {
                                  getCodeImage();
                                  return;
                                }
                                Global.saveLoginStatus(
                                    baseResult.result?.token);
                                context.replaceNamed("home");
                              }
                            },
                            child: const Text("登录"));
                      })
                    ],
                  )),
                )),
          ],
        );
      },
    ));
  }
}
