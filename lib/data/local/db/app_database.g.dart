// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $DevicesTableTable extends DevicesTable
    with TableInfo<$DevicesTableTable, DevicesTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DevicesTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _parentIdMeta = const VerificationMeta(
    'parentId',
  );
  @override
  late final GeneratedColumn<String> parentId = GeneratedColumn<String>(
    'parent_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('active'),
  );
  static const VerificationMeta _usageUnitMeta = const VerificationMeta(
    'usageUnit',
  );
  @override
  late final GeneratedColumn<String> usageUnit = GeneratedColumn<String>(
    'usage_unit',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _currentUsageMeta = const VerificationMeta(
    'currentUsage',
  );
  @override
  late final GeneratedColumn<int> currentUsage = GeneratedColumn<int>(
    'current_usage',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _scheduleTypeMeta = const VerificationMeta(
    'scheduleType',
  );
  @override
  late final GeneratedColumn<String> scheduleType = GeneratedColumn<String>(
    'schedule_type',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _intervalValueMeta = const VerificationMeta(
    'intervalValue',
  );
  @override
  late final GeneratedColumn<int> intervalValue = GeneratedColumn<int>(
    'interval_value',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _intervalUnitMeta = const VerificationMeta(
    'intervalUnit',
  );
  @override
  late final GeneratedColumn<String> intervalUnit = GeneratedColumn<String>(
    'interval_unit',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _fixedDueAtMeta = const VerificationMeta(
    'fixedDueAt',
  );
  @override
  late final GeneratedColumn<DateTime> fixedDueAt = GeneratedColumn<DateTime>(
    'fixed_due_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastMaintainedAtMeta = const VerificationMeta(
    'lastMaintainedAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastMaintainedAt =
      GeneratedColumn<DateTime>(
        'last_maintained_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _usageAtLastMaintenanceMeta =
      const VerificationMeta('usageAtLastMaintenance');
  @override
  late final GeneratedColumn<int> usageAtLastMaintenance = GeneratedColumn<int>(
    'usage_at_last_maintenance',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    parentId,
    name,
    description,
    status,
    usageUnit,
    currentUsage,
    scheduleType,
    intervalValue,
    intervalUnit,
    fixedDueAt,
    lastMaintainedAt,
    usageAtLastMaintenance,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'devices_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<DevicesTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('parent_id')) {
      context.handle(
        _parentIdMeta,
        parentId.isAcceptableOrUnknown(data['parent_id']!, _parentIdMeta),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('usage_unit')) {
      context.handle(
        _usageUnitMeta,
        usageUnit.isAcceptableOrUnknown(data['usage_unit']!, _usageUnitMeta),
      );
    }
    if (data.containsKey('current_usage')) {
      context.handle(
        _currentUsageMeta,
        currentUsage.isAcceptableOrUnknown(
          data['current_usage']!,
          _currentUsageMeta,
        ),
      );
    }
    if (data.containsKey('schedule_type')) {
      context.handle(
        _scheduleTypeMeta,
        scheduleType.isAcceptableOrUnknown(
          data['schedule_type']!,
          _scheduleTypeMeta,
        ),
      );
    }
    if (data.containsKey('interval_value')) {
      context.handle(
        _intervalValueMeta,
        intervalValue.isAcceptableOrUnknown(
          data['interval_value']!,
          _intervalValueMeta,
        ),
      );
    }
    if (data.containsKey('interval_unit')) {
      context.handle(
        _intervalUnitMeta,
        intervalUnit.isAcceptableOrUnknown(
          data['interval_unit']!,
          _intervalUnitMeta,
        ),
      );
    }
    if (data.containsKey('fixed_due_at')) {
      context.handle(
        _fixedDueAtMeta,
        fixedDueAt.isAcceptableOrUnknown(
          data['fixed_due_at']!,
          _fixedDueAtMeta,
        ),
      );
    }
    if (data.containsKey('last_maintained_at')) {
      context.handle(
        _lastMaintainedAtMeta,
        lastMaintainedAt.isAcceptableOrUnknown(
          data['last_maintained_at']!,
          _lastMaintainedAtMeta,
        ),
      );
    }
    if (data.containsKey('usage_at_last_maintenance')) {
      context.handle(
        _usageAtLastMaintenanceMeta,
        usageAtLastMaintenance.isAcceptableOrUnknown(
          data['usage_at_last_maintenance']!,
          _usageAtLastMaintenanceMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DevicesTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DevicesTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      parentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}parent_id'],
      ),
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      usageUnit: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}usage_unit'],
      ),
      currentUsage: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}current_usage'],
      )!,
      scheduleType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}schedule_type'],
      ),
      intervalValue: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}interval_value'],
      ),
      intervalUnit: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}interval_unit'],
      ),
      fixedDueAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}fixed_due_at'],
      ),
      lastMaintainedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_maintained_at'],
      ),
      usageAtLastMaintenance: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}usage_at_last_maintenance'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $DevicesTableTable createAlias(String alias) {
    return $DevicesTableTable(attachedDatabase, alias);
  }
}

