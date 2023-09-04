dart pub global activate full_coverage
dart pub global run full_coverage
flutter analyze
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
#open coverage/html/index.html