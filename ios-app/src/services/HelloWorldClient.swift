//
//  HelloWorldClient.swift
//  ios-app
//
//  Created by Andrey Tchernov on 17.02.2022.
//  Copyright © 2022 IceRock Development. All rights reserved.
//

import Foundation
import GRPC
import NIOHPACK
import Logging
import MultiPlatformLibrary
import NIO
import SwiftProtobuf

class HelloWorldCallbackBridge: HelloWorldCallbackClient {
    private var commonChannel: GRPCChannel?

    private var helloClient: Helloworld_GreeterClient?
    
    init() {
        
        //Настраиваем логгер
        var logger = Logger(label: "gRPC", factory: StreamLogHandler.standardOutput(label:))
        logger.logLevel = .debug
        
        //loopCount - сколько независимых циклов внутри группы работают внутри канала (могут одновременно отправлять/принимать сообщения)
        let eventGroup = PlatformSupport.makeEventLoopGroup(loopCount: 4)

        //создаем канал, указываем тип защищенности, хост и порт
        let newChannel = ClientConnection
            //можно вместо .insecure использовать .usingTLS но к нашему тестовому серверы мы так не подключимся, у него сертификата нет
            .insecure(group: eventGroup)
            .withBackgroundActivityLogger(logger)   //логгируем события пробуждение или ухода в фон у самого канала
            .connect(host: "127.0.0.1", port: 50051)
        
        //Работаем без заголовков, логгируем запросы
        let callOptions = CallOptions(
            customMetadata: HPACKHeaders([]),
            logger: logger
        )
        
        //создаем и сохраняем экземпляр клиента
        helloClient = Helloworld_GreeterClient(
            channel: newChannel,
            defaultCallOptions: callOptions,
            interceptors: nil
        )
        //сохраняем канал
        commonChannel = newChannel
    }
    
    func sendHello(message: HelloRequest, callback: @escaping (HelloReply?, KotlinException?) -> Void) {
        //Проверяем что все идет по плану
        guard let client = helloClient else {
            callback(nil, nil)
            return
        }

        //Создаем SwiftProtobuf.Message из WireMessage
        var request = Helloworld_HelloRequest()
        request.name = message.name
        
        //Получаем экземпляр вызова
        let responseCall = client.sayHello(request)
        DispatchQueue.global().async {
            do {
                //в фоне дожидаемся результата вызова
                let swiftMessage = try responseCall.response.wait()
                DispatchQueue.main.async {
                    //Конвертируем SwiftProtobuf.Message в WireMessage (объект ADAPTER умеет парсить конкретный сгенерированный класс из бинарного представления)
                    let (wireMessage, mappingError) = swiftMessage.toWireMessage(adapter: HelloReply.companion.ADAPTER)
                    //Обязательно вызываем коллбэк на том же потоке на котором по факту создался wireMessage, иначе получим ошибку в KotlinNative-рантайме
                    callback(wireMessage, mappingError)
                }
            } catch let err {
                DispatchQueue.main.async {
                    callback(nil, KotlinException(message: err.localizedDescription))
                }
            }
        }
    }
}

fileprivate extension SwiftProtobuf.Message {
    func toWireMessage<WireMessage, Adapter: Wire_runtimeProtoAdapter<WireMessage>>(adapter: Adapter) -> (WireMessage?, KotlinException?) {
        do {
            let data = try self.serializedData()
            let result = adapter.decode(bytes: data.toKotlinByteArray())

            if let nResult = result {
                return (nResult, nil)
            } else {
                return (nil, KotlinException(message: "Cannot parse message data"))
            }
        } catch let err {
            return (nil, KotlinException(message: err.localizedDescription))
        }
    }
}

fileprivate extension Data {
    //Побайтово копируем NSData в KotlinByteArray
    func toKotlinByteArray() -> KotlinByteArray {
        let nsData = NSData(data: self)

        return KotlinByteArray(size: Int32(self.count)) { index -> KotlinByte in
            let byte = nsData.bytes.load(fromByteOffset: Int(truncating: index), as: Int8.self)
            return KotlinByte(value: byte)
        }
    }
}
