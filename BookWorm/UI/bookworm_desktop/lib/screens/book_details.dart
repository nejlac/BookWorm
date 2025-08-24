import 'package:bookworm_desktop/model/book.dart';
import 'package:bookworm_desktop/model/genre.dart';
import 'package:bookworm_desktop/model/author.dart';
import 'package:bookworm_desktop/model/search_result.dart';
import 'package:bookworm_desktop/providers/book_provider.dart';
import 'package:bookworm_desktop/providers/genre_provider.dart';
import 'package:bookworm_desktop/providers/author_provider.dart';
import 'package:bookworm_desktop/screens/author_details.dart';
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:collection/collection.dart';
import 'package:bookworm_desktop/providers/base_provider.dart';

class BookDetails extends StatefulWidget {
  Book? book;
  bool isEditMode;
  BookDetails({super.key, this.book, this.isEditMode = false});

  @override
  State<BookDetails> createState() => _BookDetails();
}
class _BookDetails extends State<BookDetails> {
  final formKey = GlobalKey<FormBuilderState>();
    Map<String, dynamic> _initalValue = {};
    late BookProvider bookProvider;
    late GenreProvider genreProvider;
  late AuthorProvider authorProvider;

    SearchResult<Genre>? genres;
  SearchResult<Author>? authors;
    bool isLoading=true;
  bool isSaving = false;
  File? _selectedImageFile;
  String? _existingCoverPath;

    @override
    void initState() {
      super.initState();
      bookProvider = Provider.of<BookProvider>(context, listen: false);
      genreProvider = Provider.of<GenreProvider>(context, listen: false);
    authorProvider = Provider.of<AuthorProvider>(context, listen: false);
    
    if (widget.book?.coverImagePath != null) {
      _existingCoverPath = widget.book!.coverImagePath;
    }
    
      _initalValue={
        "id": widget.book?.id,
      "title": widget.book?.title ?? '',
      "authorId": widget.book?.authorId,
      "authorName": widget.book?.authorName ?? '',
      "description": widget.book?.description ?? '',
      "genres": widget.isEditMode ? widget.book?.genres ?? [] : widget.book?.genres.join(', ') ?? '',
      "publicationYear": widget.book?.publicationYear?.toString() ?? '',
      "pageCount": widget.book?.pageCount?.toString() ?? '',
    };
      initFormData();
    }
  
