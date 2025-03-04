import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:appwrite/appwrite.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart' show XFile;

// Move PaginatedResult class outside of AppwriteService class
class PaginatedResult {
  final List<Map<String, dynamic>> items;
  final String? lastId;

  PaginatedResult({required this.items, this.lastId});
}

class AppwriteService {
  static final client = Client()
    ..setEndpoint('https://cloud.appwrite.io/v1')
    ..setProject('679d7932000e35d64cea')
    ..setSelfSigned(status: true); // Enable self-signed certificates for web

  static final storage = Storage(client);
  static final databases = Databases(client);
  static final account = Account(client);

  // Constants
  static const String databaseId = '679d7c6900077e65bd0f';
  static const String collectionId = '679d7c94001cf62d45f1';
  static const String bucketId = '679d7bb200366c6ead04';

  // Initialize anonymous session
  static Future<void> createAnonymousSession() async {
    try {
      // First check if we already have an active session
      try {
        await account.get();
        // If we get here, we already have an active session
        return;
      } catch (e) {
        // No active session, create a new one
        await account.createAnonymousSession();
      }
    } catch (e) {
      debugPrint('Error with anonymous session: $e');
      rethrow;
    }
  }

  static Future<String> uploadVideo(dynamic videoFile, String fileName) async {
    try {
      // Validate file type
      if (!fileName.toLowerCase().endsWith('.mp4')) {
        throw Exception('Only MP4 videos are supported');
      }

      // Ensure we have an active session
      await createAnonymousSession();

      late InputFile file;

      if (kIsWeb) {
        if (videoFile is XFile) {
          final bytes = await videoFile.readAsBytes();
          file = InputFile.fromBytes(
            bytes: bytes,
            filename: fileName,
          );
        } else {
          throw Exception('Invalid file type for web upload');
        }
      } else {
        file = InputFile.fromPath(
          path: videoFile.path,
          filename: fileName,
        );
      }

      final uploadedFile = await storage.createFile(
        bucketId: bucketId,
        fileId: ID.unique(),
        file: file,
        permissions: [
          Permission.read(Role.any()),
          Permission.write(Role.any()),
          Permission.update(Role.any()),
          Permission.delete(Role.any()),
        ],
      );
      return uploadedFile.$id;
    } catch (e) {
      debugPrint('Error uploading video: $e');
      rethrow;
    }
  }

  static Future<void> createHallVideo({
    required String title,
    required String description,
    required String fileId,
    required String hallNumber,
    required String floor,
    required String locationDescription,
  }) async {
    try {
      await databases.createDocument(
        databaseId: databaseId,
        collectionId: collectionId,
        documentId: ID.unique(),
        data: {
          'title': title,
          'description': description,
          'fileId': fileId,
          'hallNumber': hallNumber,
          'floor': floor,
          'locationDescription': locationDescription,
          'uploadedAt': DateTime.now().toIso8601String(),
          'status': 'active',
        },
        permissions: [
          Permission.read(Role.any()),
          Permission.write(Role.any()),
          Permission.update(Role.any()),
          Permission.delete(Role.any()),
        ],
      );
    } catch (e) {
      debugPrint('Error creating hall video document: $e');
      rethrow;
    }
  }

  // Modify the getHallVideos method to support pagination
  static Future<PaginatedResult> getHallVideos({
    int limit = 20,
    String? lastId,
  }) async {
    try {
      var queries = [
        Query.equal('status', 'active'),
        Query.limit(limit),
      ];

      if (lastId != null) {
        queries.add(Query.cursorAfter(lastId));
      }

      final response = await databases.listDocuments(
        databaseId: databaseId,
        collectionId: collectionId,
        queries: queries,
      );
      
      return PaginatedResult(
        items: response.documents.map((doc) => doc.data).toList(),
        lastId: response.documents.isNotEmpty ? response.documents.last.$id : null,
      );
    } catch (e) {
      debugPrint('Error fetching hall videos: $e');
      rethrow;
    }
  }

  static Future<String> getVideoUrl(String fileId) async {
    try {
      await createAnonymousSession(); // Ensure we have an active session

      // Construct the direct file URL using the Appwrite endpoint, project ID, and bucket ID
      final String url =
          '${client.endPoint}/storage/buckets/$bucketId/files/$fileId/view?project=${client.config['project']}';

      debugPrint('Generated video URL: $url');
      return url;
    } catch (e) {
      debugPrint('Error getting video URL: $e');
      rethrow;
    }
  }

  static Future<void> deleteVideo(String fileId) async {
    try {
      // Delete the file from storage
      await storage.deleteFile(
        bucketId: bucketId,
        fileId: fileId,
      );

      // Delete the document from database
      final documents = await databases.listDocuments(
        databaseId: databaseId,
        collectionId: collectionId,
        queries: [Query.equal('fileId', fileId)],
      );

      if (documents.documents.isNotEmpty) {
        await databases.deleteDocument(
          databaseId: databaseId,
          collectionId: collectionId,
          documentId: documents.documents.first.$id,
        );
      }
    } catch (e) {
      debugPrint('Error deleting video: $e');
      rethrow;
    }
  }

  static Future<String> uploadTeacherPhoto(
      dynamic photoFile, String fileName) async {
    try {
      // Validate file type
      if (!fileName.toLowerCase().endsWith('.jpg') &&
          !fileName.toLowerCase().endsWith('.jpeg') &&
          !fileName.toLowerCase().endsWith('.png')) {
        throw Exception('Only JPG, JPEG and PNG images are supported');
      }

      await createAnonymousSession();
      late InputFile file;

      if (kIsWeb) {
        if (photoFile is XFile) {
          final bytes = await photoFile.readAsBytes();
          file = InputFile.fromBytes(
            bytes: bytes,
            filename: fileName,
            contentType: 'image/${fileName.split('.').last}',
          );
        } else {
          throw Exception('Invalid file type for web upload');
        }
      } else {
        file = InputFile.fromPath(
          path: photoFile.path,
          filename: fileName,
          contentType: 'image/${fileName.split('.').last}',
        );
      }

      final uploadedFile = await storage.createFile(
        bucketId: bucketId,
        fileId: ID.unique(),
        file: file,
        permissions: [
          Permission.read(Role.any()),
          Permission.write(Role.any()),
          Permission.update(Role.any()),
          Permission.delete(Role.any()),
        ],
      );

      return uploadedFile.$id;
    } catch (e) {
      debugPrint('Error uploading teacher photo: $e');
      rethrow;
    }
  }

  static Future<String> getTeacherPhotoUrl(String fileId) async {
    try {
      await createAnonymousSession(); // Ensure we have an active session
      final String url =
          '${client.endPoint}/storage/buckets/$bucketId/files/$fileId/view?project=${client.config['project']}';
      return url;
    } catch (e) {
      debugPrint('Error getting teacher photo URL: $e');
      rethrow;
    }
  }
}
