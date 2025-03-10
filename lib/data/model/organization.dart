class Organization {
  String? id;
  String? name;
  String? email;
  String? address;
  String? latitude;
  String? longitude;
  String? radius;
  bool? isParentOrganization;
  bool? isSubOrganization;
  String? parentOrganizationId;
  bool? geoLocationEnable;
  bool? isActive;
  bool? isDeleted;
  List<Organization>? subOrganizations;
  Organization(
      this.id,
      this.name,
      this.email,
      this.address,
      this.latitude,
      this.longitude,
      this.radius,
      this.isParentOrganization,
      this.isSubOrganization,
      this.parentOrganizationId,
      this.geoLocationEnable,
      this.isActive,
      this.isDeleted,
      this.subOrganizations);

  factory Organization.fromMap(Map<String, dynamic> map) {
    List<Organization> subOrganizations = map['subOrganizations'] == null
        ? []
        : map['subOrganizations']
            .map<Organization>(
                (subOrganization) => Organization.fromMap(subOrganization))
            .toList();
    return Organization(
        map['organizationId'] == null ? null : map['organizationId'] as String,
        map['organizationName'] == null
            ? null
            : map['organizationName'] as String,
        map['email'] == null ? null : map['email'] as String,
        map['address'] == null ? null : map['address'] as String,
        map['latitude'] == null ? null : map['latitude'] as String,
        map['longitude'] == null ? null : map['longitude'] as String,
        map['radius'] == null ? null : map['radius'] as String,
        map['isParentOrganization'] == null
            ? false
            : map['isParentOrganization'] as bool,
        map['isSubOrganization'] == null
            ? null
            : map['isSubOrganization'] as bool,
        map['parentOrganizationId'] == null
            ? null
            : map['parentOrganizationId'] as String,
        map['geoLocationEnable'] == null
            ? null
            : map['geoLocationEnable'] as bool,
        map['isActive'] = true,
        map['isDeleted'] == null ? false : map['isDeleted'] as bool,
        map['subOrganizations'] == null ? [] : subOrganizations);
  }

  Map<String, dynamic> toJson() => {
        'organizationId': id,
        'organizationName': name,
        'address': address,
        'email': email,
        'isActive': isActive,
        'isDeleted': isDeleted,
        'latitude': latitude,
        'longitude': longitude,
        'radius': radius,
        'isParentOrganization': isParentOrganization,
        'isSubOrganization': isSubOrganization,
        'parentOrganizationId': parentOrganizationId,
        'geoLocationEnable': geoLocationEnable,
        'subOrganizations': subOrganizations
      };
}

class ShiftTime {
  String? startAt;
  String? finishAt;
  ShiftTime.fromJson(data) {
    startAt = data['startAt'] ?? '';
    finishAt = data['finishAt'] ?? '';
  }
}
