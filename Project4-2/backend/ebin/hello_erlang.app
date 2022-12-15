{application, 'hello_erlang', [
	{description, "New project"},
	{vsn, "0.1.0"},
	{modules, ['backend_app','backend_handler','backend_sup']},
	{registered, []},
	{applications, [kernel,stdlib,cowboy]},
	{env, []}
]}.