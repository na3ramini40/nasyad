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
  List<GeneratedColumn> get $columns => [id, name, description, createdAt];
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
  DevicesTableData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DevicesTableData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
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
  final String name;
  final String? description;
  final DateTime createdAt;
  const DevicesTableData({
    required this.id,
    required this.name,
    this.description,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  DevicesTableCompanion toCompanion(bool nullToAbsent) {
    return DevicesTableCompanion(
      id: Value(id),
      name: Value(name),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      createdAt: Value(createdAt),
    );
  }

  factory DevicesTableData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DevicesTableData(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      description: serializer.fromJson<String?>(json['description']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'description': serializer.toJson<String?>(description),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  DevicesTableData copyWith({
    String? id,
    String? name,
    Value<String?> description = const Value.absent(),
    DateTime? createdAt,
  }) => DevicesTableData(
    id: id ?? this.id,
    name: name ?? this.name,
    description: description.present ? description.value : this.description,
    createdAt: createdAt ?? this.createdAt,
  );
  DevicesTableData copyWithCompanion(DevicesTableCompanion data) {
    return DevicesTableData(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      description: data.description.present
          ? data.description.value
          : this.description,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DevicesTableData(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, description, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DevicesTableData &&
          other.id == this.id &&
          other.name == this.name &&
          other.description == this.description &&
          other.createdAt == this.createdAt);
}

class DevicesTableCompanion extends UpdateCompanion<DevicesTableData> {
  final Value<String> id;
  final Value<String> name;
  final Value<String?> description;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const DevicesTableCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.description = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DevicesTableCompanion.insert({
    required String id,
    required String name,
    this.description = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       createdAt = Value(createdAt);
  static Insertable<DevicesTableData> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? description,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (description != null) 'description': description,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DevicesTableCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String?>? description,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return DevicesTableCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
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
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
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
    return (StringBuffer('DevicesTableCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('description: $description, ')
          ..write('createdAt: $createdAt, ')
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
  static const VerificationMeta _usageMeta = const VerificationMeta('usage');
  @override
  late final GeneratedColumn<int> usage = GeneratedColumn<int>(
    'usage',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
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
  @override
  List<GeneratedColumn> get $columns => [id, deviceId, date, usage, notes];
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
    if (data.containsKey('usage')) {
      context.handle(
        _usageMeta,
        usage.isAcceptableOrUnknown(data['usage']!, _usageMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
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
      usage: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}usage'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
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
  final int? usage;
  final String? notes;
  const DeviceLogsTableData({
    required this.id,
    required this.deviceId,
    required this.date,
    this.usage,
    this.notes,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['device_id'] = Variable<String>(deviceId);
    map['date'] = Variable<DateTime>(date);
    if (!nullToAbsent || usage != null) {
      map['usage'] = Variable<int>(usage);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    return map;
  }

  DeviceLogsTableCompanion toCompanion(bool nullToAbsent) {
    return DeviceLogsTableCompanion(
      id: Value(id),
      deviceId: Value(deviceId),
      date: Value(date),
      usage: usage == null && nullToAbsent
          ? const Value.absent()
          : Value(usage),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
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
      usage: serializer.fromJson<int?>(json['usage']),
      notes: serializer.fromJson<String?>(json['notes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'deviceId': serializer.toJson<String>(deviceId),
      'date': serializer.toJson<DateTime>(date),
      'usage': serializer.toJson<int?>(usage),
      'notes': serializer.toJson<String?>(notes),
    };
  }

  DeviceLogsTableData copyWith({
    String? id,
    String? deviceId,
    DateTime? date,
    Value<int?> usage = const Value.absent(),
    Value<String?> notes = const Value.absent(),
  }) => DeviceLogsTableData(
    id: id ?? this.id,
    deviceId: deviceId ?? this.deviceId,
    date: date ?? this.date,
    usage: usage.present ? usage.value : this.usage,
    notes: notes.present ? notes.value : this.notes,
  );
  DeviceLogsTableData copyWithCompanion(DeviceLogsTableCompanion data) {
    return DeviceLogsTableData(
      id: data.id.present ? data.id.value : this.id,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      date: data.date.present ? data.date.value : this.date,
      usage: data.usage.present ? data.usage.value : this.usage,
      notes: data.notes.present ? data.notes.value : this.notes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DeviceLogsTableData(')
          ..write('id: $id, ')
          ..write('deviceId: $deviceId, ')
          ..write('date: $date, ')
          ..write('usage: $usage, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, deviceId, date, usage, notes);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DeviceLogsTableData &&
          other.id == this.id &&
          other.deviceId == this.deviceId &&
          other.date == this.date &&
          other.usage == this.usage &&
          other.notes == this.notes);
}

class DeviceLogsTableCompanion extends UpdateCompanion<DeviceLogsTableData> {
  final Value<String> id;
  final Value<String> deviceId;
  final Value<DateTime> date;
  final Value<int?> usage;
  final Value<String?> notes;
  final Value<int> rowid;
  const DeviceLogsTableCompanion({
    this.id = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.date = const Value.absent(),
    this.usage = const Value.absent(),
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DeviceLogsTableCompanion.insert({
    required String id,
    required String deviceId,
    required DateTime date,
    this.usage = const Value.absent(),
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       deviceId = Value(deviceId),
       date = Value(date);
  static Insertable<DeviceLogsTableData> custom({
    Expression<String>? id,
    Expression<String>? deviceId,
    Expression<DateTime>? date,
    Expression<int>? usage,
    Expression<String>? notes,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (deviceId != null) 'device_id': deviceId,
      if (date != null) 'date': date,
      if (usage != null) 'usage': usage,
      if (notes != null) 'notes': notes,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DeviceLogsTableCompanion copyWith({
    Value<String>? id,
    Value<String>? deviceId,
    Value<DateTime>? date,
    Value<int?>? usage,
    Value<String?>? notes,
    Value<int>? rowid,
  }) {
    return DeviceLogsTableCompanion(
      id: id ?? this.id,
      deviceId: deviceId ?? this.deviceId,
      date: date ?? this.date,
      usage: usage ?? this.usage,
      notes: notes ?? this.notes,
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
    if (usage.present) {
      map['usage'] = Variable<int>(usage.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
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
          ..write('usage: $usage, ')
          ..write('notes: $notes, ')
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
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    devicesTable,
    deviceLogsTable,
  ];
}

typedef $$DevicesTableTableCreateCompanionBuilder =
    DevicesTableCompanion Function({
      required String id,
      required String name,
      Value<String?> description,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$DevicesTableTableUpdateCompanionBuilder =
    DevicesTableCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String?> description,
      Value<DateTime> createdAt,
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

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
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

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
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

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

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
                Value<String> name = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DevicesTableCompanion(
                id: id,
                name: name,
                description: description,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<String?> description = const Value.absent(),
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => DevicesTableCompanion.insert(
                id: id,
                name: name,
                description: description,
                createdAt: createdAt,
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
      Value<int?> usage,
      Value<String?> notes,
      Value<int> rowid,
    });
typedef $$DeviceLogsTableTableUpdateCompanionBuilder =
    DeviceLogsTableCompanion Function({
      Value<String> id,
      Value<String> deviceId,
      Value<DateTime> date,
      Value<int?> usage,
      Value<String?> notes,
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

  ColumnFilters<int> get usage => $composableBuilder(
    column: $table.usage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
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

  ColumnOrderings<int> get usage => $composableBuilder(
    column: $table.usage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
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

  GeneratedColumn<int> get usage =>
      $composableBuilder(column: $table.usage, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

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
                Value<int?> usage = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DeviceLogsTableCompanion(
                id: id,
                deviceId: deviceId,
                date: date,
                usage: usage,
                notes: notes,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String deviceId,
                required DateTime date,
                Value<int?> usage = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DeviceLogsTableCompanion.insert(
                id: id,
                deviceId: deviceId,
                date: date,
                usage: usage,
                notes: notes,
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

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$DevicesTableTableTableManager get devicesTable =>
      $$DevicesTableTableTableManager(_db, _db.devicesTable);
  $$DeviceLogsTableTableTableManager get deviceLogsTable =>
      $$DeviceLogsTableTableTableManager(_db, _db.deviceLogsTable);
}
