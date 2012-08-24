# DO NOT EDIT
# This makefile makes sure all linkable targets are
# up-to-date with anything they link to
default:
	echo "Do not invoke directly"

# For each target create a dummy rule so the target does not have to exist
/opt/local/lib/libboost_unit_test_framework-mt.a:
/opt/local/lib/libboost_system-mt.a:
/opt/local/lib/libboost_regex-mt.a:
/opt/local/lib/libboost_date_time-mt.a:
/opt/local/lib/libboost_thread-mt.a:
/opt/local/lib/libboost_filesystem-mt.a:
/opt/local/lib/libboost_program_options-mt.a:
/Users/avr/code/scratch/cpp-netlib-0.9.4/libs/network/src/Debug/libcppnetlib-uri.a:
/opt/local/lib/libssl.dylib:
/opt/local/lib/libcrypto.dylib:
/Users/avr/code/scratch/cpp-netlib-0.9.4/libs/network/src/MinSizeRel/libcppnetlib-uri.a:
/Users/avr/code/scratch/cpp-netlib-0.9.4/libs/network/src/RelWithDebInfo/libcppnetlib-uri.a:
/Users/avr/code/scratch/cpp-netlib-0.9.4/libs/network/src/Release/libcppnetlib-uri.a:
/Users/avr/code/scratch/cpp-netlib-0.9.4/libs/network/src/Debug/libcppnetlib-client-connections.a:
/Users/avr/code/scratch/cpp-netlib-0.9.4/libs/network/src/MinSizeRel/libcppnetlib-client-connections.a:
/Users/avr/code/scratch/cpp-netlib-0.9.4/libs/network/src/RelWithDebInfo/libcppnetlib-client-connections.a:
/Users/avr/code/scratch/cpp-netlib-0.9.4/libs/network/src/Release/libcppnetlib-client-connections.a:
/Users/avr/code/scratch/cpp-netlib-0.9.4/libs/network/src/Debug/libcppnetlib-server-parsers.a:
/Users/avr/code/scratch/cpp-netlib-0.9.4/libs/network/src/MinSizeRel/libcppnetlib-server-parsers.a:
/Users/avr/code/scratch/cpp-netlib-0.9.4/libs/network/src/RelWithDebInfo/libcppnetlib-server-parsers.a:
/Users/avr/code/scratch/cpp-netlib-0.9.4/libs/network/src/Release/libcppnetlib-server-parsers.a:


# Rules to remove targets that are older than anything to which they
# link.  This forces Xcode to relink the targets from scratch.  It
# does not seem to check these dependencies itself.
PostBuild.cppnetlib-client-connections.Debug:
PostBuild.cppnetlib-server-parsers.Debug:
PostBuild.cppnetlib-uri.Debug:
PostBuild.cpp-netlib-message_test.Debug:
PostBuild.cppnetlib-uri.Debug: /Users/avr/code/scratch/cpp-netlib-0.9.4/tests/Debug/cpp-netlib-message_test
/Users/avr/code/scratch/cpp-netlib-0.9.4/tests/Debug/cpp-netlib-message_test:\
	/opt/local/lib/libboost_unit_test_framework-mt.a\
	/opt/local/lib/libboost_system-mt.a\
	/opt/local/lib/libboost_regex-mt.a\
	/opt/local/lib/libboost_date_time-mt.a\
	/opt/local/lib/libboost_thread-mt.a\
	/opt/local/lib/libboost_filesystem-mt.a\
	/opt/local/lib/libboost_program_options-mt.a\
	/Users/avr/code/scratch/cpp-netlib-0.9.4/libs/network/src/Debug/libcppnetlib-uri.a\
	/opt/local/lib/libssl.dylib\
	/opt/local/lib/libcrypto.dylib
	/bin/rm -f /Users/avr/code/scratch/cpp-netlib-0.9.4/tests/Debug/cpp-netlib-message_test


PostBuild.cpp-netlib-message_transform_test.Debug:
PostBuild.cppnetlib-uri.Debug: /Users/avr/code/scratch/cpp-netlib-0.9.4/tests/Debug/cpp-netlib-message_transform_test
/Users/avr/code/scratch/cpp-netlib-0.9.4/tests/Debug/cpp-netlib-message_transform_test:\
	/opt/local/lib/libboost_unit_test_framework-mt.a\
	/opt/local/lib/libboost_system-mt.a\
	/opt/local/lib/libboost_regex-mt.a\
	/opt/local/lib/libboost_date_time-mt.a\
	/opt/local/lib/libboost_thread-mt.a\
	/opt/local/lib/libboost_filesystem-mt.a\
	/opt/local/lib/libboost_program_options-mt.a\
	/Users/avr/code/scratch/cpp-netlib-0.9.4/libs/network/src/Debug/libcppnetlib-uri.a\
	/opt/local/lib/libssl.dylib\
	/opt/local/lib/libcrypto.dylib
	/bin/rm -f /Users/avr/code/scratch/cpp-netlib-0.9.4/tests/Debug/cpp-netlib-message_transform_test


PostBuild.cpp-netlib-utils_thread_pool.Debug:
PostBuild.cppnetlib-uri.Debug: /Users/avr/code/scratch/cpp-netlib-0.9.4/tests/Debug/cpp-netlib-utils_thread_pool
/Users/avr/code/scratch/cpp-netlib-0.9.4/tests/Debug/cpp-netlib-utils_thread_pool:\
	/opt/local/lib/libboost_unit_test_framework-mt.a\
	/opt/local/lib/libboost_system-mt.a\
	/opt/local/lib/libboost_regex-mt.a\
	/opt/local/lib/libboost_date_time-mt.a\
	/opt/local/lib/libboost_thread-mt.a\
	/opt/local/lib/libboost_filesystem-mt.a\
	/opt/local/lib/libboost_program_options-mt.a\
	/Users/avr/code/scratch/cpp-netlib-0.9.4/libs/network/src/Debug/libcppnetlib-uri.a\
	/opt/local/lib/libssl.dylib\
	/opt/local/lib/libcrypto.dylib
	/bin/rm -f /Users/avr/code/scratch/cpp-netlib-0.9.4/tests/Debug/cpp-netlib-utils_thread_pool


PostBuild.cpp-netlib-relative_uri_test.Debug:
PostBuild.cppnetlib-uri.Debug: /Users/avr/code/scratch/cpp-netlib-0.9.4/tests/Debug/cpp-netlib-relative_uri_test
/Users/avr/code/scratch/cpp-netlib-0.9.4/tests/Debug/cpp-netlib-relative_uri_test:\
	/opt/local/lib/libboost_unit_test_framework-mt.a\
	/opt/local/lib/libboost_system-mt.a\
	/opt/local/lib/libboost_regex-mt.a\
	/opt/local/lib/libboost_date_time-mt.a\
	/opt/local/lib/libboost_thread-mt.a\
	/opt/local/lib/libboost_filesystem-mt.a\
	/opt/local/lib/libboost_program_options-mt.a\
	/Users/avr/code/scratch/cpp-netlib-0.9.4/libs/network/src/Debug/libcppnetlib-uri.a\
	/opt/local/lib/libssl.dylib\
	/opt/local/lib/libcrypto.dylib
	/bin/rm -f /Users/avr/code/scratch/cpp-netlib-0.9.4/tests/Debug/cpp-netlib-relative_uri_test


PostBuild.cpp-netlib-uri_builder_stream_test.Debug:
PostBuild.cppnetlib-uri.Debug: /Users/avr/code/scratch/cpp-netlib-0.9.4/tests/Debug/cpp-netlib-uri_builder_stream_test
/Users/avr/code/scratch/cpp-netlib-0.9.4/tests/Debug/cpp-netlib-uri_builder_stream_test:\
	/opt/local/lib/libboost_unit_test_framework-mt.a\
	/opt/local/lib/libboost_system-mt.a\
	/opt/local/lib/libboost_regex-mt.a\
	/opt/local/lib/libboost_date_time-mt.a\
	/opt/local/lib/libboost_thread-mt.a\
	/opt/local/lib/libboost_filesystem-mt.a\
	/opt/local/lib/libboost_program_options-mt.a\
	/Users/avr/code/scratch/cpp-netlib-0.9.4/libs/network/src/Debug/libcppnetlib-uri.a\
	/opt/local/lib/libssl.dylib\
	/opt/local/lib/libcrypto.dylib
	/bin/rm -f /Users/avr/code/scratch/cpp-netlib-0.9.4/tests/Debug/cpp-netlib-uri_builder_stream_test


PostBuild.cpp-netlib-uri_builder_test.Debug:
PostBuild.cppnetlib-uri.Debug: /Users/avr/code/scratch/cpp-netlib-0.9.4/tests/Debug/cpp-netlib-uri_builder_test
/Users/avr/code/scratch/cpp-netlib-0.9.4/tests/Debug/cpp-netlib-uri_builder_test:\
	/opt/local/lib/libboost_unit_test_framework-mt.a\
	/opt/local/lib/libboost_system-mt.a\
	/opt/local/lib/libboost_regex-mt.a\
	/opt/local/lib/libboost_date_time-mt.a\
	/opt/local/lib/libboost_thread-mt.a\
	/opt/local/lib/libboost_filesystem-mt.a\
	/opt/local/lib/libboost_program_options-mt.a\
	/Users/avr/code/scratch/cpp-netlib-0.9.4/libs/network/src/Debug/libcppnetlib-uri.a\
	/opt/local/lib/libssl.dylib\
	/opt/local/lib/libcrypto.dylib
	/bin/rm -f /Users/avr/code/scratch/cpp-netlib-0.9.4/tests/Debug/cpp-netlib-uri_builder_test


PostBuild.cpp-netlib-uri_encoding_test.Debug:
PostBuild.cppnetlib-uri.Debug: /Users/avr/code/scratch/cpp-netlib-0.9.4/tests/Debug/cpp-netlib-uri_encoding_test
/Users/avr/code/scratch/cpp-netlib-0.9.4/tests/Debug/cpp-netlib-uri_encoding_test:\
	/opt/local/lib/libboost_unit_test_framework-mt.a\
	/opt/local/lib/libboost_system-mt.a\
	/opt/local/lib/libboost_regex-mt.a\
	/opt/local/lib/libboost_date_time-mt.a\
	/opt/local/lib/libboost_thread-mt.a\
	/opt/local/lib/libboost_filesystem-mt.a\
	/opt/local/lib/libboost_program_options-mt.a\
	/Users/avr/code/scratch/cpp-netlib-0.9.4/libs/network/src/Debug/libcppnetlib-uri.a\
	/opt/local/lib/libssl.dylib\
	/opt/local/lib/libcrypto.dylib
	/bin/rm -f /Users/avr/code/scratch/cpp-netlib-0.9.4/tests/Debug/cpp-netlib-uri_encoding_test


PostBuild.cpp-netlib-uri_test.Debug:
PostBuild.cppnetlib-uri.Debug: /Users/avr/code/scratch/cpp-netlib-0.9.4/tests/Debug/cpp-netlib-uri_test
/Users/avr/code/scratch/cpp-netlib-0.9.4/tests/Debug/cpp-netlib-uri_test:\
	/opt/local/lib/libboost_unit_test_framework-mt.a\
	/opt/local/lib/libboost_system-mt.a\
	/opt/local/lib/libboost_regex-mt.a\
	/opt/local/lib/libboost_date_time-mt.a\
	/opt/local/lib/libboost_thread-mt.a\
	/opt/local/lib/libboost_filesystem-mt.a\
	/opt/local/lib/libboost_program_options-mt.a\
	/Users/avr/code/scratch/cpp-netlib-0.9.4/libs/network/src/Debug/libcppnetlib-uri.a\
	/opt/local/lib/libssl.dylib\
	/opt/local/lib/libcrypto.dylib
	/bin/rm -f /Users/avr/code/scratch/cpp-netlib-0.9.4/tests/Debug/cpp-netlib-uri_test


PostBuild.cpp-netlib-http-client_constructor_test.Debug:
PostBuild.cppnetlib-uri.Debug: /Users/avr/code/scratch/cpp-netlib-0.9.4/tests/Debug/cpp-netlib-http-client_constructor_test
PostBuild.cppnetlib-client-connections.Debug: /Users/avr/code/scratch/cpp-netlib-0.9.4/tests/Debug/cpp-netlib-http-client_constructor_test
/Users/avr/code/scratch/cpp-netlib-0.9.4/tests/Debug/cpp-netlib-http-client_constructor_test:\
	/opt/local/lib/libboost_unit_test_framework-mt.a\
	/opt/local/lib/libboost_system-mt.a\
	/opt/local/lib/libboost_regex-mt.a\
	/opt/local/lib/libboost_date_time-mt.a\
	/opt/local/lib/libboost_thread-mt.a\
	/opt/local/lib/libboost_filesystem-mt.a\
	/opt/local/lib/libboost_program_options-mt.a\
	/Users/avr/code/scratch/cpp-netlib-0.9.4/libs/network/src/Debug/libcppnetlib-uri.a\
	/Users/avr/code/scratch/cpp-netlib-0.9.4/libs/network/src/Debug/libcppnetlib-client-connections.a\
	/opt/local/lib/libssl.dylib\
	/opt/local/lib/libcrypto.dylib
	/bin/rm -f /Users/avr/code/scratch/cpp-netlib-0.9.4/tests/Debug/cpp-netlib-http-client_constructor_test


PostBuild.cpp-netlib-http-client_get_different_port_test.Debug:
PostBuild.cppnetlib-uri.Debug: /Users/avr/code/scratch/cpp-netlib-0.9.4/tests/Debug/cpp-netlib-http-client_get_different_port_test
PostBuild.cppnetlib-client-connections.Debug: /Users/avr/code/scratch/cpp-netlib-0.9.4/tests/Debug/cpp-netlib-http-client_get_different_port_test
/Users/avr/code/scratch/cpp-netlib-0.9.4/tests/Debug/cpp-netlib-http-client_get_different_port_test:\
	/opt/local/lib/libboost_unit_test_framework-mt.a\
	/opt/local/lib/libboost_system-mt.a\
	/opt/local/lib/libboost_regex-mt.a\
	/opt/local/lib/libboost_date_time-mt.a\
	/opt/local/lib/libboost_thread-mt.a\
	/opt/local/lib/libboost_filesystem-mt.a\
	/opt/local/lib/libboost_program_options-mt.a\
	/Users/avr/code/scratch/cpp-netlib-0.9.4/libs/network/src/Debug/libcppnetlib-uri.a\
	/Users/avr/code/scratch/cpp-netlib-0.9.4/libs/network/src/Debug/libcppnetlib-client-connections.a\
	/opt/local/lib/libssl.dylib\
	/opt/local/lib/libcrypto.dylib
	/bin/rm -f /Users/avr/code/scratch/cpp-netlib-0.9.4/tests/Debug/cpp-netlib-http-client_get_different_port_test


