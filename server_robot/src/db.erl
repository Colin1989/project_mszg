%%%-------------------------------------------------------------------
%%% @author linyibin <>
%%% @copyright (C) 2013, linyibin
%%% @doc
%%% Êý¾Ý¿â·ÃÎÊ²ã
%%% @end
%%% Created :  4 Nov 2013 by linyibin <>
%%%-------------------------------------------------------------------
-module(db).

-export([start/0, delete_all/1]).

-export([
        migrate/1,
        migrate/2,
	generate_key/2,
	get_RecordId/1,
	get_IntegerKey/1,
        find/1,
        find/2,
        find/3,
        find_first/1,
        find_first/2,
        find_first/3,
        find_last/1,
        find_last/2,
        find_last/3,
        count/1,
        count/2,
        counter/1,
        incr/1,
        incr/2,
        delete/1,
        save_record/1,
        push/0,
        pop/0,
        create_table/2,
        table_exists/1,
        depth/0,
        dump/0,
        execute/1,
        execute/2,
        transaction/1,
        validate_record/1,
        validate_record/2,
        validate_record_types/1,
        type/1,
        data_type/2]).

-define(DEFAULT_TIMEOUT, (30 * 1000)).
-define(POOLNAME, boss_db_pool).

start() ->
    Path = code:where_is_file("db.config"),
    {ok, [Options]} = file:consult(Path),
    DBOptions=proplists:get_value(dboptions, Options, []),
    CacheOptions = proplists:get_value(cacheoptions, Options, []),
    boss_db:start(DBOptions),
    boss_cache:start(CacheOptions),
    boss_news:start(),
    timer:sleep(1000),
    db_update:start(),
    ok.

delete_all(Table) ->
    execute(["delete from ", Table]).

%% @doc Apply migrations from list [{Tag, Fun}]
%% currently runs all migrations 'up'
migrate(Migrations) ->
    boss_db:migrate(Migrations).

%% @doc Run database migration {Tag, Fun} in Direction
migrate(TagFun, Direction) ->
    boss_db:migrate(TagFun, Direction).

generate_key(RecordName, Id) when is_list(RecordName), is_integer(Id) ->
    RecordName ++ "-" ++ integer_to_list(Id);
generate_key(RecordName, Id) when is_atom(RecordName), is_integer(Id) ->
    atom_to_list(RecordName) ++ "-" ++ integer_to_list(Id).

get_RecordId(Record)->
    Id=Record:id(),
    Type=element(1,Record),
    if
	is_atom(Type) andalso is_list(Id)->
	    list_to_integer(Id--atom_to_list(Type)++"-");
	is_integer(Id) ->
	    Id
    end.
get_IntegerKey(StrKey)when is_list(StrKey)->
    list_to_integer(lists:filter(fun(C)->
				   case C of
				       Char when Char<$0 orelse Char>$9->
					   false;
				       _ ->true
				   end
				 end,StrKey));
get_IntegerKey(Key)->
    Key.

%% @spec find(Id::string()) -> Value | {error, Reason}
%% @doc Find a BossRecord with the specified `Id' (e.g. "employee-42") or a value described
%% by a dot-separated path (e.g. "employee-42.manager.name").
find(Key) ->
    boss_db:find(Key).

%% @spec find(Type::atom(), Conditions) -> [ BossRecord ]
%% @doc Query for BossRecords. Returns all BossRecords of type
%% `Type' matching all of the given `Conditions'
find(Type, Conditions) ->
    boss_db:find(Type, Conditions).

%% @spec find(Type::atom(), Conditions, Options::proplist()) -> [ BossRecord ]
%% @doc Query for BossRecords. Returns BossRecords of type
%% `Type' matching all of the given `Conditions'. Options may include
%% `limit' (maximum number of records to return), `offset' (number of records
%% to skip), `order_by' (attribute to sort on), `descending' (whether to
%% sort the values from highest to lowest), and `include' (list of belongs_to
%% associations to pre-cache)
find(Type, Conditions, Options) ->
    boss_db:find(Type, Conditions, Options).

%% @spec find_first( Type::atom() ) -> Record | undefined
%% @doc Query for the first BossRecord of type `Type'.
find_first(Type) ->
    boss_db:find_first(Type).

%% @spec find_first( Type::atom(), Conditions ) -> Record | undefined
%% @doc Query for the first BossRecord of type `Type' matching all of the given `Conditions'
find_first(Type, Conditions) ->
    boss_db:find_first(Type, Conditions).

%% @spec find_first( Type::atom(), Conditions, Sort::atom() ) -> Record | undefined
%% @doc Query for the first BossRecord of type `Type' matching all of the given `Conditions',
%% sorted on the attribute `Sort'.
find_first(Type, Conditions, Sort) ->
    boss_db:find_first(Type, Conditions, Sort).

%% @spec find_last( Type::atom() ) -> Record | undefined
%% @doc Query for the last BossRecord of type `Type'.
find_last(Type) ->
    boss_db:find_last(Type).

%% @spec find_last( Type::atom(), Conditions ) -> Record | undefined
%% @doc Query for the last BossRecord of type `Type' matching all of the given `Conditions'
find_last(Type, Conditions) ->
    boss_db:find_last(Type, Conditions).

