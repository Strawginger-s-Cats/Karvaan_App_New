import 'package:cloud_firestore/cloud_firestore.dart';

class Cycles {
  String name;
  String location;
  String pricePerHr;
  GeoPoint coordinates;
  String ownerId;
  String owner;

  Cycles(this.name, this.ownerId, this.owner, this.location, this.coordinates,
      this.pricePerHr);
}