PostBuild.cpp-netlib-http-client_get_streaming_test.Debug:
PostBuild.cppnetlib-uri.Debug: /Users/avr/code/scratch/cpp-netlib-0.9.4/tests/Debug/cpp-netlib-http-client_get_streaming_test
PostBuild.cppnetlib-client-connections.Debug: /Users/avr/code/scratch/cpp-netlib-0.9.4/tests/Debug/cpp-netlib-http-client_get_streaming_test
/Users/avr/code/scratch/cpp-netlib-0.9.4/tests/Debug/cpp-netlib-http-client_get_streaming_test:\
	/opt/local/lib/libboost_unit_test_framework-mt.a\
	/opt/local/lib/libboost_system-mt.a\
	/opt/local/lib/libboost_regex-mt.a\
	/opt/local/lib/libboost_date_time-mt.a\
	/opt/local/lib/libboost_thread-mt.a\
	/opt/local/lib/libboost_filesystem-mt.a\
	/opt/local/lib/libboost_program_options-mt.a\
	/Users/avr/code/scratch/cpp-netlib-0.9.4/libs/network/src/Debug/libcppnetlib-uri.a\
	/Users/avr/code/scratch/cpp-netlib-0.9.4/libs/network/src/Debug/libcppnetlib-client-connections.a\
	/opt/local/lib/libssl.dylib\
	/opt/local/lib/libcrypto.dylib
	/bin/rm -f /Users/avr/code/scratch/cpp-netlib-0.9.4/tests/Debug/cpp-netlib-http-client_get_streaming_test


PostBuild.cpp-netlib-http-client_get_test.Debug:
PostBuild.cppnetlib-uri.Debug: /Users/avr/code/scratch/cpp-netlib-0.9.4/tests/Debug/cpp-netlib-http-client_get_test
PostBuild.cppnetlib-client-connections.Debug: /Users/avr/code/scratch/cpp-netlib-0.9.4/tests/Debug/cpp-netlib-http-client_get_test
/Users/avr/code/scratch/cpp-netlib-0.9.4/tests/Debug/cpp-netlib-http-client_get_test:\
	/opt/local/lib/libboost_unit_test_framework-mt.a\
	/opt/local/lib/libboost_system-mt.a\
	/opt/local/lib/libboost_regex-mt.a\
	/opt/local/lib/libboost_date_time-mt.a\
	/opt/local/lib/libboost_thread-mt.a\
	/opt/local/lib/libboost_filesystem-mt.a\
	/opt/local/lib/libboost_program_options-mt.a\
	/Users/avr/code/scratch/cpp-netlib-0.9.4/libs/network/src/Debug/libcppnetlib-uri.a\
	/Users/avr/code/scratch/cpp-netlib-0.9.4/libs/network/src/Debug/libcppnetlib-client-connections.a\
	/opt/local/lib/libssl.dylib\
	/opt/local/lib/libcrypto.dylib
	/bin/rm -f /Users/avr/code/scratch/cpp-netlib-0.9.4/tests/Debug/cpp-netlib-http-client_get_test


PostBuild.cpp-netlib-http-client_get_timeout_test.Debug:
PostBuild.cppnetlib-uri.Debug: /Users/avr/code/scratch/cpp-netlib-0.9.4/tests/Debug/cpp-netlib-http-client_get_timeout_test
PostBuild.cppnetlib-client-connections.Debug: /Users/avr/code/scratch/cpp-netlib-0.9.4/tests/Debug/cpp-netlib-http-client_get_timeout_test
/Users/avr/code/scratch/cpp-netlib-0.9.4/tests/Debug/cpp-netlib-http-client_get_timeout_test:\
	/opt/local/lib/libboost_unit_test_framework-mt.a\
	/opt/local/lib/libboost_system-mt.a\
	/opt/local/lib/libboost_regex-mt.a\
	/opt/local/lib/libboost_date_time-mt.a\
	/opt/local/lib/libboost_thread-mt.a\
	/opt/local/lib/libboost_filesystem-mt.a\
	/opt/local/lib/libboost_program_options-mt.a\
	/Users/avr/code/scratch/cpp-netlib-0.9.4/libs/network/src/Debug/libcppnetlib-uri.a\
	/Users/avr/code/scratch/cpp-netlib-0.9.4/libs/network/src/Debug/libcppnetlib-client-connections.a\
	/opt/local/lib/libssl.dylib\
	/opt/local/lib/libcrypto.dylib
	/bin/rm -f /Users/avr/code/scratch/cpp-netlib-0.9.4/tests/Debug/cpp-netlib-http-client_get_timeout_test


PostBuild.cpp-netlib-http-server_async_run_stop_concurrency.Debug:
PostBuild.cppnetlib-server-parsers.Debug: /Users/avr/code/scratch/cpp-netlib-0.9.4/tests/Debug/cpp-netlib-http-server_async_run_stop_concurrency
/Users/avr/code/scratch/cpp-netlib-0.9.4/tests/Debug/cpp-netlib-http-server_async_run_stop_concurrency:\
	/opt/local/lib/libboost_unit_test_framework-mt.a\
	/opt/local/lib/libboost_system-mt.a\
	/opt/local/lib/libboost_regex-mt.a\
	/opt/local/lib/libboost_date_time-mt.a\
	/opt/local/lib/libboost_thread-mt.a\
	/opt/local/lib/libboost_filesystem-mt.a\
	/opt/local/lib/libboost_program_options-mt.a\
	/Users/avr/code/scratch/cpp-netlib-0.9.4/libs/network/src/Debug/libcppnetlib-server-parsers.a
	/bin/rm -f /Users/avr/code/scratch/cpp-netlib-0.9.4/tests/Debug/cpp-netlib-http-server_async_run_stop_concurrency


PostBuild.cpp-netlib-http-server_constructor_test.Debug:
PostBuild.cppnetlib-server-parsers.Debug: /Users/avr/code/scratch/cpp-netlib-0.9.4/tests/Debug/cpp-netlib-http-server_constructor_test
/Users/avr/code/scratch/cpp-netlib-0.9.4/tests/Debug/cpp-netlib-http-server_constructor_test:\
	/opt/local/lib/libboost_unit_test_framework-mt.a\
	/opt/local/lib/libboost_system-mt.a\
	/opt/local/lib/libboost_regex-mt.a\
	/opt/local/lib/libboost_date_time-mt.a\
	/opt/local/lib/libboost_thread-mt.a\
	/opt/local/lib/libboost_filesystem-mt.a\
	/opt/local/lib/libboost_program_options-mt.a\
	/Users/avr/code/scratch/cpp-netlib-0.9.4/libs/network/src/Debug/libcppnetlib-server-parsers.a
	/bin/rm -f /Users/avr/code/scratch/cpp-netlib-0.9.4/tests/Debug/cpp-netlib-http-server_constructor_test


PostBuild.mime-roundtrip.Debug:
/Users/avr/code/scratch/cpp-netlib-0.9.4/libs/mime/test/Debug/mime-roundtrip:\
	/opt/local/lib/libboost_unit_test_framework-mt.a\
	/opt/local/lib/libboost_system-mt.a\
	/opt/local/lib/libboost_regex-mt.a\
	/opt/local/lib/libboost_date_time-mt.a\
	/opt/local/lib/libboost_thread-mt.a\
	/opt/local/lib/libboost_filesystem-mt.a\
	/opt/local/lib/libboost_program_options-mt.a\
	/opt/local/lib/libboost_unit_test_framework-mt.a\
	/opt/local/lib/libboost_system-mt.a\
	/opt/local/lib/libboost_regex-mt.a\
	/opt/local/lib/libboost_date_time-mt.a\
	/opt/local/lib/libboost_thread-mt.a\
	/opt/local/lib/libboost_filesystem-mt.a\
	/opt/local/lib/libboost_program_options-mt.a
	/bin/rm -f /Users/avr/code/scratch/cpp-netlib-0.9.4/libs/mime/test/Debug/mime-roundtrip


PostBuild.atom_reader.Debug:
PostBuild.cppnetlib-uri.Debug: /Users/avr/code/scratch/cpp-netlib-0.9.4/example/Debug/atom_reader
PostBuild.cppnetlib-client-connections.Debug: /Users/avr/code/scratch/cpp-netlib-0.9.4/example/Debug/atom_reader
/Users/avr/code/scratch/cpp-netlib-0.9.4/example/Debug/atom_reader:\
	/opt/local/lib/libboost_program_options-mt.a\
	/opt/local/lib/libboost_thread-mt.a\
	/opt/local/lib/libboost_date_time-mt.a\
	/opt/local/lib/libboost_regex-mt.a\
	/opt/local/lib/libboost_system-mt.a\
	/Users/avr/code/scratch/cpp-netlib-0.9.4/libs/network/src/Debug/libcppnetlib-uri.a\
	/Users/avr/code/scratch/cpp-netlib-0.9.4/libs/network/src/Debug/libcppnetlib-client-connections.a\
	/opt/local/lib/libssl.dylib\
	/opt/local/lib/libcrypto.dylib
	/bin/rm -f /Users/avr/code/scratch/cpp-netlib-0.9.4/example/Debug/atom_reader


PostBuild.fileserver.Debug:
PostBuild.cppnetlib-server-parsers.Debug: /Users/avr/code/scratch/cpp-netlib-0.9.4/example/Debug/fileserver
/Users/avr/code/scratch/cpp-netlib-0.9.4/example/Debug/fileserver:\
	/opt/local/lib/libboost_thread-mt.a\
	/opt/local/lib/libboost_system-mt.a\
	/opt/local/lib/libboost_date_time-mt.a\
	/opt/local/lib/libboost_program_options-mt.a\
	/opt/local/lib/libboost_filesystem-mt.a\
	/Users/avr/code/scratch/cpp-netlib-0.9.4/libs/network/src/Debug/libcppnetlib-server-parsers.a
	/bin/rm -f /Users/avr/code/scratch/cpp-netlib-0.9.4/example/Debug/fileserver


PostBuild.hello_world_client.Debug:
PostBuild.cppnetlib-uri.Debug: /Users/avr/code/scratch/cpp-netlib-0.9.4/example/Debug/hello_world_client
PostBuild.cppnetlib-client-connections.Debug: /Users/avr/code/scratch/cpp-netlib-0.9.4/example/Debug/hello_world_client
/Users/avr/code/scratch/cpp-netlib-0.9.4/example/Debug/hello_world_client:\
	/opt/local/lib/libboost_program_options-mt.a\
	/opt/local/lib/libboost_thread-mt.a\
	/opt/local/lib/libboost_date_time-mt.a\
	/opt/local/lib/libboost_regex-mt.a\
	/opt/local/lib/libboost_system-mt.a\
	/Users/avr/code/scratch/cpp-netlib-0.9.4/libs/network/src/Debug/libcppnetlib-uri.a\
	/Users/avr/code/scratch/cpp-netlib-0.9.4/libs/network/src/Debug/libcppnetlib-client-connections.a\
	/opt/local/lib/libssl.dylib\
	/opt/local/lib/libcrypto.dylib
	/bin/rm -f /Users/avr/code/scratch/cpp-netlib-0.9.4/example/Debug/hello_world_client


PostBuild.hello_world_server.Debug:
/Users/avr/code/scratch/cpp-netlib-0.9.4/example/Debug/hello_world_server:\
	/opt/local/lib/libboost_thread-mt.a\
	/opt/local/lib/libboost_system-mt.a\
	/opt/local/lib/libboost_date_time-mt.a\
	/opt/local/lib/libboost_program_options-mt.a\
	/opt/local/lib/libssl.dylib\
	/opt/local/lib/libcrypto.dylib
	/bin/rm -f /Users/avr/code/scratch/cpp-netlib-0.9.4/example/Debug/hello_world_server


PostBuild.http_client.Debug:
PostBuild.cppnetlib-uri.Debug: /Users/avr/code/scratch/cpp-netlib-0.9.4/example/Debug/http_client
PostBuild.cppnetlib-client-connections.Debug: /Users/avr/code/scratch/cpp-netlib-0.9.4/example/Debug/http_client
/Users/avr/code/scratch/cpp-netlib-0.9.4/example/Debug/http_client:\
	/opt/local/lib/libboost_program_options-mt.a\
	/opt/local/lib/libboost_thread-mt.a\
	/opt/local/lib/libboost_date_time-mt.a\
	/opt/local/lib/libboost_regex-mt.a\
	/opt/local/lib/libboost_system-mt.a\
	/Users/avr/code/scratch/cpp-netlib-0.9.4/libs/network/src/Debug/libcppnetlib-uri.a\
	/Users/avr/code/scratch/cpp-netlib-0.9.4/libs/network/src/Debug/libcppnetlib-client-connections.a\
	/opt/local/lib/libssl.dylib\
	/opt/local/lib/libcrypto.dylib
	/bin/rm -f /Users/avr/code/scratch/cpp-netlib-0.9.4/example/Debug/http_client


PostBuild.rss_reader.Debug:
PostBuild.cppnetlib-uri.Debug: /Users/avr/code/scratch/cpp-netlib-0.9.4/example/Debug/rss_reader
PostBuild.cppnetlib-client-connections.Debug: /Users/avr/code/scratch/cpp-netlib-0.9.4/example/Debug/rss_reader
/Users/avr/code/scratch/cpp-netlib-0.9.4/example/Debug/rss_reader:\
	/opt/local/lib/libboost_program_options-mt.a\
	/opt/local/lib/libboost_thread-mt.a\
	/opt/local/lib/libboost_date_time-mt.a\
	/opt/local/lib/libboost_regex-mt.a\
	/opt/local/lib/libboost_system-mt.a\
	/Users/avr/code/scratch/cpp-netlib-0.9.4/libs/network/src/Debug/libcppnetlib-uri.a\
	/Users/avr/code/scratch/cpp-netlib-0.9.4/libs/network/src/Debug/libcppnetlib-client-connections.a\
	/opt/local/lib/libssl.dylib\
	/opt/local/lib/libcrypto.dylib
	/bin/rm -f /Users/avr/code/scratch/cpp-netlib-0.9.4/example/Debug/rss_reader


PostBuild.simple_wget.Debug:
PostBuild.cppnetlib-uri.Debug: /Users/avr/code/scratch/cpp-netlib-0.9.4/example/Debug/simple_wget
PostBuild.cppnetlib-client-connections.Debug: /Users/avr/code/scratch/cpp-netlib-0.9.4/example/Debug/simple_wget
/Users/avr/code/scratch/cpp-netlib-0.9.4/example/Debug/simple_wget:\
	/opt/local/lib/libboost_program_options-mt.a\
	/opt/local/lib/libboost_thread-mt.a\
	/opt/local/lib/libboost_date_time-mt.a\
	/opt/local/lib/libboost_regex-mt.a\
	/opt/local/lib/libboost_system-mt.a\
	/Users/avr/code/scratch/cpp-netlib-0.9.4/libs/network/src/Debug/libcppnetlib-uri.a\
	/Users/avr/code/scratch/cpp-netlib-0.9.4/libs/network/src/Debug/libcppnetlib-client-connections.a\
	/opt/local/lib/libssl.dylib\
	/opt/local/lib/libcrypto.dylib
	/bin/rm -f /Users/avr/code/scratch/cpp-netlib-0.9.4/example/Debug/simple_wget