%% @spec find_last( Type::atom(), Conditions, Sort ) -> Record | undefined
%% @doc Query for the last BossRecord of type `Type' matching all of the given `Conditions'
find_last(Type, Conditions, Sort) ->
    boss_db:find_last(Type, Conditions, Sort).

%% @spec count( Type::atom() ) -> integer()
%% @doc Count the number of BossRecords of type `Type' in the database.
count(Type) ->
    boss_db:count(Type).

%% @spec count( Type::atom(), Conditions ) -> integer()
%% @doc Count the number of BossRecords of type `Type' in the database matching
%% all of the given `Conditions'.
count(Type, Conditions) ->
    boss_db:count(Type, Conditions).

%% @spec counter( Id::string() ) -> integer()
%% @doc Treat the record associated with `Id' as a counter and return its value.
%% Returns 0 if the record does not exist, so to reset a counter just use
%% "delete".
counter(Key) ->
    boss_db:counter(Key).

%% @spec incr( Id::string() ) -> integer()
%% @doc Treat the record associated with `Id' as a counter and atomically increment its value by 1.
incr(Key) ->
    boss_db:incr(Key).

%% @spec incr( Id::string(), Increment::integer() ) -> integer()
%% @doc Treat the record associated with `Id' as a counter and atomically increment its value by `Increment'.
incr(Key, Count) ->
    boss_db:incr(Key, Count).

%% @spec delete( Id::string() ) -> ok | {error, Reason}
%% @doc Delete the BossRecord with the given `Id'.
delete(Key) when is_list(Key)->
    boss_db:delete(Key);
delete(Item)->
    Type=atom_to_list(element(1,Item))++"-",
    ItemId=Item:id(),
    case ItemId of
	
	Id when is_list(Id)->boss_db:delete(Id);
	Idn->boss_db:delete(Type++integer_to_list(Idn))
    end.

push() ->
    boss_db:push().

pop() ->
    boss_db:pop().

depth() ->
    boss_db:depth().

dump() ->
    boss_db:dump().

%% @spec create_table ( TableName::string(), TableDefinition ) -> ok | {error, Reason}
%% @doc Create a table based on TableDefinition
create_table(TableName, TableDefinition) ->
    boss_db:create_table(TableName, TableDefinition).

table_exists(TableName) ->
    boss_db:table_exists(TableName).

%% @spec execute( Commands::iolist() ) -> RetVal
%% @doc Execute raw database commands on SQL databases
execute(Commands) ->
    boss_db:execute(Commands).

%% @spec execute( Commands::iolist(), Params::list() ) -> RetVal
%% @doc Execute database commands with interpolated parameters on SQL databases
execute(Commands, Params) ->
    boss_db:execute(Commands, Params).

%% @spec transaction( TransactionFun::function() ) -> {atomic, Result} | {aborted, Reason}
%% @doc Execute a fun inside a transaction.
transaction(TransactionFun) ->
    boss_db:transaction(TransactionFun).

%% @spec save_record( BossRecord ) -> {ok, SavedBossRecord} | {error, [ErrorMessages]}
%% @doc Save (that is, create or update) the given BossRecord in the database.
%% Performs validation first; see `validate_record/1'.
save_record(Record) ->
    boss_db:save_record(Record).

%% @spec validate_record( BossRecord ) -> ok | {error, [ErrorMessages]}
%% @doc Validate the given BossRecord without saving it in the database.
%% `ErrorMessages' are generated from the list of tests returned by the BossRecord's
%% `validation_tests/0' function (if defined). The returned list should consist of
%% `{TestFunction, ErrorMessage}' tuples, where `TestFunction' is a fun of arity 0
%% that returns `true' if the record is valid or `false' if it is invalid.
%% `ErrorMessage' should be a (constant) string which will be included in `ErrorMessages'
%% if the `TestFunction' returns `false' on this particular BossRecord.
validate_record(Record) ->
    boss_db:validate_record(Record).

%% @spec validate_record( BossRecord, IsNew ) -> ok | {error, [ErrorMessages]}
%% @doc Validate the given BossRecord without saving it in the database.
%% `ErrorMessages' are generated from the list of tests returned by the BossRecord's
%% `validation_tests/1' function (if defined), where parameter is atom() `on_create | on_update'.
%% The returned list should consist of `{TestFunction, ErrorMessage}' tuples,
%% where `TestFunction' is a fun of arity 0
%% that returns `true' if the record is valid or `false' if it is invalid.
%% `ErrorMessage' should be a (constant) string which will be included in `ErrorMessages'
%% if the `TestFunction' returns `false' on this particular BossRecord.
validate_record(Record, IsNew) ->
    boss_db:validate_record(Record, IsNew).

%% @spec validate_record_types( BossRecord ) -> ok | {error, [ErrorMessages]}
%% @doc Validate the parameter types of the given BossRecord without saving it
%% to the database.
validate_record_types(Record) ->
    boss_db:validate_record_types(Record).

%% @spec type( Id::string() ) -> Type::atom()
%% @doc Returns the type of the BossRecord with `Id', or `undefined' if the record does not exist.
type(Key) ->
    boss_db:type(Key).

data_type(Key, Val)  ->
    boss_db:data_type(Key, Val).
