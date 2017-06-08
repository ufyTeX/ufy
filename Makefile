lint:
	luacheck src examples spec

spec:
	busted .

.PHONY: lint spec