PostBuild.twitter_search.Debug:
PostBuild.cppnetlib-uri.Debug: /Users/avr/code/scratch/cpp-netlib-0.9.4/example/Debug/twitter_search
PostBuild.cppnetlib-client-connections.Debug: /Users/avr/code/scratch/cpp-netlib-0.9.4/example/Debug/twitter_search
/Users/avr/code/scratch/cpp-netlib-0.9.4/example/Debug/twitter_search:\
	/opt/local/lib/libboost_program_options-mt.a\
	/opt/local/lib/libboost_thread-mt.a\
	/opt/local/lib/libboost_date_time-mt.a\
	/opt/local/lib/libboost_regex-mt.a\
	/opt/local/lib/libboost_system-mt.a\
	/Users/avr/code/scratch/cpp-netlib-0.9.4/libs/network/src/Debug/libcppnetlib-uri.a\
	/Users/avr/code/scratch/cpp-netlib-0.9.4/libs/network/src/Debug/libcppnetlib-client-connections.a\
	/opt/local/lib/libssl.dylib\
	/opt/local/lib/libcrypto.dylib
	/bin/rm -f /Users/avr/code/scratch/cpp-netlib-0.9.4/example/Debug/twitter_search


PostBuild.cppnetlib-client-connections.Release:
PostBuild.cppnetlib-server-parsers.Release:
PostBuild.cppnetlib-uri.Release:
PostBuild.cpp-netlib-message_test.Release:
PostBuild.cppnetlib-uri.Release: /Users/avr/code/scratch/cpp-netlib-0.9.4/tests/Release/cpp-netlib-message_test
/Users/avr/code/scratch/cpp-netlib-0.9.4/tests/Release/cpp-netlib-message_test:\
	/opt/local/lib/libboost_unit_test_framework-mt.a\
	/opt/local/lib/libboost_system-mt.a\
	/opt/local/lib/libboost_regex-mt.a\
	/opt/local/lib/libboost_date_time-mt.a\
	/opt/local/lib/libboost_thread-mt.a\
	/opt/local/lib/libboost_filesystem-mt.a\
	/opt/local/lib/libboost_program_options-mt.a\
	/Users/avr/code/scratch/cpp-netlib-0.9.4/libs/network/src/Release/libcppnetlib-uri.a\
	/opt/local/lib/libssl.dylib\
	/opt/local/lib/libcrypto.dylib
	/bin/rm -f /Users/avr/code/scratch/cpp-netlib-0.9.4/tests/Release/cpp-netlib-message_test


PostBuild.cpp-netlib-message_transform_test.Release:
PostBuild.cppnetlib-uri.Release: /Users/avr/code/scratch/cpp-netlib-0.9.4/tests/Release/cpp-netlib-message_transform_test
/Users/avr/code/scratch/cpp-netlib-0.9.4/tests/Release/cpp-netlib-message_transform_test:\
	/opt/local/lib/libboost_unit_test_framework-mt.a\
	/opt/local/lib/libboost_system-mt.a\
	/opt/local/lib/libboost_regex-mt.a\
	/opt/local/lib/libboost_date_time-mt.a\
	/opt/local/lib/libboost_thread-mt.a\
	/opt/local/lib/libboost_filesystem-mt.a\
	/opt/local/lib/libboost_program_options-mt.a\
	/Users/avr/code/scratch/cpp-netlib-0.9.4/libs/network/src/Release/libcppnetlib-uri.a\
	/opt/local/lib/libssl.dylib\
	/opt/local/lib/libcrypto.dylib
	/bin/rm -f /Users/avr/code/scratch/cpp-netlib-0.9.4/tests/Release/cpp-netlib-message_transform_test


PostBuild.cpp-netlib-utils_thread_pool.Release:
PostBuild.cppnetlib-uri.Release: /Users/avr/code/scratch/cpp-netlib-0.9.4/tests/Release/cpp-netlib-utils_thread_pool
/Users/avr/code/scratch/cpp-netlib-0.9.4/tests/Release/cpp-netlib-utils_thread_pool:\
	/opt/local/lib/libboost_unit_test_framework-mt.a\
	/opt/local/lib/libboost_system-mt.a\
	/opt/local/lib/libboost_regex-mt.a\
	/opt/local/lib/libboost_date_time-mt.a\
	/opt/local/lib/libboost_thread-mt.a\
	/opt/local/lib/libboost_filesystem-mt.a\
	/opt/local/lib/libboost_program_options-mt.a\
	/Users/avr/code/scratch/cpp-netlib-0.9.4/libs/network/src/Release/libcppnetlib-uri.a\
	/opt/local/lib/libssl.dylib\
	/opt/local/lib/libcrypto.dylib
	/bin/rm -f /Users/avr/code/scratch/cpp-netlib-0.9.4/tests/Release/cpp-netlib-utils_thread_pool


PostBuild.cpp-netlib-relative_uri_test.Release:
PostBuild.cppnetlib-uri.Release: /Users/avr/code/scratch/cpp-netlib-0.9.4/tests/Release/cpp-netlib-relative_uri_test
/Users/avr/code/scratch/cpp-netlib-0.9.4/tests/Release/cpp-netlib-relative_uri_test:\
	/opt/local/lib/libboost_unit_test_framework-mt.a\
	/opt/local/lib/libboost_system-mt.a\
	/opt/local/lib/libboost_regex-mt.a\
	/opt/local/lib/libboost_date_time-mt.a\
	/opt/local/lib/libboost_thread-mt.a\
	/opt/local/lib/libboost_filesystem-mt.a\
	/opt/local/lib/libboost_program_options-mt.a\
	/Users/avr/code/scratch/cpp-netlib-0.9.4/libs/network/src/Release/libcppnetlib-uri.a\
	/opt/local/lib/libssl.dylib\
	/opt/local/lib/libcrypto.dylib
	/bin/rm -f /Users/avr/code/scratch/cpp-netlib-0.9.4/tests/Release/cpp-netlib-relative_uri_test


PostBuild.cpp-netlib-uri_builder_stream_test.Release:
PostBuild.cppnetlib-uri.Release: /Users/avr/code/scratch/cpp-netlib-0.9.4/tests/Release/cpp-netlib-uri_builder_stream_test
/Users/avr/code/scratch/cpp-netlib-0.9.4/tests/Release/cpp-netlib-uri_builder_stream_test:\
	/opt/local/lib/libboost_unit_test_framework-mt.a\
	/opt/local/lib/libboost_system-mt.a\
	/opt/local/lib/libboost_regex-mt.a\
	/opt/local/lib/libboost_date_time-mt.a\
	/opt/local/lib/libboost_thread-mt.a\
	/opt/local/lib/libboost_filesystem-mt.a\
	/opt/local/lib/libboost_program_options-mt.a\
	/Users/avr/code/scratch/cpp-netlib-0.9.4/libs/network/src/Release/libcppnetlib-uri.a\
	/opt/local/lib/libssl.dylib\
	/opt/local/lib/libcrypto.dylib
	/bin/rm -f /Users/avr/code/scratch/cpp-netlib-0.9.4/tests/Release/cpp-netlib-uri_builder_stream_test


PostBuild.cpp-netlib-uri_builder_test.Release:
PostBuild.cppnetlib-uri.Release: /Users/avr/code/scratch/cpp-netlib-0.9.4/tests/Release/cpp-netlib-uri_builder_test
/Users/avr/code/scratch/cpp-netlib-0.9.4/tests/Release/cpp-netlib-uri_builder_test:\
	/opt/local/lib/libboost_unit_test_framework-mt.a\
	/opt/local/lib/libboost_system-mt.a\
	/opt/local/lib/libboost_regex-mt.a\
	/opt/local/lib/libboost_date_time-mt.a\
	/opt/local/lib/libboost_thread-mt.a\
	/opt/local/lib/libboost_filesystem-mt.a\
	/opt/local/lib/libboost_program_options-mt.a\
	/Users/avr/code/scratch/cpp-netlib-0.9.4/libs/network/src/Release/libcppnetlib-uri.a\
	/opt/local/lib/libssl.dylib\
	/opt/local/lib/libcrypto.dylib
	/bin/rm -f /Users/avr/code/scratch/cpp-netlib-0.9.4/tests/Release/cpp-netlib-uri_builder_test


PostBuild.cpp-netlib-uri_encoding_test.Release:
PostBuild.cppnetlib-uri.Release: /Users/avr/code/scratch/cpp-netlib-0.9.4/tests/Release/cpp-netlib-uri_encoding_test
/Users/avr/code/scratch/cpp-netlib-0.9.4/tests/Release/cpp-netlib-uri_encoding_test:\
	/opt/local/lib/libboost_unit_test_framework-mt.a\
	/opt/local/lib/libboost_system-mt.a\
	/opt/local/lib/libboost_regex-mt.a\
	/opt/local/lib/libboost_date_time-mt.a\
	/opt/local/lib/libboost_thread-mt.a\
	/opt/local/lib/libboost_filesystem-mt.a\
	/opt/local/lib/libboost_program_options-mt.a\
	/Users/avr/code/scratch/cpp-netlib-0.9.4/libs/network/src/Release/libcppnetlib-uri.a\
	/opt/local/lib/libssl.dylib\
	/opt/local/lib/libcrypto.dylib
	/bin/rm -f /Users/avr/code/scratch/cpp-netlib-0.9.4/tests/Release/cpp-netlib-uri_encoding_test


PostBuild.cpp-netlib-uri_test.Release:
PostBuild.cppnetlib-uri.Release: /Users/avr/code/scratch/cpp-netlib-0.9.4/tests/Release/cpp-netlib-uri_test
/Users/avr/code/scratch/cpp-netlib-0.9.4/tests/Release/cpp-netlib-uri_test:\
	/opt/local/lib/libboost_unit_test_framework-mt.a\
	/opt/local/lib/libboost_system-mt.a\
	/opt/local/lib/libboost_regex-mt.a\
	/opt/local/lib/libboost_date_time-mt.a\
	/opt/local/lib/libboost_thread-mt.a\
	/opt/local/lib/libboost_filesystem-mt.a\
	/opt/local/lib/libboost_program_options-mt.a\
	/Users/avr/code/scratch/cpp-netlib-0.9.4/libs/network/src/Release/libcppnetlib-uri.a\
	/opt/local/lib/libssl.dylib\
	/opt/local/lib/libcrypto.dylib
	/bin/rm -f /Users/avr/code/scratch/cpp-netlib-0.9.4/tests/Release/cpp-netlib-uri_test


PostBuild.cpp-netlib-http-client_constructor_test.Release:
PostBuild.cppnetlib-uri.Release: /Users/avr/code/scratch/cpp-netlib-0.9.4/tests/Release/cpp-netlib-http-client_constructor_test
PostBuild.cppnetlib-client-connections.Release: /Users/avr/code/scratch/cpp-netlib-0.9.4/tests/Release/cpp-netlib-http-client_constructor_test
/Users/avr/code/scratch/cpp-netlib-0.9.4/tests/Release/cpp-netlib-http-client_constructor_test:\
	/opt/local/lib/libboost_unit_test_framework-mt.a\
	/opt/local/lib/libboost_system-mt.a\
	/opt/local/lib/libboost_regex-mt.a\
	/opt/local/lib/libboost_date_time-mt.a\
	/opt/local/lib/libboost_thread-mt.a\
	/opt/local/lib/libboost_filesystem-mt.a\
	/opt/local/lib/libboost_program_options-mt.a\
	/Users/avr/code/scratch/cpp-netlib-0.9.4/libs/network/src/Release/libcppnetlib-uri.a\
	/Users/avr/code/scratch/cpp-netlib-0.9.4/libs/network/src/Release/libcppnetlib-client-connections.a\
	/opt/local/lib/libssl.dylib\
	/opt/local/lib/libcrypto.dylib
	/bin/rm -f /Users/avr/code/scratch/cpp-netlib-0.9.4/tests/Release/cpp-netlib-http-client_constructor_test


PostBuild.cpp-netlib-http-client_get_different_port_test.Release:
PostBuild.cppnetlib-uri.Release: /Users/avr/code/scratch/cpp-netlib-0.9.4/tests/Release/cpp-netlib-http-client_get_different_port_test
PostBuild.cppnetlib-client-connections.Release: /Users/avr/code/scratch/cpp-netlib-0.9.4/tests/Release/cpp-netlib-http-client_get_different_port_test
/Users/avr/code/scratch/cpp-netlib-0.9.4/tests/Release/cpp-netlib-http-client_get_different_port_test:\
	/opt/local/lib/libboost_unit_test_framework-mt.a\
	/opt/local/lib/libboost_system-mt.a\
	/opt/local/lib/libboost_regex-mt.a\
	/opt/local/lib/libboost_date_time-mt.a\
	/opt/local/lib/libboost_thread-mt.a\
	/opt/local/lib/libboost_filesystem-mt.a\
	/opt/local/lib/libboost_program_options-mt.a\
	/Users/avr/code/scratch/cpp-netlib-0.9.4/libs/network/src/Release/libcppnetlib-uri.a\
	/Users/avr/code/scratch/cpp-netlib-0.9.4/libs/network/src/Release/libcppnetlib-client-connections.a\
	/opt/local/lib/libssl.dylib\
	/opt/local/lib/libcrypto.dylib
	/bin/rm -f /Users/avr/code/scratch/cpp-netlib-0.9.4/tests/Release/cpp-netlib-http-client_get_different_port_test


PostBuild.cpp-netlib-http-client_get_streaming_test.Release:
PostBuild.cppnetlib-uri.Release: /Users/avr/code/scratch/cpp-netlib-0.9.4/tests/Release/cpp-netlib-http-client_get_streaming_test
PostBuild.cppnetlib-client-connections.Release: /Users/avr/code/scratch/cpp-netlib-0.9.4/tests/Release/cpp-netlib-http-client_get_streaming_test
/Users/avr/code/scratch/cpp-netlib-0.9.4/tests/Release/cpp-netlib-http-client_get_streaming_test:\
	/opt/local/lib/libboost_unit_test_framework-mt.a\
	/opt/local/lib/libboost_system-mt.a\
	/opt/local/lib/libboost_regex-mt.a\
	/opt/local/lib/libboost_date_time-mt.a\
	/opt/local/lib/libboost_thread-mt.a\
	/opt/local/lib/libboost_filesystem-mt.a\
	/opt/local/lib/libboost_program_options-mt.a\
	/Users/avr/code/scratch/cpp-netlib-0.9.4/libs/network/src/Release/libcppnetlib-uri.a\
	/Users/avr/code/scratch/cpp-netlib-0.9.4/libs/network/src/Release/libcppnetlib-client-connections.a\
	/opt/local/lib/libssl.dylib\
	/opt/local/lib/libcrypto.dylib
	/bin/rm -f /Users/avr/code/scratch/cpp-netlib-0.9.4/tests/Release/cpp-netlib-http-client_get_streaming_test


