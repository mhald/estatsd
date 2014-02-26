DEPS = deps/ibrowse deps/mochiweb
SERVER := erl -pa apps/estatsd/ebin -pa deps/*/ebin -smp enable -s crypto -s ssl -setcookie STATS -config rel/files/app.config ${ERL_ARGS}

all: compile

compile: $(DEPS)
	@rebar compile

$(DEPS):
	@rebar get-deps

clean:
	@rebar skip_deps=true clean

depclean:
	@rebar clean

relclean:
	@rm -rf rel/estatsd

distclean: clean relclean
	@rm -rf deps

rel: compile rel/estatsd

devrel: rel
	@$(foreach dep,$(wildcard deps/*), rm -rf rel/estatsd/lib/$(shell basename $(dep))-* && ln -sf $(abspath $(dep)) rel/estatsd/lib;)
	@rm -rf rel/estatsd/lib/estatsd-*;ln -s $(abspath apps/estatsd) rel/estatsd/lib

rel/estatsd:
	@rebar generate

deploy: relclean rel

shell:
	${SERVER} -name estatsd@`hostname` -boot start_sasl -s lager -s estatsd
