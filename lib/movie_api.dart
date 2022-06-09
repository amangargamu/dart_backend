import 'dart:io';
import 'dart:convert';

import 'package:mongo_dart/mongo_dart.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:shelf/shelf.dart';

class MovieApi {
  final file = File('films.json');
  late DbCollection dbCollection;

  MovieApi(this.dbCollection);

  Router get router {
    final List data = json.decode(file.readAsStringSync());
    final router = Router();

    router.get('/', (Request request) async {
      var movies = await dbCollection.find().toList();
      return Response.ok(json.encode(movies),
          headers: {'Content-Type': 'application/json'});
    });

    router.get('/<id|[0-9]+>', (Request request, String id) async {
      final parsedId = int.tryParse(id);
      var movie = await dbCollection.findOne({"id": parsedId});
      if (movie != null) {
        return Response.ok(json.encode(movie),
            headers: {'Content-Type': 'application/json'});
      }
      return Response.notFound('Movie not found.');
    });

    router.post('/', (Request request) async {
      final payload = await request.readAsString();
      await dbCollection.insertOne(json.decode(payload));
      return Response.ok(payload,
          headers: {'Content-Type': 'application/json'});
    });

    router.delete('/<id>', (Request request, String id) async {
      final parsedId = int.tryParse(id);
      var movie = await dbCollection.findOne({"id": parsedId});
      if (movie != null) {
        await dbCollection.deleteOne({"id": parsedId});
        return Response.ok('Deleted.');
      }
      return Response.notFound('Movie not found.');
    });

    return router;
  }
}