PostBuild.cpp-netlib-http-client_get_test.Release:
PostBuild.cppnetlib-uri.Release: /Users/avr/code/scratch/cpp-netlib-0.9.4/tests/Release/cpp-netlib-http-client_get_test
PostBuild.cppnetlib-client-connections.Release: /Users/avr/code/scratch/cpp-netlib-0.9.4/tests/Release/cpp-netlib-http-client_get_test
/Users/avr/code/scratch/cpp-netlib-0.9.4/tests/Release/cpp-netlib-http-client_get_test:\
	/opt/local/lib/libboost_unit_test_framework-mt.a\
	/opt/local/lib/libboost_system-mt.a\
	/opt/local/lib/libboost_regex-mt.a\
	/opt/local/lib/libboost_date_time-mt.a\
	/opt/local/lib/libboost_thread-mt.a\
	/opt/local/lib/libboost_filesystem-mt.a\
	/opt/local/lib/libboost_program_options-mt.a\
	/Users/avr/code/scratch/cpp-netlib-0.9.4/libs/network/src/Release/libcppnetlib-uri.a\
	/Users/avr/code/scratch/cpp-netlib-0.9.4/libs/network/src/Release/libcppnetlib-client-connections.a\
	/opt/local/lib/libssl.dylib\
	/opt/local/lib/libcrypto.dylib
	/bin/rm -f /Users/avr/code/scratch/cpp-netlib-0.9.4/tests/Release/cpp-netlib-http-client_get_test


PostBuild.cpp-netlib-http-client_get_timeout_test.Release:
PostBuild.cppnetlib-uri.Release: /Users/avr/code/scratch/cpp-netlib-0.9.4/tests/Release/cpp-netlib-http-client_get_timeout_test
PostBuild.cppnetlib-client-connections.Release: /Users/avr/code/scratch/cpp-netlib-0.9.4/tests/Release/cpp-netlib-http-client_get_timeout_test
/Users/avr/code/scratch/cpp-netlib-0.9.4/tests/Release/cpp-netlib-http-client_get_timeout_test:\
	/opt/local/lib/libboost_unit_test_framework-mt.a\
	/opt/local/lib/libboost_system-mt.a\
	/opt/local/lib/libboost_regex-mt.a\
	/opt/local/lib/libboost_date_time-mt.a\
	/opt/local/lib/libboost_thread-mt.a\
	/opt/local/lib/libboost_filesystem-mt.a\
	/opt/local/lib/libboost_program_options-mt.a\
	/Users/avr/code/scratch/cpp-netlib-0.9.4/libs/network/src/Release/libcppnetlib-uri.a\
	/Users/avr/code/scratch/cpp-netlib-0.9.4/libs/network/src/Release/libcppnetlib-client-connections.a\
	/opt/local/lib/libssl.dylib\
	/opt/local/lib/libcrypto.dylib
	/bin/rm -f /Users/avr/code/scratch/cpp-netlib-0.9.4/tests/Release/cpp-netlib-http-client_get_timeout_test


PostBuild.cpp-netlib-http-server_async_run_stop_concurrency.Release:
PostBuild.cppnetlib-server-parsers.Release: /Users/avr/code/scratch/cpp-netlib-0.9.4/tests/Release/cpp-netlib-http-server_async_run_stop_concurrency
/Users/avr/code/scratch/cpp-netlib-0.9.4/tests/Release/cpp-netlib-http-server_async_run_stop_concurrency:\
	/opt/local/lib/libboost_unit_test_framework-mt.a\
	/opt/local/lib/libboost_system-mt.a\
	/opt/local/lib/libboost_regex-mt.a\
	/opt/local/lib/libboost_date_time-mt.a\
	/opt/local/lib/libboost_thread-mt.a\
	/opt/local/lib/libboost_filesystem-mt.a\
	/opt/local/lib/libboost_program_options-mt.a\
	/Users/avr/code/scratch/cpp-netlib-0.9.4/libs/network/src/Release/libcppnetlib-server-parsers.a
	/bin/rm -f /Users/avr/code/scratch/cpp-netlib-0.9.4/tests/Release/cpp-netlib-http-server_async_run_stop_concurrency


PostBuild.cpp-netlib-http-server_constructor_test.Release:
PostBuild.cppnetlib-server-parsers.Release: /Users/avr/code/scratch/cpp-netlib-0.9.4/tests/Release/cpp-netlib-http-server_constructor_test
/Users/avr/code/scratch/cpp-netlib-0.9.4/tests/Release/cpp-netlib-http-server_constructor_test:\
	/opt/local/lib/libboost_unit_test_framework-mt.a\
	/opt/local/lib/libboost_system-mt.a\
	/opt/local/lib/libboost_regex-mt.a\
	/opt/local/lib/libboost_date_time-mt.a\
	/opt/local/lib/libboost_thread-mt.a\
	/opt/local/lib/libboost_filesystem-mt.a\
	/opt/local/lib/libboost_program_options-mt.a\
	/Users/avr/code/scratch/cpp-netlib-0.9.4/libs/network/src/Release/libcppnetlib-server-parsers.a
	/bin/rm -f /Users/avr/code/scratch/cpp-netlib-0.9.4/tests/Release/cpp-netlib-http-server_constructor_test


PostBuild.mime-roundtrip.Release:
/Users/avr/code/scratch/cpp-netlib-0.9.4/libs/mime/test/Release/mime-roundtrip:\
	/opt/local/lib/libboost_unit_test_framework-mt.a\
	/opt/local/lib/libboost_system-mt.a\
	/opt/local/lib/libboost_regex-mt.a\
	/opt/local/lib/libboost_date_time-mt.a\
	/opt/local/lib/libboost_thread-mt.a\
	/opt/local/lib/libboost_filesystem-mt.a\
	/opt/local/lib/libboost_program_options-mt.a\
	/opt/local/lib/libboost_unit_test_framework-mt.a\
	/opt/local/lib/libboost_system-mt.a\
	/opt/local/lib/libboost_regex-mt.a\
	/opt/local/lib/libboost_date_time-mt.a\
	/opt/local/lib/libboost_thread-mt.a\
	/opt/local/lib/libboost_filesystem-mt.a\
	/opt/local/lib/libboost_program_options-mt.a
	/bin/rm -f /Users/avr/code/scratch/cpp-netlib-0.9.4/libs/mime/test/Release/mime-roundtrip


PostBuild.atom_reader.Release:
PostBuild.cppnetlib-uri.Release: /Users/avr/code/scratch/cpp-netlib-0.9.4/example/Release/atom_reader
PostBuild.cppnetlib-client-connections.Release: /Users/avr/code/scratch/cpp-netlib-0.9.4/example/Release/atom_reader
/Users/avr/code/scratch/cpp-netlib-0.9.4/example/Release/atom_reader:\
	/opt/local/lib/libboost_program_options-mt.a\
	/opt/local/lib/libboost_thread-mt.a\
	/opt/local/lib/libboost_date_time-mt.a\
	/opt/local/lib/libboost_regex-mt.a\
	/opt/local/lib/libboost_system-mt.a\
	/Users/avr/code/scratch/cpp-netlib-0.9.4/libs/network/src/Release/libcppnetlib-uri.a\
	/Users/avr/code/scratch/cpp-netlib-0.9.4/libs/network/src/Release/libcppnetlib-client-connections.a\
	/opt/local/lib/libssl.dylib\
	/opt/local/lib/libcrypto.dylib
	/bin/rm -f /Users/avr/code/scratch/cpp-netlib-0.9.4/example/Release/atom_reader


PostBuild.fileserver.Release:
PostBuild.cppnetlib-server-parsers.Release: /Users/avr/code/scratch/cpp-netlib-0.9.4/example/Release/fileserver
/Users/avr/code/scratch/cpp-netlib-0.9.4/example/Release/fileserver:\
	/opt/local/lib/libboost_thread-mt.a\
	/opt/local/lib/libboost_system-mt.a\
	/opt/local/lib/libboost_date_time-mt.a\
	/opt/local/lib/libboost_program_options-mt.a\
	/opt/local/lib/libboost_filesystem-mt.a\
	/Users/avr/code/scratch/cpp-netlib-0.9.4/libs/network/src/Release/libcppnetlib-server-parsers.a
	/bin/rm -f /Users/avr/code/scratch/cpp-netlib-0.9.4/example/Release/fileserver


PostBuild.hello_world_client.Release:
PostBuild.cppnetlib-uri.Release: /Users/avr/code/scratch/cpp-netlib-0.9.4/example/Release/hello_world_client
PostBuild.cppnetlib-client-connections.Release: /Users/avr/code/scratch/cpp-netlib-0.9.4/example/Release/hello_world_client
/Users/avr/code/scratch/cpp-netlib-0.9.4/example/Release/hello_world_client:\
	/opt/local/lib/libboost_program_options-mt.a\
	/opt/local/lib/libboost_thread-mt.a\
	/opt/local/lib/libboost_date_time-mt.a\
	/opt/local/lib/libboost_regex-mt.a\
	/opt/local/lib/libboost_system-mt.a\
	/Users/avr/code/scratch/cpp-netlib-0.9.4/libs/network/src/Release/libcppnetlib-uri.a\
	/Users/avr/code/scratch/cpp-netlib-0.9.4/libs/network/src/Release/libcppnetlib-client-connections.a\
	/opt/local/lib/libssl.dylib\
	/opt/local/lib/libcrypto.dylib
	/bin/rm -f /Users/avr/code/scratch/cpp-netlib-0.9.4/example/Release/hello_world_client


PostBuild.hello_world_server.Release:
/Users/avr/code/scratch/cpp-netlib-0.9.4/example/Release/hello_world_server:\
	/opt/local/lib/libboost_thread-mt.a\
	/opt/local/lib/libboost_system-mt.a\
	/opt/local/lib/libboost_date_time-mt.a\
	/opt/local/lib/libboost_program_options-mt.a\
	/opt/local/lib/libssl.dylib\
	/opt/local/lib/libcrypto.dylib
	/bin/rm -f /Users/avr/code/scratch/cpp-netlib-0.9.4/example/Release/hello_world_server


PostBuild.http_client.Release:
PostBuild.cppnetlib-uri.Release: /Users/avr/code/scratch/cpp-netlib-0.9.4/example/Release/http_client
PostBuild.cppnetlib-client-connections.Release: /Users/avr/code/scratch/cpp-netlib-0.9.4/example/Release/http_client
/Users/avr/code/scratch/cpp-netlib-0.9.4/example/Release/http_client:\
	/opt/local/lib/libboost_program_options-mt.a\
	/opt/local/lib/libboost_thread-mt.a\
	/opt/local/lib/libboost_date_time-mt.a\
	/opt/local/lib/libboost_regex-mt.a\
	/opt/local/lib/libboost_system-mt.a\
	/Users/avr/code/scratch/cpp-netlib-0.9.4/libs/network/src/Release/libcppnetlib-uri.a\
	/Users/avr/code/scratch/cpp-netlib-0.9.4/libs/network/src/Release/libcppnetlib-client-connections.a\
	/opt/local/lib/libssl.dylib\
	/opt/local/lib/libcrypto.dylib
	/bin/rm -f /Users/avr/code/scratch/cpp-netlib-0.9.4/example/Release/http_client


PostBuild.rss_reader.Release:
PostBuild.cppnetlib-uri.Release: /Users/avr/code/scratch/cpp-netlib-0.9.4/example/Release/rss_reader
PostBuild.cppnetlib-client-connections.Release: /Users/avr/code/scratch/cpp-netlib-0.9.4/example/Release/rss_reader
/Users/avr/code/scratch/cpp-netlib-0.9.4/example/Release/rss_reader:\
	/opt/local/lib/libboost_program_options-mt.a\
	/opt/local/lib/libboost_thread-mt.a\
	/opt/local/lib/libboost_date_time-mt.a\
	/opt/local/lib/libboost_regex-mt.a\
	/opt/local/lib/libboost_system-mt.a\
	/Users/avr/code/scratch/cpp-netlib-0.9.4/libs/network/src/Release/libcppnetlib-uri.a\
	/Users/avr/code/scratch/cpp-netlib-0.9.4/libs/network/src/Release/libcppnetlib-client-connections.a\
	/opt/local/lib/libssl.dylib\
	/opt/local/lib/libcrypto.dylib
	/bin/rm -f /Users/avr/code/scratch/cpp-netlib-0.9.4/example/Release/rss_reader


PostBuild.simple_wget.Release:
PostBuild.cppnetlib-uri.Release: /Users/avr/code/scratch/cpp-netlib-0.9.4/example/Release/simple_wget
PostBuild.cppnetlib-client-connections.Release: /Users/avr/code/scratch/cpp-netlib-0.9.4/example/Release/simple_wget
/Users/avr/code/scratch/cpp-netlib-0.9.4/example/Release/simple_wget:\
	/opt/local/lib/libboost_program_options-mt.a\
	/opt/local/lib/libboost_thread-mt.a\
	/opt/local/lib/libboost_date_time-mt.a\
	/opt/local/lib/libboost_regex-mt.a\
	/opt/local/lib/libboost_system-mt.a\
	/Users/avr/code/scratch/cpp-netlib-0.9.4/libs/network/src/Release/libcppnetlib-uri.a\
	/Users/avr/code/scratch/cpp-netlib-0.9.4/libs/network/src/Release/libcppnetlib-client-connections.a\
	/opt/local/lib/libssl.dylib\
	/opt/local/lib/libcrypto.dylib
	/bin/rm -f /Users/avr/code/scratch/cpp-netlib-0.9.4/example/Release/simple_wget


PostBuild.twitter_search.Release:
PostBuild.cppnetlib-uri.Release: /Users/avr/code/scratch/cpp-netlib-0.9.4/example/Release/twitter_search
PostBuild.cppnetlib-client-connections.Release: /Users/avr/code/scratch/cpp-netlib-0.9.4/example/Release/twitter_search
/Users/avr/code/scratch/cpp-netlib-0.9.4/example/Release/twitter_search:\
	/opt/local/lib/libboost_program_options-mt.a\
	/opt/local/lib/libboost_thread-mt.a\
	/opt/local/lib/libboost_date_time-mt.a\
	/opt/local/lib/libboost_regex-mt.a\
	/opt/local/lib/libboost_system-mt.a\
	/Users/avr/code/scratch/cpp-netlib-0.9.4/libs/network/src/Release/libcppnetlib-uri.a\
	/Users/avr/code/scratch/cpp-netlib-0.9.4/libs/network/src/Release/libcppnetlib-client-connections.a\
	/opt/local/lib/libssl.dylib\
	/opt/local/lib/libcrypto.dylib
	/bin/rm -f /Users/avr/code/scratch/cpp-netlib-0.9.4/example/Release/twitter_search


PostBuild.cppnetlib-client-connections.MinSizeRel:
PostBuild.cppnetlib-server-parsers.MinSizeRel:
PostBuild.cppnetlib-uri.MinSizeRel:
PostBuild.cpp-netlib-message_test.MinSizeRel:
PostBuild.cppnetlib-uri.MinSizeRel: /Users/avr/code/scratch/cpp-netlib-0.9.4/tests/MinSizeRel/cpp-netlib-message_test
/Users/avr/code/scratch/cpp-netlib-0.9.4/tests/MinSizeRel/cpp-netlib-message_test:\
	/opt/local/lib/libboost_unit_test_framework-mt.a\
	/opt/local/lib/libboost_system-mt.a\
	/opt/local/lib/libboost_regex-mt.a\
	/opt/local/lib/libboost_date_time-mt.a\
	/opt/local/lib/libboost_thread-mt.a\
	/opt/local/lib/libboost_filesystem-mt.a\
	/opt/local/lib/libboost_program_options-mt.a\
	/Users/avr/code/scratch/cpp-netlib-0.9.4/libs/network/src/MinSizeRel/libcppnetlib-uri.a\
	/opt/local/lib/libssl.dylib\
	/opt/local/lib/libcrypto.dylib
	/bin/rm -f /Users/avr/code/scratch/cpp-netlib-0.9.4/tests/MinSizeRel/cpp-netlib-message_test


