extension StringExtension on String {
  String capitalize() {
    // Capitalize all words in a string
    if (length > 1) {
      return toLowerCase().split(" ").map((str) => str[0].toUpperCase() + str.substring(1)).join(" ");
    } else {
      return toUpperCase();
    }
  }
}