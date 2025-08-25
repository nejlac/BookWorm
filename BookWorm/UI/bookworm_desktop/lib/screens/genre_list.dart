import 'package:bookworm_desktop/layouts/master_screen.dart';
import 'package:bookworm_desktop/model/genre.dart';
import 'package:bookworm_desktop/model/search_result.dart';
import 'package:bookworm_desktop/providers/genre_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class GenreList extends StatefulWidget {
  const GenreList({super.key});

  @override
  State<GenreList> createState() => _GenreListState();
}

class _GenreListState extends State<GenreList> {
  late GenreProvider genreProvider;
  SearchResult<Genre>? genres;
  
  TextEditingController searchController = TextEditingController();

  int currentPage = 1;
  int pageSize = 10;
  int totalPages = 1;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    genreProvider = context.read<GenreProvider>();
    _fetchGenres();
  }

          void _fetchGenres({int? page}) async {
          try {
            final filter = <String, dynamic>{
              'page': (page ?? currentPage) - 1,
              'pageSize': pageSize,
              'includeTotalCount': true,
            };
            
            if (searchController.text.isNotEmpty) {
              filter['Name'] = searchController.text;
            }
            
            var genres = await genreProvider.get(filter: filter);
            debugPrint("DEBUG: Genre filter parameters: page=${(page ?? currentPage) - 1}, pageSize=$pageSize");
            setState(() {
              this.genres = genres;
              currentPage = (page ?? currentPage);
              totalPages = (genres.totalCount != null && pageSize > 0)
                  ? ((genres.totalCount! + pageSize - 1) ~/ pageSize)
                  : 1;
              if (currentPage > totalPages) currentPage = totalPages;
              if (currentPage < 1) currentPage = 1;
            });
          } catch (e) {
            debugPrint("DEBUG: Error fetching genres: $e");
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error fetching genres: ${e.toString()}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }

  void _showAddEditDialog({Genre? genre}) {
    final isEditing = genre != null;
    final nameController = TextEditingController(text: genre?.name ?? '');
    final descriptionController = TextEditingController(text: genre?.description ?? '');
    String? nameError;
    String? descriptionError;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(isEditing ? 'Edit Genre' : 'Add Genre'),
              content: Container(
                width: 400,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: 'Name *',
                        border: OutlineInputBorder(),
                        errorText: nameError,
                      ),
                      onChanged: (value) {
                        if (nameError != null) {
                          setDialogState(() {
                            nameError = null;
                          });
                        }
                      },
                    ),
                    SizedBox(height: 16),
                    TextField(
                      controller: descriptionController,
                      decoration: InputDecoration(
                        labelText: 'Description',
                        border: OutlineInputBorder(),
                        errorText: descriptionError,
                      ),
                      maxLines: 3,
                      onChanged: (value) {
                        if (descriptionError != null) {
                          setDialogState(() {
                            descriptionError = null;
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    bool hasError = false;
                    if (nameController.text.trim().isEmpty) {
                      setDialogState(() {
                        nameError = 'Name is required';
                      });
                      hasError = true;
                    } else if (nameController.text.trim().length > 255) {
                      setDialogState(() {
                        nameError = 'Name must not exceed 255 characters';
                      });
                      hasError = true;
                    } else {
                      // Check for duplicate name - fetch all genres to check
                      try {
                        final allGenres = await genreProvider.getAllGenres();
                        final items = allGenres.items;
                        if (items != null) {
                          final existingGenre = items.firstWhere(
                            (g) => g.name.toLowerCase() == nameController.text.trim().toLowerCase() && 
                                   (!isEditing || g.id != genre!.id),
                            orElse: () => Genre(id: -1, name: '', description: ''),
                          );
                          
                          if (existingGenre.id != -1) {
                            setDialogState(() {
                              nameError = 'A genre with this name already exists';
                            });
                            hasError = true;
                          }
                        }
                      } catch (e) {
                        // If we can't fetch all genres, fall back to current page check
                        final items = genres?.items;
                        if (items != null) {
                          final existingGenre = items.firstWhere(
                            (g) => g.name.toLowerCase() == nameController.text.trim().toLowerCase() && 
                                   (!isEditing || g.id != genre!.id),
                            orElse: () => Genre(id: -1, name: '', description: ''),
                          );
                          
                          if (existingGenre.id != -1) {
                            setDialogState(() {
                              nameError = 'A genre with this name already exists';
                            });
                            hasError = true;
                          }
                        }
                      }
                    }

                    if (descriptionController.text.trim().length > 1000) {
                      setDialogState(() {
                        descriptionError = 'Description must not exceed 1000 characters';
                      });
                      hasError = true;
                    }

                    if (hasError) return;

                    try {
                      if (isEditing) {
                        await genreProvider.updateGenre(
                          genre!.id,
                          nameController.text.trim(),
                          descriptionController.text.trim().isEmpty ? null : descriptionController.text.trim(),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Genre updated successfully!'),
                            backgroundColor: Color(0xFF8D6748),
                          ),
                        );
                      } else {
                        await genreProvider.createGenre(
                          nameController.text.trim(),
                          descriptionController.text.trim().isEmpty ? null : descriptionController.text.trim(),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Genre created successfully!'),
                            backgroundColor: Color(0xFF8D6748),
                          ),
                        );
                      }
                      Navigator.of(context).pop();
                      _fetchGenres(page: 1); 
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error: ${e.toString()}'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  },
                  child: Text(isEditing ? 'Update' : 'Add'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          const SizedBox(height: 24),
          _buildHeader(),
          _buildSearch(),
          Expanded(child: _buildResultView()),
          _buildPaginationControls(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Genres',
            style: TextStyle(
              fontFamily: 'Literata',
              fontWeight: FontWeight.bold,
              fontSize: 28,
              color: Color(0xFF5D4037),
            ),
          ),
          ElevatedButton.icon(
            onPressed: () => _showAddEditDialog(),
            icon: Icon(Icons.add, color: Colors.white),
            label: Text('Add Genre', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF8D6748),
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearch() {
    return Padding(
      padding: const EdgeInsets.only(top: 0, bottom: 16),
      child: Center(
        child: Container(
          margin: const EdgeInsets.only(bottom: 8),
          constraints: const BoxConstraints(maxWidth: 600),
          child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
              Flexible(
                flex: 2,
                child: TextField(
                  controller: searchController,
                  decoration: InputDecoration(
                    labelText: 'Search by Name',
                    border: OutlineInputBorder(),
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: () => _fetchGenres(page: 1),
                    ),
                  ),
                  style: const TextStyle(fontSize: 14),
                  onSubmitted: (value) => _fetchGenres(page: 1),
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                height: 36,
                child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8D6748),
                foregroundColor: Colors.white,
                    textStyle: const TextStyle(
                      fontFamily: 'Literata',
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: () async {
                    _fetchGenres(page: 1);
                  },
                  child: const Text('Search'),
                ),
              ),
            ],
          ),
        ),
        ),
      );
    }

  Widget _buildResultView() {
    final totalCount = genres?.totalCount ?? 0;
    final items = genres?.items ?? [];
    
    if (items.isEmpty && totalCount == 0) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.category_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            SizedBox(height: 16),
            Text(
              'No genres found',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return Center(
      child: Container(
        constraints: BoxConstraints(maxWidth: 800),
        margin: EdgeInsets.symmetric(horizontal: 32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.brown.withOpacity(0.08),
              blurRadius: 16,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Color(0xFF8D6748),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.category, color: Colors.white, size: 24),
                  SizedBox(width: 12),
                  Text(
                    'All Genres (${totalCount})',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: DataTable(
                  columnSpacing: 32,
                  dataRowHeight: 60,
                  headingRowHeight: 56,
                  columns: [
                    DataColumn(
                      label: Text(
                        'ID',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF5D4037),
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Name',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF5D4037),
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Description',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF5D4037),
                        ),
                      ),
                    ),
                    DataColumn(
                      label: Text(
                        'Actions',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF5D4037),
                        ),
                      ),
                    ),
                  ],
                  rows: items.map((genre) {
                    return DataRow(
                      cells: [
                        DataCell(
                          Text(
                            genre.id.toString(),
                            style: TextStyle(
                              color: Color(0xFF5D4037),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        DataCell(
                          Text(
                            genre.name,
                            style: TextStyle(
                              color: Color(0xFF5D4037),
                              fontSize: 16,
                            ),
                          ),
                        ),
                        DataCell(
                          Container(
                            constraints: BoxConstraints(maxWidth: 200),
                            child: Text(
                              genre.description ?? 'No description',
                              style: TextStyle(
                                color: Color(0xFF5D4037),
                                fontSize: 14,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                            ),
                          ),
                        ),
                        DataCell(
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit, color: Color(0xFF8D6748)),
                                onPressed: () => _showAddEditDialog(genre: genre),
                              ),
                              IconButton(
                                icon: Icon(Icons.delete, color: Colors.red[400]),
                                onPressed: () async {
                                  final confirm = await showDialog<bool>(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      title: Row(
                                        children: [
                                          Icon(Icons.warning, color: Color(0xFFC62828)),
                                          SizedBox(width: 8),
                                          Text('Delete Genre'),
                                        ],
                                      ),
                                      content: Text('Are you sure you want to delete "${genre.name}"? This action cannot be undone.'),
                                      actions: [
                                        TextButton(
                                          child: Text('Cancel'),
                                          onPressed: () => Navigator.of(context).pop(false),
                                        ),
                                        ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Color(0xFFC62828),
                                            foregroundColor: Colors.white,
                                          ),
                                          child: Text('Delete'),
                                          onPressed: () => Navigator.of(context).pop(true),
                                        ),
                                      ],
                                    ),
                                  );
                                  if (confirm == true) {
                                    final errorMessage = await genreProvider.delete(genre.id);
                                    if (errorMessage == null) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Row(
                                            children: [
                                              Icon(Icons.check_circle, color: Colors.white),
                                              SizedBox(width: 12),
                                              Text('Genre deleted successfully.'),
                                            ],
                                          ),
                                          backgroundColor: Color(0xFF4CAF50),
                                          behavior: SnackBarBehavior.floating,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                        ),
                                      );
                                      _fetchGenres(page: 1);
                                    } else {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Row(
                                            children: [
                                              Icon(Icons.error, color: Colors.white),
                                              SizedBox(width: 12),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    Text(
                                                      'Cannot Delete Genre',
                                                      style: TextStyle(fontWeight: FontWeight.bold),
                                                    ),
                                                    SizedBox(height: 4),
                                                    Text(
                                                      errorMessage,
                                                      style: TextStyle(fontSize: 12),
                                                    ),
                                                    SizedBox(height: 4),
                                                    Text(
                                                      'Please remove or change the genre from all books first.',
                                                      style: TextStyle(fontSize: 11, fontStyle: FontStyle.italic),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                          backgroundColor: Color(0xFFFF9800),
                                          behavior: SnackBarBehavior.floating,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          duration: Duration(seconds: 8),
                                        ),
                                      );
                                    }
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaginationControls() {
    if ((genres?.items?.isEmpty ?? true) && totalPages <= 1) return SizedBox.shrink();
    
    int maxPageButtons = 5;
    int startPage = (currentPage - (maxPageButtons ~/ 2)).clamp(1, (totalPages - maxPageButtons + 1).clamp(1, totalPages));
    int endPage = (startPage + maxPageButtons - 1).clamp(1, totalPages);
    List<int> pageNumbers = [for (int i = startPage; i <= endPage; i++) i];

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          decoration: BoxDecoration(
            color: Color(0xFFFFF8E1),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 7,
                offset: Offset(0, 2),
              ),
            ],
            border: Border.all(color: Color(0xFF8D6748), width: 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(Icons.first_page, size: 20, color: currentPage == 1 ? Colors.grey : Color(0xFF8D6748)),
                tooltip: 'First Page',
                onPressed: currentPage > 1 ? () => _fetchGenres(page: 1) : null,
                padding: EdgeInsets.zero,
                constraints: BoxConstraints(minWidth: 28, minHeight: 28),
              ),
              const SizedBox(width: 0),
              IconButton(
                icon: Icon(Icons.chevron_left, size: 20, color: currentPage == 1 ? Colors.grey : Color(0xFF8D6748)),
                tooltip: 'Previous Page',
                onPressed: currentPage > 1 ? () => _fetchGenres(page: currentPage - 1) : null,
                padding: EdgeInsets.zero,
                constraints: BoxConstraints(minWidth: 28, minHeight: 28),
              ),
              const SizedBox(width: 4),
              ...pageNumbers.map((page) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 1),
                child: ChoiceChip(
                  label: Text('$page', style: TextStyle(
                    fontFamily: 'Literata',
              fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: page == currentPage ? Colors.white : Color(0xFF8D6748),
                  )),
                  selected: page == currentPage,
                  selectedColor: Color(0xFF8D6748),
                  backgroundColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Color(0xFF8D6748), width: 1),
                  ),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.symmetric(horizontal: 7, vertical: 0),
                  onSelected: (selected) {
                    if (page != currentPage) _fetchGenres(page: page);
                  },
                ),
              )),
              const SizedBox(width: 4),
              IconButton(
                icon: Icon(Icons.chevron_right, size: 20, color: currentPage == totalPages ? Colors.grey : Color(0xFF8D6748)),
                tooltip: 'Next Page',
                onPressed: currentPage < totalPages ? () => _fetchGenres(page: currentPage + 1) : null,
                padding: EdgeInsets.zero,
                constraints: BoxConstraints(minWidth: 28, minHeight: 28),
              ),
              const SizedBox(width: 0),
              IconButton(
                icon: Icon(Icons.last_page, size: 20, color: currentPage == totalPages ? Colors.grey : Color(0xFF8D6748)),
                tooltip: 'Last Page',
                onPressed: currentPage < totalPages ? () => _fetchGenres(page: totalPages) : null,
                padding: EdgeInsets.zero,
                constraints: BoxConstraints(minWidth: 28, minHeight: 28),
              ),
              const SizedBox(width: 10),
              Text(
                'Page $currentPage of $totalPages',
                style: TextStyle(
                  fontFamily: 'Literata',
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: Color(0xFF8D6748),
            ),
          ),
        ],
      ),
        ),
      ),
    );
  }

  TextStyle _tableHeaderStyle() {
    return const TextStyle(
      fontFamily: 'Literata',
      fontWeight: FontWeight.bold,
      fontSize: 16,
      color: Color(0xFF5D4037),
      letterSpacing: 1.1,
    );
  }

  TextStyle _tableCellStyle() {
    return const TextStyle(
      fontFamily: 'Literata',
      fontSize: 15,
      color: Color(0xFF4E342E),
    );
  }
} 