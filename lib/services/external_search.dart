import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

/// Builds and opens external search URLs (Google, Maps, YouTube, Spotify).
///
/// This is the "Opção A" of the vaccination finder: no API key, works now. We
/// hand the search off to apps the user already trusts instead of scraping.
class ExternalSearch {
  const ExternalSearch();

  /// Stable Google Maps search URL. Google Maps handles device location itself.
  Uri mapsSearch(String query) {
    final encoded = Uri.encodeComponent(query);
    return Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$encoded',
    );
  }

  Uri webSearch(String query) => Uri.parse(
    'https://www.google.com/search?q=${Uri.encodeComponent(query)}',
  );

  Uri nearbyVaccinationSearch() =>
      mapsSearch('posto de vacinação perto de mim');

  Uri vaccinationLocationsSearch(String place) =>
      mapsSearch('posto de vacinação ${place.trim()}');

  Uri vaccinationCampaignSearch(String place) {
    final normalized = place.trim();
    final query = normalized.isEmpty
        ? 'campanha vacinação infantil prefeitura saúde'
        : 'campanha vacinação infantil $normalized prefeitura saúde';
    return webSearch(query);
  }

  Uri youtubeSearch(String query) => Uri.parse(
    'https://www.youtube.com/results?search_query=${Uri.encodeComponent(query)}',
  );

  Uri spotifySearch(String query) => Uri.parse(
    'https://open.spotify.com/search/${Uri.encodeComponent(query)}',
  );

  /// Launches [uri] in an external app/browser. Returns false if nothing could
  /// handle it (the UI then shows a gentle error).
  Future<bool> open(Uri uri) async {
    try {
      return await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      debugPrint('ExternalSearch.open failed: $e');
      return false;
    }
  }
}
