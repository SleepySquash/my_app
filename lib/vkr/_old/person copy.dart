/*
class Person {
  static String fname, lname, phone;
  static DateTime bday;

  static Map toJson() => {
        'fname': Person.fname,
        'lname': Person.lname,
        'phone': Person.phone,
        'bday': Person.bday.toString(),
      };
  static void fromJson(Map json) {
    fname = json['fname'];
    lname = json['lname'];
    phone = json['phone'];
    bday = DateTime.parse(json['bday']);
  }

  static bool isLoggedIn() {
    if (Person.fname == null ||
        Person.lname == null ||
        Person.phone == null ||
        Person.bday == null) return false;
    return (Person.fname.isNotEmpty &&
        Person.lname.isNotEmpty &&
        Person.phone.isNotEmpty &&
        Person.phone.length == 11 &&
        Person.bday != null);
  }
}
*/
