import 'package:bookworm_desktop/model/book.dart';
import 'package:bookworm_desktop/providers/base_provider.dart';


class BookProvider extends BaseProvider<Book> {
  BookProvider():super("book") ;

 @override
  Book fromJson(dynamic json) {
    return Book.fromJson(json);
  }
 
  }



  
   


