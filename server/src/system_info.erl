-module(system_info).

-export([show/0,
	 show/1]).

show(Atom) ->
    erlang:system_info(Atom).

show() ->
    AtomList = [build_type,
		c_compiler_used,
		check_io,
		compat_rel,
		creation,
		debug_compiled,
		dist,
		dist_ctrl,
		driver_version,
		dynamic_trace,
		dynamic_trace_probes,
		elib_malloc,
		dist_buf_busy_limit,
		fullsweep_after,
		garbage_collection,
		heap_sizes,
		heap_type,
		%%info,
		kernel_poll,
		loaded,
		logical_processors,
		logical_processors_available,
		logical_processors_online,
		machine,
		min_heap_size,
		min_bin_vheap_size,
		modified_timing_level,
		multi_scheduling,
		multi_scheduling_blockers,
		otp_release,
		port_count,
		port_limit,
		process_count,
		process_limit,
		%%procs,
		scheduler_bind_type,
		scheduler_bindings,
		scheduler_id,
		schedulers,
		schedulers_online,
		smp_support,
		system_version,
		system_architecture,
		threads,
		thread_pool_size,
		trace_control_word,
		update_cpu_info],
    Res = [{Atom, show(Atom)} || Atom <- AtomList],
    lists:map(fun({Type, Value}) -> io:format("~p:~p~n", [Type, Value]) end, Res).



