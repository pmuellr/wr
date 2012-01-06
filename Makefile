# Copyright (c) 2012 Patrick Mueller
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

COFFEE = node_modules/.bin/coffee

#-------------------------------------------------------------------------------
all: help

#-------------------------------------------------------------------------------
watch:
	wr "make test" bin lib test

#-------------------------------------------------------------------------------
test:
	echo TBD

#-------------------------------------------------------------------------------
vendor: \
	npm_coffee \
	npm_optimist

#-------------------------------------------------------------------------------
npm_coffee:
	npm install coffee-script@1.1.3

#-------------------------------------------------------------------------------
npm_optimist:
	npm install optimist@0.3.0

#-------------------------------------------------------------------------------
help:
	@echo "available targets:"
	@echo "   watch   - run tests when a source file changes"
	@echo "   test    - run tests"
	@echo "   vendor  - get vendor files"
	@echo "   help    - print this help"
	@echo ""
	@echo "You will need to 'make vendor' before running 'make test'"
