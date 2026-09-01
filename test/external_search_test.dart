import 'package:bebecare/services/external_search.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const search = ExternalSearch();

  test(
    'Maps search uses standard HTTPS URL and encodes special characters',
    () {
      final uri = search.mapsSearch('UBS vacinação Centro, Belo Horizonte');

      expect(uri.scheme, 'https');
      expect(uri.host, 'www.google.com');
      expect(uri.path, '/maps/search/');
      expect(uri.queryParameters['api'], '1');
      expect(
        uri.queryParameters['query'],
        'UBS vacinação Centro, Belo Horizonte',
      );
      expect(uri.toString(), isNot(contains('@')));
      expect(uri.toString(), isNot(contains('-19.9')));
      expect(uri.toString(), isNot(contains('-44.0')));
    },
  );

  test('nearby vaccination search uses Maps without Cresce coordinates', () {
    final uri = search.nearbyVaccinationSearch();

    expect(uri.queryParameters['query'], 'posto de vacinação perto de mim');
    expect(uri.toString(), isNot(contains('@')));
  });

  test(
    'manual city/bairro search keeps the requested location in the query',
    () {
      final uri = search.vaccinationLocationsSearch(' Centro, Belo Horizonte ');

      expect(
        uri.queryParameters['query'],
        'posto de vacinação Centro, Belo Horizonte',
      );
    },
  );

  test('campaign search uses a standard web search URL rather than Maps', () {
    final uri = search.vaccinationCampaignSearch('Belo Horizonte');

    expect(uri.scheme, 'https');
    expect(uri.host, 'www.google.com');
    expect(uri.path, '/search');
    expect(
      uri.queryParameters['q'],
      'campanha vacinação infantil Belo Horizonte prefeitura saúde',
    );
    expect(uri.path, isNot(contains('/maps/')));
  });

  test('YouTube and Spotify search behavior remains unchanged', () {
    expect(
      search.youtubeSearch('música bebê').toString(),
      'https://www.youtube.com/results?search_query=m%C3%BAsica%20beb%C3%AA',
    );
    expect(
      search.spotifySearch('música bebê').toString(),
      'https://open.spotify.com/search/m%C3%BAsica%20beb%C3%AA',
    );
  });
}
