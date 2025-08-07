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
 
  String get baseUrl => BaseProvider.baseUrl!;

  

 
  Future<Book> insertWithCover(Map<String, dynamic> request, File? coverImage) async {
    try {
     
      print("Request: $request");
      var book = await insert(request);
      print("✅ Book created with ID: ${book.id}");
     
      if (coverImage != null && await coverImage.exists()) {
       
        
        try {
          await uploadCover(book.id, coverImage);
         
          book = await getById(book.id);
        
          
          if (book.coverImagePath == null || book.coverImagePath!.isEmpty) {
          
          } else {
          
          }
        } catch (uploadError) {
          print(" Cover image upload failed: $uploadError");
         
        }
      } else {
        print("No cover image provided or file doesn't exist");
        if (coverImage != null) {
          print("File exists check: ${await coverImage.exists()}");
        }
      }
      
      return book;
    } catch (e) {
      print(" Error in insertWithCover: $e");
      rethrow;
    }
  }

 
  Future<Book> updateWithCover(int id, Map<String, dynamic> request, File? coverImage) async {
    try {
    
    
     
      var book = await update(id, request);
    
      
     
      if (coverImage != null && await coverImage.exists()) {
      
        print("File path: ${coverImage.path}");
       
        try {
          
          await uploadCover(id, coverImage);
          print("Cover image uploaded successfully");
          
          book = await getById(id);
         
        } catch (uploadError) {
          print("Cover image upload failed: $uploadError");
        
        }
      } else {
        print("No cover image provided or file doesn't exist");
      }
      
      return book;
    } catch (e) {
      print("Error in updateWithCover: $e");
      rethrow;
    }
  }


  Future<void> uploadCover(int bookId, File coverImage) async {
    try {
     
      var url = "${baseUrl}book/$bookId/cover";
     
      var uri = Uri.parse(url);
      var request = http.MultipartRequest('POST', uri);
      var headers = createHeaders();
      headers.remove('Content-Type');
      request.headers.addAll(headers);
      var stream = http.ByteStream(coverImage.openRead());
      var length = await coverImage.length();
      var filename = coverImage.path.split('/').last;
      var multipartFile = http.MultipartFile(
        'coverImage',
        stream,
        length,
        filename: filename,
      );
      request.files.add(multipartFile);
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception("Failed to upload cover: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      print("Error in uploadCover: $e");
      rethrow;
    }
  }

  Future<List<Book>> getRecommendedBooks(int userId) async {
    try {
      final url = '${baseUrl}book/$userId/recommend';
      final uri = Uri.parse(url);
      
      final response = await http.get(uri, headers: createHeaders());
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => fromJson(json)).toList();
      } else {
        throw Exception('Failed to load recommended books: ${response.statusCode}');
      }
    } catch (e) {
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
      throw  Exception("Failed to get book: ${response.statusCode} - ${response.body}");
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
     
      return null;
    }
  }
   Future<List<Book>> getAllBooks() async {
    try {
      final result = await get(filter: {'RetrieveAll': true});
      return result.items ?? [];
    } catch (e) {
      print('Error fetching books: $e');
      return [];
    }
  }
}




 