PostBuild.cpp-netlib-message_transform_test.MinSizeRel:
PostBuild.cppnetlib-uri.MinSizeRel: /Users/avr/code/scratch/cpp-netlib-0.9.4/tests/MinSizeRel/cpp-netlib-message_transform_test
/Users/avr/code/scratch/cpp-netlib-0.9.4/tests/MinSizeRel/cpp-netlib-message_transform_test:\
	/opt/local/lib/libboost_unit_test_framework-mt.a\
	/opt/local/lib/libboost_system-mt.a\
	/opt/local/lib/libboost_regex-mt.a\
	/opt/local/lib/libboost_date_time-mt.a\
	/opt/local/lib/libboost_thread-mt.a\
	/opt/local/lib/libboost_filesystem-mt.a\
	/opt/local/lib/libboost_program_options-mt.a\
	/Users/avr/code/scratch/cpp-netlib-0.9.4/libs/network/src/MinSizeRel/libcppnetlib-uri.a\
	/opt/local/lib/libssl.dylib\
	/opt/local/lib/libcrypto.dylib
	/bin/rm -f /Users/avr/code/scratch/cpp-netlib-0.9.4/tests/MinSizeRel/cpp-netlib-message_transform_test


PostBuild.cpp-netlib-utils_thread_pool.MinSizeRel:
PostBuild.cppnetlib-uri.MinSizeRel: /Users/avr/code/scratch/cpp-netlib-0.9.4/tests/MinSizeRel/cpp-netlib-utils_thread_pool
/Users/avr/code/scratch/cpp-netlib-0.9.4/tests/MinSizeRel/cpp-netlib-utils_thread_pool:\
	/opt/local/lib/libboost_unit_test_framework-mt.a\
	/opt/local/lib/libboost_system-mt.a\
	/opt/local/lib/libboost_regex-mt.a\
	/opt/local/lib/libboost_date_time-mt.a\
	/opt/local/lib/libboost_thread-mt.a\
	/opt/local/lib/libboost_filesystem-mt.a\
	/opt/local/lib/libboost_program_options-mt.a\
	/Users/avr/code/scratch/cpp-netlib-0.9.4/libs/network/src/MinSizeRel/libcppnetlib-uri.a\
	/opt/local/lib/libssl.dylib\
	/opt/local/lib/libcrypto.dylib
	/bin/rm -f /Users/avr/code/scratch/cpp-netlib-0.9.4/tests/MinSizeRel/cpp-netlib-utils_thread_pool


PostBuild.cpp-netlib-relative_uri_test.MinSizeRel:
PostBuild.cppnetlib-uri.MinSizeRel: /Users/avr/code/scratch/cpp-netlib-0.9.4/tests/MinSizeRel/cpp-netlib-relative_uri_test
/Users/avr/code/scratch/cpp-netlib-0.9.4/tests/MinSizeRel/cpp-netlib-relative_uri_test:\
	/opt/local/lib/libboost_unit_test_framework-mt.a\
	/opt/local/lib/libboost_system-mt.a\
	/opt/local/lib/libboost_regex-mt.a\
	/opt/local/lib/libboost_date_time-mt.a\
	/opt/local/lib/libboost_thread-mt.a\
	/opt/local/lib/libboost_filesystem-mt.a\
	/opt/local/lib/libboost_program_options-mt.a\
	/Users/avr/code/scratch/cpp-netlib-0.9.4/libs/network/src/MinSizeRel/libcppnetlib-uri.a\
	/opt/local/lib/libssl.dylib\
	/opt/local/lib/libcrypto.dylib
	/bin/rm -f /Users/avr/code/scratch/cpp-netlib-0.9.4/tests/MinSizeRel/cpp-netlib-relative_uri_test


PostBuild.cpp-netlib-uri_builder_stream_test.MinSizeRel:
PostBuild.cppnetlib-uri.MinSizeRel: /Users/avr/code/scratch/cpp-netlib-0.9.4/tests/MinSizeRel/cpp-netlib-uri_builder_stream_test
/Users/avr/code/scratch/cpp-netlib-0.9.4/tests/MinSizeRel/cpp-netlib-uri_builder_stream_test:\
	/opt/local/lib/libboost_unit_test_framework-mt.a\
	/opt/local/lib/libboost_system-mt.a\
	/opt/local/lib/libboost_regex-mt.a\
	/opt/local/lib/libboost_date_time-mt.a\
	/opt/local/lib/libboost_thread-mt.a\
	/opt/local/lib/libboost_filesystem-mt.a\
	/opt/local/lib/libboost_program_options-mt.a\
	/Users/avr/code/scratch/cpp-netlib-0.9.4/libs/network/src/MinSizeRel/libcppnetlib-uri.a\
	/opt/local/lib/libssl.dylib\
	/opt/local/lib/libcrypto.dylib
	/bin/rm -f /Users/avr/code/scratch/cpp-netlib-0.9.4/tests/MinSizeRel/cpp-netlib-uri_builder_stream_test


PostBuild.cpp-netlib-uri_builder_test.MinSizeRel:
PostBuild.cppnetlib-uri.MinSizeRel: /Users/avr/code/scratch/cpp-netlib-0.9.4/tests/MinSizeRel/cpp-netlib-uri_builder_test
/Users/avr/code/scratch/cpp-netlib-0.9.4/tests/MinSizeRel/cpp-netlib-uri_builder_test:\
	/opt/local/lib/libboost_unit_test_framework-mt.a\
	/opt/local/lib/libboost_system-mt.a\
	/opt/local/lib/libboost_regex-mt.a\
	/opt/local/lib/libboost_date_time-mt.a\
	/opt/local/lib/libboost_thread-mt.a\
	/opt/local/lib/libboost_filesystem-mt.a\
	/opt/local/lib/libboost_program_options-mt.a\
	/Users/avr/code/scratch/cpp-netlib-0.9.4/libs/network/src/MinSizeRel/libcppnetlib-uri.a\
	/opt/local/lib/libssl.dylib\
	/opt/local/lib/libcrypto.dylib
	/bin/rm -f /Users/avr/code/scratch/cpp-netlib-0.9.4/tests/MinSizeRel/cpp-netlib-uri_builder_test


PostBuild.cpp-netlib-uri_encoding_test.MinSizeRel:
PostBuild.cppnetlib-uri.MinSizeRel: /Users/avr/code/scratch/cpp-netlib-0.9.4/tests/MinSizeRel/cpp-netlib-uri_encoding_test
/Users/avr/code/scratch/cpp-netlib-0.9.4/tests/MinSizeRel/cpp-netlib-uri_encoding_test:\
	/opt/local/lib/libboost_unit_test_framework-mt.a\
	/opt/local/lib/libboost_system-mt.a\
	/opt/local/lib/libboost_regex-mt.a\
	/opt/local/lib/libboost_date_time-mt.a\
	/opt/local/lib/libboost_thread-mt.a\
	/opt/local/lib/libboost_filesystem-mt.a\
	/opt/local/lib/libboost_program_options-mt.a\
	/Users/avr/code/scratch/cpp-netlib-0.9.4/libs/network/src/MinSizeRel/libcppnetlib-uri.a\
	/opt/local/lib/libssl.dylib\
	/opt/local/lib/libcrypto.dylib
	/bin/rm -f /Users/avr/code/scratch/cpp-netlib-0.9.4/tests/MinSizeRel/cpp-netlib-uri_encoding_test


PostBuild.cpp-netlib-uri_test.MinSizeRel:
PostBuild.cppnetlib-uri.MinSizeRel: /Users/avr/code/scratch/cpp-netlib-0.9.4/tests/MinSizeRel/cpp-netlib-uri_test
/Users/avr/code/scratch/cpp-netlib-0.9.4/tests/MinSizeRel/cpp-netlib-uri_test:\
	/opt/local/lib/libboost_unit_test_framework-mt.a\
	/opt/local/lib/libboost_system-mt.a\
	/opt/local/lib/libboost_regex-mt.a\
	/opt/local/lib/libboost_date_time-mt.a\
	/opt/local/lib/libboost_thread-mt.a\
	/opt/local/lib/libboost_filesystem-mt.a\
	/opt/local/lib/libboost_program_options-mt.a\
	/Users/avr/code/scratch/cpp-netlib-0.9.4/libs/network/src/MinSizeRel/libcppnetlib-uri.a\
	/opt/local/lib/libssl.dylib\
	/opt/local/lib/libcrypto.dylib
	/bin/rm -f /Users/avr/code/scratch/cpp-netlib-0.9.4/tests/MinSizeRel/cpp-netlib-uri_test


PostBuild.cpp-netlib-http-client_constructor_test.MinSizeRel:
PostBuild.cppnetlib-uri.MinSizeRel: /Users/avr/code/scratch/cpp-netlib-0.9.4/tests/MinSizeRel/cpp-netlib-http-client_constructor_test
PostBuild.cppnetlib-client-connections.MinSizeRel: /Users/avr/code/scratch/cpp-netlib-0.9.4/tests/MinSizeRel/cpp-netlib-http-client_constructor_test
/Users/avr/code/scratch/cpp-netlib-0.9.4/tests/MinSizeRel/cpp-netlib-http-client_constructor_test:\
	/opt/local/lib/libboost_unit_test_framework-mt.a\
	/opt/local/lib/libboost_system-mt.a\
	/opt/local/lib/libboost_regex-mt.a\
	/opt/local/lib/libboost_date_time-mt.a\
	/opt/local/lib/libboost_thread-mt.a\
	/opt/local/lib/libboost_filesystem-mt.a\
	/opt/local/lib/libboost_program_options-mt.a\
	/Users/avr/code/scratch/cpp-netlib-0.9.4/libs/network/src/MinSizeRel/libcppnetlib-uri.a\
	/Users/avr/code/scratch/cpp-netlib-0.9.4/libs/network/src/MinSizeRel/libcppnetlib-client-connections.a\
	/opt/local/lib/libssl.dylib\
	/opt/local/lib/libcrypto.dylib
	/bin/rm -f /Users/avr/code/scratch/cpp-netlib-0.9.4/tests/MinSizeRel/cpp-netlib-http-client_constructor_test


PostBuild.cpp-netlib-http-client_get_different_port_test.MinSizeRel:
PostBuild.cppnetlib-uri.MinSizeRel: /Users/avr/code/scratch/cpp-netlib-0.9.4/tests/MinSizeRel/cpp-netlib-http-client_get_different_port_test
PostBuild.cppnetlib-client-connections.MinSizeRel: /Users/avr/code/scratch/cpp-netlib-0.9.4/tests/MinSizeRel/cpp-netlib-http-client_get_different_port_test
/Users/avr/code/scratch/cpp-netlib-0.9.4/tests/MinSizeRel/cpp-netlib-http-client_get_different_port_test:\
	/opt/local/lib/libboost_unit_test_framework-mt.a\
	/opt/local/lib/libboost_system-mt.a\
	/opt/local/lib/libboost_regex-mt.a\
	/opt/local/lib/libboost_date_time-mt.a\
	/opt/local/lib/libboost_thread-mt.a\
	/opt/local/lib/libboost_filesystem-mt.a\
	/opt/local/lib/libboost_program_options-mt.a\
	/Users/avr/code/scratch/cpp-netlib-0.9.4/libs/network/src/MinSizeRel/libcppnetlib-uri.a\
	/Users/avr/code/scratch/cpp-netlib-0.9.4/libs/network/src/MinSizeRel/libcppnetlib-client-connections.a\
	/opt/local/lib/libssl.dylib\
	/opt/local/lib/libcrypto.dylib
	/bin/rm -f /Users/avr/code/scratch/cpp-netlib-0.9.4/tests/MinSizeRel/cpp-netlib-http-client_get_different_port_test


PostBuild.cpp-netlib-http-client_get_streaming_test.MinSizeRel:
PostBuild.cppnetlib-uri.MinSizeRel: /Users/avr/code/scratch/cpp-netlib-0.9.4/tests/MinSizeRel/cpp-netlib-http-client_get_streaming_test
PostBuild.cppnetlib-client-connections.MinSizeRel: /Users/avr/code/scratch/cpp-netlib-0.9.4/tests/MinSizeRel/cpp-netlib-http-client_get_streaming_test
/Users/avr/code/scratch/cpp-netlib-0.9.4/tests/MinSizeRel/cpp-netlib-http-client_get_streaming_test:\
	/opt/local/lib/libboost_unit_test_framework-mt.a\
	/opt/local/lib/libboost_system-mt.a\
	/opt/local/lib/libboost_regex-mt.a\
	/opt/local/lib/libboost_date_time-mt.a\
	/opt/local/lib/libboost_thread-mt.a\
	/opt/local/lib/libboost_filesystem-mt.a\
	/opt/local/lib/libboost_program_options-mt.a\
	/Users/avr/code/scratch/cpp-netlib-0.9.4/libs/network/src/MinSizeRel/libcppnetlib-uri.a\
	/Users/avr/code/scratch/cpp-netlib-0.9.4/libs/network/src/MinSizeRel/libcppnetlib-client-connections.a\
	/opt/local/lib/libssl.dylib\
	/opt/local/lib/libcrypto.dylib
	/bin/rm -f /Users/avr/code/scratch/cpp-netlib-0.9.4/tests/MinSizeRel/cpp-netlib-http-client_get_streaming_test


PostBuild.cpp-netlib-http-client_get_test.MinSizeRel:
PostBuild.cppnetlib-uri.MinSizeRel: /Users/avr/code/scratch/cpp-netlib-0.9.4/tests/MinSizeRel/cpp-netlib-http-client_get_test
PostBuild.cppnetlib-client-connections.MinSizeRel: /Users/avr/code/scratch/cpp-netlib-0.9.4/tests/MinSizeRel/cpp-netlib-http-client_get_test
/Users/avr/code/scratch/cpp-netlib-0.9.4/tests/MinSizeRel/cpp-netlib-http-client_get_test:\
	/opt/local/lib/libboost_unit_test_framework-mt.a\
	/opt/local/lib/libboost_system-mt.a\
	/opt/local/lib/libboost_regex-mt.a\
	/opt/local/lib/libboost_date_time-mt.a\
	/opt/local/lib/libboost_thread-mt.a\
	/opt/local/lib/libboost_filesystem-mt.a\
	/opt/local/lib/libboost_program_options-mt.a\
	/Users/avr/code/scratch/cpp-netlib-0.9.4/libs/network/src/MinSizeRel/libcppnetlib-uri.a\
	/Users/avr/code/scratch/cpp-netlib-0.9.4/libs/network/src/MinSizeRel/libcppnetlib-client-connections.a\
	/opt/local/lib/libssl.dylib\
	/opt/local/lib/libcrypto.dylib
	/bin/rm -f /Users/avr/code/scratch/cpp-netlib-0.9.4/tests/MinSizeRel/cpp-netlib-http-client_get_test


