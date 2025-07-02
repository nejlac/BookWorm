import 'package:bookworm_desktop/layouts/master_screen.dart';
import 'package:bookworm_desktop/providers/book_provider.dart';
import 'package:flutter/material.dart';

class BookList extends StatefulWidget {
  const BookList({super.key});

  @override
  State<BookList> createState() => _BookListState();
}

class _BookListState extends State<BookList> {
  late BookProvider bookProvider;

  TextEditingController codeController = TextEditingController();
  TextEditingController searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return MasterScreen(
      title: "Book List",
      child: Container(
        color: Colors.white,
        child: Center(
          child: Column(
            /* children: [
              _buildSearch(),
              _buildResultView()
            ],*/
          ),
        ),
      ),
    );
  }
}