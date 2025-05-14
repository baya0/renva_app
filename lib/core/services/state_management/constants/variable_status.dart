enum VariableStatus {
  loading,
  hasData,
  hasError,
  ;

  bool get isLoading => this == loading;
  bool get isHasData => this == hasData;
  bool get isHasError => this == hasError;
}