PostBuild.cpp-netlib-http-client_get_timeout_test.MinSizeRel:
PostBuild.cppnetlib-uri.MinSizeRel: /Users/avr/code/scratch/cpp-netlib-0.9.4/tests/MinSizeRel/cpp-netlib-http-client_get_timeout_test
PostBuild.cppnetlib-client-connections.MinSizeRel: /Users/avr/code/scratch/cpp-netlib-0.9.4/tests/MinSizeRel/cpp-netlib-http-client_get_timeout_test
/Users/avr/code/scratch/cpp-netlib-0.9.4/tests/MinSizeRel/cpp-netlib-http-client_get_timeout_test:\
	/opt/local/lib/libboost_unit_test_framework-mt.a\
	/opt/local/lib/libboost_system-mt.a\
	/opt/local/lib/libboost_regex-mt.a\
	/opt/local/lib/libboost_date_time-mt.a\
	/opt/local/lib/libboost_thread-mt.a\
	/opt/local/lib/libboost_filesystem-mt.a\
	/opt/local/lib/libboost_program_options-mt.a\
	/Users/avr/code/scratch/cpp-netlib-0.9.4/libs/network/src/MinSizeRel/libcppnetlib-uri.a\
	/Users/avr/code/scratch/cpp-netlib-0.9.4/libs/network/src/MinSizeRel/libcppnetlib-client-connections.a\
	/opt/local/lib/libssl.dylib\
	/opt/local/lib/libcrypto.dylib
	/bin/rm -f /Users/avr/code/scratch/cpp-netlib-0.9.4/tests/MinSizeRel/cpp-netlib-http-client_get_timeout_test


PostBuild.cpp-netlib-http-server_async_run_stop_concurrency.MinSizeRel:
PostBuild.cppnetlib-server-parsers.MinSizeRel: /Users/avr/code/scratch/cpp-netlib-0.9.4/tests/MinSizeRel/cpp-netlib-http-server_async_run_stop_concurrency
/Users/avr/code/scratch/cpp-netlib-0.9.4/tests/MinSizeRel/cpp-netlib-http-server_async_run_stop_concurrency:\
	/opt/local/lib/libboost_unit_test_framework-mt.a\
	/opt/local/lib/libboost_system-mt.a\
	/opt/local/lib/libboost_regex-mt.a\
	/opt/local/lib/libboost_date_time-mt.a\
	/opt/local/lib/libboost_thread-mt.a\
	/opt/local/lib/libboost_filesystem-mt.a\
	/opt/local/lib/libboost_program_options-mt.a\
	/Users/avr/code/scratch/cpp-netlib-0.9.4/libs/network/src/MinSizeRel/libcppnetlib-server-parsers.a
	/bin/rm -f /Users/avr/code/scratch/cpp-netlib-0.9.4/tests/MinSizeRel/cpp-netlib-http-server_async_run_stop_concurrency


PostBuild.cpp-netlib-http-server_constructor_test.MinSizeRel:
PostBuild.cppnetlib-server-parsers.MinSizeRel: /Users/avr/code/scratch/cpp-netlib-0.9.4/tests/MinSizeRel/cpp-netlib-http-server_constructor_test
/Users/avr/code/scratch/cpp-netlib-0.9.4/tests/MinSizeRel/cpp-netlib-http-server_constructor_test:\
	/opt/local/lib/libboost_unit_test_framework-mt.a\
	/opt/local/lib/libboost_system-mt.a\
	/opt/local/lib/libboost_regex-mt.a\
	/opt/local/lib/libboost_date_time-mt.a\
	/opt/local/lib/libboost_thread-mt.a\
	/opt/local/lib/libboost_filesystem-mt.a\
	/opt/local/lib/libboost_program_options-mt.a\
	/Users/avr/code/scratch/cpp-netlib-0.9.4/libs/network/src/MinSizeRel/libcppnetlib-server-parsers.a
	/bin/rm -f /Users/avr/code/scratch/cpp-netlib-0.9.4/tests/MinSizeRel/cpp-netlib-http-server_constructor_test


PostBuild.mime-roundtrip.MinSizeRel:
/Users/avr/code/scratch/cpp-netlib-0.9.4/libs/mime/test/MinSizeRel/mime-roundtrip:\
	/opt/local/lib/libboost_unit_test_framework-mt.a\
	/opt/local/lib/libboost_system-mt.a\
	/opt/local/lib/libboost_regex-mt.a\
	/opt/local/lib/libboost_date_time-mt.a\
	/opt/local/lib/libboost_thread-mt.a\
	/opt/local/lib/libboost_filesystem-mt.a\
	/opt/local/lib/libboost_program_options-mt.a\
	/opt/local/lib/libboost_unit_test_framework-mt.a\
	/opt/local/lib/libboost_system-mt.a\
	/opt/local/lib/libboost_regex-mt.a\
	/opt/local/lib/libboost_date_time-mt.a\
	/opt/local/lib/libboost_thread-mt.a\
	/opt/local/lib/libboost_filesystem-mt.a\
	/opt/local/lib/libboost_program_options-mt.a
	/bin/rm -f /Users/avr/code/scratch/cpp-netlib-0.9.4/libs/mime/test/MinSizeRel/mime-roundtrip


PostBuild.atom_reader.MinSizeRel:
PostBuild.cppnetlib-uri.MinSizeRel: /Users/avr/code/scratch/cpp-netlib-0.9.4/example/MinSizeRel/atom_reader
PostBuild.cppnetlib-client-connections.MinSizeRel: /Users/avr/code/scratch/cpp-netlib-0.9.4/example/MinSizeRel/atom_reader
/Users/avr/code/scratch/cpp-netlib-0.9.4/example/MinSizeRel/atom_reader:\
	/opt/local/lib/libboost_program_options-mt.a\
	/opt/local/lib/libboost_thread-mt.a\
	/opt/local/lib/libboost_date_time-mt.a\
	/opt/local/lib/libboost_regex-mt.a\
	/opt/local/lib/libboost_system-mt.a\
	/Users/avr/code/scratch/cpp-netlib-0.9.4/libs/network/src/MinSizeRel/libcppnetlib-uri.a\
	/Users/avr/code/scratch/cpp-netlib-0.9.4/libs/network/src/MinSizeRel/libcppnetlib-client-connections.a\
	/opt/local/lib/libssl.dylib\
	/opt/local/lib/libcrypto.dylib
	/bin/rm -f /Users/avr/code/scratch/cpp-netlib-0.9.4/example/MinSizeRel/atom_reader


PostBuild.fileserver.MinSizeRel:
PostBuild.cppnetlib-server-parsers.MinSizeRel: /Users/avr/code/scratch/cpp-netlib-0.9.4/example/MinSizeRel/fileserver
/Users/avr/code/scratch/cpp-netlib-0.9.4/example/MinSizeRel/fileserver:\
	/opt/local/lib/libboost_thread-mt.a\
	/opt/local/lib/libboost_system-mt.a\
	/opt/local/lib/libboost_date_time-mt.a\
	/opt/local/lib/libboost_program_options-mt.a\
	/opt/local/lib/libboost_filesystem-mt.a\
	/Users/avr/code/scratch/cpp-netlib-0.9.4/libs/network/src/MinSizeRel/libcppnetlib-server-parsers.a
	/bin/rm -f /Users/avr/code/scratch/cpp-netlib-0.9.4/example/MinSizeRel/fileserver


PostBuild.hello_world_client.MinSizeRel:
PostBuild.cppnetlib-uri.MinSizeRel: /Users/avr/code/scratch/cpp-netlib-0.9.4/example/MinSizeRel/hello_world_client
PostBuild.cppnetlib-client-connections.MinSizeRel: /Users/avr/code/scratch/cpp-netlib-0.9.4/example/MinSizeRel/hello_world_client
/Users/avr/code/scratch/cpp-netlib-0.9.4/example/MinSizeRel/hello_world_client:\
	/opt/local/lib/libboost_program_options-mt.a\
	/opt/local/lib/libboost_thread-mt.a\
	/opt/local/lib/libboost_date_time-mt.a\
	/opt/local/lib/libboost_regex-mt.a\
	/opt/local/lib/libboost_system-mt.a\
	/Users/avr/code/scratch/cpp-netlib-0.9.4/libs/network/src/MinSizeRel/libcppnetlib-uri.a\
	/Users/avr/code/scratch/cpp-netlib-0.9.4/libs/network/src/MinSizeRel/libcppnetlib-client-connections.a\
	/opt/local/lib/libssl.dylib\
	/opt/local/lib/libcrypto.dylib
	/bin/rm -f /Users/avr/code/scratch/cpp-netlib-0.9.4/example/MinSizeRel/hello_world_client


PostBuild.hello_world_server.MinSizeRel:
/Users/avr/code/scratch/cpp-netlib-0.9.4/example/MinSizeRel/hello_world_server:\
	/opt/local/lib/libboost_thread-mt.a\
	/opt/local/lib/libboost_system-mt.a\
	/opt/local/lib/libboost_date_time-mt.a\
	/opt/local/lib/libboost_program_options-mt.a\
	/opt/local/lib/libssl.dylib\
	/opt/local/lib/libcrypto.dylib
	/bin/rm -f /Users/avr/code/scratch/cpp-netlib-0.9.4/example/MinSizeRel/hello_world_server


PostBuild.http_client.MinSizeRel:
PostBuild.cppnetlib-uri.MinSizeRel: /Users/avr/code/scratch/cpp-netlib-0.9.4/example/MinSizeRel/http_client
PostBuild.cppnetlib-client-connections.MinSizeRel: /Users/avr/code/scratch/cpp-netlib-0.9.4/example/MinSizeRel/http_client
/Users/avr/code/scratch/cpp-netlib-0.9.4/example/MinSizeRel/http_client:\
	/opt/local/lib/libboost_program_options-mt.a\
	/opt/local/lib/libboost_thread-mt.a\
	/opt/local/lib/libboost_date_time-mt.a\
	/opt/local/lib/libboost_regex-mt.a\
	/opt/local/lib/libboost_system-mt.a\
	/Users/avr/code/scratch/cpp-netlib-0.9.4/libs/network/src/MinSizeRel/libcppnetlib-uri.a\
	/Users/avr/code/scratch/cpp-netlib-0.9.4/libs/network/src/MinSizeRel/libcppnetlib-client-connections.a\
	/opt/local/lib/libssl.dylib\
	/opt/local/lib/libcrypto.dylib
	/bin/rm -f /Users/avr/code/scratch/cpp-netlib-0.9.4/example/MinSizeRel/http_client


PostBuild.rss_reader.MinSizeRel:
PostBuild.cppnetlib-uri.MinSizeRel: /Users/avr/code/scratch/cpp-netlib-0.9.4/example/MinSizeRel/rss_reader
PostBuild.cppnetlib-client-connections.MinSizeRel: /Users/avr/code/scratch/cpp-netlib-0.9.4/example/MinSizeRel/rss_reader
/Users/avr/code/scratch/cpp-netlib-0.9.4/example/MinSizeRel/rss_reader:\
	/opt/local/lib/libboost_program_options-mt.a\
	/opt/local/lib/libboost_thread-mt.a\
	/opt/local/lib/libboost_date_time-mt.a\
	/opt/local/lib/libboost_regex-mt.a\
	/opt/local/lib/libboost_system-mt.a\
	/Users/avr/code/scratch/cpp-netlib-0.9.4/libs/network/src/MinSizeRel/libcppnetlib-uri.a\
	/Users/avr/code/scratch/cpp-netlib-0.9.4/libs/network/src/MinSizeRel/libcppnetlib-client-connections.a\
	/opt/local/lib/libssl.dylib\
	/opt/local/lib/libcrypto.dylib
	/bin/rm -f /Users/avr/code/scratch/cpp-netlib-0.9.4/example/MinSizeRel/rss_reader


PostBuild.simple_wget.MinSizeRel:
PostBuild.cppnetlib-uri.MinSizeRel: /Users/avr/code/scratch/cpp-netlib-0.9.4/example/MinSizeRel/simple_wget
PostBuild.cppnetlib-client-connections.MinSizeRel: /Users/avr/code/scratch/cpp-netlib-0.9.4/example/MinSizeRel/simple_wget
/Users/avr/code/scratch/cpp-netlib-0.9.4/example/MinSizeRel/simple_wget:\
	/opt/local/lib/libboost_program_options-mt.a\
	/opt/local/lib/libboost_thread-mt.a\
	/opt/local/lib/libboost_date_time-mt.a\
	/opt/local/lib/libboost_regex-mt.a\
	/opt/local/lib/libboost_system-mt.a\
	/Users/avr/code/scratch/cpp-netlib-0.9.4/libs/network/src/MinSizeRel/libcppnetlib-uri.a\
	/Users/avr/code/scratch/cpp-netlib-0.9.4/libs/network/src/MinSizeRel/libcppnetlib-client-connections.a\
	/opt/local/lib/libssl.dylib\
	/opt/local/lib/libcrypto.dylib
	/bin/rm -f /Users/avr/code/scratch/cpp-netlib-0.9.4/example/MinSizeRel/simple_wget


PostBuild.twitter_search.MinSizeRel:
PostBuild.cppnetlib-uri.MinSizeRel: /Users/avr/code/scratch/cpp-netlib-0.9.4/example/MinSizeRel/twitter_search
PostBuild.cppnetlib-client-connections.MinSizeRel: /Users/avr/code/scratch/cpp-netlib-0.9.4/example/MinSizeRel/twitter_search
/Users/avr/code/scratch/cpp-netlib-0.9.4/example/MinSizeRel/twitter_search:\
	/opt/local/lib/libboost_program_options-mt.a\
	/opt/local/lib/libboost_thread-mt.a\
	/opt/local/lib/libboost_date_time-mt.a\
	/opt/local/lib/libboost_regex-mt.a\
	/opt/local/lib/libboost_system-mt.a\
	/Users/avr/code/scratch/cpp-netlib-0.9.4/libs/network/src/MinSizeRel/libcppnetlib-uri.a\
	/Users/avr/code/scratch/cpp-netlib-0.9.4/libs/network/src/MinSizeRel/libcppnetlib-client-connections.a\
	/opt/local/lib/libssl.dylib\
	/opt/local/lib/libcrypto.dylib
	/bin/rm -f /Users/avr/code/scratch/cpp-netlib-0.9.4/example/MinSizeRel/twitter_search


PostBuild.cppnetlib-client-connections.RelWithDebInfo:
PostBuild.cppnetlib-server-parsers.RelWithDebInfo:
PostBuild.cppnetlib-uri.RelWithDebInfo:
PostBuild.cpp-netlib-message_test.RelWithDebInfo:
PostBuild.cppnetlib-uri.RelWithDebInfo: /Users/avr/code/scratch/cpp-netlib-0.9.4/tests/RelWithDebInfo/cpp-netlib-message_test
/Users/avr/code/scratch/cpp-netlib-0.9.4/tests/RelWithDebInfo/cpp-netlib-message_test:\
	/opt/local/lib/libboost_unit_test_framework-mt.a\
	/opt/local/lib/libboost_system-mt.a\
	/opt/local/lib/libboost_regex-mt.a\
	/opt/local/lib/libboost_date_time-mt.a\
	/opt/local/lib/libboost_thread-mt.a\
	/opt/local/lib/libboost_filesystem-mt.a\
	/opt/local/lib/libboost_program_options-mt.a\
	/Users/avr/code/scratch/cpp-netlib-0.9.4/libs/network/src/RelWithDebInfo/libcppnetlib-uri.a\
	/opt/local/lib/libssl.dylib\
	/opt/local/lib/libcrypto.dylib
	/bin/rm -f /Users/avr/code/scratch/cpp-netlib-0.9.4/tests/RelWithDebInfo/cpp-netlib-message_test


