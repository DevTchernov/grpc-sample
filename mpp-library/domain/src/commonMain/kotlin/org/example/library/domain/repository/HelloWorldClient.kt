
/*
 * Copyright 2020 IceRock MAG Inc. Use of this source code is governed by the Apache 2.0 license.
 */
package org.example.library.domain.repository

import io.grpc.examples.helloworld.HelloReply
import io.grpc.examples.helloworld.HelloRequest
import kotlin.coroutines.suspendCoroutine

interface HelloWorldSuspendClient {
    suspend fun sendHello(message: HelloRequest): HelloReply
}

interface HelloWorldCallbackClient {
    fun sendHello(message: HelloRequest, callback: (HelloReply?, Exception?) -> Unit)
}

class HelloWorldSuspendClientImpl(
    private val callbackClientCalls: HelloWorldCallbackClient
): HelloWorldSuspendClient {

    private suspend fun <In, Out> convertCallbackCallToSuspend(
        input: In,
        callbackClosure: ((In, ((Out?, Throwable?) -> Unit)) -> Unit),
    ): Out {
        return suspendCoroutine { continuation ->
            callbackClosure(input) { result, error ->
                Unit
                when {
                    error != null -> {
                        continuation.resumeWith(Result.failure(error))
                    }
                    result != null -> {
                        continuation.resumeWith(Result.success(result))
                    }
                    else -> {
                        continuation.resumeWith(Result.failure(IllegalStateException("Incorrect grpc call processing")))
                    }
                }
            }
        }
    }

    override suspend fun sendHello(message: HelloRequest): HelloReply {
        return convertCallbackCallToSuspend(message, callbackClosure = { input, callback ->
            callbackClientCalls.sendHello(input, callback)
        })
    }
}