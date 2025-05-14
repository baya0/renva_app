enum Role {
  unregistered,
  new_user,
  guest,
  user;

  //This is a helper method that converts a stored string (e.g., from GetStorage) into the correct Role value.
  static Role fromString(String s) {
    for (Role role in Role.values) {
      if (role.name == s) {
        return role;
      }
    }
    throw "No Role";
  }
}
