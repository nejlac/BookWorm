class SearchResult<T> {
  int? totalCount;
  int? page;
  int? pageSize;
  List<T>? items;

  SearchResult({this.totalCount, this.page, this.pageSize, this.items});
}