class DevicesTableData extends DataClass
    implements Insertable<DevicesTableData> {
  final String id;
  final String? parentId;
  final String name;
  final String? description;
  final String status;
  final String? usageUnit;
  final int currentUsage;
  final String? scheduleType;
  final int? intervalValue;
  final String? intervalUnit;
  final DateTime? fixedDueAt;
  final DateTime? lastMaintainedAt;
  final int usageAtLastMaintenance;
  final DateTime createdAt;
  final DateTime updatedAt;
  const DevicesTableData({
    required this.id,
    this.parentId,
    required this.name,
    this.description,
    required this.status,
    this.usageUnit,
    required this.currentUsage,
    this.scheduleType,
    this.intervalValue,
    this.intervalUnit,
    this.fixedDueAt,
    this.lastMaintainedAt,
    required this.usageAtLastMaintenance,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || parentId != null) {
      map['parent_id'] = Variable<String>(parentId);
    }
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || usageUnit != null) {
      map['usage_unit'] = Variable<String>(usageUnit);
    }
    map['current_usage'] = Variable<int>(currentUsage);
    if (!nullToAbsent || scheduleType != null) {
      map['schedule_type'] = Variable<String>(scheduleType);
    }
    if (!nullToAbsent || intervalValue != null) {
      map['interval_value'] = Variable<int>(intervalValue);
    }
    if (!nullToAbsent || intervalUnit != null) {
      map['interval_unit'] = Variable<String>(intervalUnit);
    }
    if (!nullToAbsent || fixedDueAt != null) {
      map['fixed_due_at'] = Variable<DateTime>(fixedDueAt);
    }
    if (!nullToAbsent || lastMaintainedAt != null) {
      map['last_maintained_at'] = Variable<DateTime>(lastMaintainedAt);
    }
    map['usage_at_last_maintenance'] = Variable<int>(usageAtLastMaintenance);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  DevicesTableCompanion toCompanion(bool nullToAbsent) {
    return DevicesTableCompanion(
      id: Value(id),
      parentId: parentId == null && nullToAbsent
          ? const Value.absent()
          : Value(parentId),
      name: Value(name),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      status: Value(status),
      usageUnit: usageUnit == null && nullToAbsent
          ? const Value.absent()
          : Value(usageUnit),
      currentUsage: Value(currentUsage),
      scheduleType: scheduleType == null && nullToAbsent
          ? const Value.absent()
          : Value(scheduleType),
      intervalValue: intervalValue == null && nullToAbsent
          ? const Value.absent()
          : Value(intervalValue),
      intervalUnit: intervalUnit == null && nullToAbsent
          ? const Value.absent()
          : Value(intervalUnit),
      fixedDueAt: fixedDueAt == null && nullToAbsent
          ? const Value.absent()
          : Value(fixedDueAt),
      lastMaintainedAt: lastMaintainedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastMaintainedAt),
      usageAtLastMaintenance: Value(usageAtLastMaintenance),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory DevicesTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DevicesTableData(
      id: serializer.fromJson<String>(json['id']),
      parentId: serializer.fromJson<String?>(json['parentId']),
      name: serializer.fromJson<String>(json['name']),
      description: serializer.fromJson<String?>(json['description']),
      status: serializer.fromJson<String>(json['status']),
      usageUnit: serializer.fromJson<String?>(json['usageUnit']),
      currentUsage: serializer.fromJson<int>(json['currentUsage']),
      scheduleType: serializer.fromJson<String?>(json['scheduleType']),
      intervalValue: serializer.fromJson<int?>(json['intervalValue']),
      intervalUnit: serializer.fromJson<String?>(json['intervalUnit']),
      fixedDueAt: serializer.fromJson<DateTime?>(json['fixedDueAt']),
      lastMaintainedAt: serializer.fromJson<DateTime?>(
        json['lastMaintainedAt'],
      ),
      usageAtLastMaintenance: serializer.fromJson<int>(
        json['usageAtLastMaintenance'],
      ),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'parentId': serializer.toJson<String?>(parentId),
      'name': serializer.toJson<String>(name),
      'description': serializer.toJson<String?>(description),
      'status': serializer.toJson<String>(status),
      'usageUnit': serializer.toJson<String?>(usageUnit),
      'currentUsage': serializer.toJson<int>(currentUsage),
      'scheduleType': serializer.toJson<String?>(scheduleType),
      'intervalValue': serializer.toJson<int?>(intervalValue),
      'intervalUnit': serializer.toJson<String?>(intervalUnit),
      'fixedDueAt': serializer.toJson<DateTime?>(fixedDueAt),
      'lastMaintainedAt': serializer.toJson<DateTime?>(lastMaintainedAt),
      'usageAtLastMaintenance': serializer.toJson<int>(usageAtLastMaintenance),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  DevicesTableData copyWith({
    String? id,
    Value<String?> parentId = const Value.absent(),
    String? name,
    Value<String?> description = const Value.absent(),
    String? status,
    Value<String?> usageUnit = const Value.absent(),
    int? currentUsage,
    Value<String?> scheduleType = const Value.absent(),
    Value<int?> intervalValue = const Value.absent(),
    Value<String?> intervalUnit = const Value.absent(),
    Value<DateTime?> fixedDueAt = const Value.absent(),
    Value<DateTime?> lastMaintainedAt = const Value.absent(),
    int? usageAtLastMaintenance,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => DevicesTableData(
    id: id ?? this.id,
    parentId: parentId.present ? parentId.value : this.parentId,
    name: name ?? this.name,
    description: description.present ? description.value : this.description,
    status: status ?? this.status,
    usageUnit: usageUnit.present ? usageUnit.value : this.usageUnit,
    currentUsage: currentUsage ?? this.currentUsage,
    scheduleType: scheduleType.present ? scheduleType.value : this.scheduleType,
    intervalValue: intervalValue.present
        ? intervalValue.value
        : this.intervalValue,
    intervalUnit: intervalUnit.present ? intervalUnit.value : this.intervalUnit,
    fixedDueAt: fixedDueAt.present ? fixedDueAt.value : this.fixedDueAt,
    lastMaintainedAt: lastMaintainedAt.present
        ? lastMaintainedAt.value
        : this.lastMaintainedAt,
    usageAtLastMaintenance:
        usageAtLastMaintenance ?? this.usageAtLastMaintenance,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  DevicesTableData copyWithCompanion(DevicesTableCompanion data) {
    return DevicesTableData(
      id: data.id.present ? data.id.value : this.id,
      parentId: data.parentId.present ? data.parentId.value : this.parentId,
      name: data.name.present ? data.name.value : this.name,
      description: data.description.present
          ? data.description.value
          : this.description,
      status: data.status.present ? data.status.value : this.status,
      usageUnit: data.usageUnit.present ? data.usageUnit.value : this.usageUnit,
      currentUsage: data.currentUsage.present
          ? data.currentUsage.value
          : this.currentUsage,
      scheduleType: data.scheduleType.present
          ? data.scheduleType.value
          : this.scheduleType,
      intervalValue: data.intervalValue.present
          ? data.intervalValue.value
          : this.intervalValue,
      intervalUnit: data.intervalUnit.present
          ? data.intervalUnit.value
          : this.intervalUnit,
      fixedDueAt: data.fixedDueAt.present
          ? data.fixedDueAt.value
          : this.fixedDueAt,
      lastMaintainedAt: data.lastMaintainedAt.present
          ? data.lastMaintainedAt.value
          : this.lastMaintainedAt,
      usageAtLastMaintenance: data.usageAtLastMaintenance.present
          ? data.usageAtLastMaintenance.value
          : this.usageAtLastMaintenance,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DevicesTableData(')
          ..write('id: $id, ')
          ..write('parentId: $parentId, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('status: $status, ')
          ..write('usageUnit: $usageUnit, ')
          ..write('currentUsage: $currentUsage, ')
          ..write('scheduleType: $scheduleType, ')
          ..write('intervalValue: $intervalValue, ')
          ..write('intervalUnit: $intervalUnit, ')
          ..write('fixedDueAt: $fixedDueAt, ')
          ..write('lastMaintainedAt: $lastMaintainedAt, ')
          ..write('usageAtLastMaintenance: $usageAtLastMaintenance, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    parentId,
    name,
    description,
    status,
    usageUnit,
    currentUsage,
    scheduleType,
    intervalValue,
    intervalUnit,
    fixedDueAt,
    lastMaintainedAt,
    usageAtLastMaintenance,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DevicesTableData &&
          other.id == this.id &&
          other.parentId == this.parentId &&
          other.name == this.name &&
          other.description == this.description &&
          other.status == this.status &&
          other.usageUnit == this.usageUnit &&
          other.currentUsage == this.currentUsage &&
          other.scheduleType == this.scheduleType &&
          other.intervalValue == this.intervalValue &&
          other.intervalUnit == this.intervalUnit &&
          other.fixedDueAt == this.fixedDueAt &&
          other.lastMaintainedAt == this.lastMaintainedAt &&
          other.usageAtLastMaintenance == this.usageAtLastMaintenance &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class DevicesTableCompanion extends UpdateCompanion<DevicesTableData> {
  final Value<String> id;
  final Value<String?> parentId;
  final Value<String> name;
  final Value<String?> description;
  final Value<String> status;
  final Value<String?> usageUnit;
  final Value<int> currentUsage;
  final Value<String?> scheduleType;
  final Value<int?> intervalValue;
  final Value<String?> intervalUnit;
  final Value<DateTime?> fixedDueAt;
  final Value<DateTime?> lastMaintainedAt;
  final Value<int> usageAtLastMaintenance;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const DevicesTableCompanion({
    this.id = const Value.absent(),
    this.parentId = const Value.absent(),
    this.name = const Value.absent(),
    this.description = const Value.absent(),
    this.status = const Value.absent(),
    this.usageUnit = const Value.absent(),
    this.currentUsage = const Value.absent(),
    this.scheduleType = const Value.absent(),
    this.intervalValue = const Value.absent(),
    this.intervalUnit = const Value.absent(),
    this.fixedDueAt = const Value.absent(),
    this.lastMaintainedAt = const Value.absent(),
    this.usageAtLastMaintenance = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DevicesTableCompanion.insert({
    required String id,
    this.parentId = const Value.absent(),
    required String name,
    this.description = const Value.absent(),
    this.status = const Value.absent(),
    this.usageUnit = const Value.absent(),
    this.currentUsage = const Value.absent(),
    this.scheduleType = const Value.absent(),
    this.intervalValue = const Value.absent(),
    this.intervalUnit = const Value.absent(),
    this.fixedDueAt = const Value.absent(),
    this.lastMaintainedAt = const Value.absent(),
    this.usageAtLastMaintenance = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<DevicesTableData> custom({
    Expression<String>? id,
    Expression<String>? parentId,
    Expression<String>? name,
    Expression<String>? description,
    Expression<String>? status,
    Expression<String>? usageUnit,
    Expression<int>? currentUsage,
    Expression<String>? scheduleType,
    Expression<int>? intervalValue,
    Expression<String>? intervalUnit,
    Expression<DateTime>? fixedDueAt,
    Expression<DateTime>? lastMaintainedAt,
    Expression<int>? usageAtLastMaintenance,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (parentId != null) 'parent_id': parentId,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (status != null) 'status': status,
      if (usageUnit != null) 'usage_unit': usageUnit,
      if (currentUsage != null) 'current_usage': currentUsage,
      if (scheduleType != null) 'schedule_type': scheduleType,
      if (intervalValue != null) 'interval_value': intervalValue,
      if (intervalUnit != null) 'interval_unit': intervalUnit,
      if (fixedDueAt != null) 'fixed_due_at': fixedDueAt,
      if (lastMaintainedAt != null) 'last_maintained_at': lastMaintainedAt,
      if (usageAtLastMaintenance != null)
        'usage_at_last_maintenance': usageAtLastMaintenance,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DevicesTableCompanion copyWith({
    Value<String>? id,
    Value<String?>? parentId,
    Value<String>? name,
    Value<String?>? description,
    Value<String>? status,
    Value<String?>? usageUnit,
    Value<int>? currentUsage,
    Value<String?>? scheduleType,
    Value<int?>? intervalValue,
    Value<String?>? intervalUnit,
    Value<DateTime?>? fixedDueAt,
    Value<DateTime?>? lastMaintainedAt,
    Value<int>? usageAtLastMaintenance,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return DevicesTableCompanion(
      id: id ?? this.id,
      parentId: parentId ?? this.parentId,
      name: name ?? this.name,
      description: description ?? this.description,
      status: status ?? this.status,
      usageUnit: usageUnit ?? this.usageUnit,
      currentUsage: currentUsage ?? this.currentUsage,
      scheduleType: scheduleType ?? this.scheduleType,
      intervalValue: intervalValue ?? this.intervalValue,
      intervalUnit: intervalUnit ?? this.intervalUnit,
      fixedDueAt: fixedDueAt ?? this.fixedDueAt,
      lastMaintainedAt: lastMaintainedAt ?? this.lastMaintainedAt,
      usageAtLastMaintenance:
          usageAtLastMaintenance ?? this.usageAtLastMaintenance,
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
    if (parentId.present) {
      map['parent_id'] = Variable<String>(parentId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (usageUnit.present) {
      map['usage_unit'] = Variable<String>(usageUnit.value);
    }
    if (currentUsage.present) {
      map['current_usage'] = Variable<int>(currentUsage.value);
    }
    if (scheduleType.present) {
      map['schedule_type'] = Variable<String>(scheduleType.value);
    }
    if (intervalValue.present) {
      map['interval_value'] = Variable<int>(intervalValue.value);
    }
    if (intervalUnit.present) {
      map['interval_unit'] = Variable<String>(intervalUnit.value);
    }
    if (fixedDueAt.present) {
      map['fixed_due_at'] = Variable<DateTime>(fixedDueAt.value);
    }
    if (lastMaintainedAt.present) {
      map['last_maintained_at'] = Variable<DateTime>(lastMaintainedAt.value);
    }
    if (usageAtLastMaintenance.present) {
      map['usage_at_last_maintenance'] = Variable<int>(
        usageAtLastMaintenance.value,
      );
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
    return (StringBuffer('DevicesTableCompanion(')
          ..write('id: $id, ')
          ..write('parentId: $parentId, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('status: $status, ')
          ..write('usageUnit: $usageUnit, ')
          ..write('currentUsage: $currentUsage, ')
          ..write('scheduleType: $scheduleType, ')
          ..write('intervalValue: $intervalValue, ')
          ..write('intervalUnit: $intervalUnit, ')
          ..write('fixedDueAt: $fixedDueAt, ')
          ..write('lastMaintainedAt: $lastMaintainedAt, ')
          ..write('usageAtLastMaintenance: $usageAtLastMaintenance, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DeviceLogsTableTable extends DeviceLogsTable
    with TableInfo<$DeviceLogsTableTable, DeviceLogsTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DeviceLogsTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES devices_table (id)',
    ),
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('maintenanceDone'),
  );
  static const VerificationMeta _usageValueMeta = const VerificationMeta(
    'usageValue',
  );
  @override
  late final GeneratedColumn<int> usageValue = GeneratedColumn<int>(
    'usage_value',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _usageUnitMeta = const VerificationMeta(
    'usageUnit',
  );
  @override
  late final GeneratedColumn<String> usageUnit = GeneratedColumn<String>(
    'usage_unit',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    deviceId,
    date,
    notes,
    kind,
    usageValue,
    usageUnit,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'device_logs_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<DeviceLogsTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_deviceIdMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    }
    if (data.containsKey('usage_value')) {
      context.handle(
        _usageValueMeta,
        usageValue.isAcceptableOrUnknown(data['usage_value']!, _usageValueMeta),
      );
    }
    if (data.containsKey('usage_unit')) {
      context.handle(
        _usageUnitMeta,
        usageUnit.isAcceptableOrUnknown(data['usage_unit']!, _usageUnitMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DeviceLogsTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DeviceLogsTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      usageValue: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}usage_value'],
      ),
      usageUnit: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}usage_unit'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $DeviceLogsTableTable createAlias(String alias) {
    return $DeviceLogsTableTable(attachedDatabase, alias);
  }
}

class DeviceLogsTableData extends DataClass
    implements Insertable<DeviceLogsTableData> {
  final String id;
  final String deviceId;
  final DateTime date;
  final String? notes;
  final String kind;
  final int? usageValue;
  final String? usageUnit;
  final DateTime createdAt;
  const DeviceLogsTableData({
    required this.id,
    required this.deviceId,
    required this.date,
    this.notes,
    required this.kind,
    this.usageValue,
    this.usageUnit,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['device_id'] = Variable<String>(deviceId);
    map['date'] = Variable<DateTime>(date);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['kind'] = Variable<String>(kind);
    if (!nullToAbsent || usageValue != null) {
      map['usage_value'] = Variable<int>(usageValue);
    }
    if (!nullToAbsent || usageUnit != null) {
      map['usage_unit'] = Variable<String>(usageUnit);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  DeviceLogsTableCompanion toCompanion(bool nullToAbsent) {
    return DeviceLogsTableCompanion(
      id: Value(id),
      deviceId: Value(deviceId),
      date: Value(date),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      kind: Value(kind),
      usageValue: usageValue == null && nullToAbsent
          ? const Value.absent()
          : Value(usageValue),
      usageUnit: usageUnit == null && nullToAbsent
          ? const Value.absent()
          : Value(usageUnit),
      createdAt: Value(createdAt),
    );
  }

  factory DeviceLogsTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DeviceLogsTableData(
      id: serializer.fromJson<String>(json['id']),
      deviceId: serializer.fromJson<String>(json['deviceId']),
      date: serializer.fromJson<DateTime>(json['date']),
      notes: serializer.fromJson<String?>(json['notes']),
      kind: serializer.fromJson<String>(json['kind']),
      usageValue: serializer.fromJson<int?>(json['usageValue']),
      usageUnit: serializer.fromJson<String?>(json['usageUnit']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'deviceId': serializer.toJson<String>(deviceId),
      'date': serializer.toJson<DateTime>(date),
      'notes': serializer.toJson<String?>(notes),
      'kind': serializer.toJson<String>(kind),
      'usageValue': serializer.toJson<int?>(usageValue),
      'usageUnit': serializer.toJson<String?>(usageUnit),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  DeviceLogsTableData copyWith({
    String? id,
    String? deviceId,
    DateTime? date,
    Value<String?> notes = const Value.absent(),
    String? kind,
    Value<int?> usageValue = const Value.absent(),
    Value<String?> usageUnit = const Value.absent(),
    DateTime? createdAt,
  }) => DeviceLogsTableData(
    id: id ?? this.id,
    deviceId: deviceId ?? this.deviceId,
    date: date ?? this.date,
    notes: notes.present ? notes.value : this.notes,
    kind: kind ?? this.kind,
    usageValue: usageValue.present ? usageValue.value : this.usageValue,
    usageUnit: usageUnit.present ? usageUnit.value : this.usageUnit,
    createdAt: createdAt ?? this.createdAt,
  );
  DeviceLogsTableData copyWithCompanion(DeviceLogsTableCompanion data) {
    return DeviceLogsTableData(
      id: data.id.present ? data.id.value : this.id,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      date: data.date.present ? data.date.value : this.date,
      notes: data.notes.present ? data.notes.value : this.notes,
      kind: data.kind.present ? data.kind.value : this.kind,
      usageValue: data.usageValue.present
          ? data.usageValue.value
          : this.usageValue,
      usageUnit: data.usageUnit.present ? data.usageUnit.value : this.usageUnit,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DeviceLogsTableData(')
          ..write('id: $id, ')
          ..write('deviceId: $deviceId, ')
          ..write('date: $date, ')
          ..write('notes: $notes, ')
          ..write('kind: $kind, ')
          ..write('usageValue: $usageValue, ')
          ..write('usageUnit: $usageUnit, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    deviceId,
    date,
    notes,
    kind,
    usageValue,
    usageUnit,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DeviceLogsTableData &&
          other.id == this.id &&
          other.deviceId == this.deviceId &&
          other.date == this.date &&
          other.notes == this.notes &&
          other.kind == this.kind &&
          other.usageValue == this.usageValue &&
          other.usageUnit == this.usageUnit &&
          other.createdAt == this.createdAt);
}

class DeviceLogsTableCompanion extends UpdateCompanion<DeviceLogsTableData> {
  final Value<String> id;
  final Value<String> deviceId;
  final Value<DateTime> date;
  final Value<String?> notes;
  final Value<String> kind;
  final Value<int?> usageValue;
  final Value<String?> usageUnit;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const DeviceLogsTableCompanion({
    this.id = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.date = const Value.absent(),
    this.notes = const Value.absent(),
    this.kind = const Value.absent(),
    this.usageValue = const Value.absent(),
    this.usageUnit = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DeviceLogsTableCompanion.insert({
    required String id,
    required String deviceId,
    required DateTime date,
    this.notes = const Value.absent(),
    this.kind = const Value.absent(),
    this.usageValue = const Value.absent(),
    this.usageUnit = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       deviceId = Value(deviceId),
       date = Value(date),
       createdAt = Value(createdAt);
  static Insertable<DeviceLogsTableData> custom({
    Expression<String>? id,
    Expression<String>? deviceId,
    Expression<DateTime>? date,
    Expression<String>? notes,
    Expression<String>? kind,
    Expression<int>? usageValue,
    Expression<String>? usageUnit,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (deviceId != null) 'device_id': deviceId,
      if (date != null) 'date': date,
      if (notes != null) 'notes': notes,
      if (kind != null) 'kind': kind,
      if (usageValue != null) 'usage_value': usageValue,
      if (usageUnit != null) 'usage_unit': usageUnit,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DeviceLogsTableCompanion copyWith({
    Value<String>? id,
    Value<String>? deviceId,
    Value<DateTime>? date,
    Value<String?>? notes,
    Value<String>? kind,
    Value<int?>? usageValue,
    Value<String?>? usageUnit,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return DeviceLogsTableCompanion(
      id: id ?? this.id,
      deviceId: deviceId ?? this.deviceId,
      date: date ?? this.date,
      notes: notes ?? this.notes,
      kind: kind ?? this.kind,
      usageValue: usageValue ?? this.usageValue,
      usageUnit: usageUnit ?? this.usageUnit,
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
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (usageValue.present) {
      map['usage_value'] = Variable<int>(usageValue.value);
    }
    if (usageUnit.present) {
      map['usage_unit'] = Variable<String>(usageUnit.value);
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
    return (StringBuffer('DeviceLogsTableCompanion(')
          ..write('id: $id, ')
          ..write('deviceId: $deviceId, ')
          ..write('date: $date, ')
          ..write('notes: $notes, ')
          ..write('kind: $kind, ')
          ..write('usageValue: $usageValue, ')
          ..write('usageUnit: $usageUnit, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $BirthdaysTableTable extends BirthdaysTable
    with TableInfo<$BirthdaysTableTable, BirthdaysTableData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BirthdaysTableTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _birthMonthMeta = const VerificationMeta(
    'birthMonth',
  );
  @override
  late final GeneratedColumn<int> birthMonth = GeneratedColumn<int>(
    'birth_month',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _birthDayMeta = const VerificationMeta(
    'birthDay',
  );
  @override
  late final GeneratedColumn<int> birthDay = GeneratedColumn<int>(
    'birth_day',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _calendarSystemMeta = const VerificationMeta(
    'calendarSystem',
  );
  @override
  late final GeneratedColumn<String> calendarSystem = GeneratedColumn<String>(
    'calendar_system',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('gregorian'),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    birthMonth,
    birthDay,
    calendarSystem,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'birthdays_table';
  @override
  VerificationContext validateIntegrity(
    Insertable<BirthdaysTableData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('birth_month')) {
      context.handle(
        _birthMonthMeta,
        birthMonth.isAcceptableOrUnknown(data['birth_month']!, _birthMonthMeta),
      );
    } else if (isInserting) {
      context.missing(_birthMonthMeta);
    }
    if (data.containsKey('birth_day')) {
      context.handle(
        _birthDayMeta,
        birthDay.isAcceptableOrUnknown(data['birth_day']!, _birthDayMeta),
      );
    } else if (isInserting) {
      context.missing(_birthDayMeta);
    }
    if (data.containsKey('calendar_system')) {
      context.handle(
        _calendarSystemMeta,
        calendarSystem.isAcceptableOrUnknown(
          data['calendar_system']!,
          _calendarSystemMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  BirthdaysTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BirthdaysTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      birthMonth: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}birth_month'],
      )!,
      birthDay: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}birth_day'],
      )!,
      calendarSystem: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}calendar_system'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $BirthdaysTableTable createAlias(String alias) {
    return $BirthdaysTableTable(attachedDatabase, alias);
  }
}

class BirthdaysTableData extends DataClass
    implements Insertable<BirthdaysTableData> {
  final String id;
  final String name;
  final int birthMonth;
  final int birthDay;
  final String calendarSystem;
  final DateTime createdAt;
  final DateTime updatedAt;
  const BirthdaysTableData({
    required this.id,
    required this.name,
    required this.birthMonth,
    required this.birthDay,
    required this.calendarSystem,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['birth_month'] = Variable<int>(birthMonth);
    map['birth_day'] = Variable<int>(birthDay);
    map['calendar_system'] = Variable<String>(calendarSystem);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  BirthdaysTableCompanion toCompanion(bool nullToAbsent) {
    return BirthdaysTableCompanion(
      id: Value(id),
      name: Value(name),
      birthMonth: Value(birthMonth),
      birthDay: Value(birthDay),
      calendarSystem: Value(calendarSystem),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory BirthdaysTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BirthdaysTableData(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      birthMonth: serializer.fromJson<int>(json['birthMonth']),
      birthDay: serializer.fromJson<int>(json['birthDay']),
      calendarSystem: serializer.fromJson<String>(json['calendarSystem']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'birthMonth': serializer.toJson<int>(birthMonth),
      'birthDay': serializer.toJson<int>(birthDay),
      'calendarSystem': serializer.toJson<String>(calendarSystem),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  BirthdaysTableData copyWith({
    String? id,
    String? name,
    int? birthMonth,
    int? birthDay,
    String? calendarSystem,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => BirthdaysTableData(
    id: id ?? this.id,
    name: name ?? this.name,
    birthMonth: birthMonth ?? this.birthMonth,
    birthDay: birthDay ?? this.birthDay,
    calendarSystem: calendarSystem ?? this.calendarSystem,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  BirthdaysTableData copyWithCompanion(BirthdaysTableCompanion data) {
    return BirthdaysTableData(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      birthMonth: data.birthMonth.present
          ? data.birthMonth.value
          : this.birthMonth,
      birthDay: data.birthDay.present ? data.birthDay.value : this.birthDay,
      calendarSystem: data.calendarSystem.present
          ? data.calendarSystem.value
          : this.calendarSystem,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BirthdaysTableData(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('birthMonth: $birthMonth, ')
          ..write('birthDay: $birthDay, ')
          ..write('calendarSystem: $calendarSystem, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    birthMonth,
    birthDay,
    calendarSystem,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BirthdaysTableData &&
          other.id == this.id &&
          other.name == this.name &&
          other.birthMonth == this.birthMonth &&
          other.birthDay == this.birthDay &&
          other.calendarSystem == this.calendarSystem &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class BirthdaysTableCompanion extends UpdateCompanion<BirthdaysTableData> {
  final Value<String> id;
  final Value<String> name;
  final Value<int> birthMonth;
  final Value<int> birthDay;
  final Value<String> calendarSystem;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const BirthdaysTableCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.birthMonth = const Value.absent(),
    this.birthDay = const Value.absent(),
    this.calendarSystem = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BirthdaysTableCompanion.insert({
    required String id,
    required String name,
    required int birthMonth,
    required int birthDay,
    this.calendarSystem = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       birthMonth = Value(birthMonth),
       birthDay = Value(birthDay),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<BirthdaysTableData> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<int>? birthMonth,
    Expression<int>? birthDay,
    Expression<String>? calendarSystem,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (birthMonth != null) 'birth_month': birthMonth,
      if (birthDay != null) 'birth_day': birthDay,
      if (calendarSystem != null) 'calendar_system': calendarSystem,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BirthdaysTableCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<int>? birthMonth,
    Value<int>? birthDay,
    Value<String>? calendarSystem,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return BirthdaysTableCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      birthMonth: birthMonth ?? this.birthMonth,
      birthDay: birthDay ?? this.birthDay,
      calendarSystem: calendarSystem ?? this.calendarSystem,
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
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (birthMonth.present) {
      map['birth_month'] = Variable<int>(birthMonth.value);
    }
    if (birthDay.present) {
      map['birth_day'] = Variable<int>(birthDay.value);
    }
    if (calendarSystem.present) {
      map['calendar_system'] = Variable<String>(calendarSystem.value);
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
    return (StringBuffer('BirthdaysTableCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('birthMonth: $birthMonth, ')
          ..write('birthDay: $birthDay, ')
          ..write('calendarSystem: $calendarSystem, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $DevicesTableTable devicesTable = $DevicesTableTable(this);
  late final $DeviceLogsTableTable deviceLogsTable = $DeviceLogsTableTable(
    this,
  );
  late final $BirthdaysTableTable birthdaysTable = $BirthdaysTableTable(this);
  late final DeviceDao deviceDao = DeviceDao(this as AppDatabase);
  late final DeviceLogDao deviceLogDao = DeviceLogDao(this as AppDatabase);
  late final BirthdayDao birthdayDao = BirthdayDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    devicesTable,
    deviceLogsTable,
    birthdaysTable,
  ];
}

typedef $$DevicesTableTableCreateCompanionBuilder =
    DevicesTableCompanion Function({
      required String id,
      Value<String?> parentId,
      required String name,
      Value<String?> description,
      Value<String> status,
      Value<String?> usageUnit,
      Value<int> currentUsage,
      Value<String?> scheduleType,
      Value<int?> intervalValue,
      Value<String?> intervalUnit,
      Value<DateTime?> fixedDueAt,
      Value<DateTime?> lastMaintainedAt,
      Value<int> usageAtLastMaintenance,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$DevicesTableTableUpdateCompanionBuilder =
    DevicesTableCompanion Function({
      Value<String> id,
      Value<String?> parentId,
      Value<String> name,
      Value<String?> description,
      Value<String> status,
      Value<String?> usageUnit,
      Value<int> currentUsage,
      Value<String?> scheduleType,
      Value<int?> intervalValue,
      Value<String?> intervalUnit,
      Value<DateTime?> fixedDueAt,
      Value<DateTime?> lastMaintainedAt,
      Value<int> usageAtLastMaintenance,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

final class $$DevicesTableTableReferences
    extends
        BaseReferences<_$AppDatabase, $DevicesTableTable, DevicesTableData> {
  $$DevicesTableTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$DeviceLogsTableTable, List<DeviceLogsTableData>>
  _deviceLogsTableRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.deviceLogsTable,
    aliasName: $_aliasNameGenerator(
      db.devicesTable.id,
      db.deviceLogsTable.deviceId,
    ),
  );

  $$DeviceLogsTableTableProcessedTableManager get deviceLogsTableRefs {
    final manager = $$DeviceLogsTableTableTableManager(
      $_db,
      $_db.deviceLogsTable,
    ).filter((f) => f.deviceId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _deviceLogsTableRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$DevicesTableTableFilterComposer
    extends Composer<_$AppDatabase, $DevicesTableTable> {
  $$DevicesTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get parentId => $composableBuilder(
    column: $table.parentId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get usageUnit => $composableBuilder(
    column: $table.usageUnit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get currentUsage => $composableBuilder(
    column: $table.currentUsage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get scheduleType => $composableBuilder(
    column: $table.scheduleType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get intervalValue => $composableBuilder(
    column: $table.intervalValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get intervalUnit => $composableBuilder(
    column: $table.intervalUnit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get fixedDueAt => $composableBuilder(
    column: $table.fixedDueAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastMaintainedAt => $composableBuilder(
    column: $table.lastMaintainedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get usageAtLastMaintenance => $composableBuilder(
    column: $table.usageAtLastMaintenance,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> deviceLogsTableRefs(
    Expression<bool> Function($$DeviceLogsTableTableFilterComposer f) f,
  ) {
    final $$DeviceLogsTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.deviceLogsTable,
      getReferencedColumn: (t) => t.deviceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DeviceLogsTableTableFilterComposer(
            $db: $db,
            $table: $db.deviceLogsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$DevicesTableTableOrderingComposer
    extends Composer<_$AppDatabase, $DevicesTableTable> {
  $$DevicesTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get parentId => $composableBuilder(
    column: $table.parentId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get usageUnit => $composableBuilder(
    column: $table.usageUnit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get currentUsage => $composableBuilder(
    column: $table.currentUsage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get scheduleType => $composableBuilder(
    column: $table.scheduleType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get intervalValue => $composableBuilder(
    column: $table.intervalValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get intervalUnit => $composableBuilder(
    column: $table.intervalUnit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get fixedDueAt => $composableBuilder(
    column: $table.fixedDueAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastMaintainedAt => $composableBuilder(
    column: $table.lastMaintainedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get usageAtLastMaintenance => $composableBuilder(
    column: $table.usageAtLastMaintenance,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DevicesTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $DevicesTableTable> {
  $$DevicesTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get parentId =>
      $composableBuilder(column: $table.parentId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get usageUnit =>
      $composableBuilder(column: $table.usageUnit, builder: (column) => column);

  GeneratedColumn<int> get currentUsage => $composableBuilder(
    column: $table.currentUsage,
    builder: (column) => column,
  );

  GeneratedColumn<String> get scheduleType => $composableBuilder(
    column: $table.scheduleType,
    builder: (column) => column,
  );

  GeneratedColumn<int> get intervalValue => $composableBuilder(
    column: $table.intervalValue,
    builder: (column) => column,
  );

  GeneratedColumn<String> get intervalUnit => $composableBuilder(
    column: $table.intervalUnit,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get fixedDueAt => $composableBuilder(
    column: $table.fixedDueAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastMaintainedAt => $composableBuilder(
    column: $table.lastMaintainedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get usageAtLastMaintenance => $composableBuilder(
    column: $table.usageAtLastMaintenance,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  Expression<T> deviceLogsTableRefs<T extends Object>(
    Expression<T> Function($$DeviceLogsTableTableAnnotationComposer a) f,
  ) {
    final $$DeviceLogsTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.deviceLogsTable,
      getReferencedColumn: (t) => t.deviceId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DeviceLogsTableTableAnnotationComposer(
            $db: $db,
            $table: $db.deviceLogsTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$DevicesTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DevicesTableTable,
          DevicesTableData,
          $$DevicesTableTableFilterComposer,
          $$DevicesTableTableOrderingComposer,
          $$DevicesTableTableAnnotationComposer,
          $$DevicesTableTableCreateCompanionBuilder,
          $$DevicesTableTableUpdateCompanionBuilder,
          (DevicesTableData, $$DevicesTableTableReferences),
          DevicesTableData,
          PrefetchHooks Function({bool deviceLogsTableRefs})
        > {
  $$DevicesTableTableTableManager(_$AppDatabase db, $DevicesTableTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DevicesTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DevicesTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DevicesTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> parentId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> usageUnit = const Value.absent(),
                Value<int> currentUsage = const Value.absent(),
                Value<String?> scheduleType = const Value.absent(),
                Value<int?> intervalValue = const Value.absent(),
                Value<String?> intervalUnit = const Value.absent(),
                Value<DateTime?> fixedDueAt = const Value.absent(),
                Value<DateTime?> lastMaintainedAt = const Value.absent(),
                Value<int> usageAtLastMaintenance = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DevicesTableCompanion(
                id: id,
                parentId: parentId,
                name: name,
                description: description,
                status: status,
                usageUnit: usageUnit,
                currentUsage: currentUsage,
                scheduleType: scheduleType,
                intervalValue: intervalValue,
                intervalUnit: intervalUnit,
                fixedDueAt: fixedDueAt,
                lastMaintainedAt: lastMaintainedAt,
                usageAtLastMaintenance: usageAtLastMaintenance,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String?> parentId = const Value.absent(),
                required String name,
                Value<String?> description = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> usageUnit = const Value.absent(),
                Value<int> currentUsage = const Value.absent(),
                Value<String?> scheduleType = const Value.absent(),
                Value<int?> intervalValue = const Value.absent(),
                Value<String?> intervalUnit = const Value.absent(),
                Value<DateTime?> fixedDueAt = const Value.absent(),
                Value<DateTime?> lastMaintainedAt = const Value.absent(),
                Value<int> usageAtLastMaintenance = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => DevicesTableCompanion.insert(
                id: id,
                parentId: parentId,
                name: name,
                description: description,
                status: status,
                usageUnit: usageUnit,
                currentUsage: currentUsage,
                scheduleType: scheduleType,
                intervalValue: intervalValue,
                intervalUnit: intervalUnit,
                fixedDueAt: fixedDueAt,
                lastMaintainedAt: lastMaintainedAt,
                usageAtLastMaintenance: usageAtLastMaintenance,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$DevicesTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({deviceLogsTableRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (deviceLogsTableRefs) db.deviceLogsTable,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (deviceLogsTableRefs)
                    await $_getPrefetchedData<
                      DevicesTableData,
                      $DevicesTableTable,
                      DeviceLogsTableData
                    >(
                      currentTable: table,
                      referencedTable: $$DevicesTableTableReferences
                          ._deviceLogsTableRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$DevicesTableTableReferences(
                            db,
                            table,
                            p0,
                          ).deviceLogsTableRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.deviceId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$DevicesTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DevicesTableTable,
      DevicesTableData,
      $$DevicesTableTableFilterComposer,
      $$DevicesTableTableOrderingComposer,
      $$DevicesTableTableAnnotationComposer,
      $$DevicesTableTableCreateCompanionBuilder,
      $$DevicesTableTableUpdateCompanionBuilder,
      (DevicesTableData, $$DevicesTableTableReferences),
      DevicesTableData,
      PrefetchHooks Function({bool deviceLogsTableRefs})
    >;
typedef $$DeviceLogsTableTableCreateCompanionBuilder =
    DeviceLogsTableCompanion Function({
      required String id,
      required String deviceId,
      required DateTime date,
      Value<String?> notes,
      Value<String> kind,
      Value<int?> usageValue,
      Value<String?> usageUnit,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$DeviceLogsTableTableUpdateCompanionBuilder =
    DeviceLogsTableCompanion Function({
      Value<String> id,
      Value<String> deviceId,
      Value<DateTime> date,
      Value<String?> notes,
      Value<String> kind,
      Value<int?> usageValue,
      Value<String?> usageUnit,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

final class $$DeviceLogsTableTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $DeviceLogsTableTable,
          DeviceLogsTableData
        > {
  $$DeviceLogsTableTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $DevicesTableTable _deviceIdTable(_$AppDatabase db) =>
      db.devicesTable.createAlias(
        $_aliasNameGenerator(db.deviceLogsTable.deviceId, db.devicesTable.id),
      );

  $$DevicesTableTableProcessedTableManager get deviceId {
    final $_column = $_itemColumn<String>('device_id')!;

    final manager = $$DevicesTableTableTableManager(
      $_db,
      $_db.devicesTable,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_deviceIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$DeviceLogsTableTableFilterComposer
    extends Composer<_$AppDatabase, $DeviceLogsTableTable> {
  $$DeviceLogsTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get usageValue => $composableBuilder(
    column: $table.usageValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get usageUnit => $composableBuilder(
    column: $table.usageUnit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  $$DevicesTableTableFilterComposer get deviceId {
    final $$DevicesTableTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.deviceId,
      referencedTable: $db.devicesTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DevicesTableTableFilterComposer(
            $db: $db,
            $table: $db.devicesTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DeviceLogsTableTableOrderingComposer
    extends Composer<_$AppDatabase, $DeviceLogsTableTable> {
  $$DeviceLogsTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get usageValue => $composableBuilder(
    column: $table.usageValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get usageUnit => $composableBuilder(
    column: $table.usageUnit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$DevicesTableTableOrderingComposer get deviceId {
    final $$DevicesTableTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.deviceId,
      referencedTable: $db.devicesTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DevicesTableTableOrderingComposer(
            $db: $db,
            $table: $db.devicesTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DeviceLogsTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $DeviceLogsTableTable> {
  $$DeviceLogsTableTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<int> get usageValue => $composableBuilder(
    column: $table.usageValue,
    builder: (column) => column,
  );

  GeneratedColumn<String> get usageUnit =>
      $composableBuilder(column: $table.usageUnit, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$DevicesTableTableAnnotationComposer get deviceId {
    final $$DevicesTableTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.deviceId,
      referencedTable: $db.devicesTable,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DevicesTableTableAnnotationComposer(
            $db: $db,
            $table: $db.devicesTable,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DeviceLogsTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DeviceLogsTableTable,
          DeviceLogsTableData,
          $$DeviceLogsTableTableFilterComposer,
          $$DeviceLogsTableTableOrderingComposer,
          $$DeviceLogsTableTableAnnotationComposer,
          $$DeviceLogsTableTableCreateCompanionBuilder,
          $$DeviceLogsTableTableUpdateCompanionBuilder,
          (DeviceLogsTableData, $$DeviceLogsTableTableReferences),
          DeviceLogsTableData,
          PrefetchHooks Function({bool deviceId})
        > {
  $$DeviceLogsTableTableTableManager(
    _$AppDatabase db,
    $DeviceLogsTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DeviceLogsTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DeviceLogsTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DeviceLogsTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> deviceId = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<int?> usageValue = const Value.absent(),
                Value<String?> usageUnit = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DeviceLogsTableCompanion(
                id: id,
                deviceId: deviceId,
                date: date,
                notes: notes,
                kind: kind,
                usageValue: usageValue,
                usageUnit: usageUnit,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String deviceId,
                required DateTime date,
                Value<String?> notes = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<int?> usageValue = const Value.absent(),
                Value<String?> usageUnit = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => DeviceLogsTableCompanion.insert(
                id: id,
                deviceId: deviceId,
                date: date,
                notes: notes,
                kind: kind,
                usageValue: usageValue,
                usageUnit: usageUnit,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$DeviceLogsTableTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({deviceId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
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
                      dynamic
                    >
                  >(state) {
                    if (deviceId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.deviceId,
                                referencedTable:
                                    $$DeviceLogsTableTableReferences
                                        ._deviceIdTable(db),
                                referencedColumn:
                                    $$DeviceLogsTableTableReferences
                                        ._deviceIdTable(db)
                                        .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$DeviceLogsTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DeviceLogsTableTable,
      DeviceLogsTableData,
      $$DeviceLogsTableTableFilterComposer,
      $$DeviceLogsTableTableOrderingComposer,
      $$DeviceLogsTableTableAnnotationComposer,
      $$DeviceLogsTableTableCreateCompanionBuilder,
      $$DeviceLogsTableTableUpdateCompanionBuilder,
      (DeviceLogsTableData, $$DeviceLogsTableTableReferences),
      DeviceLogsTableData,
      PrefetchHooks Function({bool deviceId})
    >;
typedef $$BirthdaysTableTableCreateCompanionBuilder =
    BirthdaysTableCompanion Function({
      required String id,
      required String name,
      required int birthMonth,
      required int birthDay,
      Value<String> calendarSystem,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$BirthdaysTableTableUpdateCompanionBuilder =
    BirthdaysTableCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<int> birthMonth,
      Value<int> birthDay,
      Value<String> calendarSystem,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$BirthdaysTableTableFilterComposer
    extends Composer<_$AppDatabase, $BirthdaysTableTable> {
  $$BirthdaysTableTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get birthMonth => $composableBuilder(
    column: $table.birthMonth,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get birthDay => $composableBuilder(
    column: $table.birthDay,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get calendarSystem => $composableBuilder(
    column: $table.calendarSystem,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$BirthdaysTableTableOrderingComposer
    extends Composer<_$AppDatabase, $BirthdaysTableTable> {
  $$BirthdaysTableTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get birthMonth => $composableBuilder(
    column: $table.birthMonth,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get birthDay => $composableBuilder(
    column: $table.birthDay,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get calendarSystem => $composableBuilder(
    column: $table.calendarSystem,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BirthdaysTableTableAnnotationComposer
    extends Composer<_$AppDatabase, $BirthdaysTableTable> {
  $$BirthdaysTableTableAnnotationComposer({
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

  GeneratedColumn<int> get birthMonth => $composableBuilder(
    column: $table.birthMonth,
    builder: (column) => column,
  );

  GeneratedColumn<int> get birthDay =>
      $composableBuilder(column: $table.birthDay, builder: (column) => column);

  GeneratedColumn<String> get calendarSystem => $composableBuilder(
    column: $table.calendarSystem,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$BirthdaysTableTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BirthdaysTableTable,
          BirthdaysTableData,
          $$BirthdaysTableTableFilterComposer,
          $$BirthdaysTableTableOrderingComposer,
          $$BirthdaysTableTableAnnotationComposer,
          $$BirthdaysTableTableCreateCompanionBuilder,
          $$BirthdaysTableTableUpdateCompanionBuilder,
          (
            BirthdaysTableData,
            BaseReferences<
              _$AppDatabase,
              $BirthdaysTableTable,
              BirthdaysTableData
            >,
          ),
          BirthdaysTableData,
          PrefetchHooks Function()
        > {
  $$BirthdaysTableTableTableManager(
    _$AppDatabase db,
    $BirthdaysTableTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BirthdaysTableTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BirthdaysTableTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BirthdaysTableTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> birthMonth = const Value.absent(),
                Value<int> birthDay = const Value.absent(),
                Value<String> calendarSystem = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BirthdaysTableCompanion(
                id: id,
                name: name,
                birthMonth: birthMonth,
                birthDay: birthDay,
                calendarSystem: calendarSystem,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required int birthMonth,
                required int birthDay,
                Value<String> calendarSystem = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => BirthdaysTableCompanion.insert(
                id: id,
                name: name,
                birthMonth: birthMonth,
                birthDay: birthDay,
                calendarSystem: calendarSystem,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$BirthdaysTableTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BirthdaysTableTable,
      BirthdaysTableData,
      $$BirthdaysTableTableFilterComposer,
      $$BirthdaysTableTableOrderingComposer,
      $$BirthdaysTableTableAnnotationComposer,
      $$BirthdaysTableTableCreateCompanionBuilder,
      $$BirthdaysTableTableUpdateCompanionBuilder,
      (
        BirthdaysTableData,
        BaseReferences<_$AppDatabase, $BirthdaysTableTable, BirthdaysTableData>,
      ),
      BirthdaysTableData,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$DevicesTableTableTableManager get devicesTable =>
      $$DevicesTableTableTableManager(_db, _db.devicesTable);
  $$DeviceLogsTableTableTableManager get deviceLogsTable =>
      $$DeviceLogsTableTableTableManager(_db, _db.deviceLogsTable);
  $$BirthdaysTableTableTableManager get birthdaysTable =>
      $$BirthdaysTableTableTableManager(_db, _db.birthdaysTable);
}
