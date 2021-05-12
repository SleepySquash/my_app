class Person {
  static String? phone;
  static String? id;

  static Map toJson() => {
        'phone': Person.phone,
        'id': Person.id,
      };
  static void fromJson(Map json) {
    phone = json['phone'];
    id = json['id'];
  }

  static bool isLoggedIn() {
    if (Person.phone == null) return false;
    return (Person.phone!.isNotEmpty && Person.phone!.length == 11);
  }
}