PostBuild.cpp-netlib-message_transform_test.RelWithDebInfo:
PostBuild.cppnetlib-uri.RelWithDebInfo: /Users/avr/code/scratch/cpp-netlib-0.9.4/tests/RelWithDebInfo/cpp-netlib-message_transform_test
/Users/avr/code/scratch/cpp-netlib-0.9.4/tests/RelWithDebInfo/cpp-netlib-message_transform_test:\
	/opt/local/lib/libboost_unit_test_framework-mt.a\
	/opt/local/lib/libboost_system-mt.a\
	/opt/local/lib/libboost_regex-mt.a\
	/opt/local/lib/libboost_date_time-mt.a\
	/opt/local/lib/libboost_thread-mt.a\
	/opt/local/lib/libboost_filesystem-mt.a\
	/opt/local/lib/libboost_program_options-mt.a\
	/Users/avr/code/scratch/cpp-netlib-0.9.4/libs/network/src/RelWithDebInfo/libcppnetlib-uri.a\
	/opt/local/lib/libssl.dylib\
	/opt/local/lib/libcrypto.dylib
	/bin/rm -f /Users/avr/code/scratch/cpp-netlib-0.9.4/tests/RelWithDebInfo/cpp-netlib-message_transform_test


PostBuild.cpp-netlib-utils_thread_pool.RelWithDebInfo:
PostBuild.cppnetlib-uri.RelWithDebInfo: /Users/avr/code/scratch/cpp-netlib-0.9.4/tests/RelWithDebInfo/cpp-netlib-utils_thread_pool
/Users/avr/code/scratch/cpp-netlib-0.9.4/tests/RelWithDebInfo/cpp-netlib-utils_thread_pool:\
	/opt/local/lib/libboost_unit_test_framework-mt.a\
	/opt/local/lib/libboost_system-mt.a\
	/opt/local/lib/libboost_regex-mt.a\
	/opt/local/lib/libboost_date_time-mt.a\
	/opt/local/lib/libboost_thread-mt.a\
	/opt/local/lib/libboost_filesystem-mt.a\
	/opt/local/lib/libboost_program_options-mt.a\
	/Users/avr/code/scratch/cpp-netlib-0.9.4/libs/network/src/RelWithDebInfo/libcppnetlib-uri.a\
	/opt/local/lib/libssl.dylib\
	/opt/local/lib/libcrypto.dylib
	/bin/rm -f /Users/avr/code/scratch/cpp-netlib-0.9.4/tests/RelWithDebInfo/cpp-netlib-utils_thread_pool


PostBuild.cpp-netlib-relative_uri_test.RelWithDebInfo:
PostBuild.cppnetlib-uri.RelWithDebInfo: /Users/avr/code/scratch/cpp-netlib-0.9.4/tests/RelWithDebInfo/cpp-netlib-relative_uri_test
/Users/avr/code/scratch/cpp-netlib-0.9.4/tests/RelWithDebInfo/cpp-netlib-relative_uri_test:\
	/opt/local/lib/libboost_unit_test_framework-mt.a\
	/opt/local/lib/libboost_system-mt.a\
	/opt/local/lib/libboost_regex-mt.a\
	/opt/local/lib/libboost_date_time-mt.a\
	/opt/local/lib/libboost_thread-mt.a\
	/opt/local/lib/libboost_filesystem-mt.a\
	/opt/local/lib/libboost_program_options-mt.a\
	/Users/avr/code/scratch/cpp-netlib-0.9.4/libs/network/src/RelWithDebInfo/libcppnetlib-uri.a\
	/opt/local/lib/libssl.dylib\
	/opt/local/lib/libcrypto.dylib
	/bin/rm -f /Users/avr/code/scratch/cpp-netlib-0.9.4/tests/RelWithDebInfo/cpp-netlib-relative_uri_test


PostBuild.cpp-netlib-uri_builder_stream_test.RelWithDebInfo:
PostBuild.cppnetlib-uri.RelWithDebInfo: /Users/avr/code/scratch/cpp-netlib-0.9.4/tests/RelWithDebInfo/cpp-netlib-uri_builder_stream_test
/Users/avr/code/scratch/cpp-netlib-0.9.4/tests/RelWithDebInfo/cpp-netlib-uri_builder_stream_test:\
	/opt/local/lib/libboost_unit_test_framework-mt.a\
	/opt/local/lib/libboost_system-mt.a\
	/opt/local/lib/libboost_regex-mt.a\
	/opt/local/lib/libboost_date_time-mt.a\
	/opt/local/lib/libboost_thread-mt.a\
	/opt/local/lib/libboost_filesystem-mt.a\
	/opt/local/lib/libboost_program_options-mt.a\
	/Users/avr/code/scratch/cpp-netlib-0.9.4/libs/network/src/RelWithDebInfo/libcppnetlib-uri.a\
	/opt/local/lib/libssl.dylib\
	/opt/local/lib/libcrypto.dylib
	/bin/rm -f /Users/avr/code/scratch/cpp-netlib-0.9.4/tests/RelWithDebInfo/cpp-netlib-uri_builder_stream_test


PostBuild.cpp-netlib-uri_builder_test.RelWithDebInfo:
PostBuild.cppnetlib-uri.RelWithDebInfo: /Users/avr/code/scratch/cpp-netlib-0.9.4/tests/RelWithDebInfo/cpp-netlib-uri_builder_test
/Users/avr/code/scratch/cpp-netlib-0.9.4/tests/RelWithDebInfo/cpp-netlib-uri_builder_test:\
	/opt/local/lib/libboost_unit_test_framework-mt.a\
	/opt/local/lib/libboost_system-mt.a\
	/opt/local/lib/libboost_regex-mt.a\
	/opt/local/lib/libboost_date_time-mt.a\
	/opt/local/lib/libboost_thread-mt.a\
	/opt/local/lib/libboost_filesystem-mt.a\
	/opt/local/lib/libboost_program_options-mt.a\
	/Users/avr/code/scratch/cpp-netlib-0.9.4/libs/network/src/RelWithDebInfo/libcppnetlib-uri.a\
	/opt/local/lib/libssl.dylib\
	/opt/local/lib/libcrypto.dylib
	/bin/rm -f /Users/avr/code/scratch/cpp-netlib-0.9.4/tests/RelWithDebInfo/cpp-netlib-uri_builder_test


PostBuild.cpp-netlib-uri_encoding_test.RelWithDebInfo:
PostBuild.cppnetlib-uri.RelWithDebInfo: /Users/avr/code/scratch/cpp-netlib-0.9.4/tests/RelWithDebInfo/cpp-netlib-uri_encoding_test
/Users/avr/code/scratch/cpp-netlib-0.9.4/tests/RelWithDebInfo/cpp-netlib-uri_encoding_test:\
	/opt/local/lib/libboost_unit_test_framework-mt.a\
	/opt/local/lib/libboost_system-mt.a\
	/opt/local/lib/libboost_regex-mt.a\
	/opt/local/lib/libboost_date_time-mt.a\
	/opt/local/lib/libboost_thread-mt.a\
	/opt/local/lib/libboost_filesystem-mt.a\
	/opt/local/lib/libboost_program_options-mt.a\
	/Users/avr/code/scratch/cpp-netlib-0.9.4/libs/network/src/RelWithDebInfo/libcppnetlib-uri.a\
	/opt/local/lib/libssl.dylib\
	/opt/local/lib/libcrypto.dylib
	/bin/rm -f /Users/avr/code/scratch/cpp-netlib-0.9.4/tests/RelWithDebInfo/cpp-netlib-uri_encoding_test


PostBuild.cpp-netlib-uri_test.RelWithDebInfo:
PostBuild.cppnetlib-uri.RelWithDebInfo: /Users/avr/code/scratch/cpp-netlib-0.9.4/tests/RelWithDebInfo/cpp-netlib-uri_test
/Users/avr/code/scratch/cpp-netlib-0.9.4/tests/RelWithDebInfo/cpp-netlib-uri_test:\
	/opt/local/lib/libboost_unit_test_framework-mt.a\
	/opt/local/lib/libboost_system-mt.a\
	/opt/local/lib/libboost_regex-mt.a\
	/opt/local/lib/libboost_date_time-mt.a\
	/opt/local/lib/libboost_thread-mt.a\
	/opt/local/lib/libboost_filesystem-mt.a\
	/opt/local/lib/libboost_program_options-mt.a\
	/Users/avr/code/scratch/cpp-netlib-0.9.4/libs/network/src/RelWithDebInfo/libcppnetlib-uri.a\
	/opt/local/lib/libssl.dylib\
	/opt/local/lib/libcrypto.dylib
	/bin/rm -f /Users/avr/code/scratch/cpp-netlib-0.9.4/tests/RelWithDebInfo/cpp-netlib-uri_test


PostBuild.cpp-netlib-http-client_constructor_test.RelWithDebInfo:
PostBuild.cppnetlib-uri.RelWithDebInfo: /Users/avr/code/scratch/cpp-netlib-0.9.4/tests/RelWithDebInfo/cpp-netlib-http-client_constructor_test
PostBuild.cppnetlib-client-connections.RelWithDebInfo: /Users/avr/code/scratch/cpp-netlib-0.9.4/tests/RelWithDebInfo/cpp-netlib-http-client_constructor_test
/Users/avr/code/scratch/cpp-netlib-0.9.4/tests/RelWithDebInfo/cpp-netlib-http-client_constructor_test:\
	/opt/local/lib/libboost_unit_test_framework-mt.a\
	/opt/local/lib/libboost_system-mt.a\
	/opt/local/lib/libboost_regex-mt.a\
	/opt/local/lib/libboost_date_time-mt.a\
	/opt/local/lib/libboost_thread-mt.a\
	/opt/local/lib/libboost_filesystem-mt.a\
	/opt/local/lib/libboost_program_options-mt.a\
	/Users/avr/code/scratch/cpp-netlib-0.9.4/libs/network/src/RelWithDebInfo/libcppnetlib-uri.a\
	/Users/avr/code/scratch/cpp-netlib-0.9.4/libs/network/src/RelWithDebInfo/libcppnetlib-client-connections.a\
	/opt/local/lib/libssl.dylib\
	/opt/local/lib/libcrypto.dylib
	/bin/rm -f /Users/avr/code/scratch/cpp-netlib-0.9.4/tests/RelWithDebInfo/cpp-netlib-http-client_constructor_test


PostBuild.cpp-netlib-http-client_get_different_port_test.RelWithDebInfo:
PostBuild.cppnetlib-uri.RelWithDebInfo: /Users/avr/code/scratch/cpp-netlib-0.9.4/tests/RelWithDebInfo/cpp-netlib-http-client_get_different_port_test
PostBuild.cppnetlib-client-connections.RelWithDebInfo: /Users/avr/code/scratch/cpp-netlib-0.9.4/tests/RelWithDebInfo/cpp-netlib-http-client_get_different_port_test
/Users/avr/code/scratch/cpp-netlib-0.9.4/tests/RelWithDebInfo/cpp-netlib-http-client_get_different_port_test:\
	/opt/local/lib/libboost_unit_test_framework-mt.a\
	/opt/local/lib/libboost_system-mt.a\
	/opt/local/lib/libboost_regex-mt.a\
	/opt/local/lib/libboost_date_time-mt.a\
	/opt/local/lib/libboost_thread-mt.a\
	/opt/local/lib/libboost_filesystem-mt.a\
	/opt/local/lib/libboost_program_options-mt.a\
	/Users/avr/code/scratch/cpp-netlib-0.9.4/libs/network/src/RelWithDebInfo/libcppnetlib-uri.a\
	/Users/avr/code/scratch/cpp-netlib-0.9.4/libs/network/src/RelWithDebInfo/libcppnetlib-client-connections.a\
	/opt/local/lib/libssl.dylib\
	/opt/local/lib/libcrypto.dylib
	/bin/rm -f /Users/avr/code/scratch/cpp-netlib-0.9.4/tests/RelWithDebInfo/cpp-netlib-http-client_get_different_port_test


PostBuild.cpp-netlib-http-client_get_streaming_test.RelWithDebInfo:
PostBuild.cppnetlib-uri.RelWithDebInfo: /Users/avr/code/scratch/cpp-netlib-0.9.4/tests/RelWithDebInfo/cpp-netlib-http-client_get_streaming_test
PostBuild.cppnetlib-client-connections.RelWithDebInfo: /Users/avr/code/scratch/cpp-netlib-0.9.4/tests/RelWithDebInfo/cpp-netlib-http-client_get_streaming_test
/Users/avr/code/scratch/cpp-netlib-0.9.4/tests/RelWithDebInfo/cpp-netlib-http-client_get_streaming_test:\
	/opt/local/lib/libboost_unit_test_framework-mt.a\
	/opt/local/lib/libboost_system-mt.a\
	/opt/local/lib/libboost_regex-mt.a\
	/opt/local/lib/libboost_date_time-mt.a\
	/opt/local/lib/libboost_thread-mt.a\
	/opt/local/lib/libboost_filesystem-mt.a\
	/opt/local/lib/libboost_program_options-mt.a\
	/Users/avr/code/scratch/cpp-netlib-0.9.4/libs/network/src/RelWithDebInfo/libcppnetlib-uri.a\
	/Users/avr/code/scratch/cpp-netlib-0.9.4/libs/network/src/RelWithDebInfo/libcppnetlib-client-connections.a\
	/opt/local/lib/libssl.dylib\
	/opt/local/lib/libcrypto.dylib
	/bin/rm -f /Users/avr/code/scratch/cpp-netlib-0.9.4/tests/RelWithDebInfo/cpp-netlib-http-client_get_streaming_test


PostBuild.cpp-netlib-http-client_get_test.RelWithDebInfo:
PostBuild.cppnetlib-uri.RelWithDebInfo: /Users/avr/code/scratch/cpp-netlib-0.9.4/tests/RelWithDebInfo/cpp-netlib-http-client_get_test
PostBuild.cppnetlib-client-connections.RelWithDebInfo: /Users/avr/code/scratch/cpp-netlib-0.9.4/tests/RelWithDebInfo/cpp-netlib-http-client_get_test
/Users/avr/code/scratch/cpp-netlib-0.9.4/tests/RelWithDebInfo/cpp-netlib-http-client_get_test:\
	/opt/local/lib/libboost_unit_test_framework-mt.a\
	/opt/local/lib/libboost_system-mt.a\
	/opt/local/lib/libboost_regex-mt.a\
	/opt/local/lib/libboost_date_time-mt.a\
	/opt/local/lib/libboost_thread-mt.a\
	/opt/local/lib/libboost_filesystem-mt.a\
	/opt/local/lib/libboost_program_options-mt.a\
	/Users/avr/code/scratch/cpp-netlib-0.9.4/libs/network/src/RelWithDebInfo/libcppnetlib-uri.a\
	/Users/avr/code/scratch/cpp-netlib-0.9.4/libs/network/src/RelWithDebInfo/libcppnetlib-client-connections.a\
	/opt/local/lib/libssl.dylib\
	/opt/local/lib/libcrypto.dylib
	/bin/rm -f /Users/avr/code/scratch/cpp-netlib-0.9.4/tests/RelWithDebInfo/cpp-netlib-http-client_get_test


