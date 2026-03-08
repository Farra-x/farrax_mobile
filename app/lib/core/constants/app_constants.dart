class FarraxConstants {
  // Tag number regex patterns
  static const ieTagPattern = r'^IE\d{12}$';         // IE141123456789
  static const ukTagPattern = r'^UK\d{12}$';         // UK123456789012

  // Supported countries
  static const List<String> supportedCountries = ['IE', 'UK'];

  // Breed codes (ICBF standard)
  static const Map<String, String> breeds = {
    'AAX': 'Aberdeen Angus Cross',
    'AA':  'Aberdeen Angus',
    'BB':  'Belgian Blue',
    'BBX': 'Belgian Blue Cross',
    'CH':  'Charolais',
    'CHX': 'Charolais Cross',
    'FR':  'Friesian',
    'HE':  'Hereford',
    'HEX': 'Hereford Cross',
    'LI':  'Limousin',
    'LIX': 'Limousin Cross',
    'SI':  'Simmental',
    'SIX': 'Simmental Cross',
    'SH':  'Shorthorn',
    'SP':  'Saler',
  };

  // Sex codes
  static const Map<String, String> sexLabels = {
    'M': 'Male',
    'F': 'Female',
  };

  // Movement directions
  static const String movementIn = 'IN';
  static const String movementOut = 'OUT';

  // TB test results
  static const List<String> tbResults = ['PASS', 'FAIL', 'INCONCLUSIVE'];

  // Calving difficulty scores
  static const Map<int, String> calvingDifficulty = {
    1: 'No assistance',
    2: 'Slight assistance',
    3: 'Mechanical assistance',
    4: 'Veterinary assistance',
    5: 'Caesarean',
  };

  // API
  static const String apiBaseUrl = String.fromEnvironment(
    'FARRAX_API_URL',
    defaultValue: 'http://10.0.2.2:8000',  // Android emulator localhost
  );
}

class TagValidator {
  static bool isValid(String tag) {
    final clean = tag.toUpperCase().replaceAll(' ', '');
    final ieRegex = RegExp(FarraxConstants.ieTagPattern);
    final ukRegex = RegExp(FarraxConstants.ukTagPattern);
    return ieRegex.hasMatch(clean) || ukRegex.hasMatch(clean);
  }

  static String normalise(String tag) {
    return tag.toUpperCase().replaceAll(' ', '').replaceAll('-', '');
  }
}
