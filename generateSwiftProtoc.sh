protoc \
--plugin=./ios-app/Pods/gRPC-Swift-Plugins/bin/protoc-gen-swift \
--swift_out=./ios-app/src/generated/proto \
--proto_path=./mpp-library/domain/src/proto \
./mpp-library/domain/src/proto/helloworld.proto
protoc \
--plugin=./ios-app/Pods/gRPC-Swift-Plugins/bin/protoc-gen-grpc-swift \
--grpc-swift_out=./ios-app/src/generated/proto \
--grpc-swift_opt=Client=true,Server=false \
--proto_path=./mpp-library/domain/src/proto \
./mpp-library/domain/src/proto/helloworld.proto