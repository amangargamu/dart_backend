import 'dart:io';

import 'package:shelf_router/shelf_router.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:mongo_dart/mongo_dart.dart';

import 'package:shelf_router_demo/movie_api.dart';

const _hostname = 'localhost';

void main(List<String> arguments) async {
  //Initializing router
  final app = Router();

  //Define default port
  var port = Platform.environment['PORT'] ?? '8080';

  //Initializing mongo db
  var db = Db("mongodb://localhost:27017/dart-sample");
  await db.open();
  var collection = db.collection('movies');

  app.get('/<name>', (Request request, String name) {
    final param = name.isNotEmpty ? name : 'World';
    return Response.ok('Hello $param!');
  });

  app.mount('/movies/', MovieApi(collection).router);

  await io.serve(app, _hostname, int.parse(port));
}
