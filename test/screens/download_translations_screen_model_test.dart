import 'package:flutter_test/flutter_test.dart';
import 'package:quran_app/helpers/my_event_bus.dart';
import 'package:quran_app/main.dart';
import 'package:quran_app/models/translation_quran_model.dart';
import 'package:quran_app/screens/download_translations_screen.dart';
import 'package:quran_app/services/database_file_service.dart';
import 'package:quran_app/services/quran_data_services.dart';
import 'package:quran_app/services/translations_list_service.dart';
import 'package:tuple/tuple.dart';
import 'package:uuid/uuid.dart';

import '../services/quran_data_service_mockup.dart';
import '../services/translations_list_service_mockup.dart';
import '../test_start.dart';

void main() {
  TestStart.registerDependencies();

  group('Test DownloadTranslationsScreenModel', () {
    test('Test Init first time before adding new translations', () async {
      String eventKey = Uuid().v4().toString();
      var model = DownloadTranslationsScreenModel(
        eventKey: eventKey,
        quranDataService: QuranDataServiceMockup(),
        translationsListService: TranslationsListServiceMockup(),
        databaseFileService: IDatabaseFileService(),
      );

      try {
        await model.init();
        // This data based on ./test_assets/translations.json
        expect(model.availableTranslations.length == 2, true);
        expect(model.notDownloadedTranslations.length > 0, true);
      } finally {
        model.dispose();
      }
    });

    test('Test add translations', () async {
      String eventKey = Uuid().v4().toString();
      var model = DownloadTranslationsScreenModel(
        eventKey: eventKey,
        quranDataService: QuranDataServiceMockup(),
        translationsListService: TranslationsListServiceMockup(),
        databaseFileService: IDatabaseFileService(),
      );

      try {
        await model.init();
        var item = model.notDownloadedTranslations.first;
        await model.moveNotDownloadedToAvailableTranslations(item);

        var result1 = model.availableTranslations.firstWhere(
          (v) => v.id == item.id,
          orElse: () => null,
        );
        expect(result1 != null, true);
        expect(
            model.notDownloadedTranslations.firstWhere(
                  (v) => v.id == item.id,
                  orElse: () => null,
                ) ==
                null,
            true);
      } finally {
        model.dispose();
      }
    });

    test('Test delete translations', () async {
      String eventKey = Uuid().v4().toString();
      var model = DownloadTranslationsScreenModel(
        eventKey: eventKey,
        quranDataService: QuranDataServiceMockup(),
        translationsListService: TranslationsListServiceMockup(),
        databaseFileService: IDatabaseFileService(),
      );

      try {
        await model.init();
        var item = model.notDownloadedTranslations.first;
        await model.moveNotDownloadedToAvailableTranslations(item);
        var result1 = model.availableTranslations.firstWhere(
          (v) => v.id == item.id,
          orElse: () => null,
        );
        expect(result1 != null, true);
        expect(
            model.notDownloadedTranslations.firstWhere(
                  (v) => v.id == item.id,
                  orElse: () => null,
                ) ==
                null,
            true);

        var downloadedTranslation = model.availableTranslations.firstWhere(
          (v) => v.id == item.id,
        );
        await model.moveAvailableToNotDownloadedTranslations(
          downloadedTranslation,
        );
        expect(
            model.availableTranslations.firstWhere(
                  (v) => v.id == item.id,
                  orElse: () => null,
                ) ==
                null,
            true);
        expect(
            model.notDownloadedTranslations.firstWhere(
                  (v) => v.id == item.id,
                  orElse: () => null,
                ) !=
                null,
            true);
      } finally {
        model.dispose();
      }
    });
  });
}
