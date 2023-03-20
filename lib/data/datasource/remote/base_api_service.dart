import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:http/http.dart' as http;

class BaseApiService {
  Dio dio = GetIt.instance.get();

  Future getList() async {
    final res = http.post(Uri.https("/hehe"));
    final res1 = dio.post("/hehe", options: Options(

    ));
  }
}
