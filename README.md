<!-- DO NOT EDIT THIS FILE DIRECTLY - it is generated from source file src/OM_TAPIGEN.pks -->
<!-- markdownlint-disable MD003 MD012 MD033 -->

Oracle PL/SQL Table API Generator
=================================

- [Package om_tapigen](#om_tapigen)
- [Procedure compile_api](#compile_api)
- [Function compile_api_and_get_code](#compile_api_and_get_code)
- [Function get_code](#get_code)
- [Function view_existing_apis](#view_existing_apis)
- [Function view_naming_conflicts](#view_naming_conflicts)


<h2><a id="om_tapigen"></a>Package om_tapigen</h2>
<!----------------------------------------------->

_This table API generator needs an Oracle DB version 12.1 or higher and can be
integrated in the Oracle SQL-Developer with an additional wrapper package
for the [SQL Developer extension oddgen](https://www.oddgen.org/)._

The effort of generated API's is to reduce your PL/SQL code by calling standard
procedures and functions for usual DML operations on tables. So the generated
table APIs work as a logical layer between your business logic and the data. And
by the way this logical layer enables you to easily separate the data schema and
the UI schema for your applications to improve security by granting only execute
rights on table APIs to the application schema. In addition to that table APIs
will speed up your development cycles because developers are able to set the
focal point to the business logic instead of wasting time by manual creating
boilerplate code for your tables.

> Get Rid of Hard-Coding in PL/SQL ([Steven Feuerstein](https://www.youtube.com/playlist?list=PL0mkplxCP4ygQo3zAvhYrrU6hIQ0JtYTA))

FEATURES

- Generates small wrappers around your tables
- Highly configurable
- You can enable or disable separately insert, update and delete functionality
- Standard CRUD methods (column and row type based) and an additional create
  or update method
- Set based methods for high performance DML processing
- For each unique constraint a read method and a getter to fetch the primary key
- Functions to check if a row exists (primary key based, returning boolean or
  varchar2)
- Support for audit columns
- Support for a row version column
- Optional getter and setter for each column
- Optional 1:1 view to support the separation of concerns (also known as ThickDB/SmartDB/PinkDB paradigm)
- Optional DML view with an instead of trigger to support low code tools like APEX

LICENSE

- [The MIT License (MIT)](https://github.com/OraMUC/table-api-generator/blob/master/LICENSE.txt)
- Copyright (c) 2015-2020 André Borngräber, Ottmar Gobrecht

We give our best to produce clean and robust code, but we are NOT responsible,
if you loose any code or data by using this API generator. By using it you
accept the MIT license. As a best practice test the generator first in your
development environment and decide after your tests, if you want to use it in
production. If you miss any feature or find a bug, we are happy to hear from you
via the GitHub [issues](https://github.com/OraMUC/table-api-generator/issues)
functionality.

DOCS

- [Changelog](https://github.com/OraMUC/table-api-generator/blob/master/docs/changelog.md)
- [Getting started](https://github.com/OraMUC/table-api-generator/blob/master/docs/getting-started.md)
- [Detailed parameter descriptions](https://github.com/OraMUC/table-api-generator/blob/master/docs/parameters.md)
- [Bulk processing](https://github.com/OraMUC/table-api-generator/blob/master/docs/bulk-processing.md)
- [Example API](https://github.com/OraMUC/table-api-generator/blob/master/docs/example-api.md)
- [SQL Developer integration](https://github.com/OraMUC/table-api-generator/blob/master/docs/sql-developer-integration.md)

LINKS

- [Project home page](https://github.com/OraMUC/table-api-generator)
- [Download the latest version](https://github.com/OraMUC/table-api-generator/releases/latest)
- [Issues](https://github.com/OraMUC/table-api-generator/issues)

SIGNATURE

```sql
PACKAGE om_tapigen AUTHID CURRENT_USER IS
c_generator         CONSTANT VARCHAR2(10 CHAR) := 'OM_TAPIGEN';
c_generator_version CONSTANT VARCHAR2(10 CHAR) := '0.5.2.37';
```


<h2><a id="compile_api"></a>Procedure compile_api</h2>
<!--------------------------------------------------->

Generates the code and compiles it. When the defaults are used you need only
to provide the table name.

```sql
BEGIN
  om_tapigen.compile_api (p_table_name => 'EMP');
END;
```

SIGNATURE

```sql
PROCEDURE compile_api
( --> For detailed parameter descriptions see https://github.com/OraMUC/table-api-generator/blob/master/docs/parameters.md
  p_table_name                  IN VARCHAR2,
  p_owner                       IN VARCHAR2 DEFAULT USER,  -- The schema, in which the API should be generated.
  p_enable_insertion_of_rows    IN BOOLEAN  DEFAULT TRUE,  -- If true, create methods are generated.
  p_enable_column_defaults      IN BOOLEAN  DEFAULT FALSE, -- If true, the data dictionary defaults of the columns are used for the create methods.
  p_enable_update_of_rows       IN BOOLEAN  DEFAULT TRUE,  -- If true, update methods are generated.
  p_enable_deletion_of_rows     IN BOOLEAN  DEFAULT FALSE, -- If true, delete methods are generated.
  p_enable_parameter_prefixes   IN BOOLEAN  DEFAULT TRUE,  -- If true, the param names of methods will be prefixed with 'p_'.
  p_enable_proc_with_out_params IN BOOLEAN  DEFAULT TRUE,  -- If true, a helper method with out parameters is generated - can be useful for low code frontends like APEX to manage session state.
  p_enable_getter_and_setter    IN BOOLEAN  DEFAULT TRUE,  -- If true, getter and setter methods are created for each column.
  p_col_prefix_in_method_names  IN BOOLEAN  DEFAULT TRUE,  -- If true, a found unique column prefix is kept otherwise omitted in the getter and setter method names.
  p_return_row_instead_of_pk    IN BOOLEAN  DEFAULT FALSE, -- If true, the whole row instead of the pk columns is returned on create methods.
  p_double_quote_names          IN BOOLEAN  DEFAULT TRUE,  -- If true, object names (owner, table, columns) are placed in double quotes.
  p_default_bulk_limit          IN INTEGER  DEFAULT 1000,  -- The default bulk size for the set based methods (create_rows, read_rows, update_rows)
  p_enable_dml_view             IN BOOLEAN  DEFAULT FALSE, -- If true, a view with an instead of trigger is generated, which simply calls the API methods - can be useful for low code frontends like APEX.
  p_dml_view_name               IN VARCHAR2 DEFAULT NULL,  -- If not null, the given name is used for the DML view - you can use substitutions like #TABLE_NAME# , #TABLE_NAME_26# or #TABLE_NAME_4_20# (treated as substr(table_name, 4, 20)).
  p_dml_view_trigger_name       IN VARCHAR2 DEFAULT NULL,  -- If not null, the given name is used for the DML view trigger - you can use substitutions like #TABLE_NAME#, #TABLE_NAME_26# or #TABLE_NAME_4_20# (treated as substr(table_name, 4, 20)).
  p_enable_one_to_one_view      IN BOOLEAN  DEFAULT FALSE, -- If true, a 1:1 view with read only is generated - useful when you want to separate the tables into an own schema without direct user access.
  p_one_to_one_view_name        IN VARCHAR2 DEFAULT NULL,  -- If not null, the given name is used for the 1:1 view - you can use substitutions like #TABLE_NAME#, #TABLE_NAME_26# or #TABLE_NAME_4_20# (treated as substr(table_name, 4, 20)).
  p_api_name                    IN VARCHAR2 DEFAULT NULL,  -- If not null, the given name is used for the API - you can use substitutions like #TABLE_NAME#, #TABLE_NAME_26# or #TABLE_NAME_4_20# (treated as substr(table_name, 4, 20)).
  p_sequence_name               IN VARCHAR2 DEFAULT NULL,  -- If not null, the given name is used for the create_row methods - same substitutions like with API name possible.
  p_exclude_column_list         IN VARCHAR2 DEFAULT NULL,  -- If not null, the provided comma separated column names are excluded on inserts and updates (virtual columns are implicitly excluded).
  p_audit_column_mappings       IN VARCHAR2 DEFAULT NULL,  -- If not null, the provided comma separated column names are excluded and populated by the API (you don't need a trigger for update_by, update_on...).
  p_audit_user_expression       IN VARCHAR2 DEFAULT c_audit_user_expression, -- You can overwrite here the expression to determine the user which created or updated the row (see also the parameter docs...).
  p_row_version_column_mapping  IN VARCHAR2 DEFAULT NULL,  -- If not null, the provided column name is excluded and populated by the API with the provided SQL expression (you don't need a trigger to provide a row version identifier).
  p_tenant_column_mapping       IN VARCHAR2 DEFAULT NULL,  -- If not null, the provided column name is hidden inside the API, populated with the provided SQL expression and used as a tenant_id in all relevant API methods.
  p_enable_custom_defaults      IN BOOLEAN  DEFAULT FALSE, -- If true, additional methods are created (mainly for testing and dummy data creation, see full parameter descriptions).
  p_custom_default_values       IN XMLTYPE  DEFAULT NULL   -- Custom values in XML format for the previous option, if the generator provided defaults are not ok.
);
```


<h2><a id="compile_api_and_get_code"></a>Function compile_api_and_get_code</h2>
<!---------------------------------------------------------------------------->

Generates the code, compiles and returns it as a CLOB. When the defaults are used you need only
to provide the table name.

```sql
DECLARE
  l_api_code CLOB;
BEGIN
  l_api_code := om_tapigen.compile_api_and_get_code (p_table_name => 'EMP');
  --> do something with the API code
END;
```

SIGNATURE

```sql
FUNCTION compile_api_and_get_code
( --> For detailed parameter descriptions see https://github.com/OraMUC/table-api-generator/blob/master/docs/parameters.md
  p_table_name                  IN VARCHAR2,
  p_owner                       IN VARCHAR2 DEFAULT USER,  -- The schema, in which the API should be generated.
  p_enable_insertion_of_rows    IN BOOLEAN  DEFAULT TRUE,  -- If true, create methods are generated.
  p_enable_column_defaults      IN BOOLEAN  DEFAULT FALSE, -- If true, the data dictionary defaults of the columns are used for the create methods.
  p_enable_update_of_rows       IN BOOLEAN  DEFAULT TRUE,  -- If true, update methods are generated.
  p_enable_deletion_of_rows     IN BOOLEAN  DEFAULT FALSE, -- If true, delete methods are generated.
  p_enable_parameter_prefixes   IN BOOLEAN  DEFAULT TRUE,  -- If true, the param names of methods will be prefixed with 'p_'.
  p_enable_proc_with_out_params IN BOOLEAN  DEFAULT TRUE,  -- If true, a helper method with out parameters is generated - can be useful for low code frontends like APEX to manage session state.
  p_enable_getter_and_setter    IN BOOLEAN  DEFAULT TRUE,  -- If true, getter and setter methods are created for each column.
  p_col_prefix_in_method_names  IN BOOLEAN  DEFAULT TRUE,  -- If true, a found unique column prefix is kept otherwise omitted in the getter and setter method names.
  p_return_row_instead_of_pk    IN BOOLEAN  DEFAULT FALSE, -- If true, the whole row instead of the pk columns is returned on create methods.
  p_double_quote_names          IN BOOLEAN  DEFAULT TRUE,  -- If true, object names (owner, table, columns) are placed in double quotes.
  p_default_bulk_limit          IN INTEGER  DEFAULT 1000,  -- The default bulk size for the set based methods (create_rows, read_rows, update_rows)
  p_enable_dml_view             IN BOOLEAN  DEFAULT FALSE, -- If true, a view with an instead of trigger is generated, which simply calls the API methods - can be useful for low code frontends like APEX.
  p_dml_view_name               IN VARCHAR2 DEFAULT NULL,  -- If not null, the given name is used for the DML view - you can use substitutions like #TABLE_NAME# , #TABLE_NAME_26# or #TABLE_NAME_4_20# (treated as substr(table_name, 4, 20)).
  p_dml_view_trigger_name       IN VARCHAR2 DEFAULT NULL,  -- If not null, the given name is used for the DML view trigger - you can use substitutions like #TABLE_NAME#, #TABLE_NAME_26# or #TABLE_NAME_4_20# (treated as substr(table_name, 4, 20)).
  p_enable_one_to_one_view      IN BOOLEAN  DEFAULT FALSE, -- If true, a 1:1 view with read only is generated - useful when you want to separate the tables into an own schema without direct user access.
  p_one_to_one_view_name        IN VARCHAR2 DEFAULT NULL,  -- If not null, the given name is used for the 1:1 view - you can use substitutions like #TABLE_NAME#, #TABLE_NAME_26# or #TABLE_NAME_4_20# (treated as substr(table_name, 4, 20)).
  p_api_name                    IN VARCHAR2 DEFAULT NULL,  -- If not null, the given name is used for the API - you can use substitutions like #TABLE_NAME#, #TABLE_NAME_26# or #TABLE_NAME_4_20# (treated as substr(table_name, 4, 20)).
  p_sequence_name               IN VARCHAR2 DEFAULT NULL,  -- If not null, the given name is used for the create_row methods - same substitutions like with API name possible.
  p_exclude_column_list         IN VARCHAR2 DEFAULT NULL,  -- If not null, the provided comma separated column names are excluded on inserts and updates (virtual columns are implicitly excluded).
  p_audit_column_mappings       IN VARCHAR2 DEFAULT NULL,  -- If not null, the provided comma separated column names are excluded and populated by the API (you don't need a trigger for update_by, update_on...).
  p_audit_user_expression       IN VARCHAR2 DEFAULT c_audit_user_expression, -- You can overwrite here the expression to determine the user which created or updated the row (see also the parameter docs...).
  p_row_version_column_mapping  IN VARCHAR2 DEFAULT NULL,  -- If not null, the provided column name is excluded and populated by the API with the provided SQL expression (you don't need a trigger to provide a row version identifier).
  p_tenant_column_mapping       IN VARCHAR2 DEFAULT NULL,  -- If not null, the provided column name is hidden inside the API, populated with the provided SQL expression and used as a tenant_id in all relevant API methods.
  p_enable_custom_defaults      IN BOOLEAN  DEFAULT FALSE, -- If true, additional methods are created (mainly for testing and dummy data creation, see full parameter descriptions).
  p_custom_default_values       IN XMLTYPE  DEFAULT NULL   -- Custom values in XML format for the previous option, if the generator provided defaults are not ok.
) RETURN CLOB;
```


<h2><a id="get_code"></a>Function get_code</h2>
<!-------------------------------------------->

Generates the code and returns it as a CLOB. When the defaults are used you
need only to provide the table name.

This function is called by the oddgen wrapper for the SQL Developer integration.

```sql
DECLARE
  l_api_code CLOB;
BEGIN
  l_api_code := om_tapigen.get_code (p_table_name => 'EMP');
  --> do something with the API code
END;
```

SIGNATURE

```sql
FUNCTION get_code
( --> For detailed parameter descriptions see https://github.com/OraMUC/table-api-generator/blob/master/docs/parameters.md
  p_table_name                  IN VARCHAR2,
  p_owner                       IN VARCHAR2 DEFAULT USER,  -- The schema, in which the API should be generated.
  p_enable_insertion_of_rows    IN BOOLEAN  DEFAULT TRUE,  -- If true, create methods are generated.
  p_enable_column_defaults      IN BOOLEAN  DEFAULT FALSE, -- If true, the data dictionary defaults of the columns are used for the create methods.
  p_enable_update_of_rows       IN BOOLEAN  DEFAULT TRUE,  -- If true, update methods are generated.
  p_enable_deletion_of_rows     IN BOOLEAN  DEFAULT FALSE, -- If true, delete methods are generated.
  p_enable_parameter_prefixes   IN BOOLEAN  DEFAULT TRUE,  -- If true, the param names of methods will be prefixed with 'p_'.
  p_enable_proc_with_out_params IN BOOLEAN  DEFAULT TRUE,  -- If true, a helper method with out parameters is generated - can be useful for low code frontends like APEX to manage session state.
  p_enable_getter_and_setter    IN BOOLEAN  DEFAULT TRUE,  -- If true, getter and setter methods are created for each column.
  p_col_prefix_in_method_names  IN BOOLEAN  DEFAULT TRUE,  -- If true, a found unique column prefix is kept otherwise omitted in the getter and setter method names.
  p_return_row_instead_of_pk    IN BOOLEAN  DEFAULT FALSE, -- If true, the whole row instead of the pk columns is returned on create methods.
  p_double_quote_names          IN BOOLEAN  DEFAULT TRUE,  -- If true, object names (owner, table, columns) are placed in double quotes.
  p_default_bulk_limit          IN INTEGER  DEFAULT 1000,  -- The default bulk size for the set based methods (create_rows, read_rows, update_rows)
  p_enable_dml_view             IN BOOLEAN  DEFAULT FALSE, -- If true, a view with an instead of trigger is generated, which simply calls the API methods - can be useful for low code frontends like APEX.
  p_dml_view_name               IN VARCHAR2 DEFAULT NULL,  -- If not null, the given name is used for the DML view - you can use substitutions like #TABLE_NAME# , #TABLE_NAME_26# or #TABLE_NAME_4_20# (treated as substr(table_name, 4, 20)).
  p_dml_view_trigger_name       IN VARCHAR2 DEFAULT NULL,  -- If not null, the given name is used for the DML view trigger - you can use substitutions like #TABLE_NAME#, #TABLE_NAME_26# or #TABLE_NAME_4_20# (treated as substr(table_name, 4, 20)).
  p_enable_one_to_one_view      IN BOOLEAN  DEFAULT FALSE, -- If true, a 1:1 view with read only is generated - useful when you want to separate the tables into an own schema without direct user access.
  p_one_to_one_view_name        IN VARCHAR2 DEFAULT NULL,  -- If not null, the given name is used for the 1:1 view - you can use substitutions like #TABLE_NAME#, #TABLE_NAME_26# or #TABLE_NAME_4_20# (treated as substr(table_name, 4, 20)).
  p_api_name                    IN VARCHAR2 DEFAULT NULL,  -- If not null, the given name is used for the API - you can use substitutions like #TABLE_NAME#, #TABLE_NAME_26# or #TABLE_NAME_4_20# (treated as substr(table_name, 4, 20)).
  p_sequence_name               IN VARCHAR2 DEFAULT NULL,  -- If not null, the given name is used for the create_row methods - same substitutions like with API name possible.
  p_exclude_column_list         IN VARCHAR2 DEFAULT NULL,  -- If not null, the provided comma separated column names are excluded on inserts and updates (virtual columns are implicitly excluded).
  p_audit_column_mappings       IN VARCHAR2 DEFAULT NULL,  -- If not null, the provided comma separated column names are excluded and populated by the API (you don't need a trigger for update_by, update_on...).
  p_audit_user_expression       IN VARCHAR2 DEFAULT c_audit_user_expression, -- You can overwrite here the expression to determine the user which created or updated the row (see also the parameter docs...).
  p_row_version_column_mapping  IN VARCHAR2 DEFAULT NULL,  -- If not null, the provided column name is excluded and populated by the API with the provided SQL expression (you don't need a trigger to provide a row version identifier).
  p_tenant_column_mapping       IN VARCHAR2 DEFAULT NULL,  -- If not null, the provided column name is hidden inside the API, populated with the provided SQL expression and used as a tenant_id in all relevant API methods.
  p_enable_custom_defaults      IN BOOLEAN  DEFAULT FALSE, -- If true, additional methods are created (mainly for testing and dummy data creation, see full parameter descriptions).
  p_custom_default_values       IN XMLTYPE  DEFAULT NULL   -- Custom values in XML format for the previous option, if the generator provided defaults are not ok.
) RETURN CLOB;
```


<h2><a id="view_existing_apis"></a>Function view_existing_apis</h2>
<!---------------------------------------------------------------->

Helper function (pipelined) to list all APIs generated by om_tapigen.

```sql
SELECT * FROM TABLE (om_tapigen.view_existing_apis);
```

SIGNATURE

```sql
FUNCTION view_existing_apis(
  p_table_name VARCHAR2 DEFAULT NULL,
  p_owner      VARCHAR2 DEFAULT USER)
RETURN t_tab_existing_apis PIPELINED;
```


<h2><a id="view_naming_conflicts"></a>Function view_naming_conflicts</h2>
<!---------------------------------------------------------------------->

Helper to check possible naming conflicts before the very first usage of the API generator.

Also see the [naming conventions](https://github.com/OraMUC/table-api-generator/blob/master/docs/naming-conventions.md) of the generator.

```sql
SELECT * FROM TABLE (om_tapigen.view_naming_conflicts);
-- No rows expected. After you generated some APIs there will be results ;-)
```

SIGNATURE

```sql
FUNCTION view_naming_conflicts(
  p_owner VARCHAR2 DEFAULT USER)
RETURN t_tab_naming_conflicts PIPELINED;
```


