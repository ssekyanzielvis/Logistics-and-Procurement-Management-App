import 'lib/utils/country_codes.dart';

void main() {
  final codes = CountryCodes.codes;
  
  // Find Canada index
  for (int i = 0; i < codes.length; i++) {
    if (codes[i]['country'] == 'Canada') {
      print('Canada is at index: $i');
      print('Value: ${codes[i]}');
    }
    if (codes[i]['country'] == 'United States') {
      print('United States is at index: $i');
      print('Value: ${codes[i]}');
    }
  }
  
  print('Total countries: ${codes.length}');
}
