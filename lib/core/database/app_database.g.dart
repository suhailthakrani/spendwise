// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $CategoriesTable extends Categories
    with TableInfo<$CategoriesTable, CategoryRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CategoriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
      'user_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('profile_main'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _iconNameMeta =
      const VerificationMeta('iconName');
  @override
  late final GeneratedColumn<String> iconName = GeneratedColumn<String>(
      'icon_name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _colorValueMeta =
      const VerificationMeta('colorValue');
  @override
  late final GeneratedColumn<int> colorValue = GeneratedColumn<int>(
      'color_value', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _isCustomMeta =
      const VerificationMeta('isCustom');
  @override
  late final GeneratedColumn<bool> isCustom = GeneratedColumn<bool>(
      'is_custom', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_custom" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _budgetLimitMeta =
      const VerificationMeta('budgetLimit');
  @override
  late final GeneratedColumn<double> budgetLimit = GeneratedColumn<double>(
      'budget_limit', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [id, userId, name, iconName, colorValue, isCustom, budgetLimit];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'categories';
  @override
  VerificationContext validateIntegrity(Insertable<CategoryRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta,
          userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('icon_name')) {
      context.handle(_iconNameMeta,
          iconName.isAcceptableOrUnknown(data['icon_name']!, _iconNameMeta));
    } else if (isInserting) {
      context.missing(_iconNameMeta);
    }
    if (data.containsKey('color_value')) {
      context.handle(
          _colorValueMeta,
          colorValue.isAcceptableOrUnknown(
              data['color_value']!, _colorValueMeta));
    } else if (isInserting) {
      context.missing(_colorValueMeta);
    }
    if (data.containsKey('is_custom')) {
      context.handle(_isCustomMeta,
          isCustom.isAcceptableOrUnknown(data['is_custom']!, _isCustomMeta));
    }
    if (data.containsKey('budget_limit')) {
      context.handle(
          _budgetLimitMeta,
          budgetLimit.isAcceptableOrUnknown(
              data['budget_limit']!, _budgetLimitMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  CategoryRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return CategoryRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      userId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}user_id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      iconName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}icon_name'])!,
      colorValue: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}color_value'])!,
      isCustom: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_custom'])!,
      budgetLimit: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}budget_limit']),
    );
  }

  @override
  $CategoriesTable createAlias(String alias) {
    return $CategoriesTable(attachedDatabase, alias);
  }
}

class CategoryRow extends DataClass implements Insertable<CategoryRow> {
  final String id;
  final String userId;
  final String name;
  final String iconName;
  final int colorValue;
  final bool isCustom;
  final double? budgetLimit;
  const CategoryRow(
      {required this.id,
      required this.userId,
      required this.name,
      required this.iconName,
      required this.colorValue,
      required this.isCustom,
      this.budgetLimit});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    map['name'] = Variable<String>(name);
    map['icon_name'] = Variable<String>(iconName);
    map['color_value'] = Variable<int>(colorValue);
    map['is_custom'] = Variable<bool>(isCustom);
    if (!nullToAbsent || budgetLimit != null) {
      map['budget_limit'] = Variable<double>(budgetLimit);
    }
    return map;
  }

  CategoriesCompanion toCompanion(bool nullToAbsent) {
    return CategoriesCompanion(
      id: Value(id),
      userId: Value(userId),
      name: Value(name),
      iconName: Value(iconName),
      colorValue: Value(colorValue),
      isCustom: Value(isCustom),
      budgetLimit: budgetLimit == null && nullToAbsent
          ? const Value.absent()
          : Value(budgetLimit),
    );
  }

  factory CategoryRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return CategoryRow(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      name: serializer.fromJson<String>(json['name']),
      iconName: serializer.fromJson<String>(json['iconName']),
      colorValue: serializer.fromJson<int>(json['colorValue']),
      isCustom: serializer.fromJson<bool>(json['isCustom']),
      budgetLimit: serializer.fromJson<double?>(json['budgetLimit']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'name': serializer.toJson<String>(name),
      'iconName': serializer.toJson<String>(iconName),
      'colorValue': serializer.toJson<int>(colorValue),
      'isCustom': serializer.toJson<bool>(isCustom),
      'budgetLimit': serializer.toJson<double?>(budgetLimit),
    };
  }

  CategoryRow copyWith(
          {String? id,
          String? userId,
          String? name,
          String? iconName,
          int? colorValue,
          bool? isCustom,
          Value<double?> budgetLimit = const Value.absent()}) =>
      CategoryRow(
        id: id ?? this.id,
        userId: userId ?? this.userId,
        name: name ?? this.name,
        iconName: iconName ?? this.iconName,
        colorValue: colorValue ?? this.colorValue,
        isCustom: isCustom ?? this.isCustom,
        budgetLimit: budgetLimit.present ? budgetLimit.value : this.budgetLimit,
      );
  CategoryRow copyWithCompanion(CategoriesCompanion data) {
    return CategoryRow(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      name: data.name.present ? data.name.value : this.name,
      iconName: data.iconName.present ? data.iconName.value : this.iconName,
      colorValue:
          data.colorValue.present ? data.colorValue.value : this.colorValue,
      isCustom: data.isCustom.present ? data.isCustom.value : this.isCustom,
      budgetLimit:
          data.budgetLimit.present ? data.budgetLimit.value : this.budgetLimit,
    );
  }

  @override
  String toString() {
    return (StringBuffer('CategoryRow(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('name: $name, ')
          ..write('iconName: $iconName, ')
          ..write('colorValue: $colorValue, ')
          ..write('isCustom: $isCustom, ')
          ..write('budgetLimit: $budgetLimit')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, userId, name, iconName, colorValue, isCustom, budgetLimit);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CategoryRow &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.name == this.name &&
          other.iconName == this.iconName &&
          other.colorValue == this.colorValue &&
          other.isCustom == this.isCustom &&
          other.budgetLimit == this.budgetLimit);
}

class CategoriesCompanion extends UpdateCompanion<CategoryRow> {
  final Value<String> id;
  final Value<String> userId;
  final Value<String> name;
  final Value<String> iconName;
  final Value<int> colorValue;
  final Value<bool> isCustom;
  final Value<double?> budgetLimit;
  final Value<int> rowid;
  const CategoriesCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.name = const Value.absent(),
    this.iconName = const Value.absent(),
    this.colorValue = const Value.absent(),
    this.isCustom = const Value.absent(),
    this.budgetLimit = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CategoriesCompanion.insert({
    required String id,
    this.userId = const Value.absent(),
    required String name,
    required String iconName,
    required int colorValue,
    this.isCustom = const Value.absent(),
    this.budgetLimit = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name),
        iconName = Value(iconName),
        colorValue = Value(colorValue);
  static Insertable<CategoryRow> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? name,
    Expression<String>? iconName,
    Expression<int>? colorValue,
    Expression<bool>? isCustom,
    Expression<double>? budgetLimit,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (name != null) 'name': name,
      if (iconName != null) 'icon_name': iconName,
      if (colorValue != null) 'color_value': colorValue,
      if (isCustom != null) 'is_custom': isCustom,
      if (budgetLimit != null) 'budget_limit': budgetLimit,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CategoriesCompanion copyWith(
      {Value<String>? id,
      Value<String>? userId,
      Value<String>? name,
      Value<String>? iconName,
      Value<int>? colorValue,
      Value<bool>? isCustom,
      Value<double?>? budgetLimit,
      Value<int>? rowid}) {
    return CategoriesCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      iconName: iconName ?? this.iconName,
      colorValue: colorValue ?? this.colorValue,
      isCustom: isCustom ?? this.isCustom,
      budgetLimit: budgetLimit ?? this.budgetLimit,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (iconName.present) {
      map['icon_name'] = Variable<String>(iconName.value);
    }
    if (colorValue.present) {
      map['color_value'] = Variable<int>(colorValue.value);
    }
    if (isCustom.present) {
      map['is_custom'] = Variable<bool>(isCustom.value);
    }
    if (budgetLimit.present) {
      map['budget_limit'] = Variable<double>(budgetLimit.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CategoriesCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('name: $name, ')
          ..write('iconName: $iconName, ')
          ..write('colorValue: $colorValue, ')
          ..write('isCustom: $isCustom, ')
          ..write('budgetLimit: $budgetLimit, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ExpensesTable extends Expenses
    with TableInfo<$ExpensesTable, ExpenseRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExpensesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
      'user_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('profile_main'));
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
      'amount', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _categoryIdMeta =
      const VerificationMeta('categoryId');
  @override
  late final GeneratedColumn<String> categoryId = GeneratedColumn<String>(
      'category_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES categories (id)'));
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
      'note', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
      'date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _paymentMethodMeta =
      const VerificationMeta('paymentMethod');
  @override
  late final GeneratedColumn<String> paymentMethod = GeneratedColumn<String>(
      'payment_method', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _isRecurringMeta =
      const VerificationMeta('isRecurring');
  @override
  late final GeneratedColumn<bool> isRecurring = GeneratedColumn<bool>(
      'is_recurring', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("is_recurring" IN (0, 1))'),
      defaultValue: const Constant(false));
  @override
  List<GeneratedColumn> get $columns =>
      [id, userId, amount, categoryId, note, date, paymentMethod, isRecurring];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'expenses';
  @override
  VerificationContext validateIntegrity(Insertable<ExpenseRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta,
          userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    }
    if (data.containsKey('amount')) {
      context.handle(_amountMeta,
          amount.isAcceptableOrUnknown(data['amount']!, _amountMeta));
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('category_id')) {
      context.handle(
          _categoryIdMeta,
          categoryId.isAcceptableOrUnknown(
              data['category_id']!, _categoryIdMeta));
    } else if (isInserting) {
      context.missing(_categoryIdMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
          _noteMeta, note.isAcceptableOrUnknown(data['note']!, _noteMeta));
    }
    if (data.containsKey('date')) {
      context.handle(
          _dateMeta, date.isAcceptableOrUnknown(data['date']!, _dateMeta));
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('payment_method')) {
      context.handle(
          _paymentMethodMeta,
          paymentMethod.isAcceptableOrUnknown(
              data['payment_method']!, _paymentMethodMeta));
    } else if (isInserting) {
      context.missing(_paymentMethodMeta);
    }
    if (data.containsKey('is_recurring')) {
      context.handle(
          _isRecurringMeta,
          isRecurring.isAcceptableOrUnknown(
              data['is_recurring']!, _isRecurringMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ExpenseRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ExpenseRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      userId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}user_id'])!,
      amount: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}amount'])!,
      categoryId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}category_id'])!,
      note: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}note'])!,
      date: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}date'])!,
      paymentMethod: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}payment_method'])!,
      isRecurring: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_recurring'])!,
    );
  }

  @override
  $ExpensesTable createAlias(String alias) {
    return $ExpensesTable(attachedDatabase, alias);
  }
}

class ExpenseRow extends DataClass implements Insertable<ExpenseRow> {
  final String id;
  final String userId;
  final double amount;
  final String categoryId;
  final String note;
  final DateTime date;
  final String paymentMethod;
  final bool isRecurring;
  const ExpenseRow(
      {required this.id,
      required this.userId,
      required this.amount,
      required this.categoryId,
      required this.note,
      required this.date,
      required this.paymentMethod,
      required this.isRecurring});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    map['amount'] = Variable<double>(amount);
    map['category_id'] = Variable<String>(categoryId);
    map['note'] = Variable<String>(note);
    map['date'] = Variable<DateTime>(date);
    map['payment_method'] = Variable<String>(paymentMethod);
    map['is_recurring'] = Variable<bool>(isRecurring);
    return map;
  }

  ExpensesCompanion toCompanion(bool nullToAbsent) {
    return ExpensesCompanion(
      id: Value(id),
      userId: Value(userId),
      amount: Value(amount),
      categoryId: Value(categoryId),
      note: Value(note),
      date: Value(date),
      paymentMethod: Value(paymentMethod),
      isRecurring: Value(isRecurring),
    );
  }

  factory ExpenseRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ExpenseRow(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      amount: serializer.fromJson<double>(json['amount']),
      categoryId: serializer.fromJson<String>(json['categoryId']),
      note: serializer.fromJson<String>(json['note']),
      date: serializer.fromJson<DateTime>(json['date']),
      paymentMethod: serializer.fromJson<String>(json['paymentMethod']),
      isRecurring: serializer.fromJson<bool>(json['isRecurring']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'amount': serializer.toJson<double>(amount),
      'categoryId': serializer.toJson<String>(categoryId),
      'note': serializer.toJson<String>(note),
      'date': serializer.toJson<DateTime>(date),
      'paymentMethod': serializer.toJson<String>(paymentMethod),
      'isRecurring': serializer.toJson<bool>(isRecurring),
    };
  }

  ExpenseRow copyWith(
          {String? id,
          String? userId,
          double? amount,
          String? categoryId,
          String? note,
          DateTime? date,
          String? paymentMethod,
          bool? isRecurring}) =>
      ExpenseRow(
        id: id ?? this.id,
        userId: userId ?? this.userId,
        amount: amount ?? this.amount,
        categoryId: categoryId ?? this.categoryId,
        note: note ?? this.note,
        date: date ?? this.date,
        paymentMethod: paymentMethod ?? this.paymentMethod,
        isRecurring: isRecurring ?? this.isRecurring,
      );
  ExpenseRow copyWithCompanion(ExpensesCompanion data) {
    return ExpenseRow(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      amount: data.amount.present ? data.amount.value : this.amount,
      categoryId:
          data.categoryId.present ? data.categoryId.value : this.categoryId,
      note: data.note.present ? data.note.value : this.note,
      date: data.date.present ? data.date.value : this.date,
      paymentMethod: data.paymentMethod.present
          ? data.paymentMethod.value
          : this.paymentMethod,
      isRecurring:
          data.isRecurring.present ? data.isRecurring.value : this.isRecurring,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ExpenseRow(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('amount: $amount, ')
          ..write('categoryId: $categoryId, ')
          ..write('note: $note, ')
          ..write('date: $date, ')
          ..write('paymentMethod: $paymentMethod, ')
          ..write('isRecurring: $isRecurring')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, userId, amount, categoryId, note, date, paymentMethod, isRecurring);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ExpenseRow &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.amount == this.amount &&
          other.categoryId == this.categoryId &&
          other.note == this.note &&
          other.date == this.date &&
          other.paymentMethod == this.paymentMethod &&
          other.isRecurring == this.isRecurring);
}

