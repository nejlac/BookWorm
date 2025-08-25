import 'package:bookworm_desktop/layouts/master_screen.dart';
import 'package:bookworm_desktop/model/country.dart';
import 'package:bookworm_desktop/model/search_result.dart';
import 'package:bookworm_desktop/providers/country_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CountryList extends StatefulWidget {
  const CountryList({super.key});

  @override
  State<CountryList> createState() => _CountryListState();
}

class _CountryListState extends State<CountryList> {
  late CountryProvider countryProvider;
  SearchResult<Country>? countries;
  
  TextEditingController searchController = TextEditingController();

  int currentPage = 1;
  int pageSize = 10;
  int totalPages = 1;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    countryProvider = context.read<CountryProvider>();
    _fetchCountries();
  }

  Future<void> _fetchCountries({int? page}) async {
    try {
      var filter = {
        "Name": searchController.text,
        "page": (page ?? currentPage) - 1,
        "pageSize": pageSize,
        "includeTotalCount": true,
      };
      
      var countries = await countryProvider.get(filter: filter);
      setState(() {
        this.countries = countries;
        currentPage = (page ?? currentPage);
        totalPages = (countries.totalCount != null && pageSize > 0)
            ? ((countries.totalCount! + pageSize - 1) ~/ pageSize)
            : 1;
        if (currentPage > totalPages) currentPage = totalPages;
        if (currentPage < 1) currentPage = 1;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error fetching countries: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showAddEditDialog({Country? country}) {
    final isEditing = country != null;
    final nameController = TextEditingController(text: country?.name ?? '');
    String? nameError;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(isEditing ? 'Edit Country' : 'Add Country'),
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
                      // Check for duplicate name - fetch all countries to check
                      try {
                        final allCountries = await countryProvider.getAllCountries();
                        final items = allCountries.items;
                        if (items != null) {
                          final existingCountry = items.firstWhere(
                            (c) => c.name.toLowerCase() == nameController.text.trim().toLowerCase() && 
                                   (!isEditing || c.id != country!.id),
                            orElse: () => Country(id: -1, name: ''),
                          );
                          
                          if (existingCountry.id != -1) {
                            setDialogState(() {
                              nameError = 'A country with this name already exists';
                            });
                            hasError = true;
                          }
                        }
                      } catch (e) {
                        // If we can't fetch all countries, fall back to current page check
                        final items = countries?.items;
                        if (items != null) {
                          final existingCountry = items.firstWhere(
                            (c) => c.name.toLowerCase() == nameController.text.trim().toLowerCase() && 
                                   (!isEditing || c.id != country!.id),
                            orElse: () => Country(id: -1, name: ''),
                          );
                          
                          if (existingCountry.id != -1) {
                            setDialogState(() {
                              nameError = 'A country with this name already exists';
                            });
                            hasError = true;
                          }
                        }
                      }
                    }

                    if (hasError) return;

                    try {
                      if (isEditing) {
                        await countryProvider.updateCountry(
                          country!.id,
                          nameController.text.trim(),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Country updated successfully!'),
                            backgroundColor: Color(0xFF8D6748),
                          ),
                        );
                      } else {
                        await countryProvider.createCountry(
                          nameController.text.trim(),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Country created successfully!'),
                            backgroundColor: Color(0xFF8D6748),
                          ),
                        );
                      }
                      Navigator.of(context).pop();
                      _fetchCountries(page: 1); 
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
          const SizedBox(height: 16),
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
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          ElevatedButton.icon(
            onPressed: () => _showAddEditDialog(),
            icon: Icon(Icons.add, color: Colors.white),
            label: Text('Add Country', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: searchController,
                  decoration: InputDecoration(
                    labelText: 'Search countries...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Color(0xFF8D6748), width: 2),
                    ),
                    prefixIcon: Icon(Icons.search, color: Color(0xFF8D6748)),
                    suffixIcon: searchController.text.isNotEmpty
                        ? IconButton(
                            icon: Icon(Icons.clear, color: Colors.grey),
                            onPressed: () {
                              searchController.clear();
                              _fetchCountries(page: 1);
                            },
                          )
                        : null,
                  ),
                  style: TextStyle(fontSize: 16),
                  onSubmitted: (value) => _fetchCountries(page: 1),
                ),
              ),
              SizedBox(width: 16),
              ElevatedButton(
                onPressed: () => _fetchCountries(page: 1),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF8D6748),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
                child: Text(
                  'Search',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResultView() {
    final totalCount = countries?.totalCount ?? 0;
    final items = countries?.items ?? [];
    
    if (items.isEmpty && totalCount == 0) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.flag_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            SizedBox(height: 16),
            Text(
              'No countries found',
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
        constraints: BoxConstraints(maxWidth: 600),
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
                   Icon(Icons.flag, color: Colors.white, size: 24),
                   SizedBox(width: 12),
                   Text(
                     'Total: ${totalCount}',
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
                        'Actions',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF5D4037),
                        ),
                      ),
                    ),
                  ],
                  rows: items.map((country) {
                    return DataRow(
                      cells: [
                        DataCell(
                          Text(
                            country.id.toString(),
                            style: TextStyle(
                              color: Color(0xFF5D4037),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        DataCell(
                          Text(
                            country.name,
                            style: TextStyle(
                              color: Color(0xFF5D4037),
                              fontSize: 16,
                            ),
                          ),
                        ),
                        DataCell(
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(Icons.edit, color: Color(0xFF8D6748)),
                                onPressed: () => _showAddEditDialog(country: country),
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
                                          Text('Delete Country'),
                                        ],
                                      ),
                                      content: Text('Are you sure you want to delete "${country.name}"? This action cannot be undone.'),
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
                                    final errorMessage = await countryProvider.delete(country.id);
                                    if (errorMessage == null) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Row(
                                            children: [
                                              Icon(Icons.check_circle, color: Colors.white),
                                              SizedBox(width: 12),
                                              Text('Country deleted successfully.'),
                                            ],
                                          ),
                                          backgroundColor: Color(0xFF4CAF50),
                                          behavior: SnackBarBehavior.floating,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                        ),
                                      );
                                      _fetchCountries(page: 1);
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
                                                      'Cannot Delete Country',
                                                      style: TextStyle(fontWeight: FontWeight.bold),
                                                    ),
                                                    SizedBox(height: 4),
                                                    Text(
                                                      errorMessage,
                                                      style: TextStyle(fontSize: 12),
                                                    ),
                                                    SizedBox(height: 4),
                                                    Text(
                                                      'Please remove or change the country from all authors and users first.',
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
    if (totalPages <= 1) return SizedBox.shrink();
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: LayoutBuilder(
        builder: (context, constraints) {
          bool isSmallScreen = constraints.maxWidth < 600;
          int maxPageButtons = isSmallScreen ? 3 : 5;
          
          int startPage = (currentPage - (maxPageButtons ~/ 2)).clamp(1, (totalPages - maxPageButtons + 1).clamp(1, totalPages));
          int endPage = (startPage + maxPageButtons - 1).clamp(1, totalPages);
          List<int> pageNumbers = [for (int i = startPage; i <= endPage; i++) i];

          return Center(
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: isSmallScreen ? 12 : 20,
                vertical: isSmallScreen ? 8 : 12,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: Offset(0, 2),
                  ),
                ],
                border: Border.all(color: Color(0xFF8D6748).withOpacity(0.2), width: 1),
              ),
              child: Wrap(
                alignment: WrapAlignment.center,
                spacing: 4,
                runSpacing: 4,
                children: [
                  IconButton(
                    icon: Icon(Icons.first_page, size: 20, color: currentPage == 1 ? Colors.grey : Color(0xFF8D6748)),
                    tooltip: 'First Page',
                    onPressed: currentPage > 1 ? () => _fetchCountries(page: 1) : null,
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(minWidth: 32, minHeight: 32),
                  ),
                  IconButton(
                    icon: Icon(Icons.chevron_left, size: 20, color: currentPage == 1 ? Colors.grey : Color(0xFF8D6748)),
                    tooltip: 'Previous Page',
                    onPressed: currentPage > 1 ? () => _fetchCountries(page: currentPage - 1) : null,
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(minWidth: 32, minHeight: 32),
                  ),
                  ...pageNumbers.map((page) => ChoiceChip(
                    label: Text('$page', style: TextStyle(
                      fontFamily: 'Literata',
                      fontWeight: FontWeight.bold,
                      fontSize: isSmallScreen ? 12 : 14,
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
                    padding: EdgeInsets.symmetric(
                      horizontal: isSmallScreen ? 6 : 8,
                      vertical: 0,
                    ),
                    onSelected: (selected) {
                      if (page != currentPage) _fetchCountries(page: page);
                    },
                  )),
                  IconButton(
                    icon: Icon(Icons.chevron_right, size: 20, color: currentPage == totalPages ? Colors.grey : Color(0xFF8D6748)),
                    tooltip: 'Next Page',
                    onPressed: currentPage < totalPages ? () => _fetchCountries(page: currentPage + 1) : null,
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(minWidth: 32, minHeight: 32),
                  ),
                  IconButton(
                    icon: Icon(Icons.last_page, size: 20, color: currentPage == totalPages ? Colors.grey : Color(0xFF8D6748)),
                    tooltip: 'Last Page',
                    onPressed: currentPage < totalPages ? () => _fetchCountries(page: totalPages) : null,
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(minWidth: 32, minHeight: 32),
                  ),
                  if (!isSmallScreen) ...[
                    SizedBox(width: 16),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Color(0xFF8D6748).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Page $currentPage of $totalPages',
                        style: TextStyle(
                          fontFamily: 'Literata',
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: Color(0xFF8D6748),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
} 