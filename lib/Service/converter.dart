import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class M3u8Controller extends GetxController {
  // List to store all m3u8 links
  var m3u8Links = <String>[].obs; // Observable list for GetX

  // Concurrency limit
  static const int maxConcurrentRequests = 10;

  // Sample JSON response
  final Map<String, dynamic> jsonResponse = {
    "success": true,
    "results": {
      "streamingInfo": [
        {
          "server": "VidHide",
          "sources": [],
        },
        {
          "server": "Stream Wish",
          "sources": [
            {
              "type": "8a161",
              "source": "https://strwish.com/e/g2zteitdjap7",
              "quality": "480p",
            },
            {
              "type": "a0eb3",
              "source": "https://strwish.com/e/519od7ao52fn",
              "quality": "720p x265",
            },
            {
              "type": "b9aff",
              "source": "https://strwish.com/e/t71t1t9sdvrp",
              "quality": "720p",
            },
            {
              "type": "c8bc7",
              "source": "https://strwish.com/e/83iqwq4ew2n2",
              "quality": "1080p x265",
            },
            {
              "type": "da9a4",
              "source": "https://strwish.com/e/1p731hfjv6eg",
              "quality": "1080p x265",
            },
          ],
        },
        {
          "server": "File Moon",
          "sources": [],
        },
      ],
    },
  };

  // Function to fetch m3u8 links
  Future<void> fetchM3u8Links() async {
    final streamingInfo = (jsonResponse['results']
        as Map<String, dynamic>)['streamingInfo'] as List?;

    if (streamingInfo != null) {
      final streamWishServer = streamingInfo.firstWhere(
        (server) => server['server'] == 'Stream Wish',
        orElse: () => {'sources': []},
      );

      final sources =
          List<Map<String, dynamic>>.from(streamWishServer['sources'] ?? []);

      await processSources(sources);
    } else {
      print('No streaming information available.');
    }
  }

  // Helper function for retry logic with adaptive delay
  Future<http.Response> retryFetch(String url,
      {int retries = 3, int delay = 1999}) async {
    const int maxDelay = 60000; // Maximum delay of 60 seconds
    for (int attempt = 0; attempt < retries; attempt++) {
      try {
        final response = await http.get(Uri.parse(url));
        if (response.statusCode == 200) return response;
        if (response.statusCode == 403) {
          print(
              '403 Forbidden, retrying in ${delay}ms (Attempt ${attempt + 1})');
          await Future.delayed(Duration(milliseconds: delay));
          delay = (delay * 2).clamp(0, maxDelay); // Exponential backoff
        } else {
          throw Exception('Failed to fetch: status ${response.statusCode}');
        }
      } catch (error) {
        if (attempt == retries - 1) throw error;
        print(
            'Retrying due to error: ${error.toString()} (Attempt ${attempt + 1})');
        await Future.delayed(Duration(milliseconds: delay));
        delay = (delay * 2).clamp(0, maxDelay); // Exponential backoff
      }
    }
    throw Exception('Failed to fetch after retries');
  }

  // Function to process each source with improved error handling
  Future<void> processSource(Map<String, dynamic> sourceObj) async {
    // Create a mutable copy of the source object
    final String htmlUrl = sourceObj['source'];

    try {
      final response = await http.get(Uri.parse(htmlUrl));
      if (response.statusCode != 200) {
        throw Exception(
            'Failed to fetch HTML data, status: ${response.statusCode}');
      }

      final htmlData = response.body;
      final apiUrl =
          'https://server2stwish-erzip86p4-kashyap2024s-projects.vercel.app/api/html';
      final apiResponse = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'text/html'},
        body: htmlData,
      );

      final data = json.decode(apiResponse.body);

      if (data['source'] != null) {
        try {
          final linkResponse = await retryFetch(data['source']);
          if (linkResponse.statusCode == 200) {
            print(
                'm3u8 link is valid and accessible: ${linkResponse.statusCode}');
            m3u8Links.add(data['source']); // Store the m3u8 link in the list
          } else {
            print(
                'm3u8 link is not accessible after retry, status: ${linkResponse.statusCode}');
          }
        } catch (error) {
          print('Error checking m3u8 link: ${error.toString()}');
        }
      } else {
        print('Invalid response format: ${data}');
      }
    } catch (error) {
      print('Error processing source: ${error.toString()}');
    }
  }

  // Function to process sources with concurrency limit and dynamic adjustment
  Future<void> processSources(List<Map<String, dynamic>> sources) async {
    List<Future<void>> queue = [];

    for (var sourceObj in sources) {
      if (queue.length >= maxConcurrentRequests) {
        await Future.wait(queue); // Wait for all tasks to complete
        queue.clear(); // Clear the queue after completion
      }

      final task = processSource(sourceObj);
      queue.add(task);
    }

    await Future.wait(queue); // Ensure all tasks are completed
  }
}
