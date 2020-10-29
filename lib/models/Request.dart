import 'package:cloud_firestore/cloud_firestore.dart';

class Request {
  String renterId;
  String renterName;
  String renterPhone;
  GeoPoint location;

  Request(this.renterId, this.renterName, this.renterPhone, this.location);
}
