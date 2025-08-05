import 'package:bookworm_desktop/model/book.dart';
import 'package:bookworm_desktop/providers/base_provider.dart';
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

  Future<void> acceptBook(int id) async {
    var url = "${baseUrl}book/$id/accept";
    var headers = createHeaders();
    var response = await http.post(Uri.parse(url), headers: headers);
    if (!isValidResponse(response)) {
      throw Exception("Failed to accept book");
    }
  }

  Future<void> declineBook(int id) async {
    var url = "${baseUrl}book/$id/decline";
    var headers = createHeaders();
    var response = await http.post(Uri.parse(url), headers: headers);
    if (!isValidResponse(response)) {
      throw Exception("Failed to decline book");
    }
  }

 
  Future<Book> insertWithCover(Map<String, dynamic> request, File? coverImage) async {
    try {
     
      var book = await insert(request);
     
      if (coverImage != null && await coverImage.exists()) {
        print("File path: ${coverImage.path}");
       
        
        try {
          
          await uploadCover(book.id!, coverImage);
          book = await getById(book.id!);
        } catch (uploadError) {
          print("Cover image upload failed: $uploadError");
        
          
        }
      } else {
        print("No cover image provided or file doesn't exist");
      }
      
      return book;
    } catch (e) {
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
          
         
          book = await getById(id);
        } catch (uploadError) {
          print("Cover image upload failed: $uploadError");
        
        }
      } else {
        print("No cover image provided or file doesn't exist");
      }
      
      return book;
    } catch (e) {
      rethrow;
    }
  }


  Future<void> uploadCover(int bookId, File coverImage) async {
    try {
      var url = "${baseUrl}book/$bookId/cover";
      print("Upload URL: $url");
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
      
      if (!isValidResponse(response)) {
        throw new Exception("Failed to upload cover image: ${response.statusCode} - ${response.body}");
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
      var book = fromJson(data);
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
}




   


