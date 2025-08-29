import 'dart:developer';

import 'package:get/get.dart';
import 'constants/variable_status.dart';

abstract class Obs<T> {
  late Rx<VariableStatus> _status;
  VariableStatus get status => _status.value;
  set status(VariableStatus value) => _status.value = value;

  String? _error;
  String? get error => _error;
  set error(value) {
    _error = value;
    if (value != null) {
      status = VariableStatus.Error;
    }
  }

  Obs();

  /// Initialize the observable variable with Error state
  Obs.fromError(String error) {
    error = error;
  }

  bool get hasData => status == VariableStatus.HasData;
  bool get hasError => status == VariableStatus.Error;
  bool get loading => status == VariableStatus.Loading;

  refresh() => _status.refresh();
}

/// Use this to observing a Variable
/// Do not use it to observing a List
class ObsVar<T> extends Obs<T> {
  T? _value;

  ObsVar(T? val) {
    if (val is List) {
      throw 'use ObsList instead ObsVar';
    }
    _value = val;
    if (_value == null) {
      _status = (VariableStatus.Loading).obs;
    } else {
      _status = (VariableStatus.HasData).obs;
    }
  }

  ObsVar.fromError(super.error) : super.fromError();

  T? get value => _value;
  set value(val) {
    bool needRefresh = value != val;
    _value = val;
    if (_value == null) {
      status = VariableStatus.Loading;
    } else {
      status = VariableStatus.HasData;
    }
    if (needRefresh) refresh();
  }

  /// Reset the state to the initial state
  /// the value will be null and the state is loading
  void reset() {
    this._value = null;
    error = null;
    status = VariableStatus.Loading;
  }

  loger() {
    log('$_status');
    log('$_value');
    log(error!);
  }
}

class ObsList<T> extends Obs<T> {
  List<T>? _value;
  List<T>? get value => _value;

  set value(List<T>? value) {
    if (value == null) {
      status = VariableStatus.Loading;
    } else {
      status = VariableStatus.HasData;
      this._value = value;
      this.valueLength = value.length;
      refresh();
    }
  }

  RxInt? _valueLength;
  int get valueLength => this._valueLength!.value;
  set valueLength(value) => this._valueLength!.value = value;

  ObsList(List<T>? value) {
    this._value = value;
    if (_value == null || _value!.isEmpty) {
      _status = (VariableStatus.Loading).obs;
      _valueLength = 0.obs;
    } else {
      _status = (VariableStatus.HasData).obs;
      _valueLength = (value!.length).obs;
    }
  }

  ObsList.fromError(super.error) : super.fromError();

  T operator [](int index) => value![index];

  bool? get isEmpty => valueLength == 0;
  bool? get isNotEmpty => valueLength != 0;

  set valueAppend(List<T> value) {
    if (status != VariableStatus.HasData) {
      status = VariableStatus.HasData;
    }
    this._value = this._value! + value;
    if (this._value!.isEmpty && value.isNotEmpty) {
      _status = (VariableStatus.HasData).obs;
    }
    this.valueLength += value.length;
  }

  ObsList<T> operator +(List<T> value) {
    if (status != VariableStatus.HasData && this.isNotEmpty!) {
      status = VariableStatus.HasData;
      refresh();
    }
    this._value = this._value! + value;
    if (this._value!.isEmpty && value.isNotEmpty) {
      _status = (VariableStatus.HasData).obs;
    }
    this.valueLength += value.length;
    return this;
  }

  bool contains(bool Function(T e) condition) =>
      value!.indexWhere(condition) != -1;

  add(T value) {
    this._value!.add(value);
    this.valueLength++;
  }

  insert(int index, T element) {
    this.value!.insert(index, element);
    valueLength++;
  }

  remove(T value) {
    _value!.remove(value);
    valueLength--;
  }

  removeAt(int index) {
    assert(index < this.valueLength);
    this._value!.removeAt(index);
    this.valueLength--;
  }

  Iterable<T> where(bool Function(T element) test) => value!.where(test);

  T firstWhere(bool Function(T element) test) => value!.firstWhere(test);

  int indexWhere(bool Function(T element) test) => value!.indexWhere(test);

  int indexOf(T element, [int start = 0]) => value!.indexOf(element, start);

  T? removeWhere(bool Function(T element) condition) {
    T? removed;
    value!.removeWhere((element) {
      if (condition(element)) {
        removed = element;
        return true;
      } else {
        return false;
      }
    });
    valueLength = value!.length;
    return removed;
  }

  Iterable<TT> map<TT>(TT Function(T element) mapper) =>
      _value!.map<TT>(mapper);

  void forEach(void Function(T element) iterable) => value!.forEach(iterable);

  reset() {
    this._value = [];
    error = null;
    this.valueLength = 0;
    status = VariableStatus.Loading;
  }

  @override
  refresh() {
    super.refresh();
    _valueLength?.refresh();
  }

  logger() {
    log('********   start   *********');
    this._value?.forEach((element) => log('$element'));
    log('********    end    *********');
    log('length: $valueLength');
    log('error: $error');
  }
}
