-define(record_type, [#activity{},#menke{}]).

%%

-record(activity, {id = int,
		   name = string,
		   begin_time = string,
		   end_time = string,
		   award_begin_time = string,
		   award_end_time = string,
		   summary = string,
		   detail = string}).

-record(menke, {id = int,
		name = string,
		q = int,
		w = int,
		qz = int,
		x = int,
		xl = int,
		b = int,
		bq = int,
		bn = int,
		t = int}).
		    
