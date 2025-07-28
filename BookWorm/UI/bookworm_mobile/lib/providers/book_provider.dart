import 'package:bookworm_mobile/model/book.dart';
import 'package:bookworm_mobile/providers/base_provider.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'dart:convert';

class BookProvider extends BaseProvider<Book> {
  BookProvider():super("book");

 @override
  Book fromJson(dynamic json) {
    return Book.fromJson(json);
  }
 
  String get baseUrl => BaseProvider.baseUrl ?? "http://10.0.2.2:7031/api/";

  

 
  Future<Book> insertWithCover(Map<String, dynamic> request, File? coverImage) async {
    try {
     
      print("Request: $request");
      var book = await insert(request);
      print("✅ Book created with ID: ${book.id}");
     
      if (coverImage != null && await coverImage.exists()) {
        print("File path: ${coverImage.path}");
        print("File exists: ${await coverImage.exists()}");
        print("File size: ${await coverImage.length()}");
        
        try {
          print("🔄 Starting image upload...");
          await uploadCover(book.id!, coverImage);
          print("✅ Image upload completed");
          
          print("🔄 Fetching updated book...");
          book = await getById(book.id!);
          print("✅ Book retrieved with cover path: ${book.coverImagePath}");
          
          if (book.coverImagePath == null || book.coverImagePath!.isEmpty) {
            print("⚠️ WARNING: Book cover path is still null/empty after upload!");
          } else {
            print("✅ SUCCESS: Book cover path saved: ${book.coverImagePath}");
          }
        } catch (uploadError) {
          print("❌ Cover image upload failed: $uploadError");
          print("⚠️ Book was created but without cover image");
          
        }
      } else {
        print("ℹ️ No cover image provided or file doesn't exist");
        if (coverImage != null) {
          print("File exists check: ${await coverImage.exists()}");
        }
      }
      
      return book;
    } catch (e) {
      print("❌ Error in insertWithCover: $e");
      rethrow;
    }
  }

 
  Future<Book> updateWithCover(int id, Map<String, dynamic> request, File? coverImage) async {
    try {
    
    
      print("Book ID: $id");
      print("Request: $request");
      var book = await update(id, request);
      print("✅ Book updated successfully");
      
     
      if (coverImage != null && await coverImage.exists()) {
      
        print("File path: ${coverImage.path}");
       
        try {
          
          await uploadCover(id, coverImage);
          print("✅ Cover image uploaded successfully");
          
         
          book = await getById(id);
          print("✅ Book retrieved with cover path: ${book.coverImagePath}");
        } catch (uploadError) {
          print("❌ Cover image upload failed: $uploadError");
          print("⚠️ Book was updated but without cover image");
        
        }
      } else {
        print("ℹ️ No cover image provided or file doesn't exist");
      }
      
      return book;
    } catch (e) {
      print("❌ Error in updateWithCover: $e");
      rethrow;
    }
  }


  Future<void> uploadCover(int bookId, File coverImage) async {
    try {
     
      print("File path: ${coverImage.path}");
      print("File exists: ${await coverImage.exists()}");
      print("File size: ${await coverImage.length()}");
    
      
      var url = "${baseUrl}book/$bookId/cover";
      print("Upload URL: $url");
      var uri = Uri.parse(url);
      
    
      var request = http.MultipartRequest('POST', uri);
      
   
      var headers = createHeaders();
      headers.remove('Content-Type'); 
      request.headers.addAll(headers);
      print("Headers: $headers");
     
      var stream = http.ByteStream(coverImage.openRead());
      var length = await coverImage.length();
      var filename = coverImage.path.split('/').last;
      print("Creating multipart file: $filename, size: $length");
      
      var multipartFile = http.MultipartFile(
        'coverImage',
        stream,
        length,
        filename: filename,
      );
      
      request.files.add(multipartFile);
      
      print("Sending request...");
      var streamedResponse = await request.send();
      print("Response status: ${streamedResponse.statusCode}");
      
      var response = await http.Response.fromStream(streamedResponse);
      print("Response body: ${response.body}");
      
      if (!isValidResponse(response)) {
        print("Upload failed with status: ${response.statusCode}");
        print("Response body: ${response.body}");
        throw new Exception("Failed to upload cover image: ${response.statusCode} - ${response.body}");
      }
      
      print("Upload successful!");
      print("Response content: ${response.body}");
    } catch (e) {
      print("Error in uploadCover: $e");
      rethrow;
    }
  }

 
  Future<Book> getById(int id) async {
    var url = "${baseUrl}book/$id";
   
    var uri = Uri.parse(url);
    var headers = createHeaders();
    var response = await http.get(uri, headers: headers);
    
    if (isValidResponse(response)) {
      var data = jsonDecode(response.body);
      print("Response data: $data");
      var book = fromJson(data);
      print("Book cover path: ${book.coverImagePath}");
      return book;
    } else {
      throw new Exception("Failed to get book: ${response.statusCode} - ${response.body}");
    }
  }

  Future<bool> existsWithTitleAndAuthor(String title, int authorId, {int? excludeId}) async {
    
    final filter = {
      'title': title,
      'authorId': authorId,
      'pageSize': 1,
      'page': 0,
    };
    final books = await get(filter: filter);
    if (books.items == null || books.items!.isEmpty) return false;
    
    if (excludeId != null) {
      return books.items!.any((b) => b.id != excludeId);
    }
    return true;
  }

  Future<Map<String, dynamic>?> getBookRating(int bookId) async {
    try {
      var url = "${baseUrl}book/$bookId/rating";
      var uri = Uri.parse(url);
      var headers = createHeaders();
      var response = await http.get(uri, headers: headers);
      
      if (isValidResponse(response)) {
        var data = jsonDecode(response.body);
        return {
          'averageRating': data['averageRating']?.toDouble() ?? 0.0,
          'ratingCount': data['ratingCount'] ?? 0,
        };
      } else {
        print("Failed to get book rating: ${response.statusCode} - ${response.body}");
        return null;
      }
    } catch (e) {
      print("Error getting book rating: $e");
      return null;
    }
  }
}




   