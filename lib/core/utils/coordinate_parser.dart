class CoordinateParser {
  /// Extract latitude and longitude from a Google Maps URL or text
  static Map<String, double>? parse(String input) {
    if (input.isEmpty) return null;

    // 1. Check for standard @lat,lng format (e.g., https://www.google.com/maps/@-7.262590,110.400584,17z)
    final atRegex = RegExp(r'@(-?\d+\.\d+),(-?\d+\.\d+)');
    var match = atRegex.firstMatch(input);
    if (match != null) {
      final lat = double.tryParse(match.group(1) ?? '');
      final lng = double.tryParse(match.group(2) ?? '');
      if (lat != null && lng != null) {
        return {'latitude': lat, 'longitude': lng};
      }
    }

    // 2. Check for query parameter q=lat,lng format (e.g., https://maps.google.com/?q=-7.262590,110.400584)
    final qRegex = RegExp(r'[?&]q=(-?\d+\.\d+),(-?\d+\.\d+)');
    match = qRegex.firstMatch(input);
    if (match != null) {
      final lat = double.tryParse(match.group(1) ?? '');
      final lng = double.tryParse(match.group(2) ?? '');
      if (lat != null && lng != null) {
        return {'latitude': lat, 'longitude': lng};
      }
    }

    // 3. Check for !3dlat!4dlng format inside Google Maps internal urls (e.g. !3d-7.262590!4d110.400584)
    final bangRegex = RegExp(r'!3d(-?\d+\.\d+).*?!4d(-?\d+\.\d+)');
    match = bangRegex.firstMatch(input);
    if (match != null) {
      final lat = double.tryParse(match.group(1) ?? '');
      final lng = double.tryParse(match.group(2) ?? '');
      if (lat != null && lng != null) {
        return {'latitude': lat, 'longitude': lng};
      }
    }

    // 4. Check if the input is directly "lat,lng" (e.g., "-7.262590,110.400584")
    final directRegex = RegExp(r'^\s*(-?\d+\.\d+)\s*,\s*(-?\d+\.\d+)\s*$');
    match = directRegex.firstMatch(input);
    if (match != null) {
      final lat = double.tryParse(match.group(1) ?? '');
      final lng = double.tryParse(match.group(2) ?? '');
      if (lat != null && lng != null) {
        return {'latitude': lat, 'longitude': lng};
      }
    }

    return null;
  }
}
