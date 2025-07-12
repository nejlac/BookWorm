import 'package:bookworm_desktop/model/search_result.dart';
import 'package:bookworm_desktop/model/user.dart';
import 'package:bookworm_desktop/providers/country_provider.dart';
import 'package:bookworm_desktop/providers/user_provider.dart';
import 'package:bookworm_desktop/screens/user_details.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dropdown_search/dropdown_search.dart';

class UserList extends StatefulWidget {
  const UserList({super.key});

  @override
  State<UserList> createState() => _UserListState();
}

class _UserListState extends State<UserList> {
  late UserProvider userProvider;
  late CountryProvider countryProvider;

  TextEditingController nameController = TextEditingController();
  List<Map<String, dynamic>> countries = [];
  Map<String, dynamic>? selectedCountry;
  SearchResult<User>? users;

  int currentPage = 1;
  int pageSize = 10;
  int totalPages = 1;
  
  

    @override
  void didChangeDependencies() {
  
    super.didChangeDependencies();
    userProvider = context.read<UserProvider>();
    countryProvider = Provider.of<CountryProvider>(context, listen: false);
  
    _fetchAllUsers();
  
    _fetchCountries();
  }

  Future<void> _fetchAllUsers({int? page}) async {
    try {
      final filter = {
        "includeTotalCount": true,
        "username": nameController.text.isNotEmpty ? nameController.text : null,
        "countryId": selectedCountry?['id'] ?? null,
        "page": (page ?? currentPage) -1,
        "pageSize": pageSize,
        
      };
     
      users = await userProvider.get(filter: filter);
     
      setState(() {
        this.users = users;
       
      currentPage = (page ?? currentPage);
        if ( users!.totalCount != null && pageSize > 0) {
       totalPages = ((users!.totalCount! + pageSize - 1) ~/ pageSize);
       if (currentPage > totalPages) currentPage = totalPages;
      if (currentPage < 1) currentPage = 1;
  }
       
      });
    } catch (e) {
     
      debugPrint("Error fetching users: $e");
    }
  }

 Future<void> _fetchCountries() async {
    try {
      await countryProvider.fetchCountries();
      var loadedCountries = countryProvider.countries;
      setState(() {
        countries = [{'id': null, 'name': 'All'}];
        countries.addAll(loadedCountries.map((c) => {'id': c.id, 'name': c.name}));
        selectedCountry = countries.first;
      });
    } catch (e) {
      setState(() {
        countries = [{'id': null, 'name': 'All'}];
        selectedCountry = countries.first;
      });
      debugPrint('Failed to load countries: ' + e.toString());
    }
  }

