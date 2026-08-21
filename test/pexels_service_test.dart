import 'package:flutter_test/flutter_test.dart';
import 'package:sutol/services/pexels_service.dart';

void main() {
  group('PexelsService Model & Parsing Tests', () {
    test('PexelsPhoto parses from realistic Pexels API JSON correctly', () {
      final sampleJson = {
        'id': 2880507,
        'width': 4000,
        'height': 3000,
        'url': 'https://www.pexels.com/photo/2880507/',
        'photographer': 'John Doe',
        'photographer_url': 'https://www.pexels.com/@johndoe',
        'photographer_id': 123456,
        'avg_color': '#4B515D',
        'src': {
          'original': 'https://images.pexels.com/photos/2880507/original.jpeg',
          'large2x': 'https://images.pexels.com/photos/2880507/large2x.jpeg',
          'large': 'https://images.pexels.com/photos/2880507/large.jpeg',
          'medium': 'https://images.pexels.com/photos/2880507/medium.jpeg',
          'small': 'https://images.pexels.com/photos/2880507/small.jpeg',
          'portrait': 'https://images.pexels.com/photos/2880507/portrait.jpeg',
          'landscape': 'https://images.pexels.com/photos/2880507/landscape.jpeg',
          'tiny': 'https://images.pexels.com/photos/2880507/tiny.jpeg',
        },
        'liked': false,
        'alt': 'Forest tree during daytime',
      };

      final photo = PexelsPhoto.fromJson(sampleJson);

      expect(photo.id, 2880507);
      expect(photo.sourceId, 'pexels-2880507');
      expect(photo.photographer, 'John Doe');
      expect(photo.aspectRatio, closeTo(4 / 3, 0.01));
      expect(photo.bestDisplayUrl,
          'https://images.pexels.com/photos/2880507/large2x.jpeg');
      expect(photo.thumbnailDisplayUrl,
          'https://images.pexels.com/photos/2880507/medium.jpeg');
    });

    test('PexelsSearchResult parses list of photos correctly', () {
      final searchResultJson = {
        'page': 1,
        'per_page': 1,
        'total_results': 100,
        'next_page': 'https://api.pexels.com/v1/search?page=2',
        'photos': [
          {
            'id': 101,
            'width': 1920,
            'height': 1080,
            'url': 'https://www.pexels.com/photo/101/',
            'photographer': 'Jane Smith',
            'photographer_url': 'https://www.pexels.com/@janesmith',
            'photographer_id': 654321,
            'avg_color': '#333333',
            'src': {
              'large2x': 'https://images.pexels.com/photos/101/large2x.jpeg',
            },
            'alt': 'Solar panels',
          }
        ],
      };

      final result = PexelsSearchResult.fromJson(searchResultJson);

      expect(result.page, 1);
      expect(result.perPage, 1);
      expect(result.totalResults, 100);
      expect(result.photos.length, 1);
      expect(result.photos.first.sourceId, 'pexels-101');
      expect(result.photos.first.aspectRatio, closeTo(16 / 9, 0.01));
    });
  });
}
