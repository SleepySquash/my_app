class Person {
  static String? phone;

  static Map toJson() => {
        'phone': Person.phone,
      };
  static void fromJson(Map json) {
    phone = json['phone'];
  }

  static bool isLoggedIn() {
    if (Person.phone == null) return false;
    return (Person.phone!.isNotEmpty && Person.phone!.length == 11);
  }
}
