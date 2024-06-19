import 'package:resourcemanager/common/Global.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class WebSocketUnit{
  final String baseUrl = "ws://localhost:8081/";
  String url;
  late WebSocketChannel _socketChannel;

  WebSocketUnit({required this.url}) {
    _socketChannel = WebSocketChannel.connect(Uri.parse("$baseUrl$url?Authorization=Bearer ${Global.token}"));
  }

  WebSocketChannel getWebSocketChannel(){
    return _socketChannel;
  }
}
