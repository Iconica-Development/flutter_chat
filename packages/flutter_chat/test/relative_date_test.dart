import "package:flutter_chat/src/util/utils.dart";
import "package:flutter_test/flutter_test.dart";

void main() {
  group("RelativeDates", () {
    test("getDateOffsetInDays", () {
      var dateA = DateTime(2024, 10, 30);
      var dateB = DateTime(2024, 10, 01);

      expect(dateA.getDateOffsetInDays(dateB), equals(29));
      expect(dateB.getDateOffsetInDays(dateA), equals(-29));
    });
  });
}