  Future<void> _initCountries() async {
    try {
      print('Fetching countries...');
      await countryProvider.fetchCountries();
      countries =countryProvider.countries
          .map((c) => {'id': c.id, 'name': c.name})
          .toList();  
   
      setState(() {});
    } catch (e) {
      print('Failed to load countries: $e');
      countries = [];
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    countryProvider = Provider.of<CountryProvider>(context, listen: false);
  
    countries = [];
    selectedCountry = null;
  }
  
  @override
  Widget build(BuildContext context) {

    return Container(
      color: Colors.white,
      alignment: Alignment.center,
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 18),
            // Add User button at the top
            Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton.icon(
                    icon: Icon(Icons.person_add, color: Colors.white),
                    label: Text('Add User', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF8D6748),
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 4,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => UserDetails(isAddMode: true),
                        ),
                      ).then((value) {
                        if (value == true) _fetchAllUsers();
                      });
                    },
                  ),
                ],
              ),
            ),
            _buildSearch(),
            _buildResultView(),
            _buildPaginationControls(),
          ],
        ),
      ),
    );
  }
  
 
   Widget _buildSearch() {
    if (countries.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(16.0),
        child: Text(
          'No valid countries available',
          style: TextStyle(color: Colors.red, fontSize: 16, fontWeight: FontWeight.bold),
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.only(top: 0, bottom: 0),
      child: Center(
        child: Container(
          margin: const EdgeInsets.only(bottom: 8),
          constraints: const BoxConstraints(maxWidth: 900),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                flex: 2,
                child: TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Username',
                    border: OutlineInputBorder(),
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.book),
                      onPressed: () {},
                    ),
                  ),
                  style: const TextStyle(fontSize: 14),
                ),
              ),
              const SizedBox(width: 12),
              Flexible(
                flex: 2,
                child: DropdownSearch<Map<String, dynamic>>(
                  items: countries,
                  itemAsString: (c) => c['name'] ?? '',
                  selectedItem: selectedCountry,
                  dropdownDecoratorProps: DropDownDecoratorProps(
                    dropdownSearchDecoration: InputDecoration(
                      labelText: 'Country',
                      border: OutlineInputBorder(),
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                    ),
                  ),
                  popupProps: PopupProps.menu(
                    showSearchBox: true,
                    searchFieldProps: TextFieldProps(
                      decoration: InputDecoration(
                        labelText: 'Search country',
                        prefixIcon: Icon(Icons.search),
                      ),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      selectedCountry = value;
                    });
                  },
                  validator: (value) {
                    if (value == null) return 'Country is required';
                    return null;
                  },
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
                    _fetchAllUsers(page: 1);
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
    final totalCount = users?.totalCount ?? 0;
  
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxWidth: 1200),
        margin: const EdgeInsets.only(top: 0),
        padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 18,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (totalCount > 0)
                Container(
                  margin: const EdgeInsets.only(left: 12, bottom: 8, top: 0),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: Color(0xFFF6E3B4),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Color(0xFF8D6748), width: 1),
                  ),
                  child: Text(
                    'Total: $totalCount user${totalCount == 1 ? '' : 's'}',
                    style: const TextStyle(
                      fontFamily: 'Literata',
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Color(0xFF4E342E),
                    ),
                  ),
                ),
              DataTable(
                showCheckboxColumn: false,
                headingRowHeight: 48,
                dataRowHeight: 44,
                dividerThickness: 0.5,
                columnSpacing: 32,
                horizontalMargin: 16,
                columns: [
                   DataColumn(label: Text("User id", style: _tableHeaderStyle())),
                  DataColumn(label: Text("First name", style: _tableHeaderStyle())),
                  DataColumn(label: Text("Last name", style: _tableHeaderStyle())),
                  DataColumn(label: Text("Username", style: _tableHeaderStyle())),
                  DataColumn(label: Text("Country", style: _tableHeaderStyle())),
                  DataColumn(label: Text("Age", style: _tableHeaderStyle())),
                  DataColumn(label: Text("Email", style: _tableHeaderStyle())),
                  DataColumn(label: Icon(Icons.info_outline, color: Color(0xFF8D6748))),
                  DataColumn(label: Icon(Icons.edit, color: Color(0xFF8D6748))),
                  DataColumn(label: Icon(Icons.delete, color: Colors.red)),
                ],
                dataRowColor: MaterialStateProperty.resolveWith<Color?>((states) {
                  if (states.contains(MaterialState.selected)) {
                    return const Color(0xFFFFF8E1);
                  }
                  return Colors.white;
                }),
                headingRowColor: MaterialStateProperty.all(const Color(0xFFF6E3B4)),
                                rows: users?.items?.map((e) {
                                return DataRow(
                  onSelectChanged: (value) {},
                  cells: [
                      DataCell(Text(e.id.toString(), style: _tableCellStyle())),
                    DataCell(Text(e.firstName, style: _tableCellStyle())),
                    DataCell(Text(e.lastName, style: _tableCellStyle())),
                      DataCell(Text(e.username, style: _tableCellStyle())),
                     DataCell( Text(
                        countries.firstWhere(
                          (c) => c['id'] == e.countryId,
                          orElse: () => {'name': 'Unknown'},
                        )['name'] ?? 'Unknown',
                      )),
                    DataCell(Text(e.age.toString(), style: _tableCellStyle())),
                    DataCell(Text(e.email, style: _tableCellStyle())),
                    DataCell(IconButton(
                      icon: const Icon(Icons.info_outline, color: Color(0xFF8D6748)),
                      onPressed: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => UserDetails(user: e, isEditMode: false,),
                          ),
                        );
                        if (result == true) {
                          _fetchAllUsers();
                        }
                     },
                      splashRadius: 20,
                      tooltip: 'Details',
                    )),
                    DataCell(IconButton(
                      icon: const Icon(Icons.edit, color: Color(0xFF8D6748)),
                      onPressed: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => UserDetails(user: e, isEditMode: true,),
                          ),
                        );
                        if (result == true) {
                          _fetchAllUsers();
                        }
                      },
                      splashRadius: 20,
                      tooltip: 'Edit',
                    )),
                    DataCell(IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Delete User'),
                            content: const Text('Are you sure you want to delete this user?'),
                            actions: [
                              TextButton(
                                onPressed: () async {
                                  try {
                                    await userProvider.delete(e.id);
                                    Navigator.pop(context);
                                    _fetchAllUsers();
                                  } catch (error) {
                                    Navigator.pop(context);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Row(
                                          children: [
                                            Icon(Icons.error, color: Colors.white),
                                            SizedBox(width: 12),
                                            Text("Failed to delete user: "+error.toString()),
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
                                child: const Text('Delete'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Cancel'),
                              ),
                            ],
                          ),
                        );
                      },
                      splashRadius: 20,
                      tooltip: 'Delete',
                    )),
                  ],
                );
                }).toList() ?? [],
              ),
            ],
          ),
        ),
      ),
    );
  }

   Widget _buildPaginationControls() {
    if (totalPages <= 1) return SizedBox.shrink();
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
                onPressed: currentPage > 1 ? () => _fetchAllUsers(page: 1) : null,
                padding: EdgeInsets.zero,
                constraints: BoxConstraints(minWidth: 28, minHeight: 28),
              ),
              const SizedBox(width: 0),
              IconButton(
                icon: Icon(Icons.chevron_left, size: 20, color: currentPage == 1 ? Colors.grey : Color(0xFF8D6748)),
                tooltip: 'Previous Page',
                onPressed: currentPage > 1 ? () => _fetchAllUsers(page: currentPage - 1) : null,
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
                    if (page != currentPage) _fetchAllUsers(page: page);
                  },
                ),
              )),
              const SizedBox(width: 4),
              IconButton(
                icon: Icon(Icons.chevron_right, size: 20, color: currentPage == totalPages ? Colors.grey : Color(0xFF8D6748)),
                tooltip: 'Next Page',
                onPressed: currentPage < totalPages ? () => _fetchAllUsers(page: currentPage + 1) : null,
                padding: EdgeInsets.zero,
                constraints: BoxConstraints(minWidth: 28, minHeight: 28),
              ),
              const SizedBox(width: 0),
              IconButton(
                icon: Icon(Icons.last_page, size: 20, color: currentPage == totalPages ? Colors.grey : Color(0xFF8D6748)),
                tooltip: 'Last Page',
                onPressed: currentPage < totalPages ? () => _fetchAllUsers(page: totalPages) : null,
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