class ExpensesCompanion extends UpdateCompanion<ExpenseRow> {
  final Value<String> id;
  final Value<String> userId;
  final Value<double> amount;
  final Value<String> categoryId;
  final Value<String> note;
  final Value<DateTime> date;
  final Value<String> paymentMethod;
  final Value<bool> isRecurring;
  final Value<int> rowid;
  const ExpensesCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.amount = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.note = const Value.absent(),
    this.date = const Value.absent(),
    this.paymentMethod = const Value.absent(),
    this.isRecurring = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ExpensesCompanion.insert({
    required String id,
    this.userId = const Value.absent(),
    required double amount,
    required String categoryId,
    this.note = const Value.absent(),
    required DateTime date,
    required String paymentMethod,
    this.isRecurring = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        amount = Value(amount),
        categoryId = Value(categoryId),
        date = Value(date),
        paymentMethod = Value(paymentMethod);
  static Insertable<ExpenseRow> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<double>? amount,
    Expression<String>? categoryId,
    Expression<String>? note,
    Expression<DateTime>? date,
    Expression<String>? paymentMethod,
    Expression<bool>? isRecurring,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (amount != null) 'amount': amount,
      if (categoryId != null) 'category_id': categoryId,
      if (note != null) 'note': note,
      if (date != null) 'date': date,
      if (paymentMethod != null) 'payment_method': paymentMethod,
      if (isRecurring != null) 'is_recurring': isRecurring,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ExpensesCompanion copyWith(
      {Value<String>? id,
      Value<String>? userId,
      Value<double>? amount,
      Value<String>? categoryId,
      Value<String>? note,
      Value<DateTime>? date,
      Value<String>? paymentMethod,
      Value<bool>? isRecurring,
      Value<int>? rowid}) {
    return ExpensesCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      amount: amount ?? this.amount,
      categoryId: categoryId ?? this.categoryId,
      note: note ?? this.note,
      date: date ?? this.date,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      isRecurring: isRecurring ?? this.isRecurring,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<String>(categoryId.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (paymentMethod.present) {
      map['payment_method'] = Variable<String>(paymentMethod.value);
    }
    if (isRecurring.present) {
      map['is_recurring'] = Variable<bool>(isRecurring.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExpensesCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('amount: $amount, ')
          ..write('categoryId: $categoryId, ')
          ..write('note: $note, ')
          ..write('date: $date, ')
          ..write('paymentMethod: $paymentMethod, ')
          ..write('isRecurring: $isRecurring, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $BudgetsTable extends Budgets with TableInfo<$BudgetsTable, BudgetRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BudgetsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
      'user_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('profile_main'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _limitAmountMeta =
      const VerificationMeta('limitAmount');
  @override
  late final GeneratedColumn<double> limitAmount = GeneratedColumn<double>(
      'limit_amount', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _categoryIdMeta =
      const VerificationMeta('categoryId');
  @override
  late final GeneratedColumn<String> categoryId = GeneratedColumn<String>(
      'category_id', aliasedName, true,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES categories (id)'));
  static const VerificationMeta _isMonthlyMeta =
      const VerificationMeta('isMonthly');
  @override
  late final GeneratedColumn<bool> isMonthly = GeneratedColumn<bool>(
      'is_monthly', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_monthly" IN (0, 1))'),
      defaultValue: const Constant(true));
  @override
  List<GeneratedColumn> get $columns =>
      [id, userId, name, limitAmount, categoryId, isMonthly];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'budgets';
  @override
  VerificationContext validateIntegrity(Insertable<BudgetRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta,
          userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('limit_amount')) {
      context.handle(
          _limitAmountMeta,
          limitAmount.isAcceptableOrUnknown(
              data['limit_amount']!, _limitAmountMeta));
    } else if (isInserting) {
      context.missing(_limitAmountMeta);
    }
    if (data.containsKey('category_id')) {
      context.handle(
          _categoryIdMeta,
          categoryId.isAcceptableOrUnknown(
              data['category_id']!, _categoryIdMeta));
    }
    if (data.containsKey('is_monthly')) {
      context.handle(_isMonthlyMeta,
          isMonthly.isAcceptableOrUnknown(data['is_monthly']!, _isMonthlyMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  BudgetRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BudgetRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      userId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}user_id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      limitAmount: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}limit_amount'])!,
      categoryId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}category_id']),
      isMonthly: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_monthly'])!,
    );
  }

  @override
  $BudgetsTable createAlias(String alias) {
    return $BudgetsTable(attachedDatabase, alias);
  }
}

class BudgetRow extends DataClass implements Insertable<BudgetRow> {
  final String id;
  final String userId;
  final String name;
  final double limitAmount;
  final String? categoryId;
  final bool isMonthly;
  const BudgetRow(
      {required this.id,
      required this.userId,
      required this.name,
      required this.limitAmount,
      this.categoryId,
      required this.isMonthly});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    map['name'] = Variable<String>(name);
    map['limit_amount'] = Variable<double>(limitAmount);
    if (!nullToAbsent || categoryId != null) {
      map['category_id'] = Variable<String>(categoryId);
    }
    map['is_monthly'] = Variable<bool>(isMonthly);
    return map;
  }

  BudgetsCompanion toCompanion(bool nullToAbsent) {
    return BudgetsCompanion(
      id: Value(id),
      userId: Value(userId),
      name: Value(name),
      limitAmount: Value(limitAmount),
      categoryId: categoryId == null && nullToAbsent
          ? const Value.absent()
          : Value(categoryId),
      isMonthly: Value(isMonthly),
    );
  }

  factory BudgetRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BudgetRow(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      name: serializer.fromJson<String>(json['name']),
      limitAmount: serializer.fromJson<double>(json['limitAmount']),
      categoryId: serializer.fromJson<String?>(json['categoryId']),
      isMonthly: serializer.fromJson<bool>(json['isMonthly']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'name': serializer.toJson<String>(name),
      'limitAmount': serializer.toJson<double>(limitAmount),
      'categoryId': serializer.toJson<String?>(categoryId),
      'isMonthly': serializer.toJson<bool>(isMonthly),
    };
  }

  BudgetRow copyWith(
          {String? id,
          String? userId,
          String? name,
          double? limitAmount,
          Value<String?> categoryId = const Value.absent(),
          bool? isMonthly}) =>
      BudgetRow(
        id: id ?? this.id,
        userId: userId ?? this.userId,
        name: name ?? this.name,
        limitAmount: limitAmount ?? this.limitAmount,
        categoryId: categoryId.present ? categoryId.value : this.categoryId,
        isMonthly: isMonthly ?? this.isMonthly,
      );
  BudgetRow copyWithCompanion(BudgetsCompanion data) {
    return BudgetRow(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      name: data.name.present ? data.name.value : this.name,
      limitAmount:
          data.limitAmount.present ? data.limitAmount.value : this.limitAmount,
      categoryId:
          data.categoryId.present ? data.categoryId.value : this.categoryId,
      isMonthly: data.isMonthly.present ? data.isMonthly.value : this.isMonthly,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BudgetRow(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('name: $name, ')
          ..write('limitAmount: $limitAmount, ')
          ..write('categoryId: $categoryId, ')
          ..write('isMonthly: $isMonthly')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, userId, name, limitAmount, categoryId, isMonthly);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BudgetRow &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.name == this.name &&
          other.limitAmount == this.limitAmount &&
          other.categoryId == this.categoryId &&
          other.isMonthly == this.isMonthly);
}

class BudgetsCompanion extends UpdateCompanion<BudgetRow> {
  final Value<String> id;
  final Value<String> userId;
  final Value<String> name;
  final Value<double> limitAmount;
  final Value<String?> categoryId;
  final Value<bool> isMonthly;
  final Value<int> rowid;
  const BudgetsCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.name = const Value.absent(),
    this.limitAmount = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.isMonthly = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BudgetsCompanion.insert({
    required String id,
    this.userId = const Value.absent(),
    required String name,
    required double limitAmount,
    this.categoryId = const Value.absent(),
    this.isMonthly = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name),
        limitAmount = Value(limitAmount);
  static Insertable<BudgetRow> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? name,
    Expression<double>? limitAmount,
    Expression<String>? categoryId,
    Expression<bool>? isMonthly,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (name != null) 'name': name,
      if (limitAmount != null) 'limit_amount': limitAmount,
      if (categoryId != null) 'category_id': categoryId,
      if (isMonthly != null) 'is_monthly': isMonthly,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BudgetsCompanion copyWith(
      {Value<String>? id,
      Value<String>? userId,
      Value<String>? name,
      Value<double>? limitAmount,
      Value<String?>? categoryId,
      Value<bool>? isMonthly,
      Value<int>? rowid}) {
    return BudgetsCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      limitAmount: limitAmount ?? this.limitAmount,
      categoryId: categoryId ?? this.categoryId,
      isMonthly: isMonthly ?? this.isMonthly,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (limitAmount.present) {
      map['limit_amount'] = Variable<double>(limitAmount.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<String>(categoryId.value);
    }
    if (isMonthly.present) {
      map['is_monthly'] = Variable<bool>(isMonthly.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BudgetsCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('name: $name, ')
          ..write('limitAmount: $limitAmount, ')
          ..write('categoryId: $categoryId, ')
          ..write('isMonthly: $isMonthly, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $RecurringExpensesTable extends RecurringExpenses
    with TableInfo<$RecurringExpensesTable, RecurringExpenseRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $RecurringExpensesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
      'user_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('profile_main'));
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
      'amount', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _categoryIdMeta =
      const VerificationMeta('categoryId');
  @override
  late final GeneratedColumn<String> categoryId = GeneratedColumn<String>(
      'category_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES categories (id)'));
  static const VerificationMeta _frequencyMeta =
      const VerificationMeta('frequency');
  @override
  late final GeneratedColumn<String> frequency = GeneratedColumn<String>(
      'frequency', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nextDueDateMeta =
      const VerificationMeta('nextDueDate');
  @override
  late final GeneratedColumn<DateTime> nextDueDate = GeneratedColumn<DateTime>(
      'next_due_date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _paymentMethodMeta =
      const VerificationMeta('paymentMethod');
  @override
  late final GeneratedColumn<String> paymentMethod = GeneratedColumn<String>(
      'payment_method', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        userId,
        title,
        amount,
        categoryId,
        frequency,
        nextDueDate,
        paymentMethod
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'recurring_expenses';
  @override
  VerificationContext validateIntegrity(
      Insertable<RecurringExpenseRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta,
          userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(_amountMeta,
          amount.isAcceptableOrUnknown(data['amount']!, _amountMeta));
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('category_id')) {
      context.handle(
          _categoryIdMeta,
          categoryId.isAcceptableOrUnknown(
              data['category_id']!, _categoryIdMeta));
    } else if (isInserting) {
      context.missing(_categoryIdMeta);
    }
    if (data.containsKey('frequency')) {
      context.handle(_frequencyMeta,
          frequency.isAcceptableOrUnknown(data['frequency']!, _frequencyMeta));
    } else if (isInserting) {
      context.missing(_frequencyMeta);
    }
    if (data.containsKey('next_due_date')) {
      context.handle(
          _nextDueDateMeta,
          nextDueDate.isAcceptableOrUnknown(
              data['next_due_date']!, _nextDueDateMeta));
    } else if (isInserting) {
      context.missing(_nextDueDateMeta);
    }
    if (data.containsKey('payment_method')) {
      context.handle(
          _paymentMethodMeta,
          paymentMethod.isAcceptableOrUnknown(
              data['payment_method']!, _paymentMethodMeta));
    } else if (isInserting) {
      context.missing(_paymentMethodMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  RecurringExpenseRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return RecurringExpenseRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      userId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}user_id'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title'])!,
      amount: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}amount'])!,
      categoryId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}category_id'])!,
      frequency: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}frequency'])!,
      nextDueDate: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}next_due_date'])!,
      paymentMethod: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}payment_method'])!,
    );
  }

  @override
  $RecurringExpensesTable createAlias(String alias) {
    return $RecurringExpensesTable(attachedDatabase, alias);
  }
}

class RecurringExpenseRow extends DataClass
    implements Insertable<RecurringExpenseRow> {
  final String id;
  final String userId;
  final String title;
  final double amount;
  final String categoryId;
  final String frequency;
  final DateTime nextDueDate;
  final String paymentMethod;
  const RecurringExpenseRow(
      {required this.id,
      required this.userId,
      required this.title,
      required this.amount,
      required this.categoryId,
      required this.frequency,
      required this.nextDueDate,
      required this.paymentMethod});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    map['title'] = Variable<String>(title);
    map['amount'] = Variable<double>(amount);
    map['category_id'] = Variable<String>(categoryId);
    map['frequency'] = Variable<String>(frequency);
    map['next_due_date'] = Variable<DateTime>(nextDueDate);
    map['payment_method'] = Variable<String>(paymentMethod);
    return map;
  }

  RecurringExpensesCompanion toCompanion(bool nullToAbsent) {
    return RecurringExpensesCompanion(
      id: Value(id),
      userId: Value(userId),
      title: Value(title),
      amount: Value(amount),
      categoryId: Value(categoryId),
      frequency: Value(frequency),
      nextDueDate: Value(nextDueDate),
      paymentMethod: Value(paymentMethod),
    );
  }

  factory RecurringExpenseRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return RecurringExpenseRow(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      title: serializer.fromJson<String>(json['title']),
      amount: serializer.fromJson<double>(json['amount']),
      categoryId: serializer.fromJson<String>(json['categoryId']),
      frequency: serializer.fromJson<String>(json['frequency']),
      nextDueDate: serializer.fromJson<DateTime>(json['nextDueDate']),
      paymentMethod: serializer.fromJson<String>(json['paymentMethod']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'title': serializer.toJson<String>(title),
      'amount': serializer.toJson<double>(amount),
      'categoryId': serializer.toJson<String>(categoryId),
      'frequency': serializer.toJson<String>(frequency),
      'nextDueDate': serializer.toJson<DateTime>(nextDueDate),
      'paymentMethod': serializer.toJson<String>(paymentMethod),
    };
  }

  RecurringExpenseRow copyWith(
          {String? id,
          String? userId,
          String? title,
          double? amount,
          String? categoryId,
          String? frequency,
          DateTime? nextDueDate,
          String? paymentMethod}) =>
      RecurringExpenseRow(
        id: id ?? this.id,
        userId: userId ?? this.userId,
        title: title ?? this.title,
        amount: amount ?? this.amount,
        categoryId: categoryId ?? this.categoryId,
        frequency: frequency ?? this.frequency,
        nextDueDate: nextDueDate ?? this.nextDueDate,
        paymentMethod: paymentMethod ?? this.paymentMethod,
      );
  RecurringExpenseRow copyWithCompanion(RecurringExpensesCompanion data) {
    return RecurringExpenseRow(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      title: data.title.present ? data.title.value : this.title,
      amount: data.amount.present ? data.amount.value : this.amount,
      categoryId:
          data.categoryId.present ? data.categoryId.value : this.categoryId,
      frequency: data.frequency.present ? data.frequency.value : this.frequency,
      nextDueDate:
          data.nextDueDate.present ? data.nextDueDate.value : this.nextDueDate,
      paymentMethod: data.paymentMethod.present
          ? data.paymentMethod.value
          : this.paymentMethod,
    );
  }

  @override
  String toString() {
    return (StringBuffer('RecurringExpenseRow(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('title: $title, ')
          ..write('amount: $amount, ')
          ..write('categoryId: $categoryId, ')
          ..write('frequency: $frequency, ')
          ..write('nextDueDate: $nextDueDate, ')
          ..write('paymentMethod: $paymentMethod')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, userId, title, amount, categoryId,
      frequency, nextDueDate, paymentMethod);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is RecurringExpenseRow &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.title == this.title &&
          other.amount == this.amount &&
          other.categoryId == this.categoryId &&
          other.frequency == this.frequency &&
          other.nextDueDate == this.nextDueDate &&
          other.paymentMethod == this.paymentMethod);
}

class RecurringExpensesCompanion extends UpdateCompanion<RecurringExpenseRow> {
  final Value<String> id;
  final Value<String> userId;
  final Value<String> title;
  final Value<double> amount;
  final Value<String> categoryId;
  final Value<String> frequency;
  final Value<DateTime> nextDueDate;
  final Value<String> paymentMethod;
  final Value<int> rowid;
  const RecurringExpensesCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.title = const Value.absent(),
    this.amount = const Value.absent(),
    this.categoryId = const Value.absent(),
    this.frequency = const Value.absent(),
    this.nextDueDate = const Value.absent(),
    this.paymentMethod = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  RecurringExpensesCompanion.insert({
    required String id,
    this.userId = const Value.absent(),
    required String title,
    required double amount,
    required String categoryId,
    required String frequency,
    required DateTime nextDueDate,
    required String paymentMethod,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        title = Value(title),
        amount = Value(amount),
        categoryId = Value(categoryId),
        frequency = Value(frequency),
        nextDueDate = Value(nextDueDate),
        paymentMethod = Value(paymentMethod);
  static Insertable<RecurringExpenseRow> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? title,
    Expression<double>? amount,
    Expression<String>? categoryId,
    Expression<String>? frequency,
    Expression<DateTime>? nextDueDate,
    Expression<String>? paymentMethod,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (title != null) 'title': title,
      if (amount != null) 'amount': amount,
      if (categoryId != null) 'category_id': categoryId,
      if (frequency != null) 'frequency': frequency,
      if (nextDueDate != null) 'next_due_date': nextDueDate,
      if (paymentMethod != null) 'payment_method': paymentMethod,
      if (rowid != null) 'rowid': rowid,
    });
  }

  RecurringExpensesCompanion copyWith(
      {Value<String>? id,
      Value<String>? userId,
      Value<String>? title,
      Value<double>? amount,
      Value<String>? categoryId,
      Value<String>? frequency,
      Value<DateTime>? nextDueDate,
      Value<String>? paymentMethod,
      Value<int>? rowid}) {
    return RecurringExpensesCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      categoryId: categoryId ?? this.categoryId,
      frequency: frequency ?? this.frequency,
      nextDueDate: nextDueDate ?? this.nextDueDate,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (categoryId.present) {
      map['category_id'] = Variable<String>(categoryId.value);
    }
    if (frequency.present) {
      map['frequency'] = Variable<String>(frequency.value);
    }
    if (nextDueDate.present) {
      map['next_due_date'] = Variable<DateTime>(nextDueDate.value);
    }
    if (paymentMethod.present) {
      map['payment_method'] = Variable<String>(paymentMethod.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('RecurringExpensesCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('title: $title, ')
          ..write('amount: $amount, ')
          ..write('categoryId: $categoryId, ')
          ..write('frequency: $frequency, ')
          ..write('nextDueDate: $nextDueDate, ')
          ..write('paymentMethod: $paymentMethod, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AppPreferencesTable extends AppPreferences
    with TableInfo<$AppPreferencesTable, PreferencesRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppPreferencesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _themeModeMeta =
      const VerificationMeta('themeMode');
  @override
  late final GeneratedColumn<String> themeMode = GeneratedColumn<String>(
      'theme_mode', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _hasCompletedOnboardingMeta =
      const VerificationMeta('hasCompletedOnboarding');
  @override
  late final GeneratedColumn<bool> hasCompletedOnboarding =
      GeneratedColumn<bool>('has_completed_onboarding', aliasedName, false,
          type: DriftSqlType.bool,
          requiredDuringInsert: false,
          defaultConstraints: GeneratedColumn.constraintIsAlways(
              'CHECK ("has_completed_onboarding" IN (0, 1))'),
          defaultValue: const Constant(false));
  static const VerificationMeta _activeUserIdMeta =
      const VerificationMeta('activeUserId');
  @override
  late final GeneratedColumn<String> activeUserId = GeneratedColumn<String>(
      'active_user_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _notificationsEnabledMeta =
      const VerificationMeta('notificationsEnabled');
  @override
  late final GeneratedColumn<bool> notificationsEnabled = GeneratedColumn<bool>(
      'notifications_enabled', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("notifications_enabled" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _billRemindersEnabledMeta =
      const VerificationMeta('billRemindersEnabled');
  @override
  late final GeneratedColumn<bool> billRemindersEnabled = GeneratedColumn<bool>(
      'bill_reminders_enabled', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("bill_reminders_enabled" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _budgetAlertsEnabledMeta =
      const VerificationMeta('budgetAlertsEnabled');
  @override
  late final GeneratedColumn<bool> budgetAlertsEnabled = GeneratedColumn<bool>(
      'budget_alerts_enabled', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("budget_alerts_enabled" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _goalRemindersEnabledMeta =
      const VerificationMeta('goalRemindersEnabled');
  @override
  late final GeneratedColumn<bool> goalRemindersEnabled = GeneratedColumn<bool>(
      'goal_reminders_enabled', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("goal_reminders_enabled" IN (0, 1))'),
      defaultValue: const Constant(true));
  static const VerificationMeta _productUpdatesEnabledMeta =
      const VerificationMeta('productUpdatesEnabled');
  @override
  late final GeneratedColumn<bool> productUpdatesEnabled =
      GeneratedColumn<bool>('product_updates_enabled', aliasedName, false,
          type: DriftSqlType.bool,
          requiredDuringInsert: false,
          defaultConstraints: GeneratedColumn.constraintIsAlways(
              'CHECK ("product_updates_enabled" IN (0, 1))'),
          defaultValue: const Constant(false));
  static const VerificationMeta _backupDriveEmailMeta =
      const VerificationMeta('backupDriveEmail');
  @override
  late final GeneratedColumn<String> backupDriveEmail = GeneratedColumn<String>(
      'backup_drive_email', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _lastBackupAtMeta =
      const VerificationMeta('lastBackupAt');
  @override
  late final GeneratedColumn<DateTime> lastBackupAt = GeneratedColumn<DateTime>(
      'last_backup_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _backupDriveFileIdMeta =
      const VerificationMeta('backupDriveFileId');
  @override
  late final GeneratedColumn<String> backupDriveFileId =
      GeneratedColumn<String>('backup_drive_file_id', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _biometricUnlockEnabledMeta =
      const VerificationMeta('biometricUnlockEnabled');
  @override
  late final GeneratedColumn<bool> biometricUnlockEnabled =
      GeneratedColumn<bool>('biometric_unlock_enabled', aliasedName, false,
          type: DriftSqlType.bool,
          requiredDuringInsert: false,
          defaultConstraints: GeneratedColumn.constraintIsAlways(
              'CHECK ("biometric_unlock_enabled" IN (0, 1))'),
          defaultValue: const Constant(false));
  static const VerificationMeta _biometricUserIdMeta =
      const VerificationMeta('biometricUserId');
  @override
  late final GeneratedColumn<String> biometricUserId = GeneratedColumn<String>(
      'biometric_user_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        themeMode,
        hasCompletedOnboarding,
        activeUserId,
        notificationsEnabled,
        billRemindersEnabled,
        budgetAlertsEnabled,
        goalRemindersEnabled,
        productUpdatesEnabled,
        backupDriveEmail,
        lastBackupAt,
        backupDriveFileId,
        biometricUnlockEnabled,
        biometricUserId
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_preferences';
  @override
  VerificationContext validateIntegrity(Insertable<PreferencesRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('theme_mode')) {
      context.handle(_themeModeMeta,
          themeMode.isAcceptableOrUnknown(data['theme_mode']!, _themeModeMeta));
    } else if (isInserting) {
      context.missing(_themeModeMeta);
    }
    if (data.containsKey('has_completed_onboarding')) {
      context.handle(
          _hasCompletedOnboardingMeta,
          hasCompletedOnboarding.isAcceptableOrUnknown(
              data['has_completed_onboarding']!, _hasCompletedOnboardingMeta));
    }
    if (data.containsKey('active_user_id')) {
      context.handle(
          _activeUserIdMeta,
          activeUserId.isAcceptableOrUnknown(
              data['active_user_id']!, _activeUserIdMeta));
    }
    if (data.containsKey('notifications_enabled')) {
      context.handle(
          _notificationsEnabledMeta,
          notificationsEnabled.isAcceptableOrUnknown(
              data['notifications_enabled']!, _notificationsEnabledMeta));
    }
    if (data.containsKey('bill_reminders_enabled')) {
      context.handle(
          _billRemindersEnabledMeta,
          billRemindersEnabled.isAcceptableOrUnknown(
              data['bill_reminders_enabled']!, _billRemindersEnabledMeta));
    }
    if (data.containsKey('budget_alerts_enabled')) {
      context.handle(
          _budgetAlertsEnabledMeta,
          budgetAlertsEnabled.isAcceptableOrUnknown(
              data['budget_alerts_enabled']!, _budgetAlertsEnabledMeta));
    }
    if (data.containsKey('goal_reminders_enabled')) {
      context.handle(
          _goalRemindersEnabledMeta,
          goalRemindersEnabled.isAcceptableOrUnknown(
              data['goal_reminders_enabled']!, _goalRemindersEnabledMeta));
    }
    if (data.containsKey('product_updates_enabled')) {
      context.handle(
          _productUpdatesEnabledMeta,
          productUpdatesEnabled.isAcceptableOrUnknown(
              data['product_updates_enabled']!, _productUpdatesEnabledMeta));
    }
    if (data.containsKey('backup_drive_email')) {
      context.handle(
          _backupDriveEmailMeta,
          backupDriveEmail.isAcceptableOrUnknown(
              data['backup_drive_email']!, _backupDriveEmailMeta));
    }
    if (data.containsKey('last_backup_at')) {
      context.handle(
          _lastBackupAtMeta,
          lastBackupAt.isAcceptableOrUnknown(
              data['last_backup_at']!, _lastBackupAtMeta));
    }
    if (data.containsKey('backup_drive_file_id')) {
      context.handle(
          _backupDriveFileIdMeta,
          backupDriveFileId.isAcceptableOrUnknown(
              data['backup_drive_file_id']!, _backupDriveFileIdMeta));
    }
    if (data.containsKey('biometric_unlock_enabled')) {
      context.handle(
          _biometricUnlockEnabledMeta,
          biometricUnlockEnabled.isAcceptableOrUnknown(
              data['biometric_unlock_enabled']!, _biometricUnlockEnabledMeta));
    }
    if (data.containsKey('biometric_user_id')) {
      context.handle(
          _biometricUserIdMeta,
          biometricUserId.isAcceptableOrUnknown(
              data['biometric_user_id']!, _biometricUserIdMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PreferencesRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PreferencesRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      themeMode: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}theme_mode'])!,
      hasCompletedOnboarding: attachedDatabase.typeMapping.read(
          DriftSqlType.bool,
          data['${effectivePrefix}has_completed_onboarding'])!,
      activeUserId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}active_user_id']),
      notificationsEnabled: attachedDatabase.typeMapping.read(
          DriftSqlType.bool, data['${effectivePrefix}notifications_enabled'])!,
      billRemindersEnabled: attachedDatabase.typeMapping.read(
          DriftSqlType.bool, data['${effectivePrefix}bill_reminders_enabled'])!,
      budgetAlertsEnabled: attachedDatabase.typeMapping.read(
          DriftSqlType.bool, data['${effectivePrefix}budget_alerts_enabled'])!,
      goalRemindersEnabled: attachedDatabase.typeMapping.read(
          DriftSqlType.bool, data['${effectivePrefix}goal_reminders_enabled'])!,
      productUpdatesEnabled: attachedDatabase.typeMapping.read(
          DriftSqlType.bool,
          data['${effectivePrefix}product_updates_enabled'])!,
      backupDriveEmail: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}backup_drive_email']),
      lastBackupAt: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}last_backup_at']),
      backupDriveFileId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}backup_drive_file_id']),
      biometricUnlockEnabled: attachedDatabase.typeMapping.read(
          DriftSqlType.bool,
          data['${effectivePrefix}biometric_unlock_enabled'])!,
      biometricUserId: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}biometric_user_id']),
    );
  }

  @override
  $AppPreferencesTable createAlias(String alias) {
    return $AppPreferencesTable(attachedDatabase, alias);
  }
}

class PreferencesRow extends DataClass implements Insertable<PreferencesRow> {
  final int id;
  final String themeMode;
  final bool hasCompletedOnboarding;
  final String? activeUserId;
  final bool notificationsEnabled;
  final bool billRemindersEnabled;
  final bool budgetAlertsEnabled;
  final bool goalRemindersEnabled;
  final bool productUpdatesEnabled;
  final String? backupDriveEmail;
  final DateTime? lastBackupAt;
  final String? backupDriveFileId;
  final bool biometricUnlockEnabled;
  final String? biometricUserId;
  const PreferencesRow(
      {required this.id,
      required this.themeMode,
      required this.hasCompletedOnboarding,
      this.activeUserId,
      required this.notificationsEnabled,
      required this.billRemindersEnabled,
      required this.budgetAlertsEnabled,
      required this.goalRemindersEnabled,
      required this.productUpdatesEnabled,
      this.backupDriveEmail,
      this.lastBackupAt,
      this.backupDriveFileId,
      required this.biometricUnlockEnabled,
      this.biometricUserId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['theme_mode'] = Variable<String>(themeMode);
    map['has_completed_onboarding'] = Variable<bool>(hasCompletedOnboarding);
    if (!nullToAbsent || activeUserId != null) {
      map['active_user_id'] = Variable<String>(activeUserId);
    }
    map['notifications_enabled'] = Variable<bool>(notificationsEnabled);
    map['bill_reminders_enabled'] = Variable<bool>(billRemindersEnabled);
    map['budget_alerts_enabled'] = Variable<bool>(budgetAlertsEnabled);
    map['goal_reminders_enabled'] = Variable<bool>(goalRemindersEnabled);
    map['product_updates_enabled'] = Variable<bool>(productUpdatesEnabled);
    if (!nullToAbsent || backupDriveEmail != null) {
      map['backup_drive_email'] = Variable<String>(backupDriveEmail);
    }
    if (!nullToAbsent || lastBackupAt != null) {
      map['last_backup_at'] = Variable<DateTime>(lastBackupAt);
    }
    if (!nullToAbsent || backupDriveFileId != null) {
      map['backup_drive_file_id'] = Variable<String>(backupDriveFileId);
    }
    map['biometric_unlock_enabled'] = Variable<bool>(biometricUnlockEnabled);
    if (!nullToAbsent || biometricUserId != null) {
      map['biometric_user_id'] = Variable<String>(biometricUserId);
    }
    return map;
  }

  AppPreferencesCompanion toCompanion(bool nullToAbsent) {
    return AppPreferencesCompanion(
      id: Value(id),
      themeMode: Value(themeMode),
      hasCompletedOnboarding: Value(hasCompletedOnboarding),
      activeUserId: activeUserId == null && nullToAbsent
          ? const Value.absent()
          : Value(activeUserId),
      notificationsEnabled: Value(notificationsEnabled),
      billRemindersEnabled: Value(billRemindersEnabled),
      budgetAlertsEnabled: Value(budgetAlertsEnabled),
      goalRemindersEnabled: Value(goalRemindersEnabled),
      productUpdatesEnabled: Value(productUpdatesEnabled),
      backupDriveEmail: backupDriveEmail == null && nullToAbsent
          ? const Value.absent()
          : Value(backupDriveEmail),
      lastBackupAt: lastBackupAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastBackupAt),
      backupDriveFileId: backupDriveFileId == null && nullToAbsent
          ? const Value.absent()
          : Value(backupDriveFileId),
      biometricUnlockEnabled: Value(biometricUnlockEnabled),
      biometricUserId: biometricUserId == null && nullToAbsent
          ? const Value.absent()
          : Value(biometricUserId),
    );
  }

  factory PreferencesRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PreferencesRow(
      id: serializer.fromJson<int>(json['id']),
      themeMode: serializer.fromJson<String>(json['themeMode']),
      hasCompletedOnboarding:
          serializer.fromJson<bool>(json['hasCompletedOnboarding']),
      activeUserId: serializer.fromJson<String?>(json['activeUserId']),
      notificationsEnabled:
          serializer.fromJson<bool>(json['notificationsEnabled']),
      billRemindersEnabled:
          serializer.fromJson<bool>(json['billRemindersEnabled']),
      budgetAlertsEnabled:
          serializer.fromJson<bool>(json['budgetAlertsEnabled']),
      goalRemindersEnabled:
          serializer.fromJson<bool>(json['goalRemindersEnabled']),
      productUpdatesEnabled:
          serializer.fromJson<bool>(json['productUpdatesEnabled']),
      backupDriveEmail: serializer.fromJson<String?>(json['backupDriveEmail']),
      lastBackupAt: serializer.fromJson<DateTime?>(json['lastBackupAt']),
      backupDriveFileId:
          serializer.fromJson<String?>(json['backupDriveFileId']),
      biometricUnlockEnabled:
          serializer.fromJson<bool>(json['biometricUnlockEnabled']),
      biometricUserId: serializer.fromJson<String?>(json['biometricUserId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'themeMode': serializer.toJson<String>(themeMode),
      'hasCompletedOnboarding': serializer.toJson<bool>(hasCompletedOnboarding),
      'activeUserId': serializer.toJson<String?>(activeUserId),
      'notificationsEnabled': serializer.toJson<bool>(notificationsEnabled),
      'billRemindersEnabled': serializer.toJson<bool>(billRemindersEnabled),
      'budgetAlertsEnabled': serializer.toJson<bool>(budgetAlertsEnabled),
      'goalRemindersEnabled': serializer.toJson<bool>(goalRemindersEnabled),
      'productUpdatesEnabled': serializer.toJson<bool>(productUpdatesEnabled),
      'backupDriveEmail': serializer.toJson<String?>(backupDriveEmail),
      'lastBackupAt': serializer.toJson<DateTime?>(lastBackupAt),
      'backupDriveFileId': serializer.toJson<String?>(backupDriveFileId),
      'biometricUnlockEnabled': serializer.toJson<bool>(biometricUnlockEnabled),
      'biometricUserId': serializer.toJson<String?>(biometricUserId),
    };
  }

  PreferencesRow copyWith(
          {int? id,
          String? themeMode,
          bool? hasCompletedOnboarding,
          Value<String?> activeUserId = const Value.absent(),
          bool? notificationsEnabled,
          bool? billRemindersEnabled,
          bool? budgetAlertsEnabled,
          bool? goalRemindersEnabled,
          bool? productUpdatesEnabled,
          Value<String?> backupDriveEmail = const Value.absent(),
          Value<DateTime?> lastBackupAt = const Value.absent(),
          Value<String?> backupDriveFileId = const Value.absent(),
          bool? biometricUnlockEnabled,
          Value<String?> biometricUserId = const Value.absent()}) =>
      PreferencesRow(
        id: id ?? this.id,
        themeMode: themeMode ?? this.themeMode,
        hasCompletedOnboarding:
            hasCompletedOnboarding ?? this.hasCompletedOnboarding,
        activeUserId:
            activeUserId.present ? activeUserId.value : this.activeUserId,
        notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
        billRemindersEnabled: billRemindersEnabled ?? this.billRemindersEnabled,
        budgetAlertsEnabled: budgetAlertsEnabled ?? this.budgetAlertsEnabled,
        goalRemindersEnabled: goalRemindersEnabled ?? this.goalRemindersEnabled,
        productUpdatesEnabled:
            productUpdatesEnabled ?? this.productUpdatesEnabled,
        backupDriveEmail: backupDriveEmail.present
            ? backupDriveEmail.value
            : this.backupDriveEmail,
        lastBackupAt:
            lastBackupAt.present ? lastBackupAt.value : this.lastBackupAt,
        backupDriveFileId: backupDriveFileId.present
            ? backupDriveFileId.value
            : this.backupDriveFileId,
        biometricUnlockEnabled:
            biometricUnlockEnabled ?? this.biometricUnlockEnabled,
        biometricUserId: biometricUserId.present
            ? biometricUserId.value
            : this.biometricUserId,
      );
  PreferencesRow copyWithCompanion(AppPreferencesCompanion data) {
    return PreferencesRow(
      id: data.id.present ? data.id.value : this.id,
      themeMode: data.themeMode.present ? data.themeMode.value : this.themeMode,
      hasCompletedOnboarding: data.hasCompletedOnboarding.present
          ? data.hasCompletedOnboarding.value
          : this.hasCompletedOnboarding,
      activeUserId: data.activeUserId.present
          ? data.activeUserId.value
          : this.activeUserId,
      notificationsEnabled: data.notificationsEnabled.present
          ? data.notificationsEnabled.value
          : this.notificationsEnabled,
      billRemindersEnabled: data.billRemindersEnabled.present
          ? data.billRemindersEnabled.value
          : this.billRemindersEnabled,
      budgetAlertsEnabled: data.budgetAlertsEnabled.present
          ? data.budgetAlertsEnabled.value
          : this.budgetAlertsEnabled,
      goalRemindersEnabled: data.goalRemindersEnabled.present
          ? data.goalRemindersEnabled.value
          : this.goalRemindersEnabled,
      productUpdatesEnabled: data.productUpdatesEnabled.present
          ? data.productUpdatesEnabled.value
          : this.productUpdatesEnabled,
      backupDriveEmail: data.backupDriveEmail.present
          ? data.backupDriveEmail.value
          : this.backupDriveEmail,
      lastBackupAt: data.lastBackupAt.present
          ? data.lastBackupAt.value
          : this.lastBackupAt,
      backupDriveFileId: data.backupDriveFileId.present
          ? data.backupDriveFileId.value
          : this.backupDriveFileId,
      biometricUnlockEnabled: data.biometricUnlockEnabled.present
          ? data.biometricUnlockEnabled.value
          : this.biometricUnlockEnabled,
      biometricUserId: data.biometricUserId.present
          ? data.biometricUserId.value
          : this.biometricUserId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PreferencesRow(')
          ..write('id: $id, ')
          ..write('themeMode: $themeMode, ')
          ..write('hasCompletedOnboarding: $hasCompletedOnboarding, ')
          ..write('activeUserId: $activeUserId, ')
          ..write('notificationsEnabled: $notificationsEnabled, ')
          ..write('billRemindersEnabled: $billRemindersEnabled, ')
          ..write('budgetAlertsEnabled: $budgetAlertsEnabled, ')
          ..write('goalRemindersEnabled: $goalRemindersEnabled, ')
          ..write('productUpdatesEnabled: $productUpdatesEnabled, ')
          ..write('backupDriveEmail: $backupDriveEmail, ')
          ..write('lastBackupAt: $lastBackupAt, ')
          ..write('backupDriveFileId: $backupDriveFileId, ')
          ..write('biometricUnlockEnabled: $biometricUnlockEnabled, ')
          ..write('biometricUserId: $biometricUserId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      themeMode,
      hasCompletedOnboarding,
      activeUserId,
      notificationsEnabled,
      billRemindersEnabled,
      budgetAlertsEnabled,
      goalRemindersEnabled,
      productUpdatesEnabled,
      backupDriveEmail,
      lastBackupAt,
      backupDriveFileId,
      biometricUnlockEnabled,
      biometricUserId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PreferencesRow &&
          other.id == this.id &&
          other.themeMode == this.themeMode &&
          other.hasCompletedOnboarding == this.hasCompletedOnboarding &&
          other.activeUserId == this.activeUserId &&
          other.notificationsEnabled == this.notificationsEnabled &&
          other.billRemindersEnabled == this.billRemindersEnabled &&
          other.budgetAlertsEnabled == this.budgetAlertsEnabled &&
          other.goalRemindersEnabled == this.goalRemindersEnabled &&
          other.productUpdatesEnabled == this.productUpdatesEnabled &&
          other.backupDriveEmail == this.backupDriveEmail &&
          other.lastBackupAt == this.lastBackupAt &&
          other.backupDriveFileId == this.backupDriveFileId &&
          other.biometricUnlockEnabled == this.biometricUnlockEnabled &&
          other.biometricUserId == this.biometricUserId);
}

class AppPreferencesCompanion extends UpdateCompanion<PreferencesRow> {
  final Value<int> id;
  final Value<String> themeMode;
  final Value<bool> hasCompletedOnboarding;
  final Value<String?> activeUserId;
  final Value<bool> notificationsEnabled;
  final Value<bool> billRemindersEnabled;
  final Value<bool> budgetAlertsEnabled;
  final Value<bool> goalRemindersEnabled;
  final Value<bool> productUpdatesEnabled;
  final Value<String?> backupDriveEmail;
  final Value<DateTime?> lastBackupAt;
  final Value<String?> backupDriveFileId;
  final Value<bool> biometricUnlockEnabled;
  final Value<String?> biometricUserId;
  const AppPreferencesCompanion({
    this.id = const Value.absent(),
    this.themeMode = const Value.absent(),
    this.hasCompletedOnboarding = const Value.absent(),
    this.activeUserId = const Value.absent(),
    this.notificationsEnabled = const Value.absent(),
    this.billRemindersEnabled = const Value.absent(),
    this.budgetAlertsEnabled = const Value.absent(),
    this.goalRemindersEnabled = const Value.absent(),
    this.productUpdatesEnabled = const Value.absent(),
    this.backupDriveEmail = const Value.absent(),
    this.lastBackupAt = const Value.absent(),
    this.backupDriveFileId = const Value.absent(),
    this.biometricUnlockEnabled = const Value.absent(),
    this.biometricUserId = const Value.absent(),
  });
  AppPreferencesCompanion.insert({
    this.id = const Value.absent(),
    required String themeMode,
    this.hasCompletedOnboarding = const Value.absent(),
    this.activeUserId = const Value.absent(),
    this.notificationsEnabled = const Value.absent(),
    this.billRemindersEnabled = const Value.absent(),
    this.budgetAlertsEnabled = const Value.absent(),
    this.goalRemindersEnabled = const Value.absent(),
    this.productUpdatesEnabled = const Value.absent(),
    this.backupDriveEmail = const Value.absent(),
    this.lastBackupAt = const Value.absent(),
    this.backupDriveFileId = const Value.absent(),
    this.biometricUnlockEnabled = const Value.absent(),
    this.biometricUserId = const Value.absent(),
  }) : themeMode = Value(themeMode);
  static Insertable<PreferencesRow> custom({
    Expression<int>? id,
    Expression<String>? themeMode,
    Expression<bool>? hasCompletedOnboarding,
    Expression<String>? activeUserId,
    Expression<bool>? notificationsEnabled,
    Expression<bool>? billRemindersEnabled,
    Expression<bool>? budgetAlertsEnabled,
    Expression<bool>? goalRemindersEnabled,
    Expression<bool>? productUpdatesEnabled,
    Expression<String>? backupDriveEmail,
    Expression<DateTime>? lastBackupAt,
    Expression<String>? backupDriveFileId,
    Expression<bool>? biometricUnlockEnabled,
    Expression<String>? biometricUserId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (themeMode != null) 'theme_mode': themeMode,
      if (hasCompletedOnboarding != null)
        'has_completed_onboarding': hasCompletedOnboarding,
      if (activeUserId != null) 'active_user_id': activeUserId,
      if (notificationsEnabled != null)
        'notifications_enabled': notificationsEnabled,
      if (billRemindersEnabled != null)
        'bill_reminders_enabled': billRemindersEnabled,
      if (budgetAlertsEnabled != null)
        'budget_alerts_enabled': budgetAlertsEnabled,
      if (goalRemindersEnabled != null)
        'goal_reminders_enabled': goalRemindersEnabled,
      if (productUpdatesEnabled != null)
        'product_updates_enabled': productUpdatesEnabled,
      if (backupDriveEmail != null) 'backup_drive_email': backupDriveEmail,
      if (lastBackupAt != null) 'last_backup_at': lastBackupAt,
      if (backupDriveFileId != null) 'backup_drive_file_id': backupDriveFileId,
      if (biometricUnlockEnabled != null)
        'biometric_unlock_enabled': biometricUnlockEnabled,
      if (biometricUserId != null) 'biometric_user_id': biometricUserId,
    });
  }

  AppPreferencesCompanion copyWith(
      {Value<int>? id,
      Value<String>? themeMode,
      Value<bool>? hasCompletedOnboarding,
      Value<String?>? activeUserId,
      Value<bool>? notificationsEnabled,
      Value<bool>? billRemindersEnabled,
      Value<bool>? budgetAlertsEnabled,
      Value<bool>? goalRemindersEnabled,
      Value<bool>? productUpdatesEnabled,
      Value<String?>? backupDriveEmail,
      Value<DateTime?>? lastBackupAt,
      Value<String?>? backupDriveFileId,
      Value<bool>? biometricUnlockEnabled,
      Value<String?>? biometricUserId}) {
    return AppPreferencesCompanion(
      id: id ?? this.id,
      themeMode: themeMode ?? this.themeMode,
      hasCompletedOnboarding:
          hasCompletedOnboarding ?? this.hasCompletedOnboarding,
      activeUserId: activeUserId ?? this.activeUserId,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      billRemindersEnabled: billRemindersEnabled ?? this.billRemindersEnabled,
      budgetAlertsEnabled: budgetAlertsEnabled ?? this.budgetAlertsEnabled,
      goalRemindersEnabled: goalRemindersEnabled ?? this.goalRemindersEnabled,
      productUpdatesEnabled:
          productUpdatesEnabled ?? this.productUpdatesEnabled,
      backupDriveEmail: backupDriveEmail ?? this.backupDriveEmail,
      lastBackupAt: lastBackupAt ?? this.lastBackupAt,
      backupDriveFileId: backupDriveFileId ?? this.backupDriveFileId,
      biometricUnlockEnabled:
          biometricUnlockEnabled ?? this.biometricUnlockEnabled,
      biometricUserId: biometricUserId ?? this.biometricUserId,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (themeMode.present) {
      map['theme_mode'] = Variable<String>(themeMode.value);
    }
    if (hasCompletedOnboarding.present) {
      map['has_completed_onboarding'] =
          Variable<bool>(hasCompletedOnboarding.value);
    }
    if (activeUserId.present) {
      map['active_user_id'] = Variable<String>(activeUserId.value);
    }
    if (notificationsEnabled.present) {
      map['notifications_enabled'] = Variable<bool>(notificationsEnabled.value);
    }
    if (billRemindersEnabled.present) {
      map['bill_reminders_enabled'] =
          Variable<bool>(billRemindersEnabled.value);
    }
    if (budgetAlertsEnabled.present) {
      map['budget_alerts_enabled'] = Variable<bool>(budgetAlertsEnabled.value);
    }
    if (goalRemindersEnabled.present) {
      map['goal_reminders_enabled'] =
          Variable<bool>(goalRemindersEnabled.value);
    }
    if (productUpdatesEnabled.present) {
      map['product_updates_enabled'] =
          Variable<bool>(productUpdatesEnabled.value);
    }
    if (backupDriveEmail.present) {
      map['backup_drive_email'] = Variable<String>(backupDriveEmail.value);
    }
    if (lastBackupAt.present) {
      map['last_backup_at'] = Variable<DateTime>(lastBackupAt.value);
    }
    if (backupDriveFileId.present) {
      map['backup_drive_file_id'] = Variable<String>(backupDriveFileId.value);
    }
    if (biometricUnlockEnabled.present) {
      map['biometric_unlock_enabled'] =
          Variable<bool>(biometricUnlockEnabled.value);
    }
    if (biometricUserId.present) {
      map['biometric_user_id'] = Variable<String>(biometricUserId.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppPreferencesCompanion(')
          ..write('id: $id, ')
          ..write('themeMode: $themeMode, ')
          ..write('hasCompletedOnboarding: $hasCompletedOnboarding, ')
          ..write('activeUserId: $activeUserId, ')
          ..write('notificationsEnabled: $notificationsEnabled, ')
          ..write('billRemindersEnabled: $billRemindersEnabled, ')
          ..write('budgetAlertsEnabled: $budgetAlertsEnabled, ')
          ..write('goalRemindersEnabled: $goalRemindersEnabled, ')
          ..write('productUpdatesEnabled: $productUpdatesEnabled, ')
          ..write('backupDriveEmail: $backupDriveEmail, ')
          ..write('lastBackupAt: $lastBackupAt, ')
          ..write('backupDriveFileId: $backupDriveFileId, ')
          ..write('biometricUnlockEnabled: $biometricUnlockEnabled, ')
          ..write('biometricUserId: $biometricUserId')
          ..write(')'))
        .toString();
  }
}

class $UserProfilesTable extends UserProfiles
    with TableInfo<$UserProfilesTable, UserProfileRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserProfilesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
      'email', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _passwordHashMeta =
      const VerificationMeta('passwordHash');
  @override
  late final GeneratedColumn<String> passwordHash = GeneratedColumn<String>(
      'password_hash', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _passwordSaltMeta =
      const VerificationMeta('passwordSalt');
  @override
  late final GeneratedColumn<String> passwordSalt = GeneratedColumn<String>(
      'password_salt', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _regionCodeMeta =
      const VerificationMeta('regionCode');
  @override
  late final GeneratedColumn<String> regionCode = GeneratedColumn<String>(
      'region_code', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('US'));
  static const VerificationMeta _currencyCodeMeta =
      const VerificationMeta('currencyCode');
  @override
  late final GeneratedColumn<String> currencyCode = GeneratedColumn<String>(
      'currency_code', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('USD'));
  static const VerificationMeta _avatarUrlMeta =
      const VerificationMeta('avatarUrl');
  @override
  late final GeneratedColumn<String> avatarUrl = GeneratedColumn<String>(
      'avatar_url', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _googleIdMeta =
      const VerificationMeta('googleId');
  @override
  late final GeneratedColumn<String> googleId = GeneratedColumn<String>(
      'google_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _memberSinceMeta =
      const VerificationMeta('memberSince');
  @override
  late final GeneratedColumn<DateTime> memberSince = GeneratedColumn<DateTime>(
      'member_since', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        name,
        email,
        passwordHash,
        passwordSalt,
        regionCode,
        currencyCode,
        avatarUrl,
        googleId,
        memberSince
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_profiles';
  @override
  VerificationContext validateIntegrity(Insertable<UserProfileRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('email')) {
      context.handle(
          _emailMeta, email.isAcceptableOrUnknown(data['email']!, _emailMeta));
    } else if (isInserting) {
      context.missing(_emailMeta);
    }
    if (data.containsKey('password_hash')) {
      context.handle(
          _passwordHashMeta,
          passwordHash.isAcceptableOrUnknown(
              data['password_hash']!, _passwordHashMeta));
    }
    if (data.containsKey('password_salt')) {
      context.handle(
          _passwordSaltMeta,
          passwordSalt.isAcceptableOrUnknown(
              data['password_salt']!, _passwordSaltMeta));
    }
    if (data.containsKey('region_code')) {
      context.handle(
          _regionCodeMeta,
          regionCode.isAcceptableOrUnknown(
              data['region_code']!, _regionCodeMeta));
    }
    if (data.containsKey('currency_code')) {
      context.handle(
          _currencyCodeMeta,
          currencyCode.isAcceptableOrUnknown(
              data['currency_code']!, _currencyCodeMeta));
    }
    if (data.containsKey('avatar_url')) {
      context.handle(_avatarUrlMeta,
          avatarUrl.isAcceptableOrUnknown(data['avatar_url']!, _avatarUrlMeta));
    }
    if (data.containsKey('google_id')) {
      context.handle(_googleIdMeta,
          googleId.isAcceptableOrUnknown(data['google_id']!, _googleIdMeta));
    }
    if (data.containsKey('member_since')) {
      context.handle(
          _memberSinceMeta,
          memberSince.isAcceptableOrUnknown(
              data['member_since']!, _memberSinceMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  UserProfileRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserProfileRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      email: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}email'])!,
      passwordHash: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}password_hash'])!,
      passwordSalt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}password_salt'])!,
      regionCode: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}region_code'])!,
      currencyCode: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}currency_code'])!,
      avatarUrl: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}avatar_url']),
      googleId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}google_id']),
      memberSince: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}member_since']),
    );
  }

  @override
  $UserProfilesTable createAlias(String alias) {
    return $UserProfilesTable(attachedDatabase, alias);
  }
}

class UserProfileRow extends DataClass implements Insertable<UserProfileRow> {
  final String id;
  final String name;
  final String email;
  final String passwordHash;
  final String passwordSalt;
  final String regionCode;
  final String currencyCode;
  final String? avatarUrl;
  final String? googleId;
  final DateTime? memberSince;
  const UserProfileRow(
      {required this.id,
      required this.name,
      required this.email,
      required this.passwordHash,
      required this.passwordSalt,
      required this.regionCode,
      required this.currencyCode,
      this.avatarUrl,
      this.googleId,
      this.memberSince});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['email'] = Variable<String>(email);
    map['password_hash'] = Variable<String>(passwordHash);
    map['password_salt'] = Variable<String>(passwordSalt);
    map['region_code'] = Variable<String>(regionCode);
    map['currency_code'] = Variable<String>(currencyCode);
    if (!nullToAbsent || avatarUrl != null) {
      map['avatar_url'] = Variable<String>(avatarUrl);
    }
    if (!nullToAbsent || googleId != null) {
      map['google_id'] = Variable<String>(googleId);
    }
    if (!nullToAbsent || memberSince != null) {
      map['member_since'] = Variable<DateTime>(memberSince);
    }
    return map;
  }

  UserProfilesCompanion toCompanion(bool nullToAbsent) {
    return UserProfilesCompanion(
      id: Value(id),
      name: Value(name),
      email: Value(email),
      passwordHash: Value(passwordHash),
      passwordSalt: Value(passwordSalt),
      regionCode: Value(regionCode),
      currencyCode: Value(currencyCode),
      avatarUrl: avatarUrl == null && nullToAbsent
          ? const Value.absent()
          : Value(avatarUrl),
      googleId: googleId == null && nullToAbsent
          ? const Value.absent()
          : Value(googleId),
      memberSince: memberSince == null && nullToAbsent
          ? const Value.absent()
          : Value(memberSince),
    );
  }

  factory UserProfileRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserProfileRow(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      email: serializer.fromJson<String>(json['email']),
      passwordHash: serializer.fromJson<String>(json['passwordHash']),
      passwordSalt: serializer.fromJson<String>(json['passwordSalt']),
      regionCode: serializer.fromJson<String>(json['regionCode']),
      currencyCode: serializer.fromJson<String>(json['currencyCode']),
      avatarUrl: serializer.fromJson<String?>(json['avatarUrl']),
      googleId: serializer.fromJson<String?>(json['googleId']),
      memberSince: serializer.fromJson<DateTime?>(json['memberSince']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'email': serializer.toJson<String>(email),
      'passwordHash': serializer.toJson<String>(passwordHash),
      'passwordSalt': serializer.toJson<String>(passwordSalt),
      'regionCode': serializer.toJson<String>(regionCode),
      'currencyCode': serializer.toJson<String>(currencyCode),
      'avatarUrl': serializer.toJson<String?>(avatarUrl),
      'googleId': serializer.toJson<String?>(googleId),
      'memberSince': serializer.toJson<DateTime?>(memberSince),
    };
  }

  UserProfileRow copyWith(
          {String? id,
          String? name,
          String? email,
          String? passwordHash,
          String? passwordSalt,
          String? regionCode,
          String? currencyCode,
          Value<String?> avatarUrl = const Value.absent(),
          Value<String?> googleId = const Value.absent(),
          Value<DateTime?> memberSince = const Value.absent()}) =>
      UserProfileRow(
        id: id ?? this.id,
        name: name ?? this.name,
        email: email ?? this.email,
        passwordHash: passwordHash ?? this.passwordHash,
        passwordSalt: passwordSalt ?? this.passwordSalt,
        regionCode: regionCode ?? this.regionCode,
        currencyCode: currencyCode ?? this.currencyCode,
        avatarUrl: avatarUrl.present ? avatarUrl.value : this.avatarUrl,
        googleId: googleId.present ? googleId.value : this.googleId,
        memberSince: memberSince.present ? memberSince.value : this.memberSince,
      );
  UserProfileRow copyWithCompanion(UserProfilesCompanion data) {
    return UserProfileRow(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      email: data.email.present ? data.email.value : this.email,
      passwordHash: data.passwordHash.present
          ? data.passwordHash.value
          : this.passwordHash,
      passwordSalt: data.passwordSalt.present
          ? data.passwordSalt.value
          : this.passwordSalt,
      regionCode:
          data.regionCode.present ? data.regionCode.value : this.regionCode,
      currencyCode: data.currencyCode.present
          ? data.currencyCode.value
          : this.currencyCode,
      avatarUrl: data.avatarUrl.present ? data.avatarUrl.value : this.avatarUrl,
      googleId: data.googleId.present ? data.googleId.value : this.googleId,
      memberSince:
          data.memberSince.present ? data.memberSince.value : this.memberSince,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserProfileRow(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('email: $email, ')
          ..write('passwordHash: $passwordHash, ')
          ..write('passwordSalt: $passwordSalt, ')
          ..write('regionCode: $regionCode, ')
          ..write('currencyCode: $currencyCode, ')
          ..write('avatarUrl: $avatarUrl, ')
          ..write('googleId: $googleId, ')
          ..write('memberSince: $memberSince')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, email, passwordHash, passwordSalt,
      regionCode, currencyCode, avatarUrl, googleId, memberSince);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserProfileRow &&
          other.id == this.id &&
          other.name == this.name &&
          other.email == this.email &&
          other.passwordHash == this.passwordHash &&
          other.passwordSalt == this.passwordSalt &&
          other.regionCode == this.regionCode &&
          other.currencyCode == this.currencyCode &&
          other.avatarUrl == this.avatarUrl &&
          other.googleId == this.googleId &&
          other.memberSince == this.memberSince);
}

class UserProfilesCompanion extends UpdateCompanion<UserProfileRow> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> email;
  final Value<String> passwordHash;
  final Value<String> passwordSalt;
  final Value<String> regionCode;
  final Value<String> currencyCode;
  final Value<String?> avatarUrl;
  final Value<String?> googleId;
  final Value<DateTime?> memberSince;
  final Value<int> rowid;
  const UserProfilesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.email = const Value.absent(),
    this.passwordHash = const Value.absent(),
    this.passwordSalt = const Value.absent(),
    this.regionCode = const Value.absent(),
    this.currencyCode = const Value.absent(),
    this.avatarUrl = const Value.absent(),
    this.googleId = const Value.absent(),
    this.memberSince = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UserProfilesCompanion.insert({
    required String id,
    required String name,
    required String email,
    this.passwordHash = const Value.absent(),
    this.passwordSalt = const Value.absent(),
    this.regionCode = const Value.absent(),
    this.currencyCode = const Value.absent(),
    this.avatarUrl = const Value.absent(),
    this.googleId = const Value.absent(),
    this.memberSince = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name),
        email = Value(email);
  static Insertable<UserProfileRow> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? email,
    Expression<String>? passwordHash,
    Expression<String>? passwordSalt,
    Expression<String>? regionCode,
    Expression<String>? currencyCode,
    Expression<String>? avatarUrl,
    Expression<String>? googleId,
    Expression<DateTime>? memberSince,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (email != null) 'email': email,
      if (passwordHash != null) 'password_hash': passwordHash,
      if (passwordSalt != null) 'password_salt': passwordSalt,
      if (regionCode != null) 'region_code': regionCode,
      if (currencyCode != null) 'currency_code': currencyCode,
      if (avatarUrl != null) 'avatar_url': avatarUrl,
      if (googleId != null) 'google_id': googleId,
      if (memberSince != null) 'member_since': memberSince,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UserProfilesCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<String>? email,
      Value<String>? passwordHash,
      Value<String>? passwordSalt,
      Value<String>? regionCode,
      Value<String>? currencyCode,
      Value<String?>? avatarUrl,
      Value<String?>? googleId,
      Value<DateTime?>? memberSince,
      Value<int>? rowid}) {
    return UserProfilesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      passwordHash: passwordHash ?? this.passwordHash,
      passwordSalt: passwordSalt ?? this.passwordSalt,
      regionCode: regionCode ?? this.regionCode,
      currencyCode: currencyCode ?? this.currencyCode,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      googleId: googleId ?? this.googleId,
      memberSince: memberSince ?? this.memberSince,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (passwordHash.present) {
      map['password_hash'] = Variable<String>(passwordHash.value);
    }
    if (passwordSalt.present) {
      map['password_salt'] = Variable<String>(passwordSalt.value);
    }
    if (regionCode.present) {
      map['region_code'] = Variable<String>(regionCode.value);
    }
    if (currencyCode.present) {
      map['currency_code'] = Variable<String>(currencyCode.value);
    }
    if (avatarUrl.present) {
      map['avatar_url'] = Variable<String>(avatarUrl.value);
    }
    if (googleId.present) {
      map['google_id'] = Variable<String>(googleId.value);
    }
    if (memberSince.present) {
      map['member_since'] = Variable<DateTime>(memberSince.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserProfilesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('email: $email, ')
          ..write('passwordHash: $passwordHash, ')
          ..write('passwordSalt: $passwordSalt, ')
          ..write('regionCode: $regionCode, ')
          ..write('currencyCode: $currencyCode, ')
          ..write('avatarUrl: $avatarUrl, ')
          ..write('googleId: $googleId, ')
          ..write('memberSince: $memberSince, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SavingGoalsTable extends SavingGoals
    with TableInfo<$SavingGoalsTable, SavingGoalRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SavingGoalsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
      'user_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('profile_main'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _targetAmountMeta =
      const VerificationMeta('targetAmount');
  @override
  late final GeneratedColumn<double> targetAmount = GeneratedColumn<double>(
      'target_amount', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _deadlineMeta =
      const VerificationMeta('deadline');
  @override
  late final GeneratedColumn<DateTime> deadline = GeneratedColumn<DateTime>(
      'deadline', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _monthlyTargetMeta =
      const VerificationMeta('monthlyTarget');
  @override
  late final GeneratedColumn<double> monthlyTarget = GeneratedColumn<double>(
      'monthly_target', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _wishlistTitleMeta =
      const VerificationMeta('wishlistTitle');
  @override
  late final GeneratedColumn<String> wishlistTitle = GeneratedColumn<String>(
      'wishlist_title', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _wishlistNoteMeta =
      const VerificationMeta('wishlistNote');
  @override
  late final GeneratedColumn<String> wishlistNote = GeneratedColumn<String>(
      'wishlist_note', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _priorityMeta =
      const VerificationMeta('priority');
  @override
  late final GeneratedColumn<int> priority = GeneratedColumn<int>(
      'priority', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
      'status', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('active'));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        userId,
        name,
        targetAmount,
        deadline,
        monthlyTarget,
        wishlistTitle,
        wishlistNote,
        priority,
        status,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'saving_goals';
  @override
  VerificationContext validateIntegrity(Insertable<SavingGoalRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta,
          userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('target_amount')) {
      context.handle(
          _targetAmountMeta,
          targetAmount.isAcceptableOrUnknown(
              data['target_amount']!, _targetAmountMeta));
    } else if (isInserting) {
      context.missing(_targetAmountMeta);
    }
    if (data.containsKey('deadline')) {
      context.handle(_deadlineMeta,
          deadline.isAcceptableOrUnknown(data['deadline']!, _deadlineMeta));
    }
    if (data.containsKey('monthly_target')) {
      context.handle(
          _monthlyTargetMeta,
          monthlyTarget.isAcceptableOrUnknown(
              data['monthly_target']!, _monthlyTargetMeta));
    }
    if (data.containsKey('wishlist_title')) {
      context.handle(
          _wishlistTitleMeta,
          wishlistTitle.isAcceptableOrUnknown(
              data['wishlist_title']!, _wishlistTitleMeta));
    }
    if (data.containsKey('wishlist_note')) {
      context.handle(
          _wishlistNoteMeta,
          wishlistNote.isAcceptableOrUnknown(
              data['wishlist_note']!, _wishlistNoteMeta));
    }
    if (data.containsKey('priority')) {
      context.handle(_priorityMeta,
          priority.isAcceptableOrUnknown(data['priority']!, _priorityMeta));
    }
    if (data.containsKey('status')) {
      context.handle(_statusMeta,
          status.isAcceptableOrUnknown(data['status']!, _statusMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SavingGoalRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SavingGoalRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      userId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}user_id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      targetAmount: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}target_amount'])!,
      deadline: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}deadline']),
      monthlyTarget: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}monthly_target']),
      wishlistTitle: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}wishlist_title']),
      wishlistNote: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}wishlist_note']),
      priority: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}priority'])!,
      status: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}status'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at'])!,
    );
  }

  @override
  $SavingGoalsTable createAlias(String alias) {
    return $SavingGoalsTable(attachedDatabase, alias);
  }
}

class SavingGoalRow extends DataClass implements Insertable<SavingGoalRow> {
  final String id;
  final String userId;
  final String name;
  final double targetAmount;
  final DateTime? deadline;
  final double? monthlyTarget;
  final String? wishlistTitle;
  final String? wishlistNote;
  final int priority;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  const SavingGoalRow(
      {required this.id,
      required this.userId,
      required this.name,
      required this.targetAmount,
      this.deadline,
      this.monthlyTarget,
      this.wishlistTitle,
      this.wishlistNote,
      required this.priority,
      required this.status,
      required this.createdAt,
      required this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    map['name'] = Variable<String>(name);
    map['target_amount'] = Variable<double>(targetAmount);
    if (!nullToAbsent || deadline != null) {
      map['deadline'] = Variable<DateTime>(deadline);
    }
    if (!nullToAbsent || monthlyTarget != null) {
      map['monthly_target'] = Variable<double>(monthlyTarget);
    }
    if (!nullToAbsent || wishlistTitle != null) {
      map['wishlist_title'] = Variable<String>(wishlistTitle);
    }
    if (!nullToAbsent || wishlistNote != null) {
      map['wishlist_note'] = Variable<String>(wishlistNote);
    }
    map['priority'] = Variable<int>(priority);
    map['status'] = Variable<String>(status);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  SavingGoalsCompanion toCompanion(bool nullToAbsent) {
    return SavingGoalsCompanion(
      id: Value(id),
      userId: Value(userId),
      name: Value(name),
      targetAmount: Value(targetAmount),
      deadline: deadline == null && nullToAbsent
          ? const Value.absent()
          : Value(deadline),
      monthlyTarget: monthlyTarget == null && nullToAbsent
          ? const Value.absent()
          : Value(monthlyTarget),
      wishlistTitle: wishlistTitle == null && nullToAbsent
          ? const Value.absent()
          : Value(wishlistTitle),
      wishlistNote: wishlistNote == null && nullToAbsent
          ? const Value.absent()
          : Value(wishlistNote),
      priority: Value(priority),
      status: Value(status),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory SavingGoalRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SavingGoalRow(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      name: serializer.fromJson<String>(json['name']),
      targetAmount: serializer.fromJson<double>(json['targetAmount']),
      deadline: serializer.fromJson<DateTime?>(json['deadline']),
      monthlyTarget: serializer.fromJson<double?>(json['monthlyTarget']),
      wishlistTitle: serializer.fromJson<String?>(json['wishlistTitle']),
      wishlistNote: serializer.fromJson<String?>(json['wishlistNote']),
      priority: serializer.fromJson<int>(json['priority']),
      status: serializer.fromJson<String>(json['status']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'name': serializer.toJson<String>(name),
      'targetAmount': serializer.toJson<double>(targetAmount),
      'deadline': serializer.toJson<DateTime?>(deadline),
      'monthlyTarget': serializer.toJson<double?>(monthlyTarget),
      'wishlistTitle': serializer.toJson<String?>(wishlistTitle),
      'wishlistNote': serializer.toJson<String?>(wishlistNote),
      'priority': serializer.toJson<int>(priority),
      'status': serializer.toJson<String>(status),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  SavingGoalRow copyWith(
          {String? id,
          String? userId,
          String? name,
          double? targetAmount,
          Value<DateTime?> deadline = const Value.absent(),
          Value<double?> monthlyTarget = const Value.absent(),
          Value<String?> wishlistTitle = const Value.absent(),
          Value<String?> wishlistNote = const Value.absent(),
          int? priority,
          String? status,
          DateTime? createdAt,
          DateTime? updatedAt}) =>
      SavingGoalRow(
        id: id ?? this.id,
        userId: userId ?? this.userId,
        name: name ?? this.name,
        targetAmount: targetAmount ?? this.targetAmount,
        deadline: deadline.present ? deadline.value : this.deadline,
        monthlyTarget:
            monthlyTarget.present ? monthlyTarget.value : this.monthlyTarget,
        wishlistTitle:
            wishlistTitle.present ? wishlistTitle.value : this.wishlistTitle,
        wishlistNote:
            wishlistNote.present ? wishlistNote.value : this.wishlistNote,
        priority: priority ?? this.priority,
        status: status ?? this.status,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
  SavingGoalRow copyWithCompanion(SavingGoalsCompanion data) {
    return SavingGoalRow(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      name: data.name.present ? data.name.value : this.name,
      targetAmount: data.targetAmount.present
          ? data.targetAmount.value
          : this.targetAmount,
      deadline: data.deadline.present ? data.deadline.value : this.deadline,
      monthlyTarget: data.monthlyTarget.present
          ? data.monthlyTarget.value
          : this.monthlyTarget,
      wishlistTitle: data.wishlistTitle.present
          ? data.wishlistTitle.value
          : this.wishlistTitle,
      wishlistNote: data.wishlistNote.present
          ? data.wishlistNote.value
          : this.wishlistNote,
      priority: data.priority.present ? data.priority.value : this.priority,
      status: data.status.present ? data.status.value : this.status,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SavingGoalRow(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('name: $name, ')
          ..write('targetAmount: $targetAmount, ')
          ..write('deadline: $deadline, ')
          ..write('monthlyTarget: $monthlyTarget, ')
          ..write('wishlistTitle: $wishlistTitle, ')
          ..write('wishlistNote: $wishlistNote, ')
          ..write('priority: $priority, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      userId,
      name,
      targetAmount,
      deadline,
      monthlyTarget,
      wishlistTitle,
      wishlistNote,
      priority,
      status,
      createdAt,
      updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SavingGoalRow &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.name == this.name &&
          other.targetAmount == this.targetAmount &&
          other.deadline == this.deadline &&
          other.monthlyTarget == this.monthlyTarget &&
          other.wishlistTitle == this.wishlistTitle &&
          other.wishlistNote == this.wishlistNote &&
          other.priority == this.priority &&
          other.status == this.status &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class SavingGoalsCompanion extends UpdateCompanion<SavingGoalRow> {
  final Value<String> id;
  final Value<String> userId;
  final Value<String> name;
  final Value<double> targetAmount;
  final Value<DateTime?> deadline;
  final Value<double?> monthlyTarget;
  final Value<String?> wishlistTitle;
  final Value<String?> wishlistNote;
  final Value<int> priority;
  final Value<String> status;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const SavingGoalsCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.name = const Value.absent(),
    this.targetAmount = const Value.absent(),
    this.deadline = const Value.absent(),
    this.monthlyTarget = const Value.absent(),
    this.wishlistTitle = const Value.absent(),
    this.wishlistNote = const Value.absent(),
    this.priority = const Value.absent(),
    this.status = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SavingGoalsCompanion.insert({
    required String id,
    this.userId = const Value.absent(),
    required String name,
    required double targetAmount,
    this.deadline = const Value.absent(),
    this.monthlyTarget = const Value.absent(),
    this.wishlistTitle = const Value.absent(),
    this.wishlistNote = const Value.absent(),
    this.priority = const Value.absent(),
    this.status = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name),
        targetAmount = Value(targetAmount),
        createdAt = Value(createdAt),
        updatedAt = Value(updatedAt);
  static Insertable<SavingGoalRow> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? name,
    Expression<double>? targetAmount,
    Expression<DateTime>? deadline,
    Expression<double>? monthlyTarget,
    Expression<String>? wishlistTitle,
    Expression<String>? wishlistNote,
    Expression<int>? priority,
    Expression<String>? status,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (name != null) 'name': name,
      if (targetAmount != null) 'target_amount': targetAmount,
      if (deadline != null) 'deadline': deadline,
      if (monthlyTarget != null) 'monthly_target': monthlyTarget,
      if (wishlistTitle != null) 'wishlist_title': wishlistTitle,
      if (wishlistNote != null) 'wishlist_note': wishlistNote,
      if (priority != null) 'priority': priority,
      if (status != null) 'status': status,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SavingGoalsCompanion copyWith(
      {Value<String>? id,
      Value<String>? userId,
      Value<String>? name,
      Value<double>? targetAmount,
      Value<DateTime?>? deadline,
      Value<double?>? monthlyTarget,
      Value<String?>? wishlistTitle,
      Value<String?>? wishlistNote,
      Value<int>? priority,
      Value<String>? status,
      Value<DateTime>? createdAt,
      Value<DateTime>? updatedAt,
      Value<int>? rowid}) {
    return SavingGoalsCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      targetAmount: targetAmount ?? this.targetAmount,
      deadline: deadline ?? this.deadline,
      monthlyTarget: monthlyTarget ?? this.monthlyTarget,
      wishlistTitle: wishlistTitle ?? this.wishlistTitle,
      wishlistNote: wishlistNote ?? this.wishlistNote,
      priority: priority ?? this.priority,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (targetAmount.present) {
      map['target_amount'] = Variable<double>(targetAmount.value);
    }
    if (deadline.present) {
      map['deadline'] = Variable<DateTime>(deadline.value);
    }
    if (monthlyTarget.present) {
      map['monthly_target'] = Variable<double>(monthlyTarget.value);
    }
    if (wishlistTitle.present) {
      map['wishlist_title'] = Variable<String>(wishlistTitle.value);
    }
    if (wishlistNote.present) {
      map['wishlist_note'] = Variable<String>(wishlistNote.value);
    }
    if (priority.present) {
      map['priority'] = Variable<int>(priority.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SavingGoalsCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('name: $name, ')
          ..write('targetAmount: $targetAmount, ')
          ..write('deadline: $deadline, ')
          ..write('monthlyTarget: $monthlyTarget, ')
          ..write('wishlistTitle: $wishlistTitle, ')
          ..write('wishlistNote: $wishlistNote, ')
          ..write('priority: $priority, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SavingContributionsTable extends SavingContributions
    with TableInfo<$SavingContributionsTable, SavingContributionRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SavingContributionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _userIdMeta = const VerificationMeta('userId');
  @override
  late final GeneratedColumn<String> userId = GeneratedColumn<String>(
      'user_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('profile_main'));
  static const VerificationMeta _goalIdMeta = const VerificationMeta('goalId');
  @override
  late final GeneratedColumn<String> goalId = GeneratedColumn<String>(
      'goal_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES saving_goals (id)'));
  static const VerificationMeta _amountMeta = const VerificationMeta('amount');
  @override
  late final GeneratedColumn<double> amount = GeneratedColumn<double>(
      'amount', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
      'note', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
      'date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, userId, goalId, amount, note, date, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'saving_contributions';
  @override
  VerificationContext validateIntegrity(
      Insertable<SavingContributionRow> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('user_id')) {
      context.handle(_userIdMeta,
          userId.isAcceptableOrUnknown(data['user_id']!, _userIdMeta));
    }
    if (data.containsKey('goal_id')) {
      context.handle(_goalIdMeta,
          goalId.isAcceptableOrUnknown(data['goal_id']!, _goalIdMeta));
    } else if (isInserting) {
      context.missing(_goalIdMeta);
    }
    if (data.containsKey('amount')) {
      context.handle(_amountMeta,
          amount.isAcceptableOrUnknown(data['amount']!, _amountMeta));
    } else if (isInserting) {
      context.missing(_amountMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
          _noteMeta, note.isAcceptableOrUnknown(data['note']!, _noteMeta));
    }
    if (data.containsKey('date')) {
      context.handle(
          _dateMeta, date.isAcceptableOrUnknown(data['date']!, _dateMeta));
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SavingContributionRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SavingContributionRow(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      userId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}user_id'])!,
      goalId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}goal_id'])!,
      amount: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}amount'])!,
      note: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}note'])!,
      date: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}date'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $SavingContributionsTable createAlias(String alias) {
    return $SavingContributionsTable(attachedDatabase, alias);
  }
}

class SavingContributionRow extends DataClass
    implements Insertable<SavingContributionRow> {
  final String id;
  final String userId;
  final String goalId;
  final double amount;
  final String note;
  final DateTime date;
  final DateTime createdAt;
  const SavingContributionRow(
      {required this.id,
      required this.userId,
      required this.goalId,
      required this.amount,
      required this.note,
      required this.date,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['user_id'] = Variable<String>(userId);
    map['goal_id'] = Variable<String>(goalId);
    map['amount'] = Variable<double>(amount);
    map['note'] = Variable<String>(note);
    map['date'] = Variable<DateTime>(date);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  SavingContributionsCompanion toCompanion(bool nullToAbsent) {
    return SavingContributionsCompanion(
      id: Value(id),
      userId: Value(userId),
      goalId: Value(goalId),
      amount: Value(amount),
      note: Value(note),
      date: Value(date),
      createdAt: Value(createdAt),
    );
  }

  factory SavingContributionRow.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SavingContributionRow(
      id: serializer.fromJson<String>(json['id']),
      userId: serializer.fromJson<String>(json['userId']),
      goalId: serializer.fromJson<String>(json['goalId']),
      amount: serializer.fromJson<double>(json['amount']),
      note: serializer.fromJson<String>(json['note']),
      date: serializer.fromJson<DateTime>(json['date']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'userId': serializer.toJson<String>(userId),
      'goalId': serializer.toJson<String>(goalId),
      'amount': serializer.toJson<double>(amount),
      'note': serializer.toJson<String>(note),
      'date': serializer.toJson<DateTime>(date),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  SavingContributionRow copyWith(
          {String? id,
          String? userId,
          String? goalId,
          double? amount,
          String? note,
          DateTime? date,
          DateTime? createdAt}) =>
      SavingContributionRow(
        id: id ?? this.id,
        userId: userId ?? this.userId,
        goalId: goalId ?? this.goalId,
        amount: amount ?? this.amount,
        note: note ?? this.note,
        date: date ?? this.date,
        createdAt: createdAt ?? this.createdAt,
      );
  SavingContributionRow copyWithCompanion(SavingContributionsCompanion data) {
    return SavingContributionRow(
      id: data.id.present ? data.id.value : this.id,
      userId: data.userId.present ? data.userId.value : this.userId,
      goalId: data.goalId.present ? data.goalId.value : this.goalId,
      amount: data.amount.present ? data.amount.value : this.amount,
      note: data.note.present ? data.note.value : this.note,
      date: data.date.present ? data.date.value : this.date,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SavingContributionRow(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('goalId: $goalId, ')
          ..write('amount: $amount, ')
          ..write('note: $note, ')
          ..write('date: $date, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, userId, goalId, amount, note, date, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SavingContributionRow &&
          other.id == this.id &&
          other.userId == this.userId &&
          other.goalId == this.goalId &&
          other.amount == this.amount &&
          other.note == this.note &&
          other.date == this.date &&
          other.createdAt == this.createdAt);
}

class SavingContributionsCompanion
    extends UpdateCompanion<SavingContributionRow> {
  final Value<String> id;
  final Value<String> userId;
  final Value<String> goalId;
  final Value<double> amount;
  final Value<String> note;
  final Value<DateTime> date;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const SavingContributionsCompanion({
    this.id = const Value.absent(),
    this.userId = const Value.absent(),
    this.goalId = const Value.absent(),
    this.amount = const Value.absent(),
    this.note = const Value.absent(),
    this.date = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SavingContributionsCompanion.insert({
    required String id,
    this.userId = const Value.absent(),
    required String goalId,
    required double amount,
    this.note = const Value.absent(),
    required DateTime date,
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        goalId = Value(goalId),
        amount = Value(amount),
        date = Value(date),
        createdAt = Value(createdAt);
  static Insertable<SavingContributionRow> custom({
    Expression<String>? id,
    Expression<String>? userId,
    Expression<String>? goalId,
    Expression<double>? amount,
    Expression<String>? note,
    Expression<DateTime>? date,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userId != null) 'user_id': userId,
      if (goalId != null) 'goal_id': goalId,
      if (amount != null) 'amount': amount,
      if (note != null) 'note': note,
      if (date != null) 'date': date,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SavingContributionsCompanion copyWith(
      {Value<String>? id,
      Value<String>? userId,
      Value<String>? goalId,
      Value<double>? amount,
      Value<String>? note,
      Value<DateTime>? date,
      Value<DateTime>? createdAt,
      Value<int>? rowid}) {
    return SavingContributionsCompanion(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      goalId: goalId ?? this.goalId,
      amount: amount ?? this.amount,
      note: note ?? this.note,
      date: date ?? this.date,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (userId.present) {
      map['user_id'] = Variable<String>(userId.value);
    }
    if (goalId.present) {
      map['goal_id'] = Variable<String>(goalId.value);
    }
    if (amount.present) {
      map['amount'] = Variable<double>(amount.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SavingContributionsCompanion(')
          ..write('id: $id, ')
          ..write('userId: $userId, ')
          ..write('goalId: $goalId, ')
          ..write('amount: $amount, ')
          ..write('note: $note, ')
          ..write('date: $date, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $CategoriesTable categories = $CategoriesTable(this);
  late final $ExpensesTable expenses = $ExpensesTable(this);
  late final $BudgetsTable budgets = $BudgetsTable(this);
  late final $RecurringExpensesTable recurringExpenses =
      $RecurringExpensesTable(this);
  late final $AppPreferencesTable appPreferences = $AppPreferencesTable(this);
  late final $UserProfilesTable userProfiles = $UserProfilesTable(this);
  late final $SavingGoalsTable savingGoals = $SavingGoalsTable(this);
  late final $SavingContributionsTable savingContributions =
      $SavingContributionsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        categories,
        expenses,
        budgets,
        recurringExpenses,
        appPreferences,
        userProfiles,
        savingGoals,
        savingContributions
      ];
}

typedef $$CategoriesTableCreateCompanionBuilder = CategoriesCompanion Function({
  required String id,
  Value<String> userId,
  required String name,
  required String iconName,
  required int colorValue,
  Value<bool> isCustom,
  Value<double?> budgetLimit,
  Value<int> rowid,
});
typedef $$CategoriesTableUpdateCompanionBuilder = CategoriesCompanion Function({
  Value<String> id,
  Value<String> userId,
  Value<String> name,
  Value<String> iconName,
  Value<int> colorValue,
  Value<bool> isCustom,
  Value<double?> budgetLimit,
  Value<int> rowid,
});

final class $$CategoriesTableReferences
    extends BaseReferences<_$AppDatabase, $CategoriesTable, CategoryRow> {
  $$CategoriesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$ExpensesTable, List<ExpenseRow>>
      _expensesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
          db.expenses,
          aliasName:
              $_aliasNameGenerator(db.categories.id, db.expenses.categoryId));

  $$ExpensesTableProcessedTableManager get expensesRefs {
    final manager = $$ExpensesTableTableManager($_db, $_db.expenses)
        .filter((f) => f.categoryId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_expensesRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$BudgetsTable, List<BudgetRow>> _budgetsRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.budgets,
          aliasName:
              $_aliasNameGenerator(db.categories.id, db.budgets.categoryId));

  $$BudgetsTableProcessedTableManager get budgetsRefs {
    final manager = $$BudgetsTableTableManager($_db, $_db.budgets)
        .filter((f) => f.categoryId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_budgetsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }

  static MultiTypedResultKey<$RecurringExpensesTable, List<RecurringExpenseRow>>
      _recurringExpensesRefsTable(_$AppDatabase db) =>
          MultiTypedResultKey.fromTable(db.recurringExpenses,
              aliasName: $_aliasNameGenerator(
                  db.categories.id, db.recurringExpenses.categoryId));

  $$RecurringExpensesTableProcessedTableManager get recurringExpensesRefs {
    final manager = $$RecurringExpensesTableTableManager(
            $_db, $_db.recurringExpenses)
        .filter((f) => f.categoryId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache =
        $_typedResult.readTableOrNull(_recurringExpensesRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$CategoriesTableFilterComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get iconName => $composableBuilder(
      column: $table.iconName, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get colorValue => $composableBuilder(
      column: $table.colorValue, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isCustom => $composableBuilder(
      column: $table.isCustom, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get budgetLimit => $composableBuilder(
      column: $table.budgetLimit, builder: (column) => ColumnFilters(column));

  Expression<bool> expensesRefs(
      Expression<bool> Function($$ExpensesTableFilterComposer f) f) {
    final $$ExpensesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.expenses,
        getReferencedColumn: (t) => t.categoryId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ExpensesTableFilterComposer(
              $db: $db,
              $table: $db.expenses,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> budgetsRefs(
      Expression<bool> Function($$BudgetsTableFilterComposer f) f) {
    final $$BudgetsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.budgets,
        getReferencedColumn: (t) => t.categoryId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$BudgetsTableFilterComposer(
              $db: $db,
              $table: $db.budgets,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<bool> recurringExpensesRefs(
      Expression<bool> Function($$RecurringExpensesTableFilterComposer f) f) {
    final $$RecurringExpensesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.recurringExpenses,
        getReferencedColumn: (t) => t.categoryId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$RecurringExpensesTableFilterComposer(
              $db: $db,
              $table: $db.recurringExpenses,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$CategoriesTableOrderingComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get iconName => $composableBuilder(
      column: $table.iconName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get colorValue => $composableBuilder(
      column: $table.colorValue, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isCustom => $composableBuilder(
      column: $table.isCustom, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get budgetLimit => $composableBuilder(
      column: $table.budgetLimit, builder: (column) => ColumnOrderings(column));
}

class $$CategoriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $CategoriesTable> {
  $$CategoriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get iconName =>
      $composableBuilder(column: $table.iconName, builder: (column) => column);

  GeneratedColumn<int> get colorValue => $composableBuilder(
      column: $table.colorValue, builder: (column) => column);

  GeneratedColumn<bool> get isCustom =>
      $composableBuilder(column: $table.isCustom, builder: (column) => column);

  GeneratedColumn<double> get budgetLimit => $composableBuilder(
      column: $table.budgetLimit, builder: (column) => column);

  Expression<T> expensesRefs<T extends Object>(
      Expression<T> Function($$ExpensesTableAnnotationComposer a) f) {
    final $$ExpensesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.expenses,
        getReferencedColumn: (t) => t.categoryId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$ExpensesTableAnnotationComposer(
              $db: $db,
              $table: $db.expenses,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> budgetsRefs<T extends Object>(
      Expression<T> Function($$BudgetsTableAnnotationComposer a) f) {
    final $$BudgetsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.budgets,
        getReferencedColumn: (t) => t.categoryId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$BudgetsTableAnnotationComposer(
              $db: $db,
              $table: $db.budgets,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }

  Expression<T> recurringExpensesRefs<T extends Object>(
      Expression<T> Function($$RecurringExpensesTableAnnotationComposer a) f) {
    final $$RecurringExpensesTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $db.recurringExpenses,
            getReferencedColumn: (t) => t.categoryId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$RecurringExpensesTableAnnotationComposer(
                  $db: $db,
                  $table: $db.recurringExpenses,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }
}

class $$CategoriesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $CategoriesTable,
    CategoryRow,
    $$CategoriesTableFilterComposer,
    $$CategoriesTableOrderingComposer,
    $$CategoriesTableAnnotationComposer,
    $$CategoriesTableCreateCompanionBuilder,
    $$CategoriesTableUpdateCompanionBuilder,
    (CategoryRow, $$CategoriesTableReferences),
    CategoryRow,
    PrefetchHooks Function(
        {bool expensesRefs, bool budgetsRefs, bool recurringExpensesRefs})> {
  $$CategoriesTableTableManager(_$AppDatabase db, $CategoriesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$CategoriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$CategoriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$CategoriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> userId = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> iconName = const Value.absent(),
            Value<int> colorValue = const Value.absent(),
            Value<bool> isCustom = const Value.absent(),
            Value<double?> budgetLimit = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CategoriesCompanion(
            id: id,
            userId: userId,
            name: name,
            iconName: iconName,
            colorValue: colorValue,
            isCustom: isCustom,
            budgetLimit: budgetLimit,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            Value<String> userId = const Value.absent(),
            required String name,
            required String iconName,
            required int colorValue,
            Value<bool> isCustom = const Value.absent(),
            Value<double?> budgetLimit = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CategoriesCompanion.insert(
            id: id,
            userId: userId,
            name: name,
            iconName: iconName,
            colorValue: colorValue,
            isCustom: isCustom,
            budgetLimit: budgetLimit,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$CategoriesTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: (
              {expensesRefs = false,
              budgetsRefs = false,
              recurringExpensesRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (expensesRefs) db.expenses,
                if (budgetsRefs) db.budgets,
                if (recurringExpensesRefs) db.recurringExpenses
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (expensesRefs)
                    await $_getPrefetchedData<CategoryRow, $CategoriesTable,
                            ExpenseRow>(
                        currentTable: table,
                        referencedTable:
                            $$CategoriesTableReferences._expensesRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$CategoriesTableReferences(db, table, p0)
                                .expensesRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.categoryId == item.id),
                        typedResults: items),
                  if (budgetsRefs)
                    await $_getPrefetchedData<CategoryRow, $CategoriesTable,
                            BudgetRow>(
                        currentTable: table,
                        referencedTable:
                            $$CategoriesTableReferences._budgetsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$CategoriesTableReferences(db, table, p0)
                                .budgetsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.categoryId == item.id),
                        typedResults: items),
                  if (recurringExpensesRefs)
                    await $_getPrefetchedData<CategoryRow, $CategoriesTable,
                            RecurringExpenseRow>(
                        currentTable: table,
                        referencedTable: $$CategoriesTableReferences
                            ._recurringExpensesRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$CategoriesTableReferences(db, table, p0)
                                .recurringExpensesRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.categoryId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$CategoriesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $CategoriesTable,
    CategoryRow,
    $$CategoriesTableFilterComposer,
    $$CategoriesTableOrderingComposer,
    $$CategoriesTableAnnotationComposer,
    $$CategoriesTableCreateCompanionBuilder,
    $$CategoriesTableUpdateCompanionBuilder,
    (CategoryRow, $$CategoriesTableReferences),
    CategoryRow,
    PrefetchHooks Function(
        {bool expensesRefs, bool budgetsRefs, bool recurringExpensesRefs})>;
typedef $$ExpensesTableCreateCompanionBuilder = ExpensesCompanion Function({
  required String id,
  Value<String> userId,
  required double amount,
  required String categoryId,
  Value<String> note,
  required DateTime date,
  required String paymentMethod,
  Value<bool> isRecurring,
  Value<int> rowid,
});
typedef $$ExpensesTableUpdateCompanionBuilder = ExpensesCompanion Function({
  Value<String> id,
  Value<String> userId,
  Value<double> amount,
  Value<String> categoryId,
  Value<String> note,
  Value<DateTime> date,
  Value<String> paymentMethod,
  Value<bool> isRecurring,
  Value<int> rowid,
});

final class $$ExpensesTableReferences
    extends BaseReferences<_$AppDatabase, $ExpensesTable, ExpenseRow> {
  $$ExpensesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CategoriesTable _categoryIdTable(_$AppDatabase db) =>
      db.categories.createAlias(
          $_aliasNameGenerator(db.expenses.categoryId, db.categories.id));

  $$CategoriesTableProcessedTableManager get categoryId {
    final $_column = $_itemColumn<String>('category_id')!;

    final manager = $$CategoriesTableTableManager($_db, $_db.categories)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_categoryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$ExpensesTableFilterComposer
    extends Composer<_$AppDatabase, $ExpensesTable> {
  $$ExpensesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get amount => $composableBuilder(
      column: $table.amount, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get note => $composableBuilder(
      column: $table.note, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get paymentMethod => $composableBuilder(
      column: $table.paymentMethod, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isRecurring => $composableBuilder(
      column: $table.isRecurring, builder: (column) => ColumnFilters(column));

  $$CategoriesTableFilterComposer get categoryId {
    final $$CategoriesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.categoryId,
        referencedTable: $db.categories,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CategoriesTableFilterComposer(
              $db: $db,
              $table: $db.categories,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ExpensesTableOrderingComposer
    extends Composer<_$AppDatabase, $ExpensesTable> {
  $$ExpensesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get amount => $composableBuilder(
      column: $table.amount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get note => $composableBuilder(
      column: $table.note, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get paymentMethod => $composableBuilder(
      column: $table.paymentMethod,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isRecurring => $composableBuilder(
      column: $table.isRecurring, builder: (column) => ColumnOrderings(column));

  $$CategoriesTableOrderingComposer get categoryId {
    final $$CategoriesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.categoryId,
        referencedTable: $db.categories,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CategoriesTableOrderingComposer(
              $db: $db,
              $table: $db.categories,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ExpensesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ExpensesTable> {
  $$ExpensesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get paymentMethod => $composableBuilder(
      column: $table.paymentMethod, builder: (column) => column);

  GeneratedColumn<bool> get isRecurring => $composableBuilder(
      column: $table.isRecurring, builder: (column) => column);

  $$CategoriesTableAnnotationComposer get categoryId {
    final $$CategoriesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.categoryId,
        referencedTable: $db.categories,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CategoriesTableAnnotationComposer(
              $db: $db,
              $table: $db.categories,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$ExpensesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ExpensesTable,
    ExpenseRow,
    $$ExpensesTableFilterComposer,
    $$ExpensesTableOrderingComposer,
    $$ExpensesTableAnnotationComposer,
    $$ExpensesTableCreateCompanionBuilder,
    $$ExpensesTableUpdateCompanionBuilder,
    (ExpenseRow, $$ExpensesTableReferences),
    ExpenseRow,
    PrefetchHooks Function({bool categoryId})> {
  $$ExpensesTableTableManager(_$AppDatabase db, $ExpensesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ExpensesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ExpensesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ExpensesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> userId = const Value.absent(),
            Value<double> amount = const Value.absent(),
            Value<String> categoryId = const Value.absent(),
            Value<String> note = const Value.absent(),
            Value<DateTime> date = const Value.absent(),
            Value<String> paymentMethod = const Value.absent(),
            Value<bool> isRecurring = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ExpensesCompanion(
            id: id,
            userId: userId,
            amount: amount,
            categoryId: categoryId,
            note: note,
            date: date,
            paymentMethod: paymentMethod,
            isRecurring: isRecurring,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            Value<String> userId = const Value.absent(),
            required double amount,
            required String categoryId,
            Value<String> note = const Value.absent(),
            required DateTime date,
            required String paymentMethod,
            Value<bool> isRecurring = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              ExpensesCompanion.insert(
            id: id,
            userId: userId,
            amount: amount,
            categoryId: categoryId,
            note: note,
            date: date,
            paymentMethod: paymentMethod,
            isRecurring: isRecurring,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$ExpensesTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: ({categoryId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (categoryId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.categoryId,
                    referencedTable:
                        $$ExpensesTableReferences._categoryIdTable(db),
                    referencedColumn:
                        $$ExpensesTableReferences._categoryIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$ExpensesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ExpensesTable,
    ExpenseRow,
    $$ExpensesTableFilterComposer,
    $$ExpensesTableOrderingComposer,
    $$ExpensesTableAnnotationComposer,
    $$ExpensesTableCreateCompanionBuilder,
    $$ExpensesTableUpdateCompanionBuilder,
    (ExpenseRow, $$ExpensesTableReferences),
    ExpenseRow,
    PrefetchHooks Function({bool categoryId})>;
typedef $$BudgetsTableCreateCompanionBuilder = BudgetsCompanion Function({
  required String id,
  Value<String> userId,
  required String name,
  required double limitAmount,
  Value<String?> categoryId,
  Value<bool> isMonthly,
  Value<int> rowid,
});
typedef $$BudgetsTableUpdateCompanionBuilder = BudgetsCompanion Function({
  Value<String> id,
  Value<String> userId,
  Value<String> name,
  Value<double> limitAmount,
  Value<String?> categoryId,
  Value<bool> isMonthly,
  Value<int> rowid,
});

final class $$BudgetsTableReferences
    extends BaseReferences<_$AppDatabase, $BudgetsTable, BudgetRow> {
  $$BudgetsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $CategoriesTable _categoryIdTable(_$AppDatabase db) =>
      db.categories.createAlias(
          $_aliasNameGenerator(db.budgets.categoryId, db.categories.id));

  $$CategoriesTableProcessedTableManager? get categoryId {
    final $_column = $_itemColumn<String>('category_id');
    if ($_column == null) return null;
    final manager = $$CategoriesTableTableManager($_db, $_db.categories)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_categoryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$BudgetsTableFilterComposer
    extends Composer<_$AppDatabase, $BudgetsTable> {
  $$BudgetsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get limitAmount => $composableBuilder(
      column: $table.limitAmount, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isMonthly => $composableBuilder(
      column: $table.isMonthly, builder: (column) => ColumnFilters(column));

  $$CategoriesTableFilterComposer get categoryId {
    final $$CategoriesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.categoryId,
        referencedTable: $db.categories,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CategoriesTableFilterComposer(
              $db: $db,
              $table: $db.categories,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$BudgetsTableOrderingComposer
    extends Composer<_$AppDatabase, $BudgetsTable> {
  $$BudgetsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get limitAmount => $composableBuilder(
      column: $table.limitAmount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isMonthly => $composableBuilder(
      column: $table.isMonthly, builder: (column) => ColumnOrderings(column));

  $$CategoriesTableOrderingComposer get categoryId {
    final $$CategoriesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.categoryId,
        referencedTable: $db.categories,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CategoriesTableOrderingComposer(
              $db: $db,
              $table: $db.categories,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$BudgetsTableAnnotationComposer
    extends Composer<_$AppDatabase, $BudgetsTable> {
  $$BudgetsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<double> get limitAmount => $composableBuilder(
      column: $table.limitAmount, builder: (column) => column);

  GeneratedColumn<bool> get isMonthly =>
      $composableBuilder(column: $table.isMonthly, builder: (column) => column);

  $$CategoriesTableAnnotationComposer get categoryId {
    final $$CategoriesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.categoryId,
        referencedTable: $db.categories,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CategoriesTableAnnotationComposer(
              $db: $db,
              $table: $db.categories,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$BudgetsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $BudgetsTable,
    BudgetRow,
    $$BudgetsTableFilterComposer,
    $$BudgetsTableOrderingComposer,
    $$BudgetsTableAnnotationComposer,
    $$BudgetsTableCreateCompanionBuilder,
    $$BudgetsTableUpdateCompanionBuilder,
    (BudgetRow, $$BudgetsTableReferences),
    BudgetRow,
    PrefetchHooks Function({bool categoryId})> {
  $$BudgetsTableTableManager(_$AppDatabase db, $BudgetsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BudgetsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BudgetsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BudgetsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> userId = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<double> limitAmount = const Value.absent(),
            Value<String?> categoryId = const Value.absent(),
            Value<bool> isMonthly = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              BudgetsCompanion(
            id: id,
            userId: userId,
            name: name,
            limitAmount: limitAmount,
            categoryId: categoryId,
            isMonthly: isMonthly,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            Value<String> userId = const Value.absent(),
            required String name,
            required double limitAmount,
            Value<String?> categoryId = const Value.absent(),
            Value<bool> isMonthly = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              BudgetsCompanion.insert(
            id: id,
            userId: userId,
            name: name,
            limitAmount: limitAmount,
            categoryId: categoryId,
            isMonthly: isMonthly,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$BudgetsTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: ({categoryId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (categoryId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.categoryId,
                    referencedTable:
                        $$BudgetsTableReferences._categoryIdTable(db),
                    referencedColumn:
                        $$BudgetsTableReferences._categoryIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$BudgetsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $BudgetsTable,
    BudgetRow,
    $$BudgetsTableFilterComposer,
    $$BudgetsTableOrderingComposer,
    $$BudgetsTableAnnotationComposer,
    $$BudgetsTableCreateCompanionBuilder,
    $$BudgetsTableUpdateCompanionBuilder,
    (BudgetRow, $$BudgetsTableReferences),
    BudgetRow,
    PrefetchHooks Function({bool categoryId})>;
typedef $$RecurringExpensesTableCreateCompanionBuilder
    = RecurringExpensesCompanion Function({
  required String id,
  Value<String> userId,
  required String title,
  required double amount,
  required String categoryId,
  required String frequency,
  required DateTime nextDueDate,
  required String paymentMethod,
  Value<int> rowid,
});
typedef $$RecurringExpensesTableUpdateCompanionBuilder
    = RecurringExpensesCompanion Function({
  Value<String> id,
  Value<String> userId,
  Value<String> title,
  Value<double> amount,
  Value<String> categoryId,
  Value<String> frequency,
  Value<DateTime> nextDueDate,
  Value<String> paymentMethod,
  Value<int> rowid,
});

final class $$RecurringExpensesTableReferences extends BaseReferences<
    _$AppDatabase, $RecurringExpensesTable, RecurringExpenseRow> {
  $$RecurringExpensesTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $CategoriesTable _categoryIdTable(_$AppDatabase db) =>
      db.categories.createAlias($_aliasNameGenerator(
          db.recurringExpenses.categoryId, db.categories.id));

  $$CategoriesTableProcessedTableManager get categoryId {
    final $_column = $_itemColumn<String>('category_id')!;

    final manager = $$CategoriesTableTableManager($_db, $_db.categories)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_categoryIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$RecurringExpensesTableFilterComposer
    extends Composer<_$AppDatabase, $RecurringExpensesTable> {
  $$RecurringExpensesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get amount => $composableBuilder(
      column: $table.amount, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get frequency => $composableBuilder(
      column: $table.frequency, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get nextDueDate => $composableBuilder(
      column: $table.nextDueDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get paymentMethod => $composableBuilder(
      column: $table.paymentMethod, builder: (column) => ColumnFilters(column));

  $$CategoriesTableFilterComposer get categoryId {
    final $$CategoriesTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.categoryId,
        referencedTable: $db.categories,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CategoriesTableFilterComposer(
              $db: $db,
              $table: $db.categories,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$RecurringExpensesTableOrderingComposer
    extends Composer<_$AppDatabase, $RecurringExpensesTable> {
  $$RecurringExpensesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get amount => $composableBuilder(
      column: $table.amount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get frequency => $composableBuilder(
      column: $table.frequency, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get nextDueDate => $composableBuilder(
      column: $table.nextDueDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get paymentMethod => $composableBuilder(
      column: $table.paymentMethod,
      builder: (column) => ColumnOrderings(column));

  $$CategoriesTableOrderingComposer get categoryId {
    final $$CategoriesTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.categoryId,
        referencedTable: $db.categories,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CategoriesTableOrderingComposer(
              $db: $db,
              $table: $db.categories,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$RecurringExpensesTableAnnotationComposer
    extends Composer<_$AppDatabase, $RecurringExpensesTable> {
  $$RecurringExpensesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<String> get frequency =>
      $composableBuilder(column: $table.frequency, builder: (column) => column);

  GeneratedColumn<DateTime> get nextDueDate => $composableBuilder(
      column: $table.nextDueDate, builder: (column) => column);

  GeneratedColumn<String> get paymentMethod => $composableBuilder(
      column: $table.paymentMethod, builder: (column) => column);

  $$CategoriesTableAnnotationComposer get categoryId {
    final $$CategoriesTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.categoryId,
        referencedTable: $db.categories,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$CategoriesTableAnnotationComposer(
              $db: $db,
              $table: $db.categories,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$RecurringExpensesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $RecurringExpensesTable,
    RecurringExpenseRow,
    $$RecurringExpensesTableFilterComposer,
    $$RecurringExpensesTableOrderingComposer,
    $$RecurringExpensesTableAnnotationComposer,
    $$RecurringExpensesTableCreateCompanionBuilder,
    $$RecurringExpensesTableUpdateCompanionBuilder,
    (RecurringExpenseRow, $$RecurringExpensesTableReferences),
    RecurringExpenseRow,
    PrefetchHooks Function({bool categoryId})> {
  $$RecurringExpensesTableTableManager(
      _$AppDatabase db, $RecurringExpensesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$RecurringExpensesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$RecurringExpensesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$RecurringExpensesTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> userId = const Value.absent(),
            Value<String> title = const Value.absent(),
            Value<double> amount = const Value.absent(),
            Value<String> categoryId = const Value.absent(),
            Value<String> frequency = const Value.absent(),
            Value<DateTime> nextDueDate = const Value.absent(),
            Value<String> paymentMethod = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              RecurringExpensesCompanion(
            id: id,
            userId: userId,
            title: title,
            amount: amount,
            categoryId: categoryId,
            frequency: frequency,
            nextDueDate: nextDueDate,
            paymentMethod: paymentMethod,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            Value<String> userId = const Value.absent(),
            required String title,
            required double amount,
            required String categoryId,
            required String frequency,
            required DateTime nextDueDate,
            required String paymentMethod,
            Value<int> rowid = const Value.absent(),
          }) =>
              RecurringExpensesCompanion.insert(
            id: id,
            userId: userId,
            title: title,
            amount: amount,
            categoryId: categoryId,
            frequency: frequency,
            nextDueDate: nextDueDate,
            paymentMethod: paymentMethod,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$RecurringExpensesTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({categoryId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (categoryId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.categoryId,
                    referencedTable:
                        $$RecurringExpensesTableReferences._categoryIdTable(db),
                    referencedColumn: $$RecurringExpensesTableReferences
                        ._categoryIdTable(db)
                        .id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$RecurringExpensesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $RecurringExpensesTable,
    RecurringExpenseRow,
    $$RecurringExpensesTableFilterComposer,
    $$RecurringExpensesTableOrderingComposer,
    $$RecurringExpensesTableAnnotationComposer,
    $$RecurringExpensesTableCreateCompanionBuilder,
    $$RecurringExpensesTableUpdateCompanionBuilder,
    (RecurringExpenseRow, $$RecurringExpensesTableReferences),
    RecurringExpenseRow,
    PrefetchHooks Function({bool categoryId})>;
typedef $$AppPreferencesTableCreateCompanionBuilder = AppPreferencesCompanion
    Function({
  Value<int> id,
  required String themeMode,
  Value<bool> hasCompletedOnboarding,
  Value<String?> activeUserId,
  Value<bool> notificationsEnabled,
  Value<bool> billRemindersEnabled,
  Value<bool> budgetAlertsEnabled,
  Value<bool> goalRemindersEnabled,
  Value<bool> productUpdatesEnabled,
  Value<String?> backupDriveEmail,
  Value<DateTime?> lastBackupAt,
  Value<String?> backupDriveFileId,
  Value<bool> biometricUnlockEnabled,
  Value<String?> biometricUserId,
});
typedef $$AppPreferencesTableUpdateCompanionBuilder = AppPreferencesCompanion
    Function({
  Value<int> id,
  Value<String> themeMode,
  Value<bool> hasCompletedOnboarding,
  Value<String?> activeUserId,
  Value<bool> notificationsEnabled,
  Value<bool> billRemindersEnabled,
  Value<bool> budgetAlertsEnabled,
  Value<bool> goalRemindersEnabled,
  Value<bool> productUpdatesEnabled,
  Value<String?> backupDriveEmail,
  Value<DateTime?> lastBackupAt,
  Value<String?> backupDriveFileId,
  Value<bool> biometricUnlockEnabled,
  Value<String?> biometricUserId,
});

class $$AppPreferencesTableFilterComposer
    extends Composer<_$AppDatabase, $AppPreferencesTable> {
  $$AppPreferencesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get themeMode => $composableBuilder(
      column: $table.themeMode, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get hasCompletedOnboarding => $composableBuilder(
      column: $table.hasCompletedOnboarding,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get activeUserId => $composableBuilder(
      column: $table.activeUserId, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get notificationsEnabled => $composableBuilder(
      column: $table.notificationsEnabled,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get billRemindersEnabled => $composableBuilder(
      column: $table.billRemindersEnabled,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get budgetAlertsEnabled => $composableBuilder(
      column: $table.budgetAlertsEnabled,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get goalRemindersEnabled => $composableBuilder(
      column: $table.goalRemindersEnabled,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get productUpdatesEnabled => $composableBuilder(
      column: $table.productUpdatesEnabled,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get backupDriveEmail => $composableBuilder(
      column: $table.backupDriveEmail,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get lastBackupAt => $composableBuilder(
      column: $table.lastBackupAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get backupDriveFileId => $composableBuilder(
      column: $table.backupDriveFileId,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get biometricUnlockEnabled => $composableBuilder(
      column: $table.biometricUnlockEnabled,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get biometricUserId => $composableBuilder(
      column: $table.biometricUserId,
      builder: (column) => ColumnFilters(column));
}

class $$AppPreferencesTableOrderingComposer
    extends Composer<_$AppDatabase, $AppPreferencesTable> {
  $$AppPreferencesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get themeMode => $composableBuilder(
      column: $table.themeMode, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get hasCompletedOnboarding => $composableBuilder(
      column: $table.hasCompletedOnboarding,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get activeUserId => $composableBuilder(
      column: $table.activeUserId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get notificationsEnabled => $composableBuilder(
      column: $table.notificationsEnabled,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get billRemindersEnabled => $composableBuilder(
      column: $table.billRemindersEnabled,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get budgetAlertsEnabled => $composableBuilder(
      column: $table.budgetAlertsEnabled,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get goalRemindersEnabled => $composableBuilder(
      column: $table.goalRemindersEnabled,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get productUpdatesEnabled => $composableBuilder(
      column: $table.productUpdatesEnabled,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get backupDriveEmail => $composableBuilder(
      column: $table.backupDriveEmail,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get lastBackupAt => $composableBuilder(
      column: $table.lastBackupAt,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get backupDriveFileId => $composableBuilder(
      column: $table.backupDriveFileId,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get biometricUnlockEnabled => $composableBuilder(
      column: $table.biometricUnlockEnabled,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get biometricUserId => $composableBuilder(
      column: $table.biometricUserId,
      builder: (column) => ColumnOrderings(column));
}

class $$AppPreferencesTableAnnotationComposer
    extends Composer<_$AppDatabase, $AppPreferencesTable> {
  $$AppPreferencesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get themeMode =>
      $composableBuilder(column: $table.themeMode, builder: (column) => column);

  GeneratedColumn<bool> get hasCompletedOnboarding => $composableBuilder(
      column: $table.hasCompletedOnboarding, builder: (column) => column);

  GeneratedColumn<String> get activeUserId => $composableBuilder(
      column: $table.activeUserId, builder: (column) => column);

  GeneratedColumn<bool> get notificationsEnabled => $composableBuilder(
      column: $table.notificationsEnabled, builder: (column) => column);

  GeneratedColumn<bool> get billRemindersEnabled => $composableBuilder(
      column: $table.billRemindersEnabled, builder: (column) => column);

  GeneratedColumn<bool> get budgetAlertsEnabled => $composableBuilder(
      column: $table.budgetAlertsEnabled, builder: (column) => column);

  GeneratedColumn<bool> get goalRemindersEnabled => $composableBuilder(
      column: $table.goalRemindersEnabled, builder: (column) => column);

  GeneratedColumn<bool> get productUpdatesEnabled => $composableBuilder(
      column: $table.productUpdatesEnabled, builder: (column) => column);

  GeneratedColumn<String> get backupDriveEmail => $composableBuilder(
      column: $table.backupDriveEmail, builder: (column) => column);

  GeneratedColumn<DateTime> get lastBackupAt => $composableBuilder(
      column: $table.lastBackupAt, builder: (column) => column);

  GeneratedColumn<String> get backupDriveFileId => $composableBuilder(
      column: $table.backupDriveFileId, builder: (column) => column);

  GeneratedColumn<bool> get biometricUnlockEnabled => $composableBuilder(
      column: $table.biometricUnlockEnabled, builder: (column) => column);

  GeneratedColumn<String> get biometricUserId => $composableBuilder(
      column: $table.biometricUserId, builder: (column) => column);
}

class $$AppPreferencesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $AppPreferencesTable,
    PreferencesRow,
    $$AppPreferencesTableFilterComposer,
    $$AppPreferencesTableOrderingComposer,
    $$AppPreferencesTableAnnotationComposer,
    $$AppPreferencesTableCreateCompanionBuilder,
    $$AppPreferencesTableUpdateCompanionBuilder,
    (
      PreferencesRow,
      BaseReferences<_$AppDatabase, $AppPreferencesTable, PreferencesRow>
    ),
    PreferencesRow,
    PrefetchHooks Function()> {
  $$AppPreferencesTableTableManager(
      _$AppDatabase db, $AppPreferencesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppPreferencesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppPreferencesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppPreferencesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> themeMode = const Value.absent(),
            Value<bool> hasCompletedOnboarding = const Value.absent(),
            Value<String?> activeUserId = const Value.absent(),
            Value<bool> notificationsEnabled = const Value.absent(),
            Value<bool> billRemindersEnabled = const Value.absent(),
            Value<bool> budgetAlertsEnabled = const Value.absent(),
            Value<bool> goalRemindersEnabled = const Value.absent(),
            Value<bool> productUpdatesEnabled = const Value.absent(),
            Value<String?> backupDriveEmail = const Value.absent(),
            Value<DateTime?> lastBackupAt = const Value.absent(),
            Value<String?> backupDriveFileId = const Value.absent(),
            Value<bool> biometricUnlockEnabled = const Value.absent(),
            Value<String?> biometricUserId = const Value.absent(),
          }) =>
              AppPreferencesCompanion(
            id: id,
            themeMode: themeMode,
            hasCompletedOnboarding: hasCompletedOnboarding,
            activeUserId: activeUserId,
            notificationsEnabled: notificationsEnabled,
            billRemindersEnabled: billRemindersEnabled,
            budgetAlertsEnabled: budgetAlertsEnabled,
            goalRemindersEnabled: goalRemindersEnabled,
            productUpdatesEnabled: productUpdatesEnabled,
            backupDriveEmail: backupDriveEmail,
            lastBackupAt: lastBackupAt,
            backupDriveFileId: backupDriveFileId,
            biometricUnlockEnabled: biometricUnlockEnabled,
            biometricUserId: biometricUserId,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String themeMode,
            Value<bool> hasCompletedOnboarding = const Value.absent(),
            Value<String?> activeUserId = const Value.absent(),
            Value<bool> notificationsEnabled = const Value.absent(),
            Value<bool> billRemindersEnabled = const Value.absent(),
            Value<bool> budgetAlertsEnabled = const Value.absent(),
            Value<bool> goalRemindersEnabled = const Value.absent(),
            Value<bool> productUpdatesEnabled = const Value.absent(),
            Value<String?> backupDriveEmail = const Value.absent(),
            Value<DateTime?> lastBackupAt = const Value.absent(),
            Value<String?> backupDriveFileId = const Value.absent(),
            Value<bool> biometricUnlockEnabled = const Value.absent(),
            Value<String?> biometricUserId = const Value.absent(),
          }) =>
              AppPreferencesCompanion.insert(
            id: id,
            themeMode: themeMode,
            hasCompletedOnboarding: hasCompletedOnboarding,
            activeUserId: activeUserId,
            notificationsEnabled: notificationsEnabled,
            billRemindersEnabled: billRemindersEnabled,
            budgetAlertsEnabled: budgetAlertsEnabled,
            goalRemindersEnabled: goalRemindersEnabled,
            productUpdatesEnabled: productUpdatesEnabled,
            backupDriveEmail: backupDriveEmail,
            lastBackupAt: lastBackupAt,
            backupDriveFileId: backupDriveFileId,
            biometricUnlockEnabled: biometricUnlockEnabled,
            biometricUserId: biometricUserId,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$AppPreferencesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $AppPreferencesTable,
    PreferencesRow,
    $$AppPreferencesTableFilterComposer,
    $$AppPreferencesTableOrderingComposer,
    $$AppPreferencesTableAnnotationComposer,
    $$AppPreferencesTableCreateCompanionBuilder,
    $$AppPreferencesTableUpdateCompanionBuilder,
    (
      PreferencesRow,
      BaseReferences<_$AppDatabase, $AppPreferencesTable, PreferencesRow>
    ),
    PreferencesRow,
    PrefetchHooks Function()>;
typedef $$UserProfilesTableCreateCompanionBuilder = UserProfilesCompanion
    Function({
  required String id,
  required String name,
  required String email,
  Value<String> passwordHash,
  Value<String> passwordSalt,
  Value<String> regionCode,
  Value<String> currencyCode,
  Value<String?> avatarUrl,
  Value<String?> googleId,
  Value<DateTime?> memberSince,
  Value<int> rowid,
});
typedef $$UserProfilesTableUpdateCompanionBuilder = UserProfilesCompanion
    Function({
  Value<String> id,
  Value<String> name,
  Value<String> email,
  Value<String> passwordHash,
  Value<String> passwordSalt,
  Value<String> regionCode,
  Value<String> currencyCode,
  Value<String?> avatarUrl,
  Value<String?> googleId,
  Value<DateTime?> memberSince,
  Value<int> rowid,
});

class $$UserProfilesTableFilterComposer
    extends Composer<_$AppDatabase, $UserProfilesTable> {
  $$UserProfilesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get email => $composableBuilder(
      column: $table.email, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get passwordHash => $composableBuilder(
      column: $table.passwordHash, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get passwordSalt => $composableBuilder(
      column: $table.passwordSalt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get regionCode => $composableBuilder(
      column: $table.regionCode, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get currencyCode => $composableBuilder(
      column: $table.currencyCode, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get avatarUrl => $composableBuilder(
      column: $table.avatarUrl, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get googleId => $composableBuilder(
      column: $table.googleId, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get memberSince => $composableBuilder(
      column: $table.memberSince, builder: (column) => ColumnFilters(column));
}

class $$UserProfilesTableOrderingComposer
    extends Composer<_$AppDatabase, $UserProfilesTable> {
  $$UserProfilesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get email => $composableBuilder(
      column: $table.email, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get passwordHash => $composableBuilder(
      column: $table.passwordHash,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get passwordSalt => $composableBuilder(
      column: $table.passwordSalt,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get regionCode => $composableBuilder(
      column: $table.regionCode, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get currencyCode => $composableBuilder(
      column: $table.currencyCode,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get avatarUrl => $composableBuilder(
      column: $table.avatarUrl, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get googleId => $composableBuilder(
      column: $table.googleId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get memberSince => $composableBuilder(
      column: $table.memberSince, builder: (column) => ColumnOrderings(column));
}

class $$UserProfilesTableAnnotationComposer
    extends Composer<_$AppDatabase, $UserProfilesTable> {
  $$UserProfilesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<String> get passwordHash => $composableBuilder(
      column: $table.passwordHash, builder: (column) => column);

  GeneratedColumn<String> get passwordSalt => $composableBuilder(
      column: $table.passwordSalt, builder: (column) => column);

  GeneratedColumn<String> get regionCode => $composableBuilder(
      column: $table.regionCode, builder: (column) => column);

  GeneratedColumn<String> get currencyCode => $composableBuilder(
      column: $table.currencyCode, builder: (column) => column);

  GeneratedColumn<String> get avatarUrl =>
      $composableBuilder(column: $table.avatarUrl, builder: (column) => column);

  GeneratedColumn<String> get googleId =>
      $composableBuilder(column: $table.googleId, builder: (column) => column);

  GeneratedColumn<DateTime> get memberSince => $composableBuilder(
      column: $table.memberSince, builder: (column) => column);
}

class $$UserProfilesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $UserProfilesTable,
    UserProfileRow,
    $$UserProfilesTableFilterComposer,
    $$UserProfilesTableOrderingComposer,
    $$UserProfilesTableAnnotationComposer,
    $$UserProfilesTableCreateCompanionBuilder,
    $$UserProfilesTableUpdateCompanionBuilder,
    (
      UserProfileRow,
      BaseReferences<_$AppDatabase, $UserProfilesTable, UserProfileRow>
    ),
    UserProfileRow,
    PrefetchHooks Function()> {
  $$UserProfilesTableTableManager(_$AppDatabase db, $UserProfilesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UserProfilesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UserProfilesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UserProfilesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> email = const Value.absent(),
            Value<String> passwordHash = const Value.absent(),
            Value<String> passwordSalt = const Value.absent(),
            Value<String> regionCode = const Value.absent(),
            Value<String> currencyCode = const Value.absent(),
            Value<String?> avatarUrl = const Value.absent(),
            Value<String?> googleId = const Value.absent(),
            Value<DateTime?> memberSince = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              UserProfilesCompanion(
            id: id,
            name: name,
            email: email,
            passwordHash: passwordHash,
            passwordSalt: passwordSalt,
            regionCode: regionCode,
            currencyCode: currencyCode,
            avatarUrl: avatarUrl,
            googleId: googleId,
            memberSince: memberSince,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String name,
            required String email,
            Value<String> passwordHash = const Value.absent(),
            Value<String> passwordSalt = const Value.absent(),
            Value<String> regionCode = const Value.absent(),
            Value<String> currencyCode = const Value.absent(),
            Value<String?> avatarUrl = const Value.absent(),
            Value<String?> googleId = const Value.absent(),
            Value<DateTime?> memberSince = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              UserProfilesCompanion.insert(
            id: id,
            name: name,
            email: email,
            passwordHash: passwordHash,
            passwordSalt: passwordSalt,
            regionCode: regionCode,
            currencyCode: currencyCode,
            avatarUrl: avatarUrl,
            googleId: googleId,
            memberSince: memberSince,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$UserProfilesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $UserProfilesTable,
    UserProfileRow,
    $$UserProfilesTableFilterComposer,
    $$UserProfilesTableOrderingComposer,
    $$UserProfilesTableAnnotationComposer,
    $$UserProfilesTableCreateCompanionBuilder,
    $$UserProfilesTableUpdateCompanionBuilder,
    (
      UserProfileRow,
      BaseReferences<_$AppDatabase, $UserProfilesTable, UserProfileRow>
    ),
    UserProfileRow,
    PrefetchHooks Function()>;
typedef $$SavingGoalsTableCreateCompanionBuilder = SavingGoalsCompanion
    Function({
  required String id,
  Value<String> userId,
  required String name,
  required double targetAmount,
  Value<DateTime?> deadline,
  Value<double?> monthlyTarget,
  Value<String?> wishlistTitle,
  Value<String?> wishlistNote,
  Value<int> priority,
  Value<String> status,
  required DateTime createdAt,
  required DateTime updatedAt,
  Value<int> rowid,
});
typedef $$SavingGoalsTableUpdateCompanionBuilder = SavingGoalsCompanion
    Function({
  Value<String> id,
  Value<String> userId,
  Value<String> name,
  Value<double> targetAmount,
  Value<DateTime?> deadline,
  Value<double?> monthlyTarget,
  Value<String?> wishlistTitle,
  Value<String?> wishlistNote,
  Value<int> priority,
  Value<String> status,
  Value<DateTime> createdAt,
  Value<DateTime> updatedAt,
  Value<int> rowid,
});

final class $$SavingGoalsTableReferences
    extends BaseReferences<_$AppDatabase, $SavingGoalsTable, SavingGoalRow> {
  $$SavingGoalsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$SavingContributionsTable,
      List<SavingContributionRow>> _savingContributionsRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.savingContributions,
          aliasName: $_aliasNameGenerator(
              db.savingGoals.id, db.savingContributions.goalId));

  $$SavingContributionsTableProcessedTableManager get savingContributionsRefs {
    final manager =
        $$SavingContributionsTableTableManager($_db, $_db.savingContributions)
            .filter((f) => f.goalId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache =
        $_typedResult.readTableOrNull(_savingContributionsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$SavingGoalsTableFilterComposer
    extends Composer<_$AppDatabase, $SavingGoalsTable> {
  $$SavingGoalsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get targetAmount => $composableBuilder(
      column: $table.targetAmount, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get deadline => $composableBuilder(
      column: $table.deadline, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get monthlyTarget => $composableBuilder(
      column: $table.monthlyTarget, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get wishlistTitle => $composableBuilder(
      column: $table.wishlistTitle, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get wishlistNote => $composableBuilder(
      column: $table.wishlistNote, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get priority => $composableBuilder(
      column: $table.priority, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));

  Expression<bool> savingContributionsRefs(
      Expression<bool> Function($$SavingContributionsTableFilterComposer f) f) {
    final $$SavingContributionsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.savingContributions,
        getReferencedColumn: (t) => t.goalId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SavingContributionsTableFilterComposer(
              $db: $db,
              $table: $db.savingContributions,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$SavingGoalsTableOrderingComposer
    extends Composer<_$AppDatabase, $SavingGoalsTable> {
  $$SavingGoalsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get targetAmount => $composableBuilder(
      column: $table.targetAmount,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get deadline => $composableBuilder(
      column: $table.deadline, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get monthlyTarget => $composableBuilder(
      column: $table.monthlyTarget,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get wishlistTitle => $composableBuilder(
      column: $table.wishlistTitle,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get wishlistNote => $composableBuilder(
      column: $table.wishlistNote,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get priority => $composableBuilder(
      column: $table.priority, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get status => $composableBuilder(
      column: $table.status, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$SavingGoalsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SavingGoalsTable> {
  $$SavingGoalsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<double> get targetAmount => $composableBuilder(
      column: $table.targetAmount, builder: (column) => column);

  GeneratedColumn<DateTime> get deadline =>
      $composableBuilder(column: $table.deadline, builder: (column) => column);

  GeneratedColumn<double> get monthlyTarget => $composableBuilder(
      column: $table.monthlyTarget, builder: (column) => column);

  GeneratedColumn<String> get wishlistTitle => $composableBuilder(
      column: $table.wishlistTitle, builder: (column) => column);

  GeneratedColumn<String> get wishlistNote => $composableBuilder(
      column: $table.wishlistNote, builder: (column) => column);

  GeneratedColumn<int> get priority =>
      $composableBuilder(column: $table.priority, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> savingContributionsRefs<T extends Object>(
      Expression<T> Function($$SavingContributionsTableAnnotationComposer a)
          f) {
    final $$SavingContributionsTableAnnotationComposer composer =
        $composerBuilder(
            composer: this,
            getCurrentColumn: (t) => t.id,
            referencedTable: $db.savingContributions,
            getReferencedColumn: (t) => t.goalId,
            builder: (joinBuilder,
                    {$addJoinBuilderToRootComposer,
                    $removeJoinBuilderFromRootComposer}) =>
                $$SavingContributionsTableAnnotationComposer(
                  $db: $db,
                  $table: $db.savingContributions,
                  $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                  joinBuilder: joinBuilder,
                  $removeJoinBuilderFromRootComposer:
                      $removeJoinBuilderFromRootComposer,
                ));
    return f(composer);
  }
}

class $$SavingGoalsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SavingGoalsTable,
    SavingGoalRow,
    $$SavingGoalsTableFilterComposer,
    $$SavingGoalsTableOrderingComposer,
    $$SavingGoalsTableAnnotationComposer,
    $$SavingGoalsTableCreateCompanionBuilder,
    $$SavingGoalsTableUpdateCompanionBuilder,
    (SavingGoalRow, $$SavingGoalsTableReferences),
    SavingGoalRow,
    PrefetchHooks Function({bool savingContributionsRefs})> {
  $$SavingGoalsTableTableManager(_$AppDatabase db, $SavingGoalsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SavingGoalsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SavingGoalsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SavingGoalsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> userId = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<double> targetAmount = const Value.absent(),
            Value<DateTime?> deadline = const Value.absent(),
            Value<double?> monthlyTarget = const Value.absent(),
            Value<String?> wishlistTitle = const Value.absent(),
            Value<String?> wishlistNote = const Value.absent(),
            Value<int> priority = const Value.absent(),
            Value<String> status = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<DateTime> updatedAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SavingGoalsCompanion(
            id: id,
            userId: userId,
            name: name,
            targetAmount: targetAmount,
            deadline: deadline,
            monthlyTarget: monthlyTarget,
            wishlistTitle: wishlistTitle,
            wishlistNote: wishlistNote,
            priority: priority,
            status: status,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            Value<String> userId = const Value.absent(),
            required String name,
            required double targetAmount,
            Value<DateTime?> deadline = const Value.absent(),
            Value<double?> monthlyTarget = const Value.absent(),
            Value<String?> wishlistTitle = const Value.absent(),
            Value<String?> wishlistNote = const Value.absent(),
            Value<int> priority = const Value.absent(),
            Value<String> status = const Value.absent(),
            required DateTime createdAt,
            required DateTime updatedAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              SavingGoalsCompanion.insert(
            id: id,
            userId: userId,
            name: name,
            targetAmount: targetAmount,
            deadline: deadline,
            monthlyTarget: monthlyTarget,
            wishlistTitle: wishlistTitle,
            wishlistNote: wishlistNote,
            priority: priority,
            status: status,
            createdAt: createdAt,
            updatedAt: updatedAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$SavingGoalsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({savingContributionsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (savingContributionsRefs) db.savingContributions
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (savingContributionsRefs)
                    await $_getPrefetchedData<SavingGoalRow, $SavingGoalsTable,
                            SavingContributionRow>(
                        currentTable: table,
                        referencedTable: $$SavingGoalsTableReferences
                            ._savingContributionsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$SavingGoalsTableReferences(db, table, p0)
                                .savingContributionsRefs,
                        referencedItemsForCurrentItem: (item,
                                referencedItems) =>
                            referencedItems.where((e) => e.goalId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$SavingGoalsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SavingGoalsTable,
    SavingGoalRow,
    $$SavingGoalsTableFilterComposer,
    $$SavingGoalsTableOrderingComposer,
    $$SavingGoalsTableAnnotationComposer,
    $$SavingGoalsTableCreateCompanionBuilder,
    $$SavingGoalsTableUpdateCompanionBuilder,
    (SavingGoalRow, $$SavingGoalsTableReferences),
    SavingGoalRow,
    PrefetchHooks Function({bool savingContributionsRefs})>;
typedef $$SavingContributionsTableCreateCompanionBuilder
    = SavingContributionsCompanion Function({
  required String id,
  Value<String> userId,
  required String goalId,
  required double amount,
  Value<String> note,
  required DateTime date,
  required DateTime createdAt,
  Value<int> rowid,
});
typedef $$SavingContributionsTableUpdateCompanionBuilder
    = SavingContributionsCompanion Function({
  Value<String> id,
  Value<String> userId,
  Value<String> goalId,
  Value<double> amount,
  Value<String> note,
  Value<DateTime> date,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

final class $$SavingContributionsTableReferences extends BaseReferences<
    _$AppDatabase, $SavingContributionsTable, SavingContributionRow> {
  $$SavingContributionsTableReferences(
      super.$_db, super.$_table, super.$_typedResult);

  static $SavingGoalsTable _goalIdTable(_$AppDatabase db) =>
      db.savingGoals.createAlias($_aliasNameGenerator(
          db.savingContributions.goalId, db.savingGoals.id));

  $$SavingGoalsTableProcessedTableManager get goalId {
    final $_column = $_itemColumn<String>('goal_id')!;

    final manager = $$SavingGoalsTableTableManager($_db, $_db.savingGoals)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_goalIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$SavingContributionsTableFilterComposer
    extends Composer<_$AppDatabase, $SavingContributionsTable> {
  $$SavingContributionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get amount => $composableBuilder(
      column: $table.amount, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get note => $composableBuilder(
      column: $table.note, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  $$SavingGoalsTableFilterComposer get goalId {
    final $$SavingGoalsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.goalId,
        referencedTable: $db.savingGoals,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SavingGoalsTableFilterComposer(
              $db: $db,
              $table: $db.savingGoals,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$SavingContributionsTableOrderingComposer
    extends Composer<_$AppDatabase, $SavingContributionsTable> {
  $$SavingContributionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get userId => $composableBuilder(
      column: $table.userId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get amount => $composableBuilder(
      column: $table.amount, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get note => $composableBuilder(
      column: $table.note, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  $$SavingGoalsTableOrderingComposer get goalId {
    final $$SavingGoalsTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.goalId,
        referencedTable: $db.savingGoals,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SavingGoalsTableOrderingComposer(
              $db: $db,
              $table: $db.savingGoals,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$SavingContributionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SavingContributionsTable> {
  $$SavingContributionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get userId =>
      $composableBuilder(column: $table.userId, builder: (column) => column);

  GeneratedColumn<double> get amount =>
      $composableBuilder(column: $table.amount, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$SavingGoalsTableAnnotationComposer get goalId {
    final $$SavingGoalsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.goalId,
        referencedTable: $db.savingGoals,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SavingGoalsTableAnnotationComposer(
              $db: $db,
              $table: $db.savingGoals,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$SavingContributionsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SavingContributionsTable,
    SavingContributionRow,
    $$SavingContributionsTableFilterComposer,
    $$SavingContributionsTableOrderingComposer,
    $$SavingContributionsTableAnnotationComposer,
    $$SavingContributionsTableCreateCompanionBuilder,
    $$SavingContributionsTableUpdateCompanionBuilder,
    (SavingContributionRow, $$SavingContributionsTableReferences),
    SavingContributionRow,
    PrefetchHooks Function({bool goalId})> {
  $$SavingContributionsTableTableManager(
      _$AppDatabase db, $SavingContributionsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SavingContributionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SavingContributionsTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SavingContributionsTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> userId = const Value.absent(),
            Value<String> goalId = const Value.absent(),
            Value<double> amount = const Value.absent(),
            Value<String> note = const Value.absent(),
            Value<DateTime> date = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SavingContributionsCompanion(
            id: id,
            userId: userId,
            goalId: goalId,
            amount: amount,
            note: note,
            date: date,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            Value<String> userId = const Value.absent(),
            required String goalId,
            required double amount,
            Value<String> note = const Value.absent(),
            required DateTime date,
            required DateTime createdAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              SavingContributionsCompanion.insert(
            id: id,
            userId: userId,
            goalId: goalId,
            amount: amount,
            note: note,
            date: date,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (
                    e.readTable(table),
                    $$SavingContributionsTableReferences(db, table, e)
                  ))
              .toList(),
          prefetchHooksCallback: ({goalId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
                  T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic>>(state) {
                if (goalId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.goalId,
                    referencedTable:
                        $$SavingContributionsTableReferences._goalIdTable(db),
                    referencedColumn: $$SavingContributionsTableReferences
                        ._goalIdTable(db)
                        .id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$SavingContributionsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SavingContributionsTable,
    SavingContributionRow,
    $$SavingContributionsTableFilterComposer,
    $$SavingContributionsTableOrderingComposer,
    $$SavingContributionsTableAnnotationComposer,
    $$SavingContributionsTableCreateCompanionBuilder,
    $$SavingContributionsTableUpdateCompanionBuilder,
    (SavingContributionRow, $$SavingContributionsTableReferences),
    SavingContributionRow,
    PrefetchHooks Function({bool goalId})>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$CategoriesTableTableManager get categories =>
      $$CategoriesTableTableManager(_db, _db.categories);
  $$ExpensesTableTableManager get expenses =>
      $$ExpensesTableTableManager(_db, _db.expenses);
  $$BudgetsTableTableManager get budgets =>
      $$BudgetsTableTableManager(_db, _db.budgets);
  $$RecurringExpensesTableTableManager get recurringExpenses =>
      $$RecurringExpensesTableTableManager(_db, _db.recurringExpenses);
  $$AppPreferencesTableTableManager get appPreferences =>
      $$AppPreferencesTableTableManager(_db, _db.appPreferences);
  $$UserProfilesTableTableManager get userProfiles =>
      $$UserProfilesTableTableManager(_db, _db.userProfiles);
  $$SavingGoalsTableTableManager get savingGoals =>
      $$SavingGoalsTableTableManager(_db, _db.savingGoals);
  $$SavingContributionsTableTableManager get savingContributions =>
      $$SavingContributionsTableTableManager(_db, _db.savingContributions);
}