PostBuild.cpp-netlib-http-client_get_timeout_test.RelWithDebInfo:
PostBuild.cppnetlib-uri.RelWithDebInfo: /Users/avr/code/scratch/cpp-netlib-0.9.4/tests/RelWithDebInfo/cpp-netlib-http-client_get_timeout_test
PostBuild.cppnetlib-client-connections.RelWithDebInfo: /Users/avr/code/scratch/cpp-netlib-0.9.4/tests/RelWithDebInfo/cpp-netlib-http-client_get_timeout_test
/Users/avr/code/scratch/cpp-netlib-0.9.4/tests/RelWithDebInfo/cpp-netlib-http-client_get_timeout_test:\
	/opt/local/lib/libboost_unit_test_framework-mt.a\
	/opt/local/lib/libboost_system-mt.a\
	/opt/local/lib/libboost_regex-mt.a\
	/opt/local/lib/libboost_date_time-mt.a\
	/opt/local/lib/libboost_thread-mt.a\
	/opt/local/lib/libboost_filesystem-mt.a\
	/opt/local/lib/libboost_program_options-mt.a\
	/Users/avr/code/scratch/cpp-netlib-0.9.4/libs/network/src/RelWithDebInfo/libcppnetlib-uri.a\
	/Users/avr/code/scratch/cpp-netlib-0.9.4/libs/network/src/RelWithDebInfo/libcppnetlib-client-connections.a\
	/opt/local/lib/libssl.dylib\
	/opt/local/lib/libcrypto.dylib
	/bin/rm -f /Users/avr/code/scratch/cpp-netlib-0.9.4/tests/RelWithDebInfo/cpp-netlib-http-client_get_timeout_test


PostBuild.cpp-netlib-http-server_async_run_stop_concurrency.RelWithDebInfo:
PostBuild.cppnetlib-server-parsers.RelWithDebInfo: /Users/avr/code/scratch/cpp-netlib-0.9.4/tests/RelWithDebInfo/cpp-netlib-http-server_async_run_stop_concurrency
/Users/avr/code/scratch/cpp-netlib-0.9.4/tests/RelWithDebInfo/cpp-netlib-http-server_async_run_stop_concurrency:\
	/opt/local/lib/libboost_unit_test_framework-mt.a\
	/opt/local/lib/libboost_system-mt.a\
	/opt/local/lib/libboost_regex-mt.a\
	/opt/local/lib/libboost_date_time-mt.a\
	/opt/local/lib/libboost_thread-mt.a\
	/opt/local/lib/libboost_filesystem-mt.a\
	/opt/local/lib/libboost_program_options-mt.a\
	/Users/avr/code/scratch/cpp-netlib-0.9.4/libs/network/src/RelWithDebInfo/libcppnetlib-server-parsers.a
	/bin/rm -f /Users/avr/code/scratch/cpp-netlib-0.9.4/tests/RelWithDebInfo/cpp-netlib-http-server_async_run_stop_concurrency


PostBuild.cpp-netlib-http-server_constructor_test.RelWithDebInfo:
PostBuild.cppnetlib-server-parsers.RelWithDebInfo: /Users/avr/code/scratch/cpp-netlib-0.9.4/tests/RelWithDebInfo/cpp-netlib-http-server_constructor_test
/Users/avr/code/scratch/cpp-netlib-0.9.4/tests/RelWithDebInfo/cpp-netlib-http-server_constructor_test:\
	/opt/local/lib/libboost_unit_test_framework-mt.a\
	/opt/local/lib/libboost_system-mt.a\
	/opt/local/lib/libboost_regex-mt.a\
	/opt/local/lib/libboost_date_time-mt.a\
	/opt/local/lib/libboost_thread-mt.a\
	/opt/local/lib/libboost_filesystem-mt.a\
	/opt/local/lib/libboost_program_options-mt.a\
	/Users/avr/code/scratch/cpp-netlib-0.9.4/libs/network/src/RelWithDebInfo/libcppnetlib-server-parsers.a
	/bin/rm -f /Users/avr/code/scratch/cpp-netlib-0.9.4/tests/RelWithDebInfo/cpp-netlib-http-server_constructor_test


PostBuild.mime-roundtrip.RelWithDebInfo:
/Users/avr/code/scratch/cpp-netlib-0.9.4/libs/mime/test/RelWithDebInfo/mime-roundtrip:\
	/opt/local/lib/libboost_unit_test_framework-mt.a\
	/opt/local/lib/libboost_system-mt.a\
	/opt/local/lib/libboost_regex-mt.a\
	/opt/local/lib/libboost_date_time-mt.a\
	/opt/local/lib/libboost_thread-mt.a\
	/opt/local/lib/libboost_filesystem-mt.a\
	/opt/local/lib/libboost_program_options-mt.a\
	/opt/local/lib/libboost_unit_test_framework-mt.a\
	/opt/local/lib/libboost_system-mt.a\
	/opt/local/lib/libboost_regex-mt.a\
	/opt/local/lib/libboost_date_time-mt.a\
	/opt/local/lib/libboost_thread-mt.a\
	/opt/local/lib/libboost_filesystem-mt.a\
	/opt/local/lib/libboost_program_options-mt.a
	/bin/rm -f /Users/avr/code/scratch/cpp-netlib-0.9.4/libs/mime/test/RelWithDebInfo/mime-roundtrip


PostBuild.atom_reader.RelWithDebInfo:
PostBuild.cppnetlib-uri.RelWithDebInfo: /Users/avr/code/scratch/cpp-netlib-0.9.4/example/RelWithDebInfo/atom_reader
PostBuild.cppnetlib-client-connections.RelWithDebInfo: /Users/avr/code/scratch/cpp-netlib-0.9.4/example/RelWithDebInfo/atom_reader
/Users/avr/code/scratch/cpp-netlib-0.9.4/example/RelWithDebInfo/atom_reader:\
	/opt/local/lib/libboost_program_options-mt.a\
	/opt/local/lib/libboost_thread-mt.a\
	/opt/local/lib/libboost_date_time-mt.a\
	/opt/local/lib/libboost_regex-mt.a\
	/opt/local/lib/libboost_system-mt.a\
	/Users/avr/code/scratch/cpp-netlib-0.9.4/libs/network/src/RelWithDebInfo/libcppnetlib-uri.a\
	/Users/avr/code/scratch/cpp-netlib-0.9.4/libs/network/src/RelWithDebInfo/libcppnetlib-client-connections.a\
	/opt/local/lib/libssl.dylib\
	/opt/local/lib/libcrypto.dylib
	/bin/rm -f /Users/avr/code/scratch/cpp-netlib-0.9.4/example/RelWithDebInfo/atom_reader


PostBuild.fileserver.RelWithDebInfo:
PostBuild.cppnetlib-server-parsers.RelWithDebInfo: /Users/avr/code/scratch/cpp-netlib-0.9.4/example/RelWithDebInfo/fileserver
/Users/avr/code/scratch/cpp-netlib-0.9.4/example/RelWithDebInfo/fileserver:\
	/opt/local/lib/libboost_thread-mt.a\
	/opt/local/lib/libboost_system-mt.a\
	/opt/local/lib/libboost_date_time-mt.a\
	/opt/local/lib/libboost_program_options-mt.a\
	/opt/local/lib/libboost_filesystem-mt.a\
	/Users/avr/code/scratch/cpp-netlib-0.9.4/libs/network/src/RelWithDebInfo/libcppnetlib-server-parsers.a
	/bin/rm -f /Users/avr/code/scratch/cpp-netlib-0.9.4/example/RelWithDebInfo/fileserver


PostBuild.hello_world_client.RelWithDebInfo:
PostBuild.cppnetlib-uri.RelWithDebInfo: /Users/avr/code/scratch/cpp-netlib-0.9.4/example/RelWithDebInfo/hello_world_client
PostBuild.cppnetlib-client-connections.RelWithDebInfo: /Users/avr/code/scratch/cpp-netlib-0.9.4/example/RelWithDebInfo/hello_world_client
/Users/avr/code/scratch/cpp-netlib-0.9.4/example/RelWithDebInfo/hello_world_client:\
	/opt/local/lib/libboost_program_options-mt.a\
	/opt/local/lib/libboost_thread-mt.a\
	/opt/local/lib/libboost_date_time-mt.a\
	/opt/local/lib/libboost_regex-mt.a\
	/opt/local/lib/libboost_system-mt.a\
	/Users/avr/code/scratch/cpp-netlib-0.9.4/libs/network/src/RelWithDebInfo/libcppnetlib-uri.a\
	/Users/avr/code/scratch/cpp-netlib-0.9.4/libs/network/src/RelWithDebInfo/libcppnetlib-client-connections.a\
	/opt/local/lib/libssl.dylib\
	/opt/local/lib/libcrypto.dylib
	/bin/rm -f /Users/avr/code/scratch/cpp-netlib-0.9.4/example/RelWithDebInfo/hello_world_client


PostBuild.hello_world_server.RelWithDebInfo:
/Users/avr/code/scratch/cpp-netlib-0.9.4/example/RelWithDebInfo/hello_world_server:\
	/opt/local/lib/libboost_thread-mt.a\
	/opt/local/lib/libboost_system-mt.a\
	/opt/local/lib/libboost_date_time-mt.a\
	/opt/local/lib/libboost_program_options-mt.a\
	/opt/local/lib/libssl.dylib\
	/opt/local/lib/libcrypto.dylib
	/bin/rm -f /Users/avr/code/scratch/cpp-netlib-0.9.4/example/RelWithDebInfo/hello_world_server


PostBuild.http_client.RelWithDebInfo:
PostBuild.cppnetlib-uri.RelWithDebInfo: /Users/avr/code/scratch/cpp-netlib-0.9.4/example/RelWithDebInfo/http_client
PostBuild.cppnetlib-client-connections.RelWithDebInfo: /Users/avr/code/scratch/cpp-netlib-0.9.4/example/RelWithDebInfo/http_client
/Users/avr/code/scratch/cpp-netlib-0.9.4/example/RelWithDebInfo/http_client:\
	/opt/local/lib/libboost_program_options-mt.a\
	/opt/local/lib/libboost_thread-mt.a\
	/opt/local/lib/libboost_date_time-mt.a\
	/opt/local/lib/libboost_regex-mt.a\
	/opt/local/lib/libboost_system-mt.a\
	/Users/avr/code/scratch/cpp-netlib-0.9.4/libs/network/src/RelWithDebInfo/libcppnetlib-uri.a\
	/Users/avr/code/scratch/cpp-netlib-0.9.4/libs/network/src/RelWithDebInfo/libcppnetlib-client-connections.a\
	/opt/local/lib/libssl.dylib\
	/opt/local/lib/libcrypto.dylib
	/bin/rm -f /Users/avr/code/scratch/cpp-netlib-0.9.4/example/RelWithDebInfo/http_client


PostBuild.rss_reader.RelWithDebInfo:
PostBuild.cppnetlib-uri.RelWithDebInfo: /Users/avr/code/scratch/cpp-netlib-0.9.4/example/RelWithDebInfo/rss_reader
PostBuild.cppnetlib-client-connections.RelWithDebInfo: /Users/avr/code/scratch/cpp-netlib-0.9.4/example/RelWithDebInfo/rss_reader
/Users/avr/code/scratch/cpp-netlib-0.9.4/example/RelWithDebInfo/rss_reader:\
	/opt/local/lib/libboost_program_options-mt.a\
	/opt/local/lib/libboost_thread-mt.a\
	/opt/local/lib/libboost_date_time-mt.a\
	/opt/local/lib/libboost_regex-mt.a\
	/opt/local/lib/libboost_system-mt.a\
	/Users/avr/code/scratch/cpp-netlib-0.9.4/libs/network/src/RelWithDebInfo/libcppnetlib-uri.a\
	/Users/avr/code/scratch/cpp-netlib-0.9.4/libs/network/src/RelWithDebInfo/libcppnetlib-client-connections.a\
	/opt/local/lib/libssl.dylib\
	/opt/local/lib/libcrypto.dylib
	/bin/rm -f /Users/avr/code/scratch/cpp-netlib-0.9.4/example/RelWithDebInfo/rss_reader


PostBuild.simple_wget.RelWithDebInfo:
PostBuild.cppnetlib-uri.RelWithDebInfo: /Users/avr/code/scratch/cpp-netlib-0.9.4/example/RelWithDebInfo/simple_wget
PostBuild.cppnetlib-client-connections.RelWithDebInfo: /Users/avr/code/scratch/cpp-netlib-0.9.4/example/RelWithDebInfo/simple_wget
/Users/avr/code/scratch/cpp-netlib-0.9.4/example/RelWithDebInfo/simple_wget:\
	/opt/local/lib/libboost_program_options-mt.a\
	/opt/local/lib/libboost_thread-mt.a\
	/opt/local/lib/libboost_date_time-mt.a\
	/opt/local/lib/libboost_regex-mt.a\
	/opt/local/lib/libboost_system-mt.a\
	/Users/avr/code/scratch/cpp-netlib-0.9.4/libs/network/src/RelWithDebInfo/libcppnetlib-uri.a\
	/Users/avr/code/scratch/cpp-netlib-0.9.4/libs/network/src/RelWithDebInfo/libcppnetlib-client-connections.a\
	/opt/local/lib/libssl.dylib\
	/opt/local/lib/libcrypto.dylib
	/bin/rm -f /Users/avr/code/scratch/cpp-netlib-0.9.4/example/RelWithDebInfo/simple_wget


PostBuild.twitter_search.RelWithDebInfo:
PostBuild.cppnetlib-uri.RelWithDebInfo: /Users/avr/code/scratch/cpp-netlib-0.9.4/example/RelWithDebInfo/twitter_search
PostBuild.cppnetlib-client-connections.RelWithDebInfo: /Users/avr/code/scratch/cpp-netlib-0.9.4/example/RelWithDebInfo/twitter_search
/Users/avr/code/scratch/cpp-netlib-0.9.4/example/RelWithDebInfo/twitter_search:\
	/opt/local/lib/libboost_program_options-mt.a\
	/opt/local/lib/libboost_thread-mt.a\
	/opt/local/lib/libboost_date_time-mt.a\
	/opt/local/lib/libboost_regex-mt.a\
	/opt/local/lib/libboost_system-mt.a\
	/Users/avr/code/scratch/cpp-netlib-0.9.4/libs/network/src/RelWithDebInfo/libcppnetlib-uri.a\
	/Users/avr/code/scratch/cpp-netlib-0.9.4/libs/network/src/RelWithDebInfo/libcppnetlib-client-connections.a\
	/opt/local/lib/libssl.dylib\
	/opt/local/lib/libcrypto.dylib
	/bin/rm -f /Users/avr/code/scratch/cpp-netlib-0.9.4/example/RelWithDebInfo/twitter_search


