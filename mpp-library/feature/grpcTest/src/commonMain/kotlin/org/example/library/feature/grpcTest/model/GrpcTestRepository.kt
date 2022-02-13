/*
 * Copyright 2022 IceRock MAG Inc. Use of this source code is governed by the Apache 2.0 license.
 */

package org.example.library.feature.grpcTest.model

interface GrpcTestRepository {
    suspend fun helloRequest(word: String): String
}