   initFormData() async {
    try {
      final loadedGenres = await genreProvider.getAllGenresForDropdown();
      final loadedAuthors = await authorProvider.getAllAuthors();
      setState(() {
        genres = SearchResult<Genre>(
          items: loadedGenres,
        );
        authors = SearchResult<Author>(
          items: loadedAuthors.whereType<Author>().toList(),
        );
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        genres = SearchResult<Genre>(items: []);
        authors = SearchResult<Author>(items: []);
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load data: '+e.toString())),
      );
    }
   }

    @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          widget.isEditMode
              ? (widget.book == null ? 'Add Book' : 'Edit Book')
              : 'Book Details'
        ),
        backgroundColor: Color(0xFF8D6748),
        foregroundColor: Colors.white,
        elevation: 2,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
        _buildForm(),
            if (widget.isEditMode)
              _buildSaveButton(),
            if (!widget.isEditMode)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: widget.book?.bookState == "Accepted" ? null : () async {
                        try {
                          await bookProvider.acceptBook(widget.book!.id);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Row(
                                children: [
                                  Icon(Icons.check_circle, color: Colors.white),
                                  SizedBox(width: 12),
                                  Text("Book accepted!"),
                                ],
                              ),
                              backgroundColor: Color(0xFF4CAF50),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          );
                          Navigator.of(context).pop(true);
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Row(
                                children: [
                                  Icon(Icons.error, color: Colors.white),
                                  SizedBox(width: 12),
                                  Text("Failed to accept book: "+e.toString()),
                                ],
                              ),
                              backgroundColor: Color(0xFFF44336),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          );
                        }
                      },
                      icon: Icon(Icons.check, color: Colors.white),
                      label: Text("Accept"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF4CAF50),
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 3,
                      ),
                    ),
                    SizedBox(width: 24),
                    ElevatedButton.icon(
                      onPressed: widget.book?.bookState == "Declined" ? null : () async {
                        try {
                          await bookProvider.declineBook(widget.book!.id);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Row(
                                children: [
                                  Icon(Icons.check_circle, color: Colors.white),
                                  SizedBox(width: 12),
                                  Text("Book declined!"),
                                ],
                              ),
                              backgroundColor: Color(0xFF4CAF50),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          );
                          Navigator.of(context).pop(true);
                        } catch (e) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Row(
                                children: [
                                  Icon(Icons.error, color: Colors.white),
                                  SizedBox(width: 12),
                                  Text("Failed to decline book: "+e.toString()),
                                ],
                              ),
                              backgroundColor: Color(0xFFF44336),
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          );
                        }
                      },
                      icon: Icon(Icons.close, color: Colors.white),
                      label: Text("Decline"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFC62828),
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 3,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildCoverImagePreview() {
    final imageWidget = _selectedImageFile != null
        ? Image.file(
            _selectedImageFile!,
            fit: BoxFit.cover,
            width: 140,
            height: 210,
          )
        : _existingCoverPath != null
            ? (() {
                String base = BaseProvider.baseUrl ?? '';
                if (base.endsWith('/api/')) {
                  base = base.substring(0, base.length - 5);
                }
                String coverUrl = '$base/$_existingCoverPath';
                return Image.network(
                  coverUrl,
                  fit: BoxFit.cover,
                  width: 140,
                  height: 210,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[200],
                      width: 140,
                      height: 210,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.image_not_supported, color: Colors.grey[600], size: 32),
                          SizedBox(height: 8),
                          Text("Image not found", style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                        ],
                      ),
                    );
                  },
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      color: Colors.grey[200],
                      width: 140,
                      height: 210,
                      child: Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                              : null,
                          strokeWidth: 2,
                        ),
                      ),
                    );
                  },
                );
              })()
            : Container(
                color: Colors.grey[200],
                width: 140,
                height: 210,
                child: Icon(Icons.image_not_supported, color: Colors.grey[600], size: 32),
              );
    return Center(
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Color(0xFF8D6E63).withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: imageWidget,
        ),
      ),
    );
  }
  
  _buildForm() {
     return FormBuilder(
        key: formKey,
        initialValue: _initalValue,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFFFFF8E1), 
                Color(0xFFFFF3E0), 
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.brown.withOpacity(0.1),
                spreadRadius: 5,
                blurRadius: 15,
                offset: Offset(0, 3),
              ),
            ],
          ),
          margin: EdgeInsets.all(16.0),
          padding: EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
             
              Row(
                children: [
                                     Container(
                     padding: EdgeInsets.all(12),
                     decoration: BoxDecoration(
                       color: Color(0xFF8D6E63), 
                       borderRadius: BorderRadius.circular(12),
                     ),
                     child: Icon(
                       Icons.book,
                       color: Colors.white,
                       size: 28,
                     ),
                   ),
                  SizedBox(width: 16),
                  Text(
                    "Book Information",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade800,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24),
              
                                          
              FormBuilderTextField(
                name: "title",
                decoration: InputDecoration(
                  labelText: "📖 Title",
                  prefixIcon: Icon(Icons.title, color: Color(0xFF8D6E63)),
                ),
                readOnly: !widget.isEditMode,
                validator: (val) {
                  if (val == null || val.isEmpty) return "Title is required";
                  if (val.length > 255) return "Title must be at most 255 characters";
                  return null;
                },
              ),
              SizedBox(height: 16),
              
             
              widget.isEditMode ? Column(
                children: [
                  FormBuilderField<int>(
                    name: 'authorId',
                    builder: (field) => SizedBox.shrink(),
                  ),
                  _buildAuthorDropdown(),
                ],
              ) : FormBuilderTextField(
                name: "authorName",
                decoration: InputDecoration(
                  labelText: "✍️ Author",
                  prefixIcon: Icon(Icons.person, color: Color(0xFFA1887F)),
                ),
                readOnly: true,
                validator: (_) => null,
              ),
              SizedBox(height: 16),
              
             
              FormBuilderTextField(
                name: "description",
                decoration: InputDecoration(
                  labelText: "📝 Description",
                  prefixIcon: Icon(Icons.description, color: Color(0xFFBCAAA4)),
                ),
                maxLines: 3,
                readOnly: !widget.isEditMode,
                validator: (val) {
                  if (val == null || val.isEmpty) return "Description is required";
                  if (val.length > 1000) return "Description must be at most 1000 characters";
                  return null;
                },
              ),
              SizedBox(height: 16),
              
            
              widget.isEditMode ? _buildGenresDropdown() : FormBuilderTextField(
                name: "genres",
                decoration: InputDecoration(
                  labelText: "🏷️ Genres",
                  prefixIcon: Icon(Icons.category, color: Color(0xFFD7CCC8)),
                ),
                readOnly: true,
                validator: (_) => null,
              ),
               SizedBox(height: 16),
               
              
               Row(
                 children: [
                   Expanded(
                     child: FormBuilderTextField(
                name: "publicationYear",
                       decoration: InputDecoration(
                         labelText: "📅 Publication Year",
                         prefixIcon: Icon(Icons.calendar_today, color: Color(0xFF6D4C41)),
                       ),
                       readOnly: !widget.isEditMode,
                       validator: (val) {
                         if (val == null || val.isEmpty) return "Publication year is required";
                         final year = int.tryParse(val);
                         if (year == null) return "Invalid year";
                         if (year > DateTime.now().year) return "Year cannot be in the future";
                         return null;
                       },
                     ),
                   ),
                   SizedBox(width: 16),
                   Expanded(
                     child: FormBuilderTextField(
                name: "pageCount",
                       decoration: InputDecoration(
                         labelText: "📄 Pages",
                         prefixIcon: Icon(Icons.pages, color: Color(0xFF795548)),
                       ),
                       readOnly: !widget.isEditMode,
                       validator: (val) {
                         if (val == null || val.isEmpty) return "Page count is required";
                         final count = int.tryParse(val);
                         if (count == null) return "Invalid page count";
                         if (count <= 0) return "Page count must be positive";
                         if (count > 10000) return "Page count cannot exceed 10,000 pages";
                         return null;
                       },
                     ),
                   ),
                 ],
               ),
               SizedBox(height: 16),
               
               
               if (_selectedImageFile != null || _existingCoverPath != null)
                 _buildCoverImagePreview(),
               
               
               if (widget.isEditMode) ...[
                 Container(
                   decoration: BoxDecoration(
                     color: Color(0xFFFFFBFE),
                     borderRadius: BorderRadius.circular(12),
                     border: Border.all(color: Color(0xFF8D6E63).withOpacity(0.4)),
                     boxShadow: [
                       BoxShadow(
                         color: Colors.brown.withOpacity(0.08),
                         spreadRadius: 1,
                         blurRadius: 4,
                         offset: Offset(0, 2),
                       ),
                     ],
                   ),
                   padding: EdgeInsets.all(16),
                   child: Column(
                     crossAxisAlignment: CrossAxisAlignment.start,
                     children: [
                       Row(
                         children: [
                           Icon(Icons.image, color: Color(0xFF8D6E63)),
                           SizedBox(width: 8),
                           Text(
                             "📷 Cover Image",
                             style: TextStyle(
                               fontSize: 16,
                               fontWeight: FontWeight.w600,
                               color: Color(0xFF8D6E63),
                             ),
                           ),
                         ],
                       ),
                       SizedBox(height: 12),
                       
                      
                       Row(
                         mainAxisSize: MainAxisSize.min,
                         children: [
                           ElevatedButton.icon(
                             onPressed: _showImagePickerDialog,
                             icon: Icon(Icons.add_photo_alternate, size: 16),
                             label: Text("Select", style: TextStyle(fontSize: 12)),
                             style: ElevatedButton.styleFrom(
                               backgroundColor: Color(0xFF8D6E63),
                               foregroundColor: Colors.white,
                               padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                               shape: RoundedRectangleBorder(
                                 borderRadius: BorderRadius.circular(6),
                               ),
                               minimumSize: Size(0, 32),
                             ),
                           ),
                           if (_selectedImageFile != null) ...[
                             SizedBox(width: 6),
                             ElevatedButton.icon(
                               onPressed: () {
                                 setState(() {
                                   _selectedImageFile = null;
                                 });
                               },
                               icon: Icon(Icons.clear, size: 16),
                               label: Text("Clear", style: TextStyle(fontSize: 12)),
                               style: ElevatedButton.styleFrom(
                                 backgroundColor: Color(0xFFD32F2F),
                                 foregroundColor: Colors.white,
                                 padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                 shape: RoundedRectangleBorder(
                                   borderRadius: BorderRadius.circular(6),
                                 ),
                                 minimumSize: Size(0, 32),
                               ),
                             ),
                           ],
                           if (_existingCoverPath != null && _selectedImageFile == null) ...[
                             SizedBox(width: 6),
                             ElevatedButton.icon(
                               onPressed: () {
                                 setState(() {
                                   _existingCoverPath = null;
                                 });
                               },
                               icon: Icon(Icons.clear, size: 16),
                               label: Text("Remove", style: TextStyle(fontSize: 12)),
                               style: ElevatedButton.styleFrom(
                                 backgroundColor: Color(0xFFFF9800),
                                 foregroundColor: Colors.white,
                                 padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                 shape: RoundedRectangleBorder(
                                   borderRadius: BorderRadius.circular(6),
                                 ),
                                 minimumSize: Size(0, 32),
                               ),
                             ),
                           ],
                         ],
                       ),
                     ],
                   ),
                 ),
                 SizedBox(height: 16),
               ],
            ],
          ),
        )     );
   }
   
   Widget _buildAuthorDropdown() {
     if (isLoading || authors == null) {
       return Container(
         decoration: BoxDecoration(
           color: Color(0xFFFFFBFE),
           borderRadius: BorderRadius.circular(12),
           border: Border.all(color: Color(0xFFA1887F).withOpacity(0.4)),
         ),
         padding: EdgeInsets.all(16),
         child: Row(
           children: [
             Icon(Icons.person, color: Color(0xFFA1887F)),
             SizedBox(width: 12),
             Text(
               "✍️ Author",
               style: TextStyle(
                 color: Color(0xFFA1887F),
                 fontWeight: FontWeight.w600,
               ),
             ),
             Spacer(),
             SizedBox(
               width: 20,
               height: 20,
               child: CircularProgressIndicator(
                 strokeWidth: 2,
                 valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFA1887F)),
               ),
             ),
           ],
         ),
       );
     }
     
     return Row(    
       crossAxisAlignment: CrossAxisAlignment.start,
       children: [
         Expanded(
           child: DropdownSearch<Author>(
             items: authors?.items ?? [],
             itemAsString: (author) => author?.name ?? '',
             selectedItem: authors?.items?.firstWhereOrNull((a) => a.id == formKey.currentState?.fields['authorId']?.value),
             dropdownDecoratorProps: DropDownDecoratorProps(
               dropdownSearchDecoration: InputDecoration(
                 labelText: "✍️ Author",
                 prefixIcon: Icon(Icons.person, color: Color(0xFFA1887F)),
                 border: OutlineInputBorder(
                   borderRadius: BorderRadius.circular(12),
                   borderSide: BorderSide.none,
                 ),
                 filled: true,
                 fillColor: Colors.transparent,
                 labelStyle: TextStyle(
                   color: Color(0xFFA1887F),
                   fontWeight: FontWeight.w600,
                 ),
                 contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
               ),
             ),
             popupProps: PopupProps.menu(
               showSearchBox: true,
               searchFieldProps: TextFieldProps(
                 decoration: InputDecoration(
                   labelText: 'Search author',
                   prefixIcon: Icon(Icons.search),
                 ),
               ),
             ),
             onChanged: (author) {
               if (author != null) {
                 formKey.currentState?.fields['authorId']?.didChange(author.id);
                 formKey.currentState?.fields['authorName']?.didChange(author.name);
               }
             },
             validator: (author) {
               if (author == null) {
                 return "Please select an author";
               }
               return null;
             },
           ),
         ),
         SizedBox(width: 8),
         ElevatedButton.icon(
           icon: Icon(Icons.add, size: 18),
           label: Text("Add Author", style: TextStyle(fontSize: 13)),
           style: ElevatedButton.styleFrom(
             backgroundColor: Color(0xFF8D6748),
             foregroundColor: Colors.white,
             padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
             shape: RoundedRectangleBorder(
               borderRadius: BorderRadius.circular(8),
             ),
             elevation: 2,
           ),
           onPressed: () async {
             final result = await Navigator.push(
               context,
               MaterialPageRoute(
                 builder: (context) => AuthorDetails(isEditMode: true, isAddMode: true),
               ),
             );
             if (result == true) {
               final loadedAuthors = await authorProvider.getAllAuthors();
               setState(() {
                 authors = SearchResult<Author>(
                   items: loadedAuthors.whereType<Author>().toList(),
                 );
               });
               final newAuthor = authors?.items?.reduce((a, b) => a.id > b.id ? a : b);
               if (newAuthor != null) {
                 formKey.currentState?.fields['authorId']?.didChange(newAuthor.id);
                 formKey.currentState?.fields['authorName']?.didChange(newAuthor.name);
               }
             }
           },
         ),
       ],
     );
   }
   
   Widget _buildGenresDropdown() {
     if (isLoading || genres == null) {
       return Container(
         decoration: BoxDecoration(
           color: Color(0xFFFFFBFE),
           borderRadius: BorderRadius.circular(12),
           border: Border.all(color: Color(0xFFD7CCC8).withOpacity(0.4)),
         ),
         padding: EdgeInsets.all(16),
         child: Row(
           children: [
             Icon(Icons.category, color: Color(0xFFD7CCC8)),
             SizedBox(width: 12),
             Text(
               "🏷️ Genres",
               style: TextStyle(
                 color: Color(0xFFD7CCC8),
                 fontWeight: FontWeight.w600,
               ),
             ),
             Spacer(),
             SizedBox(
               width: 20,
               height: 20,
               child: CircularProgressIndicator(
                 strokeWidth: 2,
                 valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFD7CCC8)),
               ),
             ),
           ],
         ),
       );
     }
     
     return FormBuilderFilterChip(
       name: "genres",
       decoration: InputDecoration(
         labelText: "🏷️ Genres",
       ),
       options: genres?.items?.map((genre) =>
         FormBuilderChipOption(
           value: genre.name,
           child: Text(genre.name),
         )
       ).toList() ?? [],
       selectedColor: Color(0xFFD7CCC8).withOpacity(0.3),
       checkmarkColor: Color(0xFF8D6E63),
       validator: (val) {
         if (val == null || val.isEmpty) return "Select at least one genre";
         return null;
       },
     );
   }
   
     Widget _buildStyledField({
     required String name,
     required String label,
     required IconData icon,
     required Color color,
     bool readOnly = false,
     int maxLines = 1,
   }) {
     return Container(
       decoration: BoxDecoration(
         color: Color(0xFFFFFBFE),
         borderRadius: BorderRadius.circular(12),
         border: Border.all(color: color.withOpacity(0.4)),
         boxShadow: [
           BoxShadow(
             color: Colors.brown.withOpacity(0.08),
             spreadRadius: 1,
             blurRadius: 4,
             offset: Offset(0, 2),
           ),
         ],
       ),
       child: FormBuilderTextField(
         name: name,
         readOnly: readOnly,
         maxLines: maxLines,
         decoration: InputDecoration(
           labelText: label,
           prefixIcon: Icon(icon, color: color),
           border: OutlineInputBorder(
             borderRadius: BorderRadius.circular(12),
             borderSide: BorderSide.none,
           ),
           filled: true,
           fillColor: Colors.transparent,
           labelStyle: TextStyle(
             color: color,
             fontWeight: FontWeight.w600,
           ),
           contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
         ),
         style: TextStyle(
           fontSize: 16,
           color: Color(0xFF5D4037), 
           fontWeight: readOnly ? FontWeight.w500 : FontWeight.normal,
         ),
       ),
          );
   }
   
   Widget _buildSaveButton() {
     return Container(
       margin: EdgeInsets.only(top: 24, left: 16, right: 16),
       child: ElevatedButton(
         onPressed: isSaving ? null : _saveChanges,
         style: ElevatedButton.styleFrom(
           backgroundColor: Color(0xFF8D6E63), 
           foregroundColor: Colors.white,
           padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
           shape: RoundedRectangleBorder(
             borderRadius: BorderRadius.circular(12),
           ),
           elevation: 3,
         ),
         child: Row(
           mainAxisSize: MainAxisSize.min,
           children: [
             if (isSaving) 
               Container(
                 width: 20,
                 height: 20,
                 margin: EdgeInsets.only(right: 12),
                 child: CircularProgressIndicator(
                   strokeWidth: 2,
                   valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                 ),
               ),
             Icon(
               isSaving ? Icons.hourglass_empty : Icons.save,
               size: 20,
             ),
             SizedBox(width: 8),
             Text(
               isSaving ? "Saving..." : (widget.book == null ? "Add Book" : "Save Changes"),
               style: TextStyle(
                 fontSize: 16,
                 fontWeight: FontWeight.w600,
               ),
             ),
           ],
         ),
       ),
     );
   }
   
   Future<void> _saveChanges() async {
     if (!formKey.currentState!.saveAndValidate()) {
       return;
     }
     
     setState(() {
       isSaving = true;
     });
     
     try {
       final formData = formKey.currentState!.value;
       
       final selectedGenreNames = formData["genres"] ?? [];
       final selectedGenreIds = genres?.items
           ?.where((genre) => selectedGenreNames.contains(genre.name))
           ?.map((genre) => genre.id)
           ?.toList() ?? [];
           
       final request = {
         "title": formData["title"],
         "authorId": formData["authorId"] ?? 0,
         "description": formData["description"],
         "publicationYear": int.tryParse(formData["publicationYear"] ?? "") ?? 0,
         "pageCount": int.tryParse(formData["pageCount"] ?? "") ?? 0,
         "genreIds": selectedGenreIds,
         "coverImagePath": _existingCoverPath, 
       };

       final title = formData["title"]?.toString().trim() ?? "";
       final authorId = formData["authorId"] ?? 0;
       final excludeId = widget.book?.id;
       final exists = await bookProvider.existsWithTitleAndAuthor(title, authorId, excludeId: excludeId);
       if (exists) {
         ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(
             content: Row(
               children: [
                 Icon(Icons.error, color: Colors.white),
                 SizedBox(width: 12),
                 Text("A book with this title and author already exists!"),
               ],
             ),
             backgroundColor: Color(0xFFF44336),
             behavior: SnackBarBehavior.floating,
             shape: RoundedRectangleBorder(
               borderRadius: BorderRadius.circular(8),
             ),
           ),
         );
         setState(() { isSaving = false; });
         return;
       }
       
       if (widget.book == null) {
        
         await bookProvider.insertWithCover(request, _selectedImageFile);
         
         ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(
             content: Row(
               children: [
                 Icon(Icons.check_circle, color: Colors.white),
                 SizedBox(width: 12),
                 Text("Book added successfully!"),
               ],
             ),
             backgroundColor: Color(0xFF4CAF50),
             behavior: SnackBarBehavior.floating,
             shape: RoundedRectangleBorder(
               borderRadius: BorderRadius.circular(8),
             ),
           ),
         );
       } else {
         await bookProvider.updateWithCover(widget.book!.id, request, _selectedImageFile);
         
         ScaffoldMessenger.of(context).showSnackBar(
           SnackBar(
             content: Row(
               children: [
                 Icon(Icons.check_circle, color: Colors.white),
                 SizedBox(width: 12),
                 Text("Book updated successfully!"),
               ],
             ),
             backgroundColor: Color(0xFF4CAF50),
             behavior: SnackBarBehavior.floating,
             shape: RoundedRectangleBorder(
               borderRadius: BorderRadius.circular(8),
             ),
           ),
         );
       }
       
       Navigator.of(context).pop(true);
       
     } catch (e) {
      
       ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(
           content: Row(
             children: [
               Icon(Icons.error, color: Colors.white),
               SizedBox(width: 12),
               Text("Failed to "+(widget.book == null ? 'add' : 'update')+" book: "+e.toString()),
             ],
           ),
           backgroundColor: Color(0xFFF44336),
           behavior: SnackBarBehavior.floating,
           shape: RoundedRectangleBorder(
             borderRadius: BorderRadius.circular(8),
           ),
         ),
       );
     } finally {
       setState(() {
         isSaving = false;
       });
     }
   }
   
   
   Future<void> _pickImageFile() async {
     FilePickerResult? result = await FilePicker.platform.pickFiles(
       type: FileType.custom,
       allowedExtensions: ['jpg', 'jpeg', 'png', 'gif', 'bmp', 'webp'],
       allowMultiple: false,
       withData: false,
     );
     if (result != null && result.files.single.path != null) {
       final pickedFile = File(result.files.single.path!);
       try {
         await decodeImageFromList(await pickedFile.readAsBytes());
         setState(() {
           _selectedImageFile = pickedFile;
         });
       } catch (e) {
         showDialog(
           context: context,
           builder: (context) => AlertDialog(
             title: Row(
               children: [
                 Icon(Icons.info_outline, color: Color(0xFF8D6E63)),
                 SizedBox(width: 8),
                 Text('Invalid Image'),
               ],
             ),
             content: Text(
               'The selected file could not be loaded as an image.\nPlease choose a valid image file (JPG, PNG, GIF, BMP, or WEBP).',
               style: TextStyle(fontSize: 15),
             ),
             backgroundColor: Color(0xFFFFF8E1),
             shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
             actions: [
               TextButton(
                 child: Text('OK', style: TextStyle(color: Color(0xFF8D6E63))),
                 onPressed: () => Navigator.of(context).pop(),
               ),
             ],
           ),
         );
       }
     }
   }

  void _showImagePickerDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select Cover Image'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.photo_library),
                title: Text('Browse'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImageFile();
                },
              ),
            ],
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        );
      },
    );
  